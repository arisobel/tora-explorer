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
User clicks "Bereshit ›" or "Shemot ›" chip
  → drawerOpen({ bookKey })
  → fetch("data/parashiot/{bookKey}/index.json")
  → render parashiot list with summary_short and mini-ruler
  → user clicks a parasha
  → fetch(parasha.data_file)    ← e.g. "data/parashiot/genesis/01-bereshit.json"
  → render facts[]
  → each fact has "→ Capítulo N" button
  → click → drawerGoToPessukim(chapter, bookKey)
           → resolves Sefaria name via BOOK_META[bookKey].sefaria
           → showPage('pessukim'); pkLoad()
```

Current status:
- Drawer is book-aware: implemented for Genesis and Exodus.
- `drawerOpen()` accepts `{ bookKey, parashaId?, factIds? }`.
- Drawer-to-Pessukim navigation is book-aware (fixed 2026-06-01).
- Exodus ERA colors in the drawer (`egito`, `saida-egito`) still fall back to
  `patriarcas` style — a known cosmetic gap.

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
| Parasha Drawer — Genesis | Estrutura | Implemented |
| Parasha Drawer — Exodus | Estrutura | Implemented (9 of 11 parashiot have JSON; 2 missing) |
| Parasha Drawer — Leviticus/Numbers/Deuteronomy | Estrutura | Data exists; drawer chip not yet exposed in UI |
| Historical Ruler inside Drawer | Estrutura | Implemented; AM ranges from book index |
| ERA color styling — Exodus | Estrutura Drawer | `egito`/`saida-egito` fall back to `patriarcas` color (known gap) |
| Facts panel with inline Sefaria passages | Estrutura Drawer | Implemented |
| Book-aware drawer-to-Pessukim navigation | Estrutura/Pessukim | Implemented (2026-06-01) |
| Timeline → Parasha drawer cross-link | Timeline | Pilot for Genesis (creation, flood, avraham) |
| Timeline phase drill-down groups | Timeline | Implemented via `data/timeline_groups.json` |
| Chumash Atlas milestones | Chumash | Implemented via `data/milestones/chumash.json` |
| Nach data model | Data | Implemented for `data/nach/joshua/` and `data/nach/judges/` |
| SQLite authoring database | Authoring | Schema + import implemented; export script not yet written |
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
