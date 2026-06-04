# Content and Visual Strategy

## Decision

Keep static JSON files as the publication and public runtime format for the app.
Use SQLite as a local authoring and integration layer.

The content model will evolve to support richer drill-down views, visual
markers, icons, images, and future local authoring tools. The browser app should
continue to consume static JSON for portability and zero-build deployment.

---

## Why JSON Remains the Runtime Format

The current project benefits from being simple:
- no backend
- no authentication
- no server-side storage
- easy sharing as static files

SQLite is useful for local authoring because it enables reusable nodes, typed
edges, validation, and future generated projections without introducing a
public backend. A hosted database would be justified only when the project
needs one or more of these:
- multi-user editing
- authenticated editorial workflow
- image uploads through a hosted admin panel
- complex search/indexing that static JSON cannot handle
- audit history beyond Git
- large enough content volume that JSON loading becomes a real bottleneck

Until then, JSON keeps the deployed content inspectable, versionable, and
portable.

---

## Target Content Layers

The product should support multiple levels of exploration.

### Level 1 - Canonical Structure

Macro view of the tradition:
- Torah Escrita
- Torah Oral
- Mikra
- Talmud
- Halacha
- major periods and textual families

This level is conceptual and should favor broad visual grouping.

### Level 2 - Chumash Overview

Five-book overview:
- Genesis, Exodus, Leviticus, Numbers, Deuteronomy
- major event lanes
- major character lanes
- visual rhythm across books
- key moments as icons or image markers

This level should resemble a visual atlas: dense, scannable, and chronological.

### Level 3 - Book and Parasha Overview

Book-level drill-down:
- all parashiot in one book
- each parasha with summary, range, major facts, people, and themes
- representative icon/image per parasha
- historical ruler and event clustering

Genesis currently has enough data to become the first complete Level 3 view.
Exodus should become the second after its remaining JSON files are completed.

### Level 4 - Fact Detail

Fact-level view:
- fact text
- Hebrew highlight where useful
- Sefaria ref and verse reader link
- people, places, themes, and tags
- visual marker, icon, image, or illustration
- optional short caption for visual memory

This is the level that creates the sensory layer: the user should not only read
the event, but recognize it visually.

---

## Visual Marker Model

Visual markers are metadata attached to facts, parashiot, books, or timeline
events. They should not store binary data inside JSON. JSON stores references;
image and icon files live in `assets/`.

Example fact extension:

```json
{
  "id": "n003",
  "text": "Noach constrói a arca conforme a ordem divina.",
  "sefaria_ref": "Genesis 6:14-22",
  "chapter": 6,
  "verse_start": 14,
  "verse_end": 22,
  "visual": {
    "marker_type": "icon",
    "icon": "ark",
    "asset": "assets/facts/genesis/noach/ark.png",
    "caption": "A Arca de Noach",
    "lane": "evento",
    "importance": 5,
    "color": "#4a7fa5"
  }
}
```

Suggested fields:

| Field | Purpose |
|-------|---------|
| `marker_type` | `icon`, `image`, `symbol`, `map`, `none` |
| `icon` | Stable symbolic id, such as `ark`, `sinai`, `ladder`, `covenant` |
| `asset` | Relative path to an image file |
| `caption` | Short display label or accessibility text |
| `lane` | Visual grouping, such as `evento`, `personagem`, `lei`, `lugar` |
| `importance` | 1-5 priority for dense overview layouts |
| `color` | Optional display accent |

---

## Asset Organization

Proposed future folder structure:

```
assets/
  icons/
    ark.svg
    covenant.svg
    sinai.svg
  facts/
    genesis/
      noach/
        ark.png
    exodus/
      yitro/
        sinai.png
  books/
    genesis.png
    exodus.png
```

Rules:
- Keep binary assets outside JSON.
- Prefer stable semantic names over decorative names.
- Use SVG for reusable symbolic icons.
- Use PNG/JPG/WebP for richer illustrations or generated images.
- Every visual asset referenced from JSON must have a caption or alt text.

---

## Authoring Strategy

### Phase 1 - Manual JSON + SQLite Import

Continue editing JSON files directly while the schema is still evolving, then
import them into SQLite through `scripts/import-json-to-sqlite.ps1`.

Needed support:
- schema documentation
- validation checklist or script
- consistent `facts_count`
- missing-file detection
- visual marker field conventions

### Phase 2 - SQLite Export and Generated Projections

Implement `scripts/export-sqlite-to-json.ps1` and generate runtime JSON views
for structure, timeline, and other drill-down entry points.

This allows SQLite to mature into the authoring source without changing the
static browser runtime.

### Phase 3 - Local Content Studio

Build a local `editor.html` or `admin.html` that reads JSON and helps edit:
- parasha metadata
- facts
- refs
- tags/themes
- visual marker metadata
- image paths and captions

The editor can use the browser File System Access API where available, or export
updated JSON for manual replacement.

This keeps the app backend-free while reducing editing friction.

### Phase 4 - Hosted Editorial Backend

Introduce a hosted database only if authoring needs outgrow local files and
SQLite. In that model:
- the hosted database is the editing backend
- static JSON export remains the app runtime format
- the public app can still be hosted as static files

Possible entities:
- `books`
- `parashiot`
- `facts`
- `people`
- `themes`
- `places`
- `assets`
- `timeline_events`
- join tables such as `fact_people`, `fact_themes`, `fact_assets`

---

## Implementation Order

1. Extend the documented parasha schema with optional `visual` metadata.
2. Add a small asset folder convention.
3. Add validation for missing assets and required captions.
4. Add visual markers to a small Genesis pilot, probably Noach or Lech Lecha.
5. Render visual markers in the existing drawer.
6. Implement SQLite-to-JSON export and generated runtime projections.
7. Create a book-level visual atlas view after the data proves stable.
8. Build a local editor only after the schema stops moving.

---

## Guardrails

- Do not store images as base64 inside JSON.
- Do not make the public runtime depend on a live database or API before there
  is a real hosted editing workflow need.
- Do not let visual assets replace source refs; each fact remains anchored to
  Sefaria-compatible refs.
- Do not make the first visual pass too broad. Pilot one parasha or one book
  before filling all Chumash.
- Keep JSON compatible with static hosting.
