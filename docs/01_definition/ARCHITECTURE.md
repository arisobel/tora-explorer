# Architecture — Torá Explorer

## Stack

**Zero-dependency, zero-build SPA.**

| Layer | Technology |
|-------|-----------|
| Markup | HTML5 (single file: `index.html`) |
| Styles | Inline CSS with CSS custom properties |
| Logic | Vanilla JS (ES6, inline `<script>` blocks) |
| Data | Static JSON files under `data/` |
| Visual Assets | Planned static files under `assets/` |
| Deployment | CapRover tar package with Nginx Dockerfile |
| External API | Sefaria REST API (read-only, no auth) |
| Fonts | Google Fonts CDN (Crimson Pro, DM Sans) |

No npm, no bundler, no framework. Open `index.html` directly in any browser.

The public runtime should remain static-file based. A database is deferred until
there is a real authoring workflow need; even then, the preferred public output
is exported JSON consumed by the static app.

---

## File Structure

```
tora-explorer/
├── index.html                         # Entire app
├── data/
│   ├── timeline.json                  # Eras + key events (global ruler)
│   ├── SCHEMA.md                      # Parasha JSON schema spec
│   └── parashiot/
│       ├── genesis/
│       │   ├── index.json             # Lightweight index (12 parashiot metadata)
│       │   └── 01-bereshit.json ... 12-vayechi.json
│       └── exodus/
│           ├── index.json             # Lightweight index (11 parashiot metadata)
│           └── 01-shemot.json ... 08-tetzaveh.json
├── assets/                            # Planned visual icons/images referenced by JSON
│   ├── icons/
│   ├── facts/
│   └── books/
├── captain-definition                 # CapRover manifest
├── Dockerfile                         # Nginx static hosting image
├── scripts/
│   └── build-caprover.ps1             # Generates dist/*.tar, keeps last 5
├── dist/                              # Generated CapRover tar packages
└── docs/
    ├── 00_meta/                       # Orchestration skill
    ├── 01_definition/                 # PRD, Domain Model, Architecture
    ├── 02_execution/                  # Progress, Backlog, Decisions
    ├── 03_validation/                 # (reserved)
    └── 04_technical/                  # (reserved)
```

---

## UI Architecture: 5-Tab SPA

```
<nav>                          ← sticky, tab buttons
<div class="hero">             ← always visible header
<div id="page-*">              ← one per tab, toggled via showPage()
```

Tab switching: `showPage(id, btn)` toggles `.active` class.
Book switching (Chumash tab): `showBook(id, btn)` same pattern.
Verse view toggle: `pkSetView(mode, btn)` adds class to `#pk-reader`.

Future drill-down levels:
- Level 1: canonical structure map
- Level 2: Chumash five-book visual overview
- Level 3: book/parasha overview
- Level 4: fact detail with Sefaria passage and optional visual marker

Timeline/parasha cross-interaction is a first-class architectural concern:
global timeline events should route into parashiot/facts, and parasha/fact views
should expose their related global timeline markers.

---

## Data Flow: Parasha Drawer

```
User clicks "Bereshit ›" chip
  → drawerOpen()
  → fetch("data/parashiot/genesis/index.json")
  → render list of 12 parashiot with summary_short
  → user expands a parasha
  → fetch(parasha.data_file)    ← e.g. "data/parashiot/genesis/01-bereshit.json"
  → render facts[]
  → each fact has "→ Ver versículos" button
  → click → showPage('pessukim'); pkLoad(fact.ref_start)
```

Current status:
- Implemented for Genesis.
- The drawer is still hardcoded to `data/parashiot/genesis/index.json`.
- The Shemot/Exodus data exists partially, but the Shemot chip does not yet open
  a drawer.
- Drawer-to-Pessukim navigation currently assumes `Genesis`.

Target next architecture:
```
drawerOpen({ bookKey, parashaId?, factIds? })
  → load data/parashiot/{bookKey}/index.json
  → render the same drawer UI for any supported Chumash book
  → optionally select a parasha and highlight linked facts
  → drawerGoToPessukim(book, chapter, verseStart?)
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
--bg: #0e0d0b          /* darkest background */
--gold / --gold2 / --gold3   /* primary accent — Torah Oral */
--blue / --blue2              /* Torah Escrita */
--green / --green2            /* Oral Law */
--text / --text2 / --text3    /* text hierarchy */
--border / --border2          /* gold-tinted borders */
```

---

## Component Status

| Component | Tab | Status |
|-----------|-----|--------|
| Parasha Drawer | Estrutura | Implemented for Genesis only |
| Historical Ruler inside Drawer | Estrutura | Implemented for Genesis; labels/ranges are hardcoded |
| Facts panel with inline Sefaria passages | Estrutura Drawer | Implemented for Genesis facts |
| Drawer support for Exodus | Estrutura | Not implemented |
| Book-aware drawer-to-Pessukim navigation | Estrutura/Pessukim | Not implemented |
| Data validation script | Data | Not implemented |
| Visual markers for facts/parashiot | Data/UI | Planned |
| Local JSON editor / Content Studio | Authoring | Planned, not implemented |

---

## Content Authoring Direction

The current source-of-truth for runtime data remains static JSON. Visual
metadata should be added as optional fields that reference static files under
`assets/`.

Near-term authoring stays manual. Later, a local `editor.html` or `admin.html`
can provide forms for editing JSON fields and exporting or saving files through
browser-supported local file APIs.

Database-backed authoring remains a future option, not the current runtime
architecture. If introduced, it should export the same JSON format the app
already consumes.

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
