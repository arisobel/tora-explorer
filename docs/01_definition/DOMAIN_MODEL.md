# Domain Model — Torá Explorer

## Core Concepts

The long-term model for drill-down is documented in
`docs/04_technical/GENERAL_DRILL_DOWN_ARCHITECTURE.md`. The key principle is
that screens such as Estrutura, Timeline, Chumash Atlas, and future character
views are entry points over the same domain graph, not owners of separate data.

### Torah (תּוֹרָה)
Split into two traditions:
- **Torah Escrita** (Written): Chumash (5 books) + Nach (Prophets + Writings)
- **Torah Oral** (Oral): Mishna → Guemara → Halachá

### Chumash
The 5 books of Moses. Divided into 54 **Parashiot** (weekly portions).
- Gênesis (Bereshit): 12 parashiot — complete
- Shemot (Exodus): 11 parashiot — 9 JSON files present; Vayakhel + Pekudei missing
- Vayikrá (Leviticus): 10 parashiot — complete
- Bamidbar (Numbers): 10 parashiot — complete
- Devarim (Deuteronomy): 11 parashiot — complete

### Nach
Post-Chumash biblical books use a different content unit from parasha. They are
modeled as:

```
Nach Book → Narrative Unit → Fact → Pessukim
```

The first implemented Nach books are:
- Yehoshua (Joshua): 8 narrative units — complete first pass
- Shoftim (Judges): 7 narrative units — complete first pass
- Shemuel (Samuel I/II): 8 narrative units — complete first pass

### Parasha
The atomic content unit. Each parasha has:
- **Identity**: name (Hebrew + Portuguese), transliteration, aliyot count
- **Range**: Sefaria API ref (e.g. `"Genesis 1:1-6:8"`), chapters covered
- **Timeline**: anno_mundi start/end, era, position_pct (0–100 across full 5785 AM span)
- **Summary**: short (1 sentence), medium (2–3 paragraphs), characters, themes
- **Facts**: ordered list of narrative moments, each with a Sefaria ref for direct verse access
- **Aliyot**: the 7 Torah-reading divisions within the parasha
- **Haftarah**: prophetic reading paired with the parasha
- **Connections**: prev/next parasha, thematic links

### Fact
The sub-atomic content unit inside a parasha. Enables the "→ Ver versículos" flow:
```
fact.ref_start → Pessukim tab loads book/chapter → highlights verse range
```

Facts may also carry optional visual metadata. This metadata points to icons,
images, captions, lanes, colors, and importance levels, but it must not embed
binary image data directly in JSON.

### Visual Marker
An optional sensory/visual layer attached to a fact, parasha, book, or timeline
event.

Visual markers can represent:
- key events, such as the Ark, Sinai, Akeda, or the ladder dream
- people or character clusters
- places or journeys
- legal/thematic categories
- visual emphasis in dense overview screens

Suggested shape:
```json
{
  "marker_type": "icon",
  "icon": "ark",
  "asset": "assets/facts/genesis/noach/ark.png",
  "caption": "A Arca de Noach",
  "lane": "evento",
  "importance": 5,
  "color": "#4a7fa5"
}
```

The `visual` field is optional. Source refs remain mandatory for facts that
open Sefaria passages.

### Milestone
A strategic aggregation layer between book, parasha, themes, characters, facts,
and timeline events.

Milestones are broader than facts and more concrete than eras. They are useful
for visual drill-down screens such as the Chumash Atlas:

```
Book → Milestone → Parasha → Theme → Fact → Pessukim
```

Each milestone may include:
- book key
- label and icon
- parasha IDs
- fact IDs
- themes
- characters
- Sefaria ref
- visual metadata

Milestones should aggregate existing facts; they should not duplicate fact
content.

For Nach books, the same `milestone` concept is reused for narrative units.
This avoids introducing a parallel table/type before the UI needs it and keeps
cross-screen drill-down consistent.

### Timeline Group
A subject-level drill-down inside a large historical phase. It is narrower than
an era and broader than a fact.

Timeline groups currently live in `data/timeline_groups.json` as a transitional
runtime file and may point to:
- a Chumash book via `book_key`
- a milestone via `milestone_id`
- a parasha via `parasha_id`
- facts via `fact_ids`
- themes for filtering/visual grouping

They should not duplicate the detailed parasha/fact narrative.

The intended long-term model is horizontal: timeline groups, milestones,
characters, themes, parashiot, and facts should become reusable database nodes
connected by typed edges. See
`docs/04_technical/GENERAL_DRILL_DOWN_ARCHITECTURE.md` and
`docs/04_technical/DATABASE_DRILL_MODEL.md`.

### Anno Mundi (AM)
The Jewish calendar year-from-creation. Used as the x-axis of the timeline.
- 0 AM = Creation
- ~5785 AM = Today
- `position_pct = (anno_mundi_start / 5785) * 100`

### Era
A named period of the timeline (e.g. `patriarcas`, `tanaim`, `rishonim`). Each era has:
- AM range
- Color (used in timeline rendering)
- Associated books and parashiot

### Sefaria API
External read-only source for Hebrew and English verse text.
- Endpoint currently used by the app: `https://www.sefaria.org/api/v3/texts/{ref}`
- Ref format: `"Genesis 1:1-6:8"` (English book name, exact)
- Returns versioned text payloads under `versions[].text`; the app requests Hebrew and English separately

---

## Entities and Relationships

