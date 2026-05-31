# Database Drill Model

## Purpose

The current JSON files are useful for static runtime delivery, but they are
starting to create vertical data silos:

- timeline-specific groups
- Chumash-specific milestones
- parasha-local facts
- future character/person views

The target data model should be horizontal. A fact, milestone, character, book,
period, or visual marker should be reusable by several views:

- Timeline
- Chumash Atlas
- Book overview
- Parasha drawer
- Character view
- Theme view
- Pessukim reader

## Recommended Direction

Use a database as the authoring/source-of-truth layer, but keep static JSON
exports as the public app runtime format until the frontend needs a live API.

```text
Database authoring model
        ↓ export
Static JSON runtime model
        ↓ fetch
Static CapRover frontend
```

This avoids forcing authentication, migrations, and backend operations into the
public app too early.

## Core Principle

Represent content as reusable nodes connected by typed edges.

```text
node -> edge -> node
```

Examples:

- `book:genesis` contains `parasha:bereshit`
- `milestone:gen-creation` aggregates `fact:b001`
- `timeline_phase:early-world` includes `milestone:gen-creation`
- `character:avraham` appears_in `fact:ll001`
- `theme:aliança` tags `milestone:gen-avraham-call`

This makes Timeline drill-down, Chumash drill-down, and character drill-down
different projections of the same graph.

## Drill Levels

The app should support these levels without hard-coding them to one view:

| Level | Meaning | Example node types |
|---|---|---|
| 1 | Canonical structure | `tradition`, `corpus` |
| 2 | Large textual/body grouping | `book`, `order`, `tractate`, `era` |
| 3 | Strategic aggregator | `milestone`, `timeline_phase`, `theme_cluster` |
| 4 | Local content unit | `parasha`, `chapter`, `sugya` |
| 5 | Atomic narrative/legal unit | `fact`, `law_topic`, `teaching` |
| 6 | Source text | `source_ref`, `verse_range` |
| 7 | Sensory layer | `visual_marker`, `asset` |

## Proposed Tables

### `nodes`

Generic table for reusable content units.

| Field | Type | Notes |
|---|---|---|
| `id` | UUID / text | Stable internal ID |
| `slug` | text | Human-readable stable key, e.g. `gen-creation` |
| `type` | enum/text | `book`, `parasha`, `fact`, `milestone`, `character`, `theme`, `era`, `source_ref`, `visual_marker` |
| `label` | text | Display label |
| `label_he` | text nullable | Hebrew label |
| `summary_short` | text nullable | One-line display |
| `summary_long` | text nullable | Longer authoring text |
| `sort_order` | integer nullable | Local ordering |
| `importance` | integer nullable | 1-5 visual priority |
| `created_at` | timestamp | |
| `updated_at` | timestamp | |

### `node_edges`

Typed relation between two nodes.

| Field | Type | Notes |
|---|---|---|
| `id` | UUID / text | |
| `source_node_id` | FK `nodes.id` | Parent/source |
| `target_node_id` | FK `nodes.id` | Child/target |
| `relation_type` | enum/text | `contains`, `aggregates`, `appears_in`, `tagged_with`, `located_in`, `opens`, `precedes`, `related_to` |
| `sort_order` | integer nullable | Ordering inside the relation |
| `weight` | integer nullable | Strength/importance of relation |
| `metadata_json` | json nullable | View hints without schema churn |

### `source_refs`

Source text references, usually Sefaria-compatible.

| Field | Type | Notes |
|---|---|---|
| `id` | UUID / text | |
| `node_id` | FK `nodes.id` | Usually attached to fact/parasha/chapter |
| `source_system` | text | `sefaria` |
| `book_name` | text | English Sefaria name, e.g. `Genesis` |
| `ref_start` | text | e.g. `Genesis 1:1` |
| `ref_end` | text nullable | e.g. `Genesis 2:3` |
| `ref_display` | text | e.g. `Genesis 1:1-2:3` |
| `chapter_start` | integer nullable | |
| `verse_start` | integer nullable | |
| `chapter_end` | integer nullable | |
| `verse_end` | integer nullable | |

