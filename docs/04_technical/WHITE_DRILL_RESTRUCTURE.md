# White UI and Multi-Level Drill Strategy

## Goal

Move the product from a dark exploratory prototype to a white, atlas-like
learning interface with a clear drill-down hierarchy.

The visual direction should feel closer to a structured study wall, map, or
educational atlas than to a dashboard.

## Drill Hierarchy

The core navigation model is:

1. **Canonical Structure**
   - Torah Escrita
   - Torah Oral
   - Mikra
   - Talmud
   - Halacha

2. **Chumash / Book Level**
   - Bereshit
   - Shemot
   - Vayikra
   - Bamidbar
   - Devarim

3. **Milestone Level**
   - Strategic narrative aggregators
   - Stored in `data/milestones/chumash.json`
   - Links to parashiot and facts by ID
   - Timeline phases can expose related subject groups. The current runtime
     file is `data/timeline_groups.json`; the intended source-of-truth is the
     horizontal database model.

4. **Parasha Level**
   - Local parasha drawer
   - Historical ruler
   - Themes
   - Characters
   - Facts

5. **Fact / Pessukim Level**
   - Fact detail
   - Sefaria reference
   - Inline passage
   - Chapter navigation in the Pessukim tab

## Current Implementation

The first implementation adds:

- a light visual theme through global CSS tokens in `index.html`
- a 5-level drill rail on the Estrutura page
- Timeline phase expansion through `data/timeline_groups.json`
- navigation from the drill rail into Estrutura, Chumash, Genesis milestones,
  the Genesis parasha drawer, and Pessukim
- white drawer styling to match the new visual direction
- an Atlas 2D tab that renders a runtime semantic drill projection over
  `data/milestones/chumash.json` and `data/timeline_groups.json`
- Atlas 2D interaction rules: hover marks the candidate, scroll-up drills into
  that candidate, scroll-down moves back one level, and background grab/pan
  handles vertical navigation when content overflows
- a fixed bottom AM ruler in the Atlas 2D tab, visually analogous to the sticky
  top navigation, showing the current historical focus range

## Data Principle

The drill hierarchy should not create duplicated content.

Milestones, timeline events, parasha summaries, facts, and visual markers should
cross-link through stable IDs:

```text
book_key -> milestone.id -> parasha_id -> fact_id -> sefaria_ref
```

Timeline-specific groups currently use the same IDs:

```text
timeline_phase -> timeline_group -> book_key/parasha_id/fact_ids
```

This should be treated as a runtime projection, not a long-term data silo.

## Next Design Iterations

- Replace the static Estrutura flow with a data-driven drill view.
- Refine the Atlas 2D into the primary level-2/level-3 experience.
- Add a selected-state breadcrumb when a user enters a book, milestone, parasha,
  or fact.
- Make milestone cards show visual markers more prominently.
- Add character lanes as a parallel drill dimension.
- Make drawer-to-Pessukim navigation book-aware.

## Constraints

- Runtime remains static HTML/CSS/JS.
- JSON remains the public content format.
- SQLite may support local authoring and generated projections, but the public
  runtime remains static JSON.
