# Database Export Specification

## Purpose

This document specifies how the SQLite authoring database is exported back into
the static JSON runtime files consumed by the frontend.

The full lifecycle is:

```
JSON source files
      ↓  import-json-to-sqlite.ps1
SQLite (db/tora-explorer.sqlite)
      ↓  export-sqlite-to-json.ps1  ← this doc specifies this step
Static JSON runtime files
      ↓  fetch
Static frontend
```

The export is the missing step. Until it is implemented, the workflow is:
edit JSON → import to SQLite (for cross-context querying and validation) →
the same JSON files remain the runtime source of truth.

---

## Output Files and Their SQL Mapping

### `data/parashiot/{book}/index.json`

Generated once per book by querying the `book` node and all `parasha` children.

**Book-level fields:**

| JSON field | SQL source |
|---|---|
| `book` | `nodes.label` WHERE `nodes.id = 'book:{bookKey}'` |
| `book_he` | `nodes.label_he` |
| `total_chapters` | `nodes.metadata_json ->> 'total_chapters'` |
| `total_parashiot` | `nodes.metadata_json ->> 'total_parashiot'` |
| `timeline.anno_mundi_start` | `time_ranges.start_value` WHERE `calendar='anno_mundi'` |
| `timeline.anno_mundi_end` | `time_ranges.end_value` |
| `timeline.description` | `time_ranges.label` |

**Per-parasha fields (ordered by `node_edges.sort_order`):**

| JSON field | SQL source |
|---|---|
| `id` | `nodes.slug` stripped of `{bookKey}:` prefix |
| `index` | `node_edges.sort_order` on the `book → contains → parasha` edge |
| `name` | `nodes.label` |
| `hebrew` | `nodes.label_he` |
| `name_pt` | `nodes.metadata_json ->> 'name_pt'` |
| `ref_start` | `source_refs.ref_start` |
| `ref_end` | `source_refs.ref_end` |
| `sefaria_ref` | `source_refs.ref_display` |
| `chapter_start` | `source_refs.chapter_start` |
| `chapter_end` | `source_refs.chapter_end` |
| `anno_mundi_start` | `time_ranges.start_value` |
| `anno_mundi_end` | `time_ranges.end_value` |
| `era` | `nodes.metadata_json ->> 'era'` |
| `position_pct` | computed: `CAST(time_ranges.start_value * 100.0 / 5785 AS INTEGER)` |
| `summary_short` | `nodes.summary_short` |
| `characters` | `SELECT n.label FROM node_edges e JOIN nodes n ON n.id=e.source_node_id WHERE e.relation_type='appears_in' AND e.target_node_id=parasha.id AND n.type='character'` |
| `data_file` | `nodes.metadata_json ->> 'data_file'` |
| `facts_count` | `SELECT COUNT(*) FROM node_edges WHERE source_node_id=parasha.id AND relation_type='contains'` |

---

### `data/parashiot/{book}/{parasha}.json`

Generated once per parasha by joining nodes, edges, source_refs, and time_ranges.

**`identity` block:**

| JSON field | SQL source |
|---|---|
| `id` | slug stripped of `{bookKey}:` prefix |
| `name` | `nodes.label` |
| `hebrew` | `nodes.label_he` |
| `name_pt` | `nodes.metadata_json ->> 'name_pt'` |

**`range` block:**

| JSON field | SQL source |
|---|---|
| `ref_start` | `source_refs.ref_start` |
| `ref_end` | `source_refs.ref_end` |
| `sefaria_ref` | `source_refs.ref_display` |
| `chapter_start` | `source_refs.chapter_start` |
| `chapter_end` | `source_refs.chapter_end` |

**`timeline` block:**

| JSON field | SQL source |
|---|---|
| `anno_mundi_start` | `time_ranges.start_value` |
| `anno_mundi_end` | `time_ranges.end_value` |
| `era` | `nodes.metadata_json ->> 'era'` |

**`summary` block:**

