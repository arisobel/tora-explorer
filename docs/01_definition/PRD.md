# PRD — Torá Explorer (Minian)

## Vision

An interactive, browser-based reference tool for exploring the structure, timeline, and content of the Torah and Oral Law tradition — in Portuguese, sourced live from the Sefaria API.

## Target User

Hebrew school students, adult learners, and researchers in the Brazilian Jewish community who want an overview of the canonical corpus and easy access to primary texts.

## Core Problem

The Torah tradition spans thousands of years and dozens of texts. There is no single Portuguese-language tool that visualizes its structure, historical arc, key figures, and allows reading the source verses in one place.

---

## Feature Set (5 tabs)

### Tab 1 — Estrutura
- Visual map of Written Torah (Chumash + Nach) and Oral Torah (Mishna, Guemara, Halacha)
- Flow diagram: Mikra → Talmud → Halachá
- Chips for each book, with tooltips
- **Bereshit and Shemot chips open the parasha drawer** (lateral panel)
- Future visual drill-down: macro tradition map → Chumash overview → book/parasha overview → fact detail

### Tab 2 — Linha do Tempo
- Vertical timeline from Creation (0 AM) to Acharonim (today)
- Color-coded: blue = Written Torah, green = Oral Torah, purple = Transition
- Horizontal bar showing Oral Torah periods by century CE
- Events are clickable (currently no action)
- Future event markers may include icons or images for key narrative moments

### Tab 3 — Mishna & Guemara
- Two-column panel: Tanaim (Mishna) and Amoraim (Guemara) with key figures
- Academies section (Israel + Babylon)
- Braitot & parallel works

### Tab 4 — Chumash — 5 Livros
- Sub-navigation per book
- Key events list + character roster per book
- Static content, not API-driven
- Future visual atlas: event lanes, character lanes, book markers, and parasha-level drill-down

### Tab 5 — Pessukim — Versículos
- Live reader: selects book + chapter, fetches from Sefaria API
- View modes: Parallel (Hebrew + English), Hebrew only, English only
- Chapter navigation, verse jump, link to Sefaria
- Connects from parasha drawer ("→ Ver versículos" button)

---

## Non-Goals
- No user accounts or bookmarks
- No Hebrew keyboard input
- No commentary layer (Rashi, etc.) in this version
- No mobile-first design (responsive exists but desktop-primary)
- No database-backed public runtime in the current phase; static JSON remains the app data format

---

## Visual Content Strategy

The product should evolve from text-only facts into a visual learning atlas.
Facts, parashiot, timeline events, and books may receive optional visual metadata:
icons, image references, captions, lanes, colors, and importance levels.

Images and icons should live as files under a future `assets/` folder. JSON files
should reference those assets, not embed binary data.

The intended drill-down hierarchy is:

1. Canonical structure: Torah Escrita, Torah Oral, Mikra, Talmud, Halacha
2. Chumash overview: five books, major event lanes, people lanes
3. Book/parasha overview: all parashiot in a book with summaries and markers
4. Fact detail: text, Sefaria ref, people/themes, and visual marker

Authoring should remain JSON-first for now. A future local `editor.html` /
`admin.html` may edit or export JSON files through forms before any database is
introduced.

---

## Success Criteria
- All 12 Gênesis parashiot have populated JSON data files
- Drawer opens with facts and links to Pessukim tab for each parasha
- Historical ruler renders inside the drawer
- App loads with zero build step (pure HTML/CSS/JS)
- Visual markers can be added to facts without changing the static hosting model
