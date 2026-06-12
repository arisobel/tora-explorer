# Architecture — Torá Explorer

## Stack

**Zero-dependency, zero-build SPA.**

| Layer | Technology |
|-------|-----------|
| Markup | HTML5 (single file: `index.html`) |
| Styles | Inline CSS with CSS custom properties |
| Logic | Vanilla JS (ES6, inline `<script>` blocks) |
| Data | Static JSON files under `data/` |
| Authoring | SQLite local database under `db/`, populated from JSON |
| Visual Assets | Planned static files under `assets/` |
| Deployment | CapRover tar package with Nginx Dockerfile |
| External API | Sefaria REST API (read-only, no auth) |
| Fonts | Google Fonts CDN (Crimson Pro, DM Sans) |

No npm, no bundler, no framework. Open `index.html` directly in any browser.

The public runtime remains static-file based. SQLite is already available as a
local authoring and integration layer, while the preferred public output remains
exported JSON consumed by the static app.

---

## File Structure

```
tora-explorer/
├── index.html                         # Entire app
├── data/
│   ├── timeline.json                  # Eras + key events (global ruler)
│   ├── timeline_groups.json           # Timeline phase drill-down projection
│   ├── SCHEMA.md                      # Parasha JSON schema spec
│   ├── milestones/
│   │   └── chumash.json               # Strategic Chumash aggregators
│   ├── parashiot/
│   │   ├── genesis/
│   │   │   ├── index.json             # Lightweight index (12 parashiot metadata)
│   │   │   └── 01-bereshit.json ... 12-vayechi.json
│   │   └── exodus/ ... deuteronomy/   # Chumash book indexes and parasha files
│   └── nach/
│       ├── joshua/ ... trei-assar/    # Neviim unit indexes and files
│       └── psalms/ ... chronicles/    # Ketuvim unit indexes and files
├── db/
│   ├── migrations/                    # SQLite authoring schema
│   └── tora-explorer.sqlite           # Local generated authoring database
├── assets/                            # Planned visual icons/images referenced by JSON
│   ├── icons/
│   ├── facts/
│   └── books/
├── captain-definition                 # CapRover manifest
├── Dockerfile                         # Nginx static hosting image
├── scripts/
│   ├── build-caprover.ps1             # Generates dist/*.tar, keeps last 5
│   ├── init-sqlite.ps1                # Creates the local SQLite database
│   └── import-json-to-sqlite.ps1      # Imports runtime JSON into SQLite
├── dist/                              # Generated CapRover tar packages
└── docs/
    ├── 00_meta/                       # Orchestration skill
    ├── 01_definition/                 # PRD, Domain Model, Architecture
    ├── 02_execution/                  # Progress, Backlog, Decisions
    ├── 03_validation/                 # (reserved)
    └── 04_technical/                  # (reserved)
```

---

## UI Architecture: 6-Tab SPA

```
<nav>                          ← sticky, tab buttons
<div class="hero">             ← always visible header
<div id="page-*">              ← one per tab, toggled via showPage()
```

Tab switching: `showPage(id, btn)` toggles `.active` class.
Book switching (Chumash tab): `showBook(id, btn)` same pattern.
Verse view toggle: `pkSetView(mode, btn)` adds class to `#pk-reader`.
Atlas view initialization: `initAtlas()` loads `data/milestones/chumash.json`
and `data/timeline_groups.json` and renders a runtime 2D projection.

Drill-down levels:
- Level 1: canonical structure map
- Level 2: book-family and five-book visual overview
- Level 3: milestone, parasha, or Nach/Ketuvim narrative-unit overview
- Level 4: fact detail with Sefaria passage and optional visual marker

Atlas 2D uses hover as a drill candidate selector and scroll as the drill
confirmation gesture. Scroll-up enters the hovered candidate; scroll-down moves
back one level. Because the mouse wheel is reserved for drill depth, the Atlas
background supports grab/pan to navigate vertically overflowing content. Its AM
ruler is fixed to the viewport bottom, full-width like the top nav, and updates
to the current focus range.

Timeline/parasha cross-interaction is a first-class architectural concern:
global timeline events should route into parashiot/facts, and parasha/fact views
should expose their related global timeline markers.

---

## Data Flow: Parasha Drawer

```
User clicks a Chumash, Nach, or Ketuvim book chip
  → drawerOpen({ bookKey })
  → resolve index path via BOOK_META[bookKey]
  → fetch Chumash parashiot or Nach/Ketuvim units index
  → render unit list with summary_short and mini-ruler
  → user clicks a parasha or narrative unit
  → fetch(unit.data_file)
  → render facts[]
  → each fact has "→ Capítulo N" button
  → click → drawerGoToPessukim(chapter, bookKey)
           → resolves Sefaria name via BOOK_META[bookKey].sefaria
           → showPage('pessukim'); pkLoad()
```

Current status:
- Drawer is book-aware for all Chumash, Nach, and Ketuvim chips exposed in
  Estrutura.
- `drawerOpen()` accepts `{ bookKey, parashaId?, factIds? }`.
- Drawer-to-Pessukim navigation is book-aware (fixed 2026-06-01).
- `ERA` includes core Genesis, Exodus, journey, land-entry, and Nach styles;
  richer period-specific visual polish remains possible.

