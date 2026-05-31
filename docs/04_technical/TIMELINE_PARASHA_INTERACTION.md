# Timeline and Parasha Interaction Strategy

## Problem

The app currently has two timeline-like dimensions that are not fully connected:

1. `data/timeline.json` defines global eras and key historical events across the
   full Jewish timeline.
2. Parasha JSON files define narrative ranges, facts, and local historical
   positions for Torah portions.

These two dimensions overlap but are not the same thing. A global event such as
`Saída do Egito / Sinai` may correspond to multiple parashiot and many facts,
while a parasha may contain several narrative facts that do not map neatly to a
single global timeline marker.

The current UI should not force these into one flat list. It should support
cross-interaction between global history, parasha ranges, and fact-level
markers.

---

## Decision

Pause raw parasha population as a near-term priority. Prioritize the structural
model that links:

- global timeline events
- eras
- books
- parashiot
- fact-level markers
- Pessukim refs

This creates a coherent drill-down path before adding more content.

---

## Conceptual Model

### Global Timeline Event

A broad historical marker in `data/timeline.json`.

Examples:
- Criação
- Dilúvio
- Avraham / Lech-Lecha
- Saída do Egito / Sinai
- Primeiro Templo

This answers: "Where are we in the broad historical arc?"

### Parasha Range

A Torah-reading unit with its own textual range and approximate timeline span.

Examples:
- `bereshit`: Genesis 1:1-6:8
- `noach`: Genesis 6:9-11:32
- `ki-tisa`: Exodus 30:11-34:35

This answers: "Which weekly portion contains this material?"

### Fact Marker

A narrative or legal moment inside a parasha, anchored to exact refs.

Examples:
- The Ark
- The covenant with Avraham
- The Golden Calf
- Moshe's radiant face

This answers: "What happened here, and where can I read it?"

### Milestone

A strategic aggregator for visual drill-down. It sits between book/parasha and
fact-level detail.

Examples:
- Criação do Mundo
- Dilúvio e Arca de Noach
- Bezerro de Ouro
- Yom Kippur
- Espiões / Meraglim

This answers: "What are the major narrative anchors of this book?"

---

## Proposed Cross-Link Fields

### In `timeline.json`

Extend `key_events[]` with optional routing metadata:

```json
{
  "id": "golden-calf",
  "am": 2449,
  "label": "Bezerro de Ouro",
  "label_he": "עֵגֶל הַזָּהָב",
  "book": "Exodus 32",
  "links": {
    "book_key": "exodus",
    "parasha_id": "ki-tisa",
    "fact_ids": ["kt008", "kt009", "kt010", "kt011"],
    "sefaria_ref": "Exodus 32:1-35"
  },
  "visual": {
    "marker_type": "icon",
    "icon": "golden-calf",
    "lane": "evento",
    "importance": 5
  }
}
```

### In Parasha Index Files

Keep the current lightweight fields, but allow optional cross-links:

```json
{
  "id": "ki-tisa",
  "timeline_event_ids": ["golden-calf", "second-tablets"],
  "primary_marker_ids": ["kt008", "kt014", "kt015"]
}
```

### In Fact Objects

Allow optional timeline link fields:

```json
{
  "id": "kt008",
  "timeline_event_id": "golden-calf",
  "marker_scope": "major",
  "visual": {
    "icon": "golden-calf",
    "lane": "evento",
    "importance": 5
  }
}
```

---

## Derived Marts from Book Indices

Each `data/parashiot/{book}/index.json` should be treated as a strategic
intermediate layer between the global timeline and full parasha files.

The app can derive runtime marts from book indices without creating separate
manual data files:

```text
data/timeline.json
data/milestones/chumash.json
data/parashiot/genesis/index.json
data/parashiot/exodus/index.json
        ↓
runtime parasha mart
        ↓
Timeline tab, Parasha drawer, Chumash atlas, future character views
```

Initial derived structures:

```js
{
  byId: {
    "lech-lecha": { /* parasha index row */ }
  },
  byCharacter: {
    "Avraham": ["lech-lecha", "vayera", "chayei-sarah"]
  },
  byEra: {
    "patriarcas": ["lech-lecha", "vayera", "chayei-sarah"]
  }
}
```

This keeps the book index as the source for:
- parasha bands
- character clusters
- book/era intersections
- navigation targets
- future visual atlas markers

`data/milestones/chumash.json` provides explicit book-level aggregators for
the atlas. It links to parashas and facts by ID instead of copying their full
content.

Later, when facts carry stable character IDs, a deeper character mart can link:

```text
character → book → parasha → fact → Sefaria ref
```

For now, the runtime mart starts from the existing `characters` arrays in each
book index.

---

## Interaction Behavior

### From Timeline to Parasha

When a user clicks a global timeline event:

1. If the event has `links.parasha_id`, open the parasha drawer for that book.
2. Highlight the linked parasha in the drawer.
3. If `fact_ids` exist, scroll to or expand those facts.
4. Offer actions:
   - open inline passage
   - open Pessukim reader
   - view related parashiot

### From Parasha Drawer to Timeline

When a user opens a parasha:

1. Show the parasha range on the local ruler.
2. Show related global timeline events.
3. Allow clicking a related event to jump to the Timeline tab.
4. Highlight the same era/event there.

### From Fact to Timeline

When a user opens a fact:

1. Show its global event link if present.
2. Show where it sits inside:
   - parasha
   - book
   - era
   - global AM timeline

This makes a fact both textual and historical.

---

## UI Implications

### Timeline Tab

The timeline tab should evolve from a static vertical list into an interactive
controller:

- eras as large bands
- key events as markers
- event click opens related parasha drawer or Pessukim chapter
- selected event state
- related parashiot shown in context

### Parasha Drawer

The drawer should show:

- local parasha ruler
- linked global events
- fact markers
- visual icons/images when available
- "ver na linha do tempo" action

### Chumash Visual Atlas

The Chumash Atlas uses `data/milestones/chumash.json` and reuses the same marker
model:

- global era
- book
- parasha
- fact
- visual marker

The atlas should not be a separate data universe.

---

## Implementation Order

1. Add IDs to `timeline.json.key_events[]`.
2. Add optional `links` object to selected key events.
3. Create a small pilot linking Genesis global events to Genesis parashiot:
   - Criação -> Bereshit
   - Dilúvio -> Noach
   - Avraham / Lech-Lecha -> Lech Lecha
4. Refactor drawer open functions to accept `{ bookKey, parashaId, factIds }`.
5. Make timeline event clicks open the drawer with the correct selection.
6. Add selected/highlight state to timeline and drawer.
7. Extend pilot to Exodus once drawer supports multiple books.
8. Only after the interaction model is stable, resume bulk parasha population.

---

## Guardrails

- Do not duplicate facts inside `timeline.json`.
- Timeline events are broad routing/overview markers, not replacements for
  parasha facts.
- Facts remain anchored to Sefaria refs.
- One global event can link to many facts.
- One parasha can link to many global events.
- If exact AM dating is uncertain, use an approximate marker and keep source
  text refs precise.