```
Timeline
  └── Era[] (14 eras, 0AM → 5785AM)

Chumash
  └── Book[] (5 books)
       ├── Milestone[] (strategic narrative aggregators)
       └── Parasha[] (54 total; Genesis, Vayikra, Bamidbar, and Devarim complete; Exodus partially populated)
            ├── Fact[] (ordered narrative moments with Sefaria refs)
            │    └── VisualMarker? (optional icon/image metadata)
            ├── Aliyot[] (7 divisions per Parasha)
            ├── Haftarah
            └── Connections { prev, next, thematic_links[] }

Nach
  └── Book[] (Joshua, Judges, Samuel, Kings, Isaiah)
       └── NarrativeUnit[] (stored as milestone nodes)
            └── Fact[] (ordered narrative moments with Sefaria refs)

Sefaria API (external)
  └── Text { he[], text[] } keyed by ref string
```

---

## Data Files

| File | Content |
|------|---------|
| `data/timeline.json` | All eras + key events (complete) |
| `data/timeline_groups.json` | Timeline phase drill-down groups |
| `data/SCHEMA.md` | JSON schema spec for parasha files |
| `data/parashiot/genesis/index.json` | Light metadata for all 12 Genesis parashiot |
| `data/parashiot/genesis/01-bereshit.json` through `12-vayechi.json` | Full Genesis data; all `facts_count` values match actual `facts[]` length |
| `data/parashiot/exodus/index.json` | Light metadata for all 11 Exodus parashiot |
| `data/parashiot/exodus/01-shemot.json` through `09-ki-tisa.json` | Full Exodus data currently present |
| `data/parashiot/exodus/10-vayakhel.json` and `11-pekudei.json` | Referenced in `index.json` but not yet present on disk |
| `data/parashiot/leviticus/index.json` | Light metadata for all 10 Vayikra parashiot |
| `data/parashiot/leviticus/01-vayikra.json` through `10-bechukotai.json` | Full Vayikra data; all `facts_count` values match actual `facts[]` length |
| `data/parashiot/numbers/index.json` | Light metadata for all 10 Bamidbar parashiot |
| `data/parashiot/numbers/01-bamidbar.json` through `10-masei.json` | Full Bamidbar data; all `facts_count` values match actual `facts[]` length |
| `data/parashiot/deuteronomy/index.json` | Light metadata for all 11 Devarim parashiot |
| `data/parashiot/deuteronomy/01-devarim.json` through `11-vezot-haberakhah.json` | Full Devarim data; all `facts_count` values match actual `facts[]` length |
| `data/nach/joshua/index.json` | Yehoshua/Joshua metadata and 8 narrative-unit summaries |
| `data/nach/joshua/01-entry-into-canaan.json` through `08-farewell-covenant-shechem.json` | Full Joshua first-pass data; all `facts_count` values match actual `facts[]` length |
| `data/nach/judges/index.json` | Shoftim/Judges metadata and 7 narrative-unit summaries |
| `data/nach/judges/01-transition-and-first-judges.json` through `07-gibeah-civil-war.json` | Full Judges first-pass data; all `facts_count` values match actual `facts[]` length |
| `data/nach/samuel/index.json` | Shemuel/Samuel I-II metadata and 8 narrative-unit summaries |
| `data/nach/samuel/01-samuel-birth-ark-crisis.json` through `08-david-restoration-final-appendix.json` | Full Samuel first-pass data; all `facts_count` values match actual `facts[]` length |
| `data/nach/kings/index.json` | Melachim/Kings I-II metadata and 8 narrative-unit summaries |
| `data/nach/kings/01-solomon-consolidation-wisdom.json` through `08-judah-reform-exile.json` | Full Kings first-pass data; all `facts_count` values match actual `facts[]` length |
| `data/nach/isaiah/index.json` | Yeshaya/Isaiah metadata and 8 prophetic-unit summaries |
| `data/nach/isaiah/01-zion-indictment-call.json` through `08-servant-zion-restoration.json` | Full Isaiah first-pass data; all `facts_count` values match actual `facts[]` length |
| `data/milestones/chumash.json` | Chumash Atlas milestones across the 5 books |
| `assets/` | Planned folder for visual icons/images referenced by JSON; not implemented yet |

---

## Key Invariants

1. `fact.sefaria_ref` must match Sefaria API book naming exactly (English: `Genesis`, not `Bereshit`)
2. `index.json.facts_count` must equal the actual `facts[]` length in the parasha JSON
3. `position_pct` must be derived from `anno_mundi_start / 5785 * 100`
4. Drawer reads from `index.json` first, then lazy-loads the full parasha JSON on expand
5. Any book exposed in the drawer must have matching book-aware navigation into the Pessukim reader
6. Visual assets are referenced by path from JSON; image binaries are never embedded in JSON
7. Every visual marker with an `asset` must include a `caption` or equivalent accessible label
8. Milestones aggregate parashiot/facts by ID; they must not become duplicate narrative text stores
9. Nach books use `units[]`, not `parashiot[]`; each unit aggregates facts by stable local IDs
10. Timeline-specific JSON drill files are transitional; the intended source-of-truth is a horizontal node/edge data model that can export runtime JSON

---

## Current Implementation Boundary

The data model supports all 5 books through parallel folders under
`data/parashiot/`. The drawer is book-aware for Genesis and Exodus.
Drawer-to-Pessukim navigation is also book-aware (fixed 2026-06-01).

Remaining drawer gaps: ERA color styling for Exodus-specific eras (`egito`,
`saida-egito`); Leviticus/Numbers/Deuteronomy chips not yet exposed in the UI
drawer even though data files exist.

The next content-model evolution is documented in
`docs/04_technical/DATABASE_DRILL_MODEL.md`: keep JSON as the app runtime
format, but introduce a database authoring/source-of-truth model with reusable
nodes and typed edges.
