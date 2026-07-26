# Timeline v2 — Melachim pilot

## Purpose

Create the smallest complete vertical slice for the future multi-track timeline:

```
Historical phase -> Group -> Narrative unit -> Fact
```

Characters are a transversal layer linked to units and facts. The pilot is intentionally restricted to **Monarchy and First Temple -> Kingdom split -> Decline of Shlomo and division of the kingdom**.

## Scope

- Preserve AM as the canonical chronology.
- Reuse canonical fact text and Sefaria references from the existing Kings unit JSON.
- Add an experimental projection at `data/timeline_v2/melachim-pilot.json`.
- Add stable character/entity IDs at `data/entities/characters.json`.
- Support four depth levels: phase, group, unit and fact.
- Define three initial tracks: units, facts and characters.
- Prepare one renderer contract for two presentations:
  - compact footer in Atlas 2D;
  - expanded view in the Timeline tab.

## Non-goals

- No replacement of the existing Atlas footer in this PR.
- No map or globe.
- No complete BCE/CE conversion.
- No migration of every canonical fact.
- No invented exact dates for events or characters.
- No duplicated fact prose in the projection.

## Data contract

The pilot projection references canonical files instead of copying their content. Additional metadata is limited to:

- hierarchy references;
- stable character IDs;
- chronology precision;
- sequence and relative position inside a narrative unit;
- display importance and minimum zoom.

A fact with no reviewed exact AM year uses:

```json
{
  "chronology": {
    "precision": "relative",
    "sequence": 3,
    "position_in_unit": 0.333
  }
}
```

## Intended UI behavior

| Depth | Timeline | Main Atlas context |
|---|---|---|
| Phase | Monarchy and First Temple | Historical phase |
| Group | Kingdom split | Group cards |
| Unit | Decline of Shlomo and division | Narrative unit |
| Fact | Selected major events | Fact details/drawer |

Clicking drills into a target. Back returns one level. Scroll-driven drill may remain an optional shortcut, but is not part of the pilot acceptance criteria.

## Acceptance criteria for the next implementation PR

1. A shared renderer reads the pilot projection without hard-coded Melachim labels.
2. The user can navigate phase -> group -> unit -> fact by click.
3. Back returns exactly one level.
4. Facts and characters can be independently shown or hidden.
5. Selecting a fact opens the existing drawer and correct Sefaria context.
6. Compact and expanded modes share state and data.
7. No existing Atlas, Timeline, drawer or Pessukim behavior regresses.
8. Approximate/relative chronology is visually distinguishable from exact ranges.

## Files

- `data/timeline_v2/melachim-pilot.json`: experimental timeline projection.
- `data/entities/characters.json`: initial identity registry for the pilot.
- `docs/04_technical/TIMELINE_V2_MELACHIM_PILOT.md`: this contract.

## Visual-first requirement

Visual identity is part of the navigation contract, not optional decoration.

- Historical phases declare a dominant color and semantic icon.
- Groups declare an icon, caption, importance and accent color.
- Narrative units inherit their canonical `visual` block by default.
- Facts declare an icon fallback and may later use a curated image.
- Characters declare an icon fallback and may later receive a portrait.
- Every referenced asset requires a caption.
- Missing images fall back to icons; missing icons fall back to color and label.

The pilot reuses existing repository assets such as `crown.svg`, `sword.svg`, `scroll.svg` and other semantic icons. Rich images remain external files under `assets/`, never embedded in JSON.
