# Domain Model — Torá Explorer

## Core Concepts

### Torah (תּוֹרָה)
Split into two traditions:
- **Torah Escrita** (Written): Chumash (5 books) + Nach (Prophets + Writings)
- **Torah Oral** (Oral): Mishna → Guemara → Halachá

### Chumash
The 5 books of Moses. Divided into 54 **Parashiot** (weekly portions).
- Gênesis (Bereshit): 12 parashiot
- Shemot (Exodus): 11 parashiot
- Vayikrá (Leviticus), Bamidbar (Numbers), Devarim (Deuteronomy): remaining Chumash parashiot not yet represented as data folders

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
       └── Parasha[] (54 total; Genesis complete, Exodus partially populated)
            ├── Fact[] (ordered narrative moments with Sefaria refs)
            │    └── VisualMarker? (optional icon/image metadata)
            ├── Aliyot[] (7 divisions per Parasha)
            ├── Haftarah
            └── Connections { prev, next, thematic_links[] }

Sefaria API (external)
  └── Text { he[], text[] } keyed by ref string
```

---

## Data Files

| File | Content |
|------|---------|
| `data/timeline.json` | All eras + key events (complete) |
| `data/SCHEMA.md` | JSON schema spec for parasha files |
| `data/parashiot/genesis/index.json` | Light metadata for all 12 Genesis parashiot |
| `data/parashiot/genesis/01-bereshit.json` through `12-vayechi.json` | Full Genesis data; all `facts_count` values match actual `facts[]` length |
| `data/parashiot/exodus/index.json` | Light metadata for all 11 Exodus parashiot |
| `data/parashiot/exodus/01-shemot.json` through `08-tetzaveh.json` | Full Exodus data currently present |
| `data/parashiot/exodus/09-ki-tisa.json` through `11-pekudei.json` | Referenced in `index.json` but not yet present on disk |
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

---

## Current Implementation Boundary

The data model already supports multiple books through parallel folders under
`data/parashiot/`. The UI drawer, however, is currently implemented only for
Genesis: it loads `data/parashiot/genesis/index.json`, uses Genesis labels in
the historical ruler, and sends drawer verse navigation to the Genesis selector
in the Pessukim tab.

The next model/UI alignment step is to make the drawer book-aware so that
`genesis` and `exodus` can use the same rendering flow.

The next content-model evolution is documented in
`docs/04_technical/CONTENT_VISUAL_STRATEGY.md`: keep JSON as the app runtime
format, add optional visual metadata, and defer database usage until authoring
needs justify it.