| JSON field | SQL source |
|---|---|
| `short` | `nodes.summary_short` |
| `medium` | **NOT IN SQLite — see Lossy Fields below** |
| `themes` | character nodes via `theme → tagged_with → parasha` WHERE `n.type='theme'` |
| `characters_main` | **NOT DISTINGUISHED — see Lossy Fields below** |
| `characters_secondary` | **NOT DISTINGUISHED — see Lossy Fields below** |

Note: the import merges `characters_main` and `characters_secondary` into a single
`appears_in` relation. The export cannot distinguish them without adding a
`character_role` field to `node_edges.metadata_json`.

**`facts[]` array (ordered by `node_edges.sort_order`):**

| JSON field | SQL source |
|---|---|
| `id` | `nodes.slug` stripped of `{bookKey}:` prefix |
| `order` | `node_edges.sort_order` on `parasha → contains → fact` edge |
| `topic` | `nodes.label` |
| `text` | `nodes.summary_short` |
| `text_he` | `nodes.summary_long` |
| `ref_start` | `source_refs.ref_start` |
| `ref_end` | `source_refs.ref_end` |
| `sefaria_ref` | `source_refs.ref_display` |
| `chapter` | `nodes.metadata_json ->> 'chapter'` |
| `day_of_creation` | `nodes.metadata_json ->> 'day_of_creation'` |
| `tags` | theme nodes via `theme → tagged_with → fact` |

---

### `data/timeline.json`

**`eras[]` array:**

| JSON field | SQL source |
|---|---|
| `id` | `nodes.slug` |
| `name` | `nodes.label` |
| `name_he` | `nodes.label_he` |
| `am_start` | `time_ranges.start_value` |
| `am_end` | `time_ranges.end_value` |
| `color` | `nodes.metadata_json ->> 'color'` |
| `books` | `nodes.metadata_json ->> 'books'` |
| `parashiot` | `nodes.metadata_json ->> 'parashiot'` |

**`key_events[]` array:**

| JSON field | SQL source |
|---|---|
| `id` | `nodes.slug` |
| `am` | `time_ranges.start_value` |
| `label` | `nodes.label` |
| `label_he` | `nodes.label_he` |
| `book` | `nodes.summary_short` |
| `links` | `nodes.metadata_json ->> 'links'` (stored as JSON blob) |

---

### `data/milestones/chumash.json`

**`books[]` array:**

| JSON field | SQL source |
|---|---|
| `book_key` | `nodes.slug` |
| `book` | `nodes.label` |
| `label_he` | `nodes.label_he` |

**Per-book `milestones[]` array (via `book → aggregates → milestone` edges):**

| JSON field | SQL source |
|---|---|
| `id` | `nodes.slug` |
| `label` | `nodes.label` |
| `icon` | `nodes.metadata_json ->> 'icon'` |
| `importance` | `nodes.importance` |
| `sefaria_ref` | `source_refs.ref_display` |
| `themes` | theme nodes via `theme → tagged_with → milestone` |
| `characters` | character nodes via `character → appears_in → milestone` |
| `parasha_ids` | parasha nodes via `milestone → aggregates → parasha`, slug stripped of book prefix |
| `fact_ids` | fact nodes via `milestone → aggregates → fact`, slug stripped of book prefix |

---

### `data/timeline_groups.json`

**`phases[]` array** (timeline_phase nodes):

| JSON field | SQL source |
|---|---|
| `id` | `nodes.slug` |
| `label` | `nodes.label` |
| `summary` | `nodes.summary_short` |
| `am_start` | `time_ranges.start_value` |
| `am_end` | `time_ranges.end_value` |
| `timeline_event_id` | `nodes.metadata_json ->> 'timeline_event_id'` |

**Per-phase `groups[]` array** (milestone nodes WHERE `metadata_json->>'source'='timeline_groups'`):

