param(
  [string]$DatabasePath = "db/tora-explorer.sqlite",
  [switch]$Reset
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dbPath = if ([System.IO.Path]::IsPathRooted($DatabasePath)) {
  $DatabasePath
} else {
  Join-Path $root $DatabasePath
}

if (-not (Test-Path $dbPath)) {
  & (Join-Path $PSScriptRoot "init-sqlite.ps1") -DatabasePath $DatabasePath
}

$sqlite = (Get-Command sqlite3 -ErrorAction Stop).Source
$sql = New-Object 'System.Collections.Generic.List[string]'
$knownNodes = @{}
$pendingEdges = New-Object 'System.Collections.Generic.List[object]'
$skippedEdges = New-Object 'System.Collections.Generic.List[object]'

function Sql-Value($value) {
  if ($null -eq $value) { return "NULL" }
  if ($value -is [int] -or $value -is [long] -or $value -is [double]) { return [string]$value }
  if ($value -is [bool]) { return $(if ($value) { "1" } else { "0" }) }
  $s = [string]$value
  return "'" + $s.Replace("'", "''") + "'"
}

function Json-Compact($value) {
  if ($null -eq $value) { return $null }
  return ($value | ConvertTo-Json -Depth 50 -Compress)
}

function Node-Id($type, $slug) {
  return "$type`:$slug"
}

function Book-Key-From-Sefaria($bookName) {
  switch ($bookName) {
    "Genesis" { return "genesis" }
    "Exodus" { return "exodus" }
    "Leviticus" { return "leviticus" }
    "Numbers" { return "numbers" }
    "Deuteronomy" { return "deuteronomy" }
    default { return ($bookName -replace '\s+', '-').ToLowerInvariant() }
  }
}

function Fact-Node-Id($bookKey, $factId) {
  return "fact:$bookKey`:$factId"
}

function Add-Node($id, $slug, $type, $label, $labelHe = $null, $summaryShort = $null, $summaryLong = $null, $sortOrder = $null, $importance = $null, $metadata = $null) {
  $knownNodes[$id] = $true
  $metadataJson = Json-Compact $metadata
  $storedSlug = $id
  $sortOrderValue = if ($sortOrder -is [int] -or $sortOrder -is [long] -or $sortOrder -is [double]) { [int]$sortOrder } else { $null }
  $importanceValue = if (($importance -is [int] -or $importance -is [long] -or $importance -is [double]) -and [int]$importance -ge 1 -and [int]$importance -le 5) { [int]$importance } else { $null }
  $sql.Add(@"
INSERT INTO nodes(id, slug, type, label, label_he, summary_short, summary_long, sort_order, importance, metadata_json, updated_at)
VALUES ($(Sql-Value $id), $(Sql-Value $storedSlug), $(Sql-Value $type), $(Sql-Value $label), $(Sql-Value $labelHe), $(Sql-Value $summaryShort), $(Sql-Value $summaryLong), $(Sql-Value $sortOrderValue), $(Sql-Value $importanceValue), $(Sql-Value $metadataJson), CURRENT_TIMESTAMP)
ON CONFLICT(id) DO UPDATE SET
  slug=excluded.slug,
  type=excluded.type,
  label=excluded.label,
  label_he=excluded.label_he,
  summary_short=excluded.summary_short,
  summary_long=excluded.summary_long,
  sort_order=excluded.sort_order,
  importance=excluded.importance,
  metadata_json=excluded.metadata_json,
  updated_at=CURRENT_TIMESTAMP;
"@)
}

function Add-Edge($sourceId, $targetId, $relationType, $sortOrder = $null, $weight = $null, $metadata = $null) {
  if (-not $sourceId -or -not $targetId) { return }
  $pendingEdges.Add([pscustomobject]@{
    SourceId = $sourceId
    TargetId = $targetId
    RelationType = $relationType
    SortOrder = $sortOrder
    Weight = $weight
    Metadata = $metadata
  }) | Out-Null
}

function Emit-Edge($edge) {
  $id = "edge:$($edge.SourceId):$($edge.RelationType):$($edge.TargetId)"
  $metadataJson = Json-Compact $edge.Metadata
  $sortOrderValue = if ($edge.SortOrder -is [int] -or $edge.SortOrder -is [long] -or $edge.SortOrder -is [double]) { [int]$edge.SortOrder } else { $null }
  $weightValue = if ($edge.Weight -is [int] -or $edge.Weight -is [long] -or $edge.Weight -is [double]) { [int]$edge.Weight } else { $null }
  $sql.Add(@"
INSERT INTO node_edges(id, source_node_id, target_node_id, relation_type, sort_order, weight, metadata_json)
VALUES ($(Sql-Value $id), $(Sql-Value $edge.SourceId), $(Sql-Value $edge.TargetId), $(Sql-Value $edge.RelationType), $(Sql-Value $sortOrderValue), $(Sql-Value $weightValue), $(Sql-Value $metadataJson))
ON CONFLICT(source_node_id, target_node_id, relation_type) DO UPDATE SET
  sort_order=excluded.sort_order,
  weight=excluded.weight,
  metadata_json=excluded.metadata_json;
"@)
}

function Parse-Ref($ref) {
  if (-not $ref) { return $null }
  if ($ref -match '^(.+?)\s+(\d+):(\d+)(?:-(?:(\d+):)?(\d+))?$') {
    $chapterEnd = if ($Matches[4]) { [int]$Matches[4] } else { [int]$Matches[2] }
    $verseEnd = if ($Matches[5]) { [int]$Matches[5] } else { [int]$Matches[3] }
    return [pscustomobject]@{
      Book = $Matches[1]
      ChapterStart = [int]$Matches[2]
      VerseStart = [int]$Matches[3]
      ChapterEnd = $chapterEnd
      VerseEnd = $verseEnd
    }
  }
  return $null
}

function Add-SourceRef($nodeId, $refDisplay, $refStart = $null, $refEnd = $null, $refKey = $null) {
  if (-not $nodeId -or -not $refDisplay) { return }
  $parsed = Parse-Ref $refDisplay
  $bookName = if ($parsed) { $parsed.Book } else { (($refDisplay -split '\s+')[0]) }
  $id = if ($refKey) { "source-ref:" + $nodeId + ":" + $refKey } else { "source-ref:$nodeId" }
  $start = if ($refStart) { $refStart } else { $refDisplay }
  $sql.Add(@"
INSERT INTO source_refs(id, node_id, source_system, book_name, ref_start, ref_end, ref_display, chapter_start, verse_start, chapter_end, verse_end)
VALUES ($(Sql-Value $id), $(Sql-Value $nodeId), 'sefaria', $(Sql-Value $bookName), $(Sql-Value $start), $(Sql-Value $refEnd), $(Sql-Value $refDisplay), $(Sql-Value $($parsed.ChapterStart)), $(Sql-Value $($parsed.VerseStart)), $(Sql-Value $($parsed.ChapterEnd)), $(Sql-Value $($parsed.VerseEnd)))
ON CONFLICT(id) DO UPDATE SET
  book_name=excluded.book_name,
  ref_start=excluded.ref_start,
  ref_end=excluded.ref_end,
  ref_display=excluded.ref_display,
  chapter_start=excluded.chapter_start,
  verse_start=excluded.verse_start,
  chapter_end=excluded.chapter_end,
  verse_end=excluded.verse_end;
"@)
}

function Add-TimeRange($nodeId, $calendar, $startValue, $endValue = $null, $label = $null, $certainty = "traditional") {
  if (-not $nodeId -or $null -eq $startValue) { return }
  $id = "time:${nodeId}:${calendar}"
  $sql.Add(@"
INSERT INTO time_ranges(id, node_id, calendar, start_value, end_value, certainty, label)
VALUES ($(Sql-Value $id), $(Sql-Value $nodeId), $(Sql-Value $calendar), $(Sql-Value $startValue), $(Sql-Value $endValue), $(Sql-Value $certainty), $(Sql-Value $label))
ON CONFLICT(id) DO UPDATE SET
  start_value=excluded.start_value,
  end_value=excluded.end_value,
  certainty=excluded.certainty,
  label=excluded.label;
"@)
}

function Add-VisualMarker($nodeId, $markerType, $icon = $null, $assetPath = $null, $caption = $null, $lane = $null, $color = $null, $importance = $null, $metadata = $null) {
  if (-not $nodeId -or -not $markerType) { return }
  $id = "visual:$nodeId"
  $metadataJson = Json-Compact $metadata
  $importanceValue = if (($importance -is [int] -or $importance -is [long] -or $importance -is [double]) -and [int]$importance -ge 1 -and [int]$importance -le 5) { [int]$importance } else { $null }
  $sql.Add(@"
INSERT INTO visual_markers(id, node_id, marker_type, icon, asset_path, caption, lane, color, importance, metadata_json)
VALUES ($(Sql-Value $id), $(Sql-Value $nodeId), $(Sql-Value $markerType), $(Sql-Value $icon), $(Sql-Value $assetPath), $(Sql-Value $caption), $(Sql-Value $lane), $(Sql-Value $color), $(Sql-Value $importanceValue), $(Sql-Value $metadataJson))
ON CONFLICT(id) DO UPDATE SET
  marker_type=excluded.marker_type,
  icon=excluded.icon,
  asset_path=excluded.asset_path,
  caption=excluded.caption,
  lane=excluded.lane,
  color=excluded.color,
  importance=excluded.importance,
  metadata_json=excluded.metadata_json;
"@)
}

function Add-Projection($viewKey, $nodeId, $parentNodeId = $null, $displayMode = $null, $sortOrder = $null, $metadata = $null) {
  if (-not $viewKey -or -not $nodeId) { return }
  $parentPart = if ($parentNodeId) { $parentNodeId } else { "root" }
  $modePart = if ($displayMode) { $displayMode } else { "default" }
  $id = "view:${viewKey}:${parentPart}:${modePart}:${nodeId}"
  $metadataJson = Json-Compact $metadata
  $sortOrderValue = if ($sortOrder -is [int] -or $sortOrder -is [long] -or $sortOrder -is [double]) { [int]$sortOrder } else { $null }
  $sql.Add(@"
INSERT INTO view_projections(id, view_key, node_id, parent_node_id, display_mode, sort_order, metadata_json)
VALUES ($(Sql-Value $id), $(Sql-Value $viewKey), $(Sql-Value $nodeId), $(Sql-Value $parentNodeId), $(Sql-Value $displayMode), $(Sql-Value $sortOrderValue), $(Sql-Value $metadataJson))
ON CONFLICT(id) DO UPDATE SET
  sort_order=excluded.sort_order,
  metadata_json=excluded.metadata_json;
"@)
}

function Add-Theme($themeLabel) {
  if (-not $themeLabel) { return $null }
  $slug = ($themeLabel.ToString().Trim().ToLowerInvariant() -replace '\s+', '-' -replace '[^a-z0-9\-\u00c0-\u017f]', '')
  $id = Node-Id "theme" $slug
  Add-Node $id $slug "theme" $themeLabel
  return $id
}

function Add-Character($name) {
  if (-not $name) { return $null }
  $slug = ($name.ToString().Trim().ToLowerInvariant() -replace '\s+', '-' -replace '[^a-z0-9\-]', '')
  $id = Node-Id "character" $slug
  Add-Node $id $slug "character" $name
  return $id
}

$sql.Add("PRAGMA foreign_keys = ON;")
$sql.Add("BEGIN TRANSACTION;")
$sql.Add("PRAGMA defer_foreign_keys = ON;")

if ($Reset) {
  $sql.Add("DELETE FROM view_projections;")
  $sql.Add("DELETE FROM visual_markers;")
  $sql.Add("DELETE FROM time_ranges;")
  $sql.Add("DELETE FROM source_refs;")
  $sql.Add("DELETE FROM node_edges;")
  $sql.Add("DELETE FROM nodes;")
}

# Canonical structure
$written = Node-Id "tradition" "written-torah"
$oral = Node-Id "tradition" "oral-torah"
$chumash = Node-Id "corpus" "chumash"
$nach = Node-Id "corpus" "nach"
$mishna = Node-Id "corpus" "mishna"
$guemara = Node-Id "corpus" "guemara"
$halacha = Node-Id "corpus" "halacha"

Add-Node $written "written-torah" "tradition" "Tora Escrita" $null "Chumash e Nach"
Add-Node $oral "oral-torah" "tradition" "Tora Oral" $null "Mishna, Guemara e Halacha"
Add-Node $chumash "chumash" "corpus" "Chumash" $null "Cinco livros de Moshe"
Add-Node $nach "nach" "corpus" "Nach" $null "Neviim e Ketuvim"
Add-Node $mishna "mishna" "corpus" "Mishna"
Add-Node $guemara "guemara" "corpus" "Guemara"
Add-Node $halacha "halacha" "corpus" "Halacha"
Add-Edge $written $chumash "contains" 1
Add-Edge $written $nach "contains" 2
Add-Edge $oral $mishna "contains" 1
Add-Edge $oral $guemara "contains" 2
Add-Edge $oral $halacha "contains" 3
Add-Projection "structure" $written $null "card" 1
Add-Projection "structure" $oral $null "card" 2
Add-Projection "structure" $chumash $written "chip" 1
Add-Projection "structure" $nach $written "chip" 2
Add-Projection "structure" $mishna $oral "chip" 1
Add-Projection "structure" $guemara $oral "chip" 2
Add-Projection "structure" $halacha $oral "chip" 3

# Timeline
$timelinePath = Join-Path $root "data/timeline.json"
if (Test-Path $timelinePath) {
  $timeline = Get-Content $timelinePath -Encoding UTF8 | ConvertFrom-Json
  foreach ($era in @($timeline.eras)) {
    $eraId = Node-Id "era" $era.id
    Add-Node $eraId $era.id "era" $era.name $era.name_he $null $null $null $null @{ color = $era.color; books = $era.books; parashiot = $era.parashiot }
    Add-TimeRange $eraId "anno_mundi" $era.am_start $era.am_end $era.name
    Add-Projection "timeline" $eraId $null "band" $era.am_start @{ color = $era.color }
  }

  foreach ($event in @($timeline.key_events)) {
    $eventId = Node-Id "timeline_event" $event.id
    Add-Node $eventId $event.id "timeline_event" $event.label $event.label_he $event.book $null $event.am $null @{ links = $event.links }
    Add-TimeRange $eventId "anno_mundi" $event.am $event.am $event.label
    Add-Projection "timeline" $eventId $null "ruler_segment" $event.am
    if ($event.links) {
      if ($event.links.parasha_id -and $event.links.book_key) {
        Add-Edge $eventId (Node-Id "parasha" "$($event.links.book_key):$($event.links.parasha_id)") "opens"
      }
      foreach ($fid in @($event.links.fact_ids)) {
        Add-Edge $eventId (Fact-Node-Id $event.links.book_key $fid) "aggregates"
      }
    }
  }
}

# Books, parashiot, facts
$parashiotRoot = Join-Path $root "data/parashiot"
if (Test-Path $parashiotRoot) {
  foreach ($indexFile in Get-ChildItem $parashiotRoot -Recurse -Filter "index.json") {
    $bookKey = Split-Path (Split-Path $indexFile.FullName -Parent) -Leaf
    $idx = Get-Content $indexFile.FullName -Encoding UTF8 | ConvertFrom-Json
    $bookId = Node-Id "book" $bookKey
    Add-Node $bookId $bookKey "book" $idx.book $idx.book_he $idx.timeline.description $null $null $null @{ total_chapters = $idx.total_chapters; total_parashiot = $idx.total_parashiot }
    Add-TimeRange $bookId "anno_mundi" $idx.timeline.anno_mundi_start $idx.timeline.anno_mundi_end $idx.timeline.description
    Add-Edge $chumash $bookId "contains"
    Add-Projection "structure" $bookId $chumash "chip" $idx.total_chapters
    Add-Projection "chumash-atlas" $bookId $null "band" $idx.timeline.anno_mundi_start

    foreach ($p in @($idx.parashiot)) {
      $parashaId = Node-Id "parasha" "$bookKey`:$($p.id)"
      Add-Node $parashaId "$bookKey`:$($p.id)" "parasha" $p.name $p.hebrew $p.summary_short $null $p.index $null @{ name_pt = $p.name_pt; data_file = $p.data_file; facts_count = $p.facts_count; era = $p.era }
      Add-Edge $bookId $parashaId "contains" $p.index
      Add-TimeRange $parashaId "anno_mundi" $p.anno_mundi_start $p.anno_mundi_end $p.summary_short
      Add-SourceRef $parashaId $p.sefaria_ref $p.ref_start $p.ref_end
      Add-Projection "parasha-drawer" $parashaId $bookId "list_item" $p.index

      $eraId = Node-Id "era" $p.era
      Add-Edge $eraId $parashaId "contains" $p.index

      foreach ($character in @($p.characters)) {
        $charId = Add-Character $character
        Add-Edge $charId $parashaId "appears_in"
      }

      $dataFilePath = Join-Path $root $p.data_file
      if (Test-Path $dataFilePath) {
        $full = Get-Content $dataFilePath -Encoding UTF8 | ConvertFrom-Json
        foreach ($theme in @($full.summary.themes)) {
          $themeId = Add-Theme $theme
          Add-Edge $themeId $parashaId "tagged_with"
        }
        foreach ($character in @($full.summary.characters_main + $full.summary.characters_secondary)) {
          $charId = Add-Character $character
          Add-Edge $charId $parashaId "appears_in"
        }
        foreach ($f in @($full.facts)) {
          $factId = Fact-Node-Id $bookKey $f.id
          $factLabel = if ($f.topic) { $f.topic } else { $f.id }
          Add-Node $factId "$bookKey`:$($f.id)" "fact" $factLabel $null $f.text $f.text_he $f.order $null @{ local_id = $f.id; chapter = $f.chapter; day_of_creation = $f.day_of_creation }
          Add-Edge $parashaId $factId "contains" $f.order
          Add-SourceRef $factId $f.sefaria_ref $f.ref_start $f.ref_end
          Add-Projection "parasha-drawer" $factId $parashaId "drawer_item" $f.order
          foreach ($tag in @($f.tags)) {
            $themeId = Add-Theme $tag
            Add-Edge $themeId $factId "tagged_with"
          }
        }
      }
    }
  }
}

# Chumash milestones
$milestonesPath = Join-Path $root "data/milestones/chumash.json"
if (Test-Path $milestonesPath) {
  $milestoneData = Get-Content $milestonesPath -Encoding UTF8 | ConvertFrom-Json
  foreach ($book in @($milestoneData.books)) {
    $bookId = Node-Id "book" $book.book_key
    Add-Node $bookId $book.book_key "book" $book.book $book.label_he $book.label $null $null $null @{ source = "milestones"; book_key = $book.book_key }
    Add-Edge $chumash $bookId "contains"
    Add-Projection "chumash-atlas" $bookId $null "band"
    foreach ($m in @($book.milestones)) {
      $milestoneId = Node-Id "milestone" $m.id
      Add-Node $milestoneId $m.id "milestone" $m.label $null $null $null $null $m.importance @{ icon = $m.icon; book_key = $book.book_key; sefaria_ref = $m.sefaria_ref }
      Add-Edge $bookId $milestoneId "aggregates" $null $m.importance
      Add-Projection "chumash-atlas" $milestoneId $bookId "card" $null @{ icon = $m.icon }
      Add-VisualMarker $milestoneId "icon" $m.icon $null $m.label "evento" $null $m.importance
      Add-SourceRef $milestoneId $m.sefaria_ref
      foreach ($parashaLocalId in @($m.parasha_ids)) {
        Add-Edge $milestoneId (Node-Id "parasha" "$($book.book_key):$parashaLocalId") "aggregates"
      }
      foreach ($fid in @($m.fact_ids)) {
        Add-Edge $milestoneId (Fact-Node-Id $book.book_key $fid) "aggregates"
      }
      foreach ($theme in @($m.themes)) {
        $themeId = Add-Theme $theme
        Add-Edge $themeId $milestoneId "tagged_with"
      }
      foreach ($character in @($m.characters)) {
        $charId = Add-Character $character
        Add-Edge $charId $milestoneId "appears_in"
      }
    }
  }
}

# Nach books, narrative units, facts
$nachRoot = Join-Path $root "data/nach"
if (Test-Path $nachRoot) {
  foreach ($indexFile in Get-ChildItem $nachRoot -Recurse -Filter "index.json") {
    $bookKey = Split-Path (Split-Path $indexFile.FullName -Parent) -Leaf
    $idx = Get-Content $indexFile.FullName -Encoding UTF8 | ConvertFrom-Json
    $bookId = Node-Id "book" "nach:$bookKey"
    Add-Node $bookId "nach:$bookKey" "book" $idx.book $idx.book_he $idx.summary.short $null $null $null @{ corpus = $idx.corpus; division = $idx.division; book_pt = $idx.book_pt; total_chapters = $idx.total_chapters; units_count = @($idx.units).Count }
    Add-TimeRange $bookId "anno_mundi" $idx.timeline.anno_mundi_start $idx.timeline.anno_mundi_end $idx.timeline.description
    Add-Edge $nach $bookId "contains"
    Add-Projection "structure" $bookId $nach "chip" $idx.total_chapters
    Add-Projection "nach-atlas" $bookId $null "band" $idx.timeline.anno_mundi_start

    foreach ($theme in @($idx.summary.themes)) {
      $themeId = Add-Theme $theme
      Add-Edge $themeId $bookId "tagged_with"
    }
    foreach ($character in @($idx.summary.characters)) {
      $charId = Add-Character $character
      Add-Edge $charId $bookId "appears_in"
    }

    foreach ($unit in @($idx.units)) {
      $unitId = Node-Id "milestone" "nach:$bookKey`:$($unit.id)"
      Add-Node $unitId "nach:$bookKey`:$($unit.id)" "milestone" $unit.label $null $unit.summary_short $null $unit.index $null @{ corpus = "nach"; division = $idx.division; book_key = $bookKey; label_pt = $unit.label_pt; data_file = $unit.data_file; facts_count = $unit.facts_count }
      Add-Edge $bookId $unitId "aggregates" $unit.index
      Add-TimeRange $unitId "anno_mundi" $unit.anno_mundi_start $unit.anno_mundi_end $unit.summary_short
      Add-SourceRef $unitId $unit.sefaria_ref $unit.ref_start $unit.ref_end
      Add-Projection "nach-atlas" $unitId $bookId "card" $unit.index

      foreach ($character in @($unit.characters)) {
        $charId = Add-Character $character
        Add-Edge $charId $unitId "appears_in"
      }

      $dataFilePath = Join-Path $root $unit.data_file
      if (Test-Path $dataFilePath) {
        $full = Get-Content $dataFilePath -Encoding UTF8 | ConvertFrom-Json
        foreach ($theme in @($full.summary.themes)) {
          $themeId = Add-Theme $theme
          Add-Edge $themeId $unitId "tagged_with"
        }
        foreach ($character in @($full.summary.characters_main + $full.summary.characters_secondary)) {
          $charId = Add-Character $character
          Add-Edge $charId $unitId "appears_in"
        }
        foreach ($f in @($full.facts)) {
          $factId = Node-Id "fact" "nach:$bookKey`:$($f.id)"
          $factLabel = if ($f.topic) { $f.topic } else { $f.id }
          Add-Node $factId "nach:$bookKey`:$($f.id)" "fact" $factLabel $null $f.text $f.text_he $f.order $null @{ corpus = "nach"; division = $idx.division; book_key = $bookKey; local_id = $f.id; chapter = $f.chapter }
          Add-Edge $unitId $factId "contains" $f.order
          Add-SourceRef $factId $f.sefaria_ref $f.ref_start $f.ref_end
          Add-Projection "nach-atlas" $factId $unitId "drawer_item" $f.order
          foreach ($tag in @($f.tags)) {
            $themeId = Add-Theme $tag
            Add-Edge $themeId $factId "tagged_with"
          }
        }
      }
    }
  }
}

# Transitional timeline groups
$timelineGroupsPath = Join-Path $root "data/timeline_groups.json"
if (Test-Path $timelineGroupsPath) {
  $groupData = Get-Content $timelineGroupsPath -Encoding UTF8 | ConvertFrom-Json
  foreach ($phase in @($groupData.phases)) {
    $phaseId = Node-Id "timeline_phase" $phase.id
    Add-Node $phaseId $phase.id "timeline_phase" $phase.label $null $phase.summary $null $null $null @{ timeline_event_id = $phase.timeline_event_id }
    Add-TimeRange $phaseId "anno_mundi" $phase.am_start $phase.am_end $phase.label
    Add-Projection "timeline" $phaseId $null "band" $phase.am_start
    foreach ($g in @($phase.groups)) {
      $groupId = Node-Id "milestone" "timeline-$($g.id)"
      Add-Node $groupId "timeline-$($g.id)" "milestone" $g.label $null $g.summary $null $null $null @{ icon = $g.icon; source = "timeline_groups"; milestone_id = $g.milestone_id; book_key = $g.book_key }
      Add-Edge $phaseId $groupId "aggregates"
      Add-Projection "timeline" $groupId $phaseId "card" $null @{ icon = $g.icon }
      Add-VisualMarker $groupId "icon" $g.icon $null $g.label "evento"
      if ($g.milestone_id) {
        Add-Edge $groupId (Node-Id "milestone" $g.milestone_id) "related_to"
      }
      if ($g.parasha_id -and $g.book_key) {
        Add-Edge $groupId (Node-Id "parasha" "$($g.book_key):$($g.parasha_id)") "aggregates"
      }
      foreach ($fid in @($g.fact_ids)) {
        Add-Edge $groupId (Fact-Node-Id $g.book_key $fid) "aggregates"
      }
      foreach ($theme in @($g.themes)) {
        $themeId = Add-Theme $theme
        Add-Edge $themeId $groupId "tagged_with"
      }
    }
  }
}


# Character and tribe entities
$tribesPath = Join-Path $root "data/entities/tribes.json"
if (Test-Path $tribesPath) {
  $tribeData = Get-Content $tribesPath -Encoding UTF8 | ConvertFrom-Json
  foreach ($tribe in @($tribeData.tribes)) {
    $tribeId = Node-Id "tribe" $tribe.id
    Add-Node $tribeId $tribe.id "theme" $tribe.name $tribe.name_he $tribe.name_pt $null $null $null @{
      entity_kind = "tribe"
      people = $tribe.people
      name_pt = $tribe.name_pt
      schema_version = $tribeData.schema_version
    }
    if ($tribe.visual) {
      Add-VisualMarker $tribeId $tribe.visual.marker_type $tribe.visual.icon $tribe.visual.asset $tribe.visual.caption "tribes" $tribe.visual.color
    }
  }
}

$characterIndexPath = Join-Path $root "data/entities/characters.json"
if (Test-Path $characterIndexPath) {
  $characterIndex = Get-Content $characterIndexPath -Encoding UTF8 | ConvertFrom-Json

  # Register compact identities first so relationships resolve independently of detail-file order.
  foreach ($entry in @($characterIndex.characters | Where-Object { $_.type -eq "person" })) {
    $characterId = Node-Id "character" $entry.id
    Add-Node $characterId $entry.id "character" $entry.name $entry.name_he $entry.name_pt $null $null $null @{
      entity_kind = "person"
      name_pt = $entry.name_pt
      related_book_keys = $entry.related_book_keys
      detail_file = $entry.detail_file
      tribe_id = $entry.tribe_id
      schema_version = $characterIndex.schema_version
    }
    if ($entry.visual) {
      Add-VisualMarker $characterId $entry.visual.marker_type $entry.visual.icon $entry.visual.asset $entry.visual.caption "characters" $null $null @{
        portrait_asset = $entry.visual.portrait_asset
      }
    }
    Add-Projection "character-index" $characterId $null "list_item"
  }

  foreach ($entry in @($characterIndex.characters | Where-Object { $_.type -eq "person" -and $_.detail_file })) {
    $detailPath = Join-Path $root $entry.detail_file
    if (-not (Test-Path $detailPath)) {
      throw "Character detail file not found: $($entry.detail_file)"
    }

    $character = Get-Content $detailPath -Encoding UTF8 | ConvertFrom-Json
    if ($character.id -ne $entry.id) {
      throw "Character detail id '$($character.id)' does not match index id '$($entry.id)'"
    }

    $characterId = Node-Id "character" $character.id
    Add-Node $characterId $character.id "character" $character.names.primary $character.names.he $character.biography.short $null $null $null @{
      entity_kind = "person"
      status = $character.status
      names = $character.names
      roles = $character.identity.roles
      people = $character.identity.people
      biography_sections = $character.biography.sections
      characterization = $character.characterization
      places = $character.places
      editorial = $character.editorial
      detail_file = $entry.detail_file
      schema_version = $character.schema_version
    }

    $active = $character.timeline.active_period
    if ($active -and $null -ne $active.am_start) {
      $certainty = if (@("traditional", "approximate", "unknown") -contains $active.precision) { $active.precision } else { "approximate" }
      Add-TimeRange $characterId "anno_mundi" $active.am_start $active.am_end "Active period" $certainty
    }

    $sourceIndex = 0
    foreach ($source in @($character.source_ranges)) {
      $sourceIndex++
      $key = if ($source.id) { $source.id } else { "range-$sourceIndex" }
      Add-SourceRef $characterId $source.sefaria_ref $null $null $key
    }

    if ($character.visual) {
      Add-VisualMarker $characterId $character.visual.marker_type $character.visual.icon $character.visual.icon_asset $character.visual.caption "characters" $character.visual.color $null @{
        portrait_asset = $character.visual.portrait_asset
        symbolic_role = $character.visual.symbolic_role
        alt = $character.visual.alt
      }
    }

    $tribe = $character.identity.tribe
    if ($tribe -and $tribe.tribe_id) {
      Add-Edge $characterId (Node-Id "tribe" $tribe.tribe_id) "related_to" $null $null @{
        semantic_relation = "member_of_tribe"
        classification = $tribe.classification
        evidence = $tribe.evidence
        review_status = $tribe.review_status
      }
    }

    foreach ($relation in @($character.relationships)) {
      $relatedId = Node-Id "character" $relation.character_id
      if ($relation.type -eq "parent") {
        Add-Edge $relatedId $characterId "related_to" $null $null @{
          semantic_relation = "parent_of"
          classification = $relation.classification
          evidence = $relation.evidence
        }
      } elseif ($relation.type -eq "child") {
        Add-Edge $characterId $relatedId "related_to" $null $null @{
          semantic_relation = "parent_of"
          classification = $relation.classification
          evidence = $relation.evidence
        }
      } else {
        Add-Edge $characterId $relatedId "related_to" $null $null @{
          semantic_relation = $relation.type
          classification = $relation.classification
          evidence = $relation.evidence
        }
      }
    }

    foreach ($link in @($character.canonical_fact_links)) {
      $factSlug = "nach:" + $link.book_key + ":" + $link.fact_id
      Add-Edge $characterId (Node-Id "fact" $factSlug) "appears_in" $null $null @{
        semantic_relation = "participates_in"
        source = "character-detail"
      }
    }

    foreach ($place in @($character.places)) {
      $placeId = Node-Id "place" $place.place_id
      $placeLabel = (Get-Culture).TextInfo.ToTitleCase($place.place_id.Replace("-", " "))
      Add-Node $placeId $place.place_id "place" $placeLabel
      Add-Edge $characterId $placeId "located_in" $null $null @{
        semantic_relation = $place.relation
        classification = $place.classification
        evidence = $place.evidence
      }
    }

    Add-Projection "character-bio" $characterId $null "drawer_item"
    Add-Projection "timeline-v2" $characterId $null "lane_marker"
  }
}

foreach ($edge in $pendingEdges) {
  if ($knownNodes.ContainsKey($edge.SourceId) -and $knownNodes.ContainsKey($edge.TargetId)) {
    Emit-Edge $edge
  } else {
    $skippedEdges.Add($edge) | Out-Null
  }
}

$sql.Add("COMMIT;")

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("tora-import-" + [System.Guid]::NewGuid().ToString("N") + ".sql")
Set-Content -Path $tmp -Value ($sql -join [Environment]::NewLine) -Encoding UTF8

$importSucceeded = $false
try {
  & $sqlite $dbPath ".read '$($tmp.Replace("'", "''"))'"
  if ($LASTEXITCODE -ne 0) {
    throw "sqlite3 import failed"
  }
  $importSucceeded = $true
} finally {
  if ($importSucceeded -and (Test-Path $tmp)) {
    Remove-Item -LiteralPath $tmp -Force
  } elseif (Test-Path $tmp) {
    Write-Host "import_sql_debug|$tmp"
  }
}

$counts = & $sqlite $dbPath @"
SELECT 'nodes', COUNT(*) FROM nodes
UNION ALL SELECT 'node_edges', COUNT(*) FROM node_edges
UNION ALL SELECT 'source_refs', COUNT(*) FROM source_refs
UNION ALL SELECT 'time_ranges', COUNT(*) FROM time_ranges
UNION ALL SELECT 'visual_markers', COUNT(*) FROM visual_markers
UNION ALL SELECT 'view_projections', COUNT(*) FROM view_projections;
"@

Write-Host "JSON import complete: $dbPath"
$counts | ForEach-Object { Write-Host $_ }
if ($skippedEdges.Count -gt 0) {
  Write-Host "skipped_edges|$($skippedEdges.Count)"
}
