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

## Current Scope

The first schema models:

- reusable content nodes
- typed edges between nodes
- source references
- historical time ranges
- visual markers
- view projections

The next step is to import existing JSON content into this schema and then
export runtime JSON back out.