### `time_ranges`

Historical placement for any node.

| Field | Type | Notes |
|---|---|---|
| `id` | UUID / text | |
| `node_id` | FK `nodes.id` | era, event, milestone, parasha, fact |
| `calendar` | text | `anno_mundi`, `ce`, `bce` |
| `start_value` | integer nullable | |
| `end_value` | integer nullable | |
| `certainty` | text nullable | `traditional`, `approximate`, `unknown` |
| `label` | text nullable | Display label |

### `visual_markers`

Sensory/visual layer attached to any node.

| Field | Type | Notes |
|---|---|---|
| `id` | UUID / text | |
| `node_id` | FK `nodes.id` | |
| `marker_type` | text | `icon`, `image`, `symbol`, `map`, `color` |
| `icon` | text nullable | icon key or emoji during prototype |
| `asset_path` | text nullable | e.g. `assets/facts/genesis/ark.png` |
| `caption` | text nullable | Required when asset exists |
| `lane` | text nullable | `evento`, `personagem`, `lugar`, `lei`, etc. |
| `color` | text nullable | Hex or design token |
| `importance` | integer nullable | 1-5 |

### `view_projections`

Defines how reusable nodes appear in specific UI views without duplicating core
content.

| Field | Type | Notes |
|---|---|---|
| `id` | UUID / text | |
| `view_key` | text | `timeline`, `chumash_atlas`, `parasha_drawer`, `character_view` |
| `node_id` | FK `nodes.id` | Node shown in that view |
| `parent_node_id` | FK `nodes.id` nullable | Local view hierarchy |
| `display_mode` | text nullable | `band`, `card`, `chip`, `drawer_item`, `lane_marker` |
| `sort_order` | integer nullable | |
| `metadata_json` | json nullable | View-specific hints |

## Example: Timeline Without Timeline-Specific Content

Instead of:

```text
data/timeline_groups.json owns the groups
```

Use:

```text
nodes:
  timeline_phase:early-world
  milestone:gen-creation
  milestone:gen-eden-fall
  fact:b001

node_edges:
  early-world aggregates gen-creation
  early-world aggregates gen-eden-fall
  gen-creation aggregates b001
```

The Timeline then asks:

```text
show children of early-world where relation_type = aggregates
```

The Chumash Atlas can reuse the same `milestone:gen-creation` node under
`book:genesis`.

## Export Strategy

Short term, export database content back into the current JSON shapes:

- `data/timeline.json`
- `data/milestones/chumash.json`
- `data/parashiot/{book}/index.json`
- `data/parashiot/{book}/{parasha}.json`

Medium term, generate additional view JSON files:

- `data/views/timeline.json`
- `data/views/chumash-atlas.json`
- `data/views/characters.json`

Long term, if needed, replace static JSON fetches with API reads.

## Suggested Implementation Order

1. Keep current JSON runtime unchanged.
2. Define the database schema in SQL/migrations. **Done in `db/migrations/001_initial_drill_model.sql`.**
3. Initialize a local SQLite database. **Done through `scripts/init-sqlite.ps1`.**
4. Import existing JSON into database tables.
5. Build export scripts that regenerate the JSON files.
6. Use the exported JSON in the existing frontend.
7. Only then consider a live admin/editor UI.

## Current SQLite Files

- `db/README.md`
- `db/migrations/001_initial_drill_model.sql`
- `scripts/init-sqlite.ps1`

Default local database path:

```text
db/tora-explorer.sqlite
```

The local `.sqlite` file is ignored by Git.

## Open Decision

SQLite is the initial authoring database for the current stage.

PostgreSQL remains a future candidate if the project needs:

- multi-user editing
- hosted admin workflows
- concurrent writes
- richer permissions
- server-side querying
