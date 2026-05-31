# Architecture — Torá Explorer

## Stack

**Zero-dependency, zero-build SPA.**

| Layer | Technology |
|-------|-----------|
| Markup | HTML5 (single file: `index.html`) |
| Styles | Inline CSS with CSS custom properties |
| Logic | Vanilla JS (ES6, inline `<script>` blocks) |
| Data | Static JSON files under `data/` |
| External API | Sefaria REST API (read-only, no auth) |
| Fonts | Google Fonts CDN (Crimson Pro, DM Sans) |

No npm, no bundler, no framework. Open `index.html` directly in any browser.

---

## File Structure

```
tora-explorer/
├── index.html                         # Entire app
├── data/
│   ├── timeline.json                  # Eras + key events (global ruler)
│   ├── SCHEMA.md                      # Parasha JSON schema spec
│   └── parashiot/
│       └── genesis/
│           ├── index.json             # Lightweight index (12 parashiot metadata)
│           ├── 01-bereshit.json       # Full parasha data + 20 facts
│           └── 02-noach.json          # Shell (no facts yet)
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

Status: `drawerOpen()` is referenced in HTML but **not yet implemented** in JS.

---

## Data Flow: Pessukim Reader

```
User selects Book + Chapter → pkLoad()
  → fetch("https://www.sefaria.org/api/texts/{book}.{chapter}")
  → pkRender(data.he, data.text)
  → verse rows built dynamically
  → pkNavChapter(±1) adjusts chapter, re-fetches
  → pkJumpToVerse() scrolls to .verse-row[data-v=N]
```

---

## Sefaria API Contract

Base URL: `https://www.sefaria.org/api/texts/`

Request: `GET /api/texts/Genesis.1`

Response shape used:
```json
{
  "he": ["בְּרֵאשִׁית בָּרָא...", ...],
  "text": ["In the beginning...", ...],
  "book": "Genesis",
  "sections": [1],
  "toSections": [31]
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

## Planned Components (not yet built)

| Component | Tab | Status |
|-----------|-----|--------|
| Parasha Drawer | Estrutura | Stub exists (`drawerOpen()` called, not defined) |
| Historical Ruler inside Drawer | Estrutura | Not started |
| Facts panel with "→ Ver versículos" | Estrutura Drawer | Not started |
