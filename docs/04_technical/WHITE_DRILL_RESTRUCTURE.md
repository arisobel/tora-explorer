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
- navigation from the drill rail into Estrutura, Chumash, Genesis milestones,
  the Genesis parasha drawer, and Pessukim
- white drawer styling to match the new visual direction

## Data Principle

The drill hierarchy should not create duplicated content.

Milestones, timeline events, parasha summaries, facts, and visual markers should
cross-link through stable IDs:

```text
book_key -> milestone.id -> parasha_id -> fact_id -> sefaria_ref
```

## Next Design Iterations

- Replace the static Estrutura flow with a data-driven drill view.
- Make the Chumash Atlas the primary level-2/level-3 experience.
- Add a selected-state breadcrumb when a user enters a book, milestone, parasha,
  or fact.
- Make milestone cards show visual markers more prominently.
- Add character lanes as a parallel drill dimension.
- Make drawer-to-Pessukim navigation book-aware.

## Constraints

- Runtime remains static HTML/CSS/JS.
- JSON remains the public content format.
- Database-backed editing is deferred until authoring volume justifies it.
