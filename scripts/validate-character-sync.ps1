param(
  [switch]$KeepDatabase
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$sqlite = (Get-Command sqlite3 -ErrorAction Stop).Source
$tempDb = Join-Path ([System.IO.Path]::GetTempPath()) ("tora-character-sync-" + [System.Guid]::NewGuid().ToString("N") + ".sqlite")

function Assert-Equal($label, $actual, $expected) {
  if ([string]$actual -ne [string]$expected) {
    throw "$label expected '$expected' but received '$actual'"
  }
  Write-Host "ok|$label|$actual"
}

try {
  $indexPath = Join-Path $root "data/entities/characters.json"
  $tribesPath = Join-Path $root "data/entities/tribes.json"
  $shlomoPath = Join-Path $root "data/entities/characters/shlomo.json"

  foreach ($path in @($indexPath, $tribesPath, $shlomoPath)) {
    if (-not (Test-Path $path)) {
      throw "Required JSON file not found: $path"
    }
  }

  $index = Get-Content $indexPath -Encoding UTF8 | ConvertFrom-Json
  $tribes = Get-Content $tribesPath -Encoding UTF8 | ConvertFrom-Json
  $shlomo = Get-Content $shlomoPath -Encoding UTF8 | ConvertFrom-Json

  $indexEntry = @($index.characters | Where-Object { $_.id -eq "shlomo" })
  Assert-Equal "json.index.shlomo" $indexEntry.Count 1
  Assert-Equal "json.detail.id" $shlomo.id "shlomo"
  Assert-Equal "json.tribe.registry" @($tribes.tribes | Where-Object { $_.id -eq $shlomo.identity.tribe.tribe_id }).Count 1
  Assert-Equal "json.fact.links" @($shlomo.canonical_fact_links).Count 8

  & (Join-Path $PSScriptRoot "init-sqlite.ps1") -DatabasePath $tempDb
  & (Join-Path $PSScriptRoot "import-json-to-sqlite.ps1") -DatabasePath $tempDb -Reset

  Assert-Equal "db.character.shlomo" (& $sqlite $tempDb "SELECT COUNT(*) FROM nodes WHERE id='character:shlomo' AND type='character';") 1
  Assert-Equal "db.tribe.judah" (& $sqlite $tempDb "SELECT COUNT(*) FROM nodes WHERE id='tribe:judah' AND type='theme';") 1
  Assert-Equal "db.shlomo.sources" (& $sqlite $tempDb "SELECT COUNT(*) FROM source_refs WHERE node_id='character:shlomo';") 2
  Assert-Equal "db.shlomo.time" (& $sqlite $tempDb "SELECT COUNT(*) FROM time_ranges WHERE node_id='character:shlomo' AND calendar='anno_mundi' AND start_value=2924 AND end_value=2964;") 1
  Assert-Equal "db.shlomo.visual" (& $sqlite $tempDb "SELECT COUNT(*) FROM visual_markers WHERE node_id='character:shlomo' AND asset_path='assets/icons/crown.svg';") 1
  Assert-Equal "db.shlomo.facts" (& $sqlite $tempDb "SELECT COUNT(*) FROM node_edges WHERE source_node_id='character:shlomo' AND relation_type='appears_in' AND target_node_id LIKE 'fact:nach:kings:kg%';") 8
  Assert-Equal "db.shlomo.tribe" (& $sqlite $tempDb "SELECT COUNT(*) FROM node_edges WHERE source_node_id='character:shlomo' AND target_node_id='tribe:judah' AND relation_type='related_to' AND json_extract(metadata_json,'$.semantic_relation')='member_of_tribe';") 1
  Assert-Equal "db.shlomo.parents" (& $sqlite $tempDb "SELECT COUNT(*) FROM node_edges WHERE target_node_id='character:shlomo' AND relation_type='related_to' AND json_extract(metadata_json,'$.semantic_relation')='parent_of';") 2
  Assert-Equal "db.shlomo.children" (& $sqlite $tempDb "SELECT COUNT(*) FROM node_edges WHERE source_node_id='character:shlomo' AND target_node_id='character:rechavam' AND relation_type='related_to' AND json_extract(metadata_json,'$.semantic_relation')='parent_of';") 1
  Assert-Equal "db.foreign-key-check" @(& $sqlite $tempDb "PRAGMA foreign_key_check;").Count 0

  Write-Host "Character JSON/SQLite correlation validated."
}
finally {
  if ($KeepDatabase) {
    Write-Host "Validation database kept at: $tempDb"
  } elseif (Test-Path $tempDb) {
    Remove-Item -LiteralPath $tempDb -Force
  }
}
