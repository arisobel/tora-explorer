# General Drill-Down Architecture

## Purpose

The project needs a general drill-down model that works from multiple entry
points:

- Estrutura Geral
- Linha do Tempo
- Chumash Atlas
- Parasha drawer
- future character/theme views

No screen should own the data. Screens should be projections over the same
domain graph.

## Core Idea

The data model is horizontal:

```text
domain data -> reusable nodes -> typed relations -> view projections
```

The UI model is vertical:

```text
entry point -> drill level -> deeper drill level -> source text
```

This allows different screens to start from different dimensions while reusing
the same facts, milestones, characters, themes, visual markers, and source refs.

## Two Primary Entry Points

### Entry Point 1: Estrutura Geral

The structure view starts from canonical organization:

```text
Estrutura Geral
  -> Tradição / Corpus
    -> Livro / Ordem / Tratado / Era
      -> Milestone / Agrupador
        -> Parasha / Tema / Personagem
          -> Fato
            -> Pessukim / Fonte
```

Examples:

```text
Torah Escrita
  -> Chumash
    -> Bereshit
      -> Criação
        -> Bereshit
          -> Deus cria céu e terra
            -> Genesis 1:1
```

```text
Torah Oral
  -> Mishna
    -> Moed
      -> Shabat
        -> future sugya/topic drill
```

### Entry Point 2: Linha do Tempo

The timeline starts from historical placement:

```text
Linha do Tempo
  -> Era / Fase
    -> Milestone / Agrupador
      -> Parasha / Personagem / Tema
        -> Fato
          -> Pessukim / Fonte
```

Examples:

```text
Pré-Dilúvio
  -> Ordem da criação
    -> Bereshit
      -> Dias da criação
        -> Genesis 1:1-2:3
```

```text
Saída do Egito / Sinai
  -> Pessach e saída
    -> Bo
      -> Korban Pessach / saída do Egito
        -> Exodus 12
```

## Drill Levels

The same level names should be reused across screens.

| Level | Name | Meaning | Examples |
|---|---|---|---|
| 1 | Entry | User's starting lens | Estrutura, Timeline, Chumash, Personagens |
| 2 | Macro Container | Large canonical or historical grouping | Torah Escrita, Chumash, Patriarcas, Sinai |
| 3 | Aggregator | Strategic narrative or conceptual grouping | Criação, Dilúvio, Chamado de Avraham, Sinai |
| 4 | Local Unit | Concrete textual/content unit | Parasha, chapter, tractate, topic |
| 5 | Atomic Unit | Smallest authored meaning unit | Fact, law topic, teaching |
| 6 | Source | Primary source reference | Genesis 1:1, Exodus 12:1-14 |
| 7 | Visual Layer | Sensory/contextual marker | icon, image, map, character lane |

## Data Ownership

Data belongs to the domain, not to UI screens.

Wrong direction:

```text
Timeline owns timeline_groups
Chumash owns milestones
Parasha owns facts only locally
Character view later duplicates facts
```

Preferred direction:

```text
nodes own content units
node_edges own relationships
views project the same graph for different screens
```

## Node Types

Initial node types:

- `tradition`
- `corpus`
- `book`
- `era`
- `timeline_phase`
- `milestone`
- `parasha`
- `fact`
- `character`
- `theme`
- `place`
- `source_ref`
- `visual_marker`
- `asset`

Future node types:

- `mishna_order`
- `tractate`
- `sugya`
- `halacha_topic`
- `commentary`

## Relation Types

Initial relation types:

- `contains`
- `aggregates`
- `appears_in`
- `tagged_with`
- `located_in`
- `precedes`
- `related_to`
- `opens`
- `has_source`
- `has_visual`

Examples:

```text
book:genesis contains parasha:bereshit
parasha:bereshit contains fact:b001
milestone:gen-creation aggregates fact:b001
timeline_phase:early-world aggregates milestone:gen-creation
character:adam appears_in fact:b001
theme:criacao tagged_with fact:b001
fact:b001 has_source source_ref:genesis-1-1
fact:b001 has_visual visual_marker:creation-light
```

## View Projections

A view projection defines which nodes appear in a screen and how they are
arranged. It should not duplicate the content.

Examples:

### Structure Projection

```text
view:structure
  tradition:written-torah
    corpus:chumash
      book:genesis
      book:exodus
```

### Timeline Projection

```text
view:timeline
  timeline_phase:early-world
    milestone:gen-creation
    milestone:gen-eden-fall
    milestone:gen-cain-abel
```

### Chumash Atlas Projection

```text
view:chumash-atlas
  book:genesis
    milestone:gen-creation
    milestone:gen-flood
    milestone:gen-avraham-call
```

### Character Projection

```text
view:character
  character:avraham
    fact:ll001
    milestone:gen-avraham-call
    parasha:lech-lecha
```

## Runtime Strategy

Do not force the public app to become dynamic immediately.

Recommended runtime path:

```text
SQLite/Postgres authoring database
  -> export scripts
    -> static JSON views
      -> current static frontend
```

This gives the project a better data model without immediately adding backend
complexity to CapRover.

## Initial Export Targets

The database should eventually export:

- `data/views/structure.json`
- `data/views/timeline.json`
- `data/views/chumash-atlas.json`
- `data/views/characters.json`
- `data/parashiot/{book}/index.json`
- `data/parashiot/{book}/{parasha}.json`
- `data/milestones/chumash.json` during transition

## Migration Principle

The migration should be incremental.

1. Keep current JSON runtime.
2. Create database schema.
3. Import existing JSON into nodes and edges.
4. Export the same JSON files back out.
5. Verify exported JSON produces the same app behavior.
6. Replace view-specific hand-authored JSON with generated view JSON.
7. Add editor/admin only after the data model stabilizes.

## Short-Term Consequence

`data/timeline_groups.json` can remain as a temporary runtime file, but it
should not be treated as the long-term data owner.

Its contents should later become:

```text
timeline_phase nodes
milestone nodes
node_edges with relation_type = aggregates
view_projections for view_key = timeline
```

## Open Questions

- Should the first authoring database be SQLite or PostgreSQL?
- Should IDs be UUIDs, stable slugs, or both?
- Should Hebrew labels be one field or a separate localization table?
- Should Sefaria refs be nodes or attached records?
- How much view-specific layout metadata belongs in `view_projections`?

## Current Recommendation

Start with SQLite, stable slugs, and export scripts.

Use:

- `nodes`
- `node_edges`
- `source_refs`
- `time_ranges`
- `visual_markers`
- `view_projections`

This gives enough structure for general drill-down without prematurely building
a full backend.
