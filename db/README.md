# Authoring Database

This folder contains the SQLite authoring model for the general drill-down
architecture.

The public app runtime still reads static JSON files from `data/`. The SQLite
database is the planned source-of-truth layer for authoring and exporting those
JSON files later.

## Create Local Database

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\init-sqlite.ps1
```

Default output:

```text
db/tora-explorer.sqlite
```

The `.sqlite` file is ignored by Git. Migrations are versioned under
`db/migrations/`.

## Schema Migrations

| Migration | Purpose |
|---|---|
| `001_initial_drill_model.sql` | Creates all tables: `nodes`, `node_edges`, `source_refs`, `time_ranges`, `visual_markers`, `view_projections`, `schema_migrations`. |
| `002_rebuild_relationship_tables.sql` | Rebuilds `node_edges`, `source_refs`, `time_ranges`, `visual_markers`, and `view_projections` with `FOREIGN KEY` constraints and corrected `UNIQUE` indexes. SQLite does not support `ALTER COLUMN` or `ADD CONSTRAINT`, so the tables were recreated via rename-create-copy-drop. |

## Current Scope

The schema models:

- reusable content nodes
- typed edges between nodes
- source references
- historical time ranges
- visual markers
- view projections

JSON has been imported. The next step is the export script, which regenerates
runtime JSON from the database. See
`docs/04_technical/DATABASE_EXPORT_SPEC.md` for the full field mapping.

## Import Current JSON

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\import-json-to-sqlite.ps1 -Reset
```

Current import sources:

- `data/timeline.json`
- `data/timeline_groups.json`
- `data/milestones/chumash.json`
- `data/parashiot/*/index.json`
- existing `data/parashiot/*/*.json` files
- `data/entities/tribes.json`
- `data/entities/characters.json`
- character detail files referenced by `characters[].detail_file`

The import is idempotent. Use `-Reset` to clear imported content tables before
loading the current JSON state again.


## Validate Character Correlation

The Shlomo pilot includes an isolated JSON-to-SQLite correlation check:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-character-sync.ps1
```

The validator creates a temporary database, runs every migration, imports the
current JSON, verifies the Shlomo node, tribe, chronology, sources, visual,
family relations and eight canonical fact links, runs `foreign_key_check`, and
removes the temporary database. Use `-KeepDatabase` only when inspection is
needed.

Until SQLite-to-JSON export exists, JSON remains the operational source and
SQLite is its normalized authoring/validation mirror.
