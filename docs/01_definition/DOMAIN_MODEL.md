# Domain Model — Torá Explorer

## Core Concepts

### Torah (תּוֹרָה)
Split into two traditions:
- **Torah Escrita** (Written): Chumash (5 books) + Nach (Prophets + Writings)
- **Torah Oral** (Oral): Mishna → Guemara → Halachá

### Chumash
The 5 books of Moses. Divided into 54 **Parashiot** (weekly portions).
- Gênesis (Bereshit): 12 parashiot
- Shemot (Exodus), Vayikrá (Leviticus), Bamidbar (Numbers), Devarim (Deuteronomy): ~42 remaining

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
- Endpoint: `https://www.sefaria.org/api/texts/{ref}`
- Ref format: `"Genesis 1:1-6:8"` (English book name, exact)
- Returns: `text[]` (English), `he[]` (Hebrew), both arrays indexed by verse

---

## Entities and Relationships

```
Timeline
  └── Era[] (14 eras, 0AM → 5785AM)

Chumash
  └── Book[] (5 books)
       └── Parasha[] (54 total; 12 for Genesis currently populated)
            ├── Fact[] (ordered narrative moments with Sefaria refs)
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
| `data/parashiot/genesis/01-bereshit.json` | Full data, 20 facts (complete) |
| `data/parashiot/genesis/02-noach.json` | Shell exists, facts_count = 0 (incomplete) |
| `data/parashiot/genesis/03–12-*.json` | Referenced in index.json but **do not exist yet** |

---

## Key Invariants

1. `fact.sefaria_ref` must match Sefaria API book naming exactly (English: `Genesis`, not `Bereshit`)
2. `index.json.facts_count` must equal the actual `facts[]` length in the parasha JSON
3. `position_pct` must be derived from `anno_mundi_start / 5785 * 100`
4. Drawer reads from `index.json` first, then lazy-loads the full parasha JSON on expand