| JSON field | SQL source |
|---|---|
| `id` | `nodes.slug` stripped of `timeline-` prefix |
| `label` | `nodes.label` |
| `summary` | `nodes.summary_short` |
| `icon` | `nodes.metadata_json ->> 'icon'` |
| `milestone_id` | `nodes.metadata_json ->> 'milestone_id'` |
| `book_key` | `nodes.metadata_json ->> 'book_key'` |
| `parasha_id` | slug from `milestone → aggregates → parasha` edge |
| `fact_ids` | slugs from `milestone → aggregates → fact` edges |
| `themes` | theme nodes via `theme → tagged_with → milestone-group` |

---

## Lossy Fields — Not Currently in SQLite

These fields exist in the source JSON but are not imported into the database.
A round-trip export without them would produce incomplete parasha files.

| Field | Location | Resolution |
|---|---|---|
| `summary.medium` | parasha JSON | Store as `nodes.metadata_json ->> 'summary_medium'`, or add a dedicated column |
| `aliyot[]` | parasha JSON | Add a new `aliyot` table, or store as `nodes.metadata_json ->> 'aliyot'` |
| `haftarah` | parasha JSON | Store as `nodes.metadata_json ->> 'haftarah'` |
| `connections.prev/next/thematic_links` | parasha JSON | Reconstructable via `precedes` edges; add `thematic_links` to metadata |
| `characters_main` vs `characters_secondary` | parasha JSON | Add `character_role` to `node_edges.metadata_json` on `appears_in` edges |

Until these gaps are closed in the schema, the export script should either:
- Read the lossy fields from the original source JSON (hybrid export), or
- Accept that the exported JSON will lack those fields

**Recommended short-term approach:** hybrid export — use SQLite for the
reconstructable fields and fall back to the original JSON files for lossy fields.

---

## Proposed Export Script

### `scripts/export-sqlite-to-json.ps1`

Parameters:
```powershell
param(
  [string]$DatabasePath = "db/tora-explorer.sqlite",
  [string]$OutputRoot   = "data",
  [string]$BookKey      = $null,   # if null, export all books
  [switch]$DryRun                  # print paths without writing files
)
```

Execution order:
1. Export `data/timeline.json`
2. Export `data/milestones/chumash.json`
3. Export `data/timeline_groups.json`
4. For each book in `data/parashiot/`:
   - Export `index.json`
   - For each parasha node WHERE full JSON exists, export `{parasha}.json`

Validation after export:
- Verify `facts_count` in `index.json` matches `facts[]` length in each parasha JSON
- Verify `sefaria_ref` format is valid (`Book Chapter:Verse`)
- Report any parasha node with no source ref

---

## New View Files (Medium-Term Targets)

These files do not yet exist. They would be generated from view_projections.

### `data/views/structure.json`

A flat projection of the canonical hierarchy for the Estrutura tab:

```json
{
  "traditions": [
    {
      "id": "written-torah",
      "label": "Tora Escrita",
      "corpora": [
        { "id": "chumash", "label": "Chumash", "books": [...] }
      ]
    }
  ]
}
```

### `data/views/timeline.json`

A pre-computed timeline projection (eras + events + phase groups) in one file:

```json
{
  "eras": [...],
  "key_events": [...],
  "phases": [...]
}
```

Currently the frontend fetches `data/timeline.json` and `data/timeline_groups.json`
separately. This merged view would reduce fetch count.

### `data/views/characters.json`

A character index with their parasha/fact appearances:

```json
{
  "characters": [
    {
      "id": "avraham",
      "label": "Avraham",
      "appears_in": {
        "parashiot": ["lech-lecha", "vayera", "chayei-sarah"],
        "facts": ["ll001", "ll002", "v001"]
      }
    }
  ]
}
```

This does not yet exist in the frontend but is derivable from the current graph.

---

## Implementation Order

1. Write and validate `scripts/export-sqlite-to-json.ps1` for `index.json` files only.
2. Confirm that exported index files produce the same drawer behavior as the originals.
3. Add full parasha JSON export (hybrid, using original JSON for lossy fields).
4. Add `summary_medium`, `aliyot`, `haftarah` to the import script and schema.
5. Switch to pure SQLite export once the schema round-trips cleanly.
6. Add `data/views/*.json` generation as the final step.
