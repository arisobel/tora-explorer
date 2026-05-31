# Decisions Log

---

## 2026-05-31 — Zero-dependency stack

**Context:** Project is a personal/educational tool. Needs to be shareable as a plain file with no server.

**Decision:** Pure HTML/CSS/JS, no npm, no framework, single `index.html`.

**Impact:** No build step, instant open in browser. Constrains tooling (no TypeScript, no components library). All JS is inline in the HTML.

---

## 2026-05-31 — Sefaria as sole verse source

**Context:** Need a free, authoritative source for Hebrew + English text.

**Decision:** Use Sefaria public API with no auth token. The current implementation uses `sefaria.org/api/v3/texts/{ref}`.

**Impact:** No API key needed. Dependent on Sefaria uptime and CORS policy. Verse text is always current/authoritative.

---

## 2026-05-31 — Anno Mundi as canonical timeline unit

**Context:** Jewish tradition uses its own year count (from Creation). Gregorian BCE/CE dates are approximate and debated.

**Decision:** All timeline positions use Anno Mundi (AM). Sefaria refs use chapter:verse only (not dates).

**Impact:** position_pct formula: `am_start / 5785 * 100`. Consistent across all JSON files. No BCE/CE conversion needed in the UI.

---

## 2026-05-31 — Parasha JSON split: index + full

**Context:** Loading all 54 parashiot upfront would be slow. Drawer only needs metadata to render the list.

**Decision:** Two-level data: `index.json` (lightweight, all parashiot per book) + `XX-name.json` (full data including facts, loaded on demand).

**Impact:** Drawer renders instantly from index. Full JSON only fetched when user expands a specific parasha.

---

## 2026-05-31 — facts_count kept in sync manually

**Context:** No build-time validation exists.

**Decision:** `index.json.parashiot[n].facts_count` must be updated manually when facts are added to a parasha JSON.

**Impact:** Risk of drift. Mitigation: schema doc notes this requirement. Future improvement could add a validation script.

---

## 2026-05-31 — Documentation reconciled to repository reality

**Context:** Several docs still described an older state where Genesis data and the parasha drawer were incomplete, while the repository now contains all 12 Genesis files, a working Genesis drawer, and partial Exodus data.

**Decision:** Treat `docs/02_execution/07_progress.md` as the operational source of truth for current state, keep `09_backlog.md` focused on next work, and keep `KNOWN_ISSUES.md` limited to verified issues.

**Impact:** Next iterations should start from the real blockers: missing Exodus files, Genesis-only drawer assumptions, book-aware Pessukim navigation, and validation tooling.

---

## 2026-05-31 — JSON-first visual content strategy

**Context:** The project needs richer drill-down views and sensory visual markers, including icons or images for narrative facts. A database could support editing, but would add backend, deployment, authentication, migrations, and storage complexity before those needs are proven.

**Decision:** Keep static JSON as the public app runtime format. Add optional visual metadata to facts, parashiot, books, and timeline events. Store images/icons as separate static files under a future `assets/` folder and reference them from JSON. Defer database usage until a real authoring workflow requires it.

**Impact:** The next implementation can add visual markers incrementally without changing hosting architecture. A future local `editor.html` / `admin.html` can edit or export JSON through forms. If a database is introduced later, it should act as an authoring backend that exports the same JSON format consumed by the static app.

---

## 2026-05-31 — CapRover tar packaging

**Context:** The project needs a repeatable way to deploy the static app to CapRover while preserving the zero-build runtime.

**Decision:** Add a CapRover `captain-definition`, a minimal Nginx `Dockerfile`, and a PowerShell packaging script that creates timestamped `.tar` files under `dist/`.

**Impact:** Deployment artifacts are generated locally with `scripts/build-caprover.ps1`. The script includes only runtime files and keeps the 5 newest CapRover tar packages in `dist/`.

---

## 2026-05-31 — Same-origin Sefaria proxy for production

**Context:** `corsproxy.io` free usage is limited to localhost/development origins, so the deployed CapRover app could not fetch Sefaria passages in production.

**Decision:** Add an Nginx reverse proxy at `/api/sefaria/` and update browser code to call that same-origin path in production. Local `file://` and localhost usage can still fall back to `corsproxy.io`.

**Impact:** Production Sefaria calls no longer depend on a public CORS proxy. CapRover packages now include `nginx.conf`, and the Docker image uses it as the default Nginx site config.

---

## 2026-05-31 — Prioritize timeline/parasha cross-interaction

**Context:** Continuing to populate parasha JSON files adds content, but the Timeline tab and parasha drawer currently represent overlapping historical dimensions without a shared interaction model.

**Decision:** Deprioritize further bulk parasha population temporarily. Prioritize stable timeline event IDs, routing links from timeline events to parashiot/facts, and bidirectional highlight/navigation between the Timeline tab and Parasha drawer.

**Impact:** The next development cycle should focus on structure and cross-interaction. Remaining Exodus files (`10-vayakhel.json`, `11-pekudei.json`) move to long-term/backlog until the interaction model is stable.

