# Character entity and biography model

## Status

Proposed data contract and UI baby-step. Shlomo is the first complete specimen.

## Purpose

A character is a reusable knowledge entity, not a label embedded in a timeline. The entity must connect identity, chronology, biography, canonical facts, textual sources, family, tribal affiliation, places and visual representation.

## Source discipline

Every field that may be disputed or inferred must carry provenance and confidence. The model distinguishes:

- `explicit`: stated directly by the Biblical text;
- `traditional`: supplied by an identified traditional source;
- `fact-derived`: derived from reviewed canonical facts;
- `narrative-interpretation`: editorial interpretation of a narrative arc;
- `editorial`: project terminology or summary;
- `unknown`: not established.

The project must not invent exact dates, tribal affiliation, kinship or personality characteristics merely to complete a visualization.

## Proposed entity structure

```json
{
  "id": "shlomo",
  "entity_type": "person",
  "names": {
    "primary": "Shlomo",
    "pt": "Salomão",
    "he": "שְׁלֹמֹה",
    "variants": ["Shelomo", "Solomon"]
  },
  "roles": ["king", "sage", "temple-builder"],
  "people_affiliation": {
    "people": "israel",
    "tribe_id": "judah",
    "classification": "traditional",
    "evidence": []
  },
  "timeline": {
    "birth": { "am": null, "precision": "unknown", "evidence": [] },
    "death": { "am": null, "precision": "unknown", "evidence": [] },
    "active_period": {
      "am_start": null,
      "am_end": null,
      "precision": "fact-derived",
      "evidence": []
    }
  },
  "biography": {
    "short": "",
    "sections": [
      {
        "id": "reign",
        "title": "Reign",
        "summary": "",
        "fact_ids": []
      }
    ]
  },
  "source_ranges": [],
  "relationships": [],
  "characterization": [],
  "places": [],
  "visual": {
    "icon_asset": "assets/icons/crown.svg",
    "portrait_asset": null,
    "symbolic_role": "king",
    "color": "#c9a84c",
    "alt": "Crown symbol associated with the reign of Shlomo"
  }
}
```

## Tribal affiliation

Tribal affiliation is optional because it is not applicable or securely known for every character.

Recommended structure:

```json
{
  "people_affiliation": {
    "people": "israel",
    "tribe_id": "judah",
    "classification": "explicit",
    "evidence": ["Biblical reference or reviewed source"],
    "note": null
  }
}
```

Rules:

- use stable IDs from a future tribe registry;
- do not use a free-text tribe name as the canonical relation;
- allow `null` when not applicable or unknown;
- distinguish tribal descent from political kingdom;
- support Levi-related distinctions later, such as priestly or Levitical lineage;
- allow multiple or disputed affiliations only as separately sourced assertions.

A person's tribe must not be inferred only from residence, political allegiance or presence in a kingdom.

## Relationships and genealogy

Relationships are directed edges between stable character IDs.

```json
{
  "type": "parent",
  "character_id": "david",
  "classification": "explicit",
  "evidence": ["II Samuel 12:24"]
}
```

Initial relationship types:

- `parent`;
- `child`;
- `spouse`;
- `sibling`.

Ancestors and descendants should normally be computed from direct relations instead of duplicated.

## Biography and canonical facts

Biography sections reference canonical `fact_ids`. They do not copy fact prose. A section may add a concise editorial synthesis, but the underlying event remains canonical.

This allows one fact to appear in:

- the global timeline;
- a narrative unit;
- several character biographies;
- a place history;
- a relationship context.

## Source appearances

A character may have:

- broad source ranges;
- explicit mentions;
- active participation in facts;
- later references or retrospective mentions.

```json
{
  "book_key": "kings",
  "ref_start": "I Kings 1:1",
  "ref_end": "I Kings 11:43",
  "relation": "primary-narrative",
  "classification": "explicit"
}
```

## Characterization, not fixed personality labels

The system should avoid unsupported fixed labels such as `ambitious` or `weak`. Use contextual narrative characterization with evidence:

```json
{
  "trait": "wisdom",
  "classification": "explicit",
  "context": "Early reign",
  "evidence": ["I Kings 3:12"],
  "note": "Explicitly attributed in the narrative."
}
```

A characterization is:

- contextual, not necessarily permanent;
- evidence-based;
- attributable to a source or editorial interpretation;
- visually secondary to canonical facts.

## Visual model

Separate symbolic navigation assets from editorial portraits:

- `icon_asset`: small SVG used in timeline and compact UI;
- `portrait_asset`: optional larger illustration used in the biography;
- `symbolic_role`: semantic role communicated by the icon;
- `alt`: accessible description.

Portraits must not be presented as historically verified physical likenesses.

## Storage strategy

Keep the current index lightweight and add one file per developed character:

```text
data/entities/
  characters.json
  tribes.json
  characters/
    shlomo.json
    yeravam.json
    rechavam.json
```

The index supports fast timeline rendering. Individual files hold complete biographies.

## Baby-step CH-H1 — Shlomo biography specimen

Deliver:

- [ ] create `data/entities/tribes.json` with the minimal stable tribe registry;
- [ ] expand the Shlomo index entry with stable summary fields;
- [ ] create `data/entities/characters/shlomo.json`;
- [ ] add identity and name variants;
- [ ] add roles;
- [ ] add tribal affiliation with classification and evidence;
- [ ] add active-period chronology without invented exact dates;
- [ ] add a short biography divided into fact-linked sections;
- [ ] add primary source ranges;
- [ ] add direct parents, relevant spouse and child relations;
- [ ] add symbolic SVG metadata;
- [ ] add up to three evidence-based narrative characterizations;
- [ ] render a read-only biography drawer opened from the timeline.

## Acceptance criteria

1. The character bio opens from Shlomo's timeline representation.
2. Every biography section links to canonical facts or explicit references.
3. Tribal affiliation shows its evidence classification.
4. Missing birth/death dates remain visibly unknown.
5. Relationships use stable character IDs.
6. Characterization never appears without classification and evidence.
7. The timeline loads only the compact index until the biography is requested.

## Deferred work

- complete genealogy tree renderer;
- complete tribe registry and tribe pages;
- automatic reference extraction;
- editorial workflow for competing traditions;
- portraits for every character;
- relationship inference;
- full multilingual biography content.