Next step:
```
drawerGoToPessukim(chapter, bookKey)
  → also support verse-level navigation once fact refs carry chapter:verse
```

Timeline interaction target:
```
timelineEvent.links
  → { book_key, parasha_id, fact_ids[], sefaria_ref }
  → drawerOpen({ bookKey, parashaId, factIds })
```

Runtime mart target:
```
data/parashiot/{book}/index.json
  → { byId, byCharacter }
  → timeline routing, drawer lookup, future character views
```

---

## Data Flow: Pessukim Reader

```
User selects Book + Chapter → pkLoad()
  → fetch Hebrew + English from "https://www.sefaria.org/api/v3/texts/{book chapter}"
  → extract versions[0].text from each response
  → pkRender()
  → verse rows built dynamically
  → pkNavChapter(±1) adjusts chapter, re-fetches
  → pkJumpToVerse() scrolls to .verse-row[data-v=N]
```

---

## Sefaria API Contract

Base URL currently used in the app:
`https://www.sefaria.org/api/v3/texts/{ref}`

Local development can still call it through `https://corsproxy.io/?url=...` when
the app runs from `file://` or `localhost`. Production CapRover deploys use the
same-origin Nginx proxy below.

Production flow:
- Browser calls same-origin URL: `/api/sefaria/{ref}?version=...`
- Nginx proxies that path to: `https://www.sefaria.org/api/v3/texts/{ref}?version=...`
- Browser sees same-origin response, so no CORS proxy is needed.

Request examples:
- Chapter reader: `GET /api/v3/texts/Genesis%201?version=hebrew&return_format=text_only`
- Inline passage: `GET /api/v3/texts/Genesis%201:1-1:5?version=english&return_format=text_only`

Response shape used:
```json
{
  "versions": [
    {
      "text": ["בְּרֵאשִׁית בָּרָא...", "..."]
    }
  ]
}
```

---

## Design Tokens (CSS Custom Properties)

```css
--bg: #fbfaf7           /* light atlas background */
--surface: #ffffff      /* primary reading surface */
--gold / --gold2 / --gold3   /* primary accent — Torah Oral */
--blue / --blue2              /* Torah Escrita */
--green / --green2            /* Oral Law */
--text / --text2 / --text3    /* text hierarchy */
--border / --border2          /* restrained atlas borders */
```

---

## Component Status

| Component | Tab | Status |
|-----------|-----|--------|
| Parasha Drawer — Genesis | Estrutura | Implemented |
| Parasha Drawer — Exodus | Estrutura | Implemented (9 of 11 parashiot have JSON; 2 missing) |
| Parasha Drawer — Leviticus/Numbers/Deuteronomy | Estrutura | Data exists; structure chips open the drawer |
| Historical Ruler inside Drawer | Estrutura | Implemented; AM ranges from book index |
| ERA color styling — Exodus and Nach | Estrutura Drawer | Core eras are mapped in `ERA`; additional book-specific polish remains possible |
| Facts panel with inline Sefaria passages | Estrutura Drawer | Implemented |
| Book-aware drawer-to-Pessukim navigation | Estrutura/Pessukim | Implemented (2026-06-01) |
| Timeline → drawer cross-link | Timeline | Implemented for Chumash and exposed Nach/Ketuvim timeline groups |
| Timeline phase drill-down groups | Timeline | Implemented via `data/timeline_groups.json` |
| Atlas 2D drill map | Atlas 2D | Implemented as a runtime projection over Chumash milestones and timeline groups; includes hover-target drill, scroll depth, background grab, and fixed bottom AM ruler |
| Chumash Atlas milestones | Chumash | Implemented via `data/milestones/chumash.json`; all five books route milestones to parashiot, with fact-level highlights present where `fact_ids` exist |
| Nach/Ketuvim data model | Data | Implemented for all Estrutura chips from Joshua through Chronicles |
| SQLite authoring database | Authoring | Schema + import implemented; export script not yet written |
| Data validation script | Data | Not implemented |
| Visual markers for facts/parashiot | Data/UI | Planned |
| Local JSON editor / Content Studio | Authoring | Planned, not implemented |

---

## Content Authoring Direction

The runtime source-of-truth remains static JSON. Visual metadata should be added
as optional fields that reference static files under `assets/`.

SQLite authoring is implemented through `db/migrations/`,
`scripts/init-sqlite.ps1`, and `scripts/import-json-to-sqlite.ps1`. The next
authoring step is an SQLite-to-JSON export pipeline so generated runtime
projections can replace manually synchronized files without changing the public
static architecture. A future local `editor.html` or `admin.html` can edit that
authoring model.

Detailed strategy:
`docs/04_technical/CONTENT_VISUAL_STRATEGY.md`

Timeline/parasha interaction strategy:
`docs/04_technical/TIMELINE_PARASHA_INTERACTION.md`

---

## Deployment

CapRover deployment is package-based. Run:

```powershell
.\scripts\build-caprover.ps1
```

The script creates a timestamped `.tar` in `dist/` and keeps only the 5 newest
CapRover packages.

Detailed flow:
`docs/04_technical/CAPROVER_DEPLOY.md`