---

## 2026-05-31 — Runtime marts from book indices

**Context:** Book index files already contain strategic mid-level data: parasha ranges, eras, characters, summaries, and target JSON paths. This is the natural bridge between global timeline events and full fact-level parasha files.

**Decision:** Use each `data/parashiot/{book}/index.json` as the source for runtime marts, starting with `byId` and `byCharacter`. Do not create separate manual mart files until a real need appears.

**Impact:** Timeline and future character interactions can use book indices as a stable intermediate layer. This avoids duplicating parasha metadata across timeline, drawer, and future atlas views.

---

## 2026-05-31 — Chumash milestones as drill-down aggregators

**Context:** Theme chips inside parasha drawers are useful, but the project also needs larger narrative anchors for a 5-book overview, similar to a visual atlas. These anchors should connect books, parashiot, facts, characters, and future icons/images.

**Decision:** Add `data/milestones/chumash.json` as a milestone layer. Milestones aggregate existing parashiot and facts by ID and should not duplicate detailed fact content.

**Impact:** The Chumash tab can render a 5-book atlas and open the parasha drawer from milestone cards. This creates another drill level: book → milestone → parasha/theme → fact → pessukim.

---

## 2026-05-31 — White atlas UI as default presentation

**Context:** The dark prototype made the app feel more like a dashboard than a visual Torah atlas. The next product direction requires clearer scanability, visual markers, book lanes, and multi-level drill-down.

**Decision:** Move the default presentation to a white, atlas-like study surface. Treat this as a navigation restructure, not only a palette change.

**Impact:** New UI work should use the light CSS tokens as the default. Remaining dark-theme assumptions in inline styles should be removed incrementally. Drill levels should remain explicit: structure → book → milestone → parasha → fact/pessukim.

---

## 2026-05-31 — Timeline groups as intermediate drill-down

**Context:** Timeline phases were too coarse and clicking them jumped directly to parasha detail. The product needs an intermediate level for large structures of events and subject aggregators.

**Decision:** Add `data/timeline_groups.json` as the Timeline drill-down layer. Timeline phases can expand into subject/milestone cards. Cards link by stable IDs to books, milestones, parashiot, and facts.

**Impact:** The Timeline now supports phase → group → parasha/facts. Future timeline work should add groups to JSON rather than hard-coding additional cards in HTML.

---

## 2026-05-31 — Horizontal database model for drill-down data

**Context:** Timeline groups, Chumash milestones, parasha facts, themes, characters, and future visual markers are cross-cutting dimensions. Keeping separate JSON files per view risks vertical data silos.

**Decision:** Define a database authoring/source-of-truth model based on reusable `nodes` and typed `node_edges`. Timeline, Chumash Atlas, character views, and parasha drawers should become projections over the same graph. Static JSON remains the public runtime format until a live API is justified.

**Impact:** `data/timeline_groups.json` is transitional. The next data architecture step is to import current JSON into the node/edge model and export the existing runtime JSON shapes from the database.

---

## 2026-05-31 — General drill-down is screen-agnostic

**Context:** The product needs drill-down from both Estrutura Geral and Linha do Tempo, and later from Chumash, characters, themes, and visual markers.

**Decision:** Define a screen-agnostic drill-down architecture. Estrutura and Timeline are entry points over the same graph of nodes and typed relations. No UI screen owns the content.

**Impact:** Future implementation should avoid creating more view-specific source files unless they are generated runtime projections. New domain content should be modeled as reusable nodes and edges first.

---

## 2026-05-31 — SQLite first for authoring database

**Context:** The project needs to start structuring a database for horizontal drill-down data, but the public app should remain static and JSON-driven for CapRover deployment.

**Decision:** Use SQLite as the first authoring/source-of-truth database. Version the schema as SQL migrations under `db/migrations/` and create local ignored database files with `scripts/init-sqlite.ps1`.

**Impact:** The runtime app is unchanged. The next work is to import current JSON into SQLite and then export equivalent runtime JSON from the database.

---

## 2026-05-31 — Current JSON imported into SQLite

**Context:** The SQLite authoring schema exists, but needed a first import from the current JSON runtime files.

**Decision:** Add `scripts/import-json-to-sqlite.ps1` to load timeline, milestones, parasha indexes, parasha facts, source refs, time ranges, visual markers, and view projections into SQLite.

**Impact:** The database can now be rebuilt from current JSON. The next database task is export back to runtime JSON; the next content task is to resume populating missing parasha JSON files.

---

## 2026-05-31 — Vayikra JSON generated and synced to SQLite

**Context:** The content backlog resumed with Vayikra after the SQLite import path was created.

**Decision:** Add a complete first pass for `data/parashiot/leviticus/`, including the book `index.json` and all 10 parasha JSON files from Vayikra through Bechukotai.

**Impact:** Vayikra now participates in the JSON source set and in the SQLite node/edge model. Before exposing it fully in the UI, the drawer still needs book-aware polish and the Vayikra facts should receive a focused content review.
