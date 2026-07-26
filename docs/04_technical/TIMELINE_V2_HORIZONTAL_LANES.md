# Timeline v2 — synchronized horizontal lanes

## Status

Proposed next baby-step after the Melachim drill-down pilot.

## Problem statement

The current pilot validates the hierarchy, but phase, group, narrative unit, character and fact are still rendered as variants of the same card. These objects have different temporal semantics and require different visual grammars.

The next experiment must preserve the existing hierarchy while replacing the detail level with a shared horizontal time canvas.

## Design principle

All tracks use the same horizontal coordinate system and move together. Each entity type receives a distinct representation.

| Layer | Temporal semantics | Visual representation |
|---|---|---|
| Historical phase | Long interval | Background band |
| Group | Interval inside a phase | Wide labeled bar |
| Narrative unit | Bounded narrative interval | Continuous block |
| Character | Presence or activity interval | Avatar plus activity line |
| Fact | Point or short event | Icon marker on the axis |
| Place, later | Spatial context attached to facts | Map/location marker |

## Shared time axis

The detail view must provide:

- one AM axis shared by every lane;
- synchronized horizontal scrolling;
- sticky time ruler;
- sticky lane labels;
- drag-to-pan;
- previous/next controls;
- zoom centered on the current focus;
- a command to recenter the selected interval;
- visible treatment of chronological uncertainty.

The first implementation does not require a continuous historical scale for every event. Facts with relative chronology may use their reviewed `position_in_unit` inside the selected unit.

## Interaction contract

### Fact selection

Selecting a fact:

- opens the canonical fact detail;
- highlights linked characters;
- preserves the current horizontal position;
- exposes source references.

### Character selection

Selecting a character:

- highlights the character activity line;
- highlights facts connected through `character_ids`;
- dims unrelated facts and characters;
- opens a character bio panel;
- preserves the selected historical context.

### Uncertain chronology

Uncertainty must be represented rather than hidden:

- solid line: reviewed interval;
- dashed line: approximate interval;
- faded boundary: open or uncertain start/end;
- relative position: derived from sequence inside a narrative unit;
- unknown: present in the contextual lane without an invented coordinate.

## Baby-step TL-H1 — Melachim horizontal canvas

### Scope

Replace only depth 4 of the current Melachim pilot.

Deliver:

- [ ] sticky AM ruler for the selected unit;
- [ ] synchronized scroll container shared by all lanes;
- [ ] narrative unit as one continuous bar;
- [ ] characters as avatars plus activity lines;
- [ ] facts as icon markers positioned by `position_in_unit`;
- [ ] selection linkage between facts and characters;
- [ ] lateral previous/next navigation;
- [ ] fact detail panel retained;
- [ ] responsive fallback for narrow screens;
- [ ] explicit styling for approximate chronology.

### Acceptance criteria

1. Scrolling any temporal track moves every track and the ruler together.
2. Facts keep their relative order and occupy distinct positions.
3. Characters no longer appear as fact-like cards.
4. Selecting Shlomo highlights facts linked to `shlomo`.
5. Selecting `kg023` highlights Shlomo, Achiyah and Yeravam.
6. No exact date is invented when only relative chronology exists.
7. Depths 1–3 continue to work without regression.

## Deferred work

- complete timeline minimap;
- map or globe synchronization;
- automatic collision layout for large datasets;
- virtualization for hundreds of facts;
- conversion between AM and BCE/CE;
- migration of every Biblical book;
- advanced relationship visualization.

## Data requirements exposed by this baby-step

Facts already provide `sequence` and `position_in_unit`. Character activity lines require an optional interval:

```json
{
  "timeline": {
    "am_start": 2935,
    "am_end": 2964,
    "precision": "approximate",
    "start_open": false,
    "end_open": true
  }
}
```

When no reviewed interval exists, the renderer must derive contextual presence from linked facts and mark it as `fact-derived`.
