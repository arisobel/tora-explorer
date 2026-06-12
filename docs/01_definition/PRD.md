# PRD — Torá Explorer (Minian)

## Vision

An interactive, browser-based reference tool for exploring the structure, timeline, and content of the Torah and Oral Law tradition — in Portuguese, sourced live from the Sefaria API.

## Target User

Hebrew school students, adult learners, and researchers in the Brazilian Jewish community who want an overview of the canonical corpus and easy access to primary texts.

## Core Problem

The Torah tradition spans thousands of years and dozens of texts. There is no single Portuguese-language tool that visualizes its structure, historical arc, key figures, and allows reading the source verses in one place.

---

## Feature Set (6 tabs)

### Tab 1 — Estrutura
- Visual map of Written Torah (Chumash + Nach) and Oral Torah (Mishna, Guemara, Halacha)
- Flow diagram: Mikra → Talmud → Halachá
- Chips for each book, with tooltips
- Chumash chips open the parasha drawer; Nach/Ketuvim chips open the reusable
  narrative-unit drawer
- Future visual drill-down: macro tradition map → Chumash overview → book/parasha overview → fact detail

### Tab 2 — Linha do Tempo
- Vertical timeline from Creation (0 AM) to Acharonim (today)
- Color-coded: blue = Written Torah, green = Oral Torah, purple = Transition
- Horizontal bar showing Oral Torah periods by century CE
- Large phases expand into subject/milestone groups that can open linked
  parashiot or Nach/Ketuvim units
- Future event markers may include icons or images for key narrative moments

### Tab 3 — Atlas 2D
- Semantic 2D drill-down map over the existing data projections
- Macro lenses: Chumash, historical/Nach timeline, and future Torah Oral
- Chumash drill path: macro → 5 books → milestones → parashiot/units → facts
- Timeline/Nach drill path: macro → AM phases → timeline groups → units/facts
- Scroll-up confirms drill into the currently hovered candidate; scroll-down returns
  one level
- Background grab/pan lets users navigate overflowing content while the mouse
  wheel remains reserved for drill depth
- A fixed bottom AM ruler stays visible like the top navigation bar and reflects
  the current historical focus

### Tab 4 — Mishna & Guemara
- Two-column panel: Tanaim (Mishna) and Amoraim (Guemara) with key figures
- Academies section (Israel + Babylon)
- Braitot & parallel works

### Tab 5 — Chumash — 5 Livros
- Sub-navigation per book
- Key events list + character roster per book
- Static content, not API-driven
- Future visual atlas: event lanes, character lanes, book markers, and parasha-level drill-down

### Tab 6 — Pessukim — Versículos
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

The default UI direction is a white, atlas-like study surface. Dark UI should not
be the default presentation.

Images and icons should live as files under a future `assets/` folder. JSON files
should reference those assets, not embed binary data.

The intended drill-down hierarchy is:

1. Canonical structure: Torah Escrita, Torah Oral, Mikra, Talmud, Halacha
2. Chumash overview: five books, major event lanes, people lanes
3. Milestone overview: strategic narrative aggregators across books/parashiot
4. Book/parasha overview: all parashiot in a book with summaries and markers
5. Fact detail: text, Sefaria ref, people/themes, and visual marker
6. Pessukim: source text and chapter-level reading

The public runtime remains JSON-first. SQLite is available as a local authoring
and integration layer, and a future `editor.html` / `admin.html` may edit that
model or export JSON files through forms.

---

## Success Criteria
- All 12 Gênesis parashiot have populated JSON data files
- Drawer opens with facts and links to Pessukim tab for each parasha
- Estrutura and Timeline can reach the same Chumash, Nach, and Ketuvim content
  through reusable drill-down links
- Historical ruler renders inside the drawer
- App loads with zero build step (pure HTML/CSS/JS)
- Visual markers can be added to facts without changing the static hosting model
