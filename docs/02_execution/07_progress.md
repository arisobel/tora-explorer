# Project Progress

## Current State
- **Phase:** Timeline/parasha interaction model + drawer generalization
- **Last update:** 2026-05-31
- **Reality check:** Documentation was reconciled with the actual repository state on 2026-05-31.

---

## Completed

- [x] `index.html` - full 5-tab SPA (Estrutura, Timeline, Mishna/Guemara, Chumash, Pessukim)
- [x] CSS design system with tokens, responsive layout, dark theme
- [x] Tab 1 (Estrutura): Written + Oral Torah visual map, flow diagram, book chips
- [x] Tab 2 (Linha do Tempo): Vertical timeline + oral-law horizontal bar
- [x] Tab 3 (Mishna & Guemara): Tanaim/Amoraim panels, academies, braitot
- [x] Tab 4 (Chumash): All 5 books with events + characters
- [x] Tab 5 (Pessukim): live Sefaria reader with parallel view, chapter nav, verse jump, and visible fetch errors
- [x] `data/timeline.json` - 14 eras, 16 key events
- [x] `data/SCHEMA.md` - parasha JSON schema documented
- [x] `data/parashiot/genesis/index.json` - all 12 Genesis parashiot metadata
- [x] `data/parashiot/genesis/01-bereshit.json` through `12-vayechi.json` - all Genesis parashiot populated
- [x] Genesis `facts_count` values verified against actual JSON `facts[]` lengths
- [x] Parasha drawer implemented for Genesis: slide-in panel, historical ruler, facts list, inline Sefaria passages, chapter navigation to Pessukim, Escape/overlay close
- [x] `data/parashiot/exodus/index.json` - all 11 Exodus parashiot metadata
- [x] `data/parashiot/exodus/01-shemot.json` through `08-tetzaveh.json` - first 8 Exodus parashiot populated
- [x] `data/parashiot/exodus/09-ki-tisa.json` - 15 facts
- [x] Exodus `facts_count` verified for existing files `01` through `09`
- [x] Content/visual strategy documented: keep JSON as runtime format, add optional icons/images, defer database until authoring needs justify it
- [x] CapRover deploy packaging added: `captain-definition`, `Dockerfile`, `scripts/build-caprover.ps1`, and `dist/` output folder
- [x] Production Sefaria CORS fixed with same-origin Nginx proxy at `/api/sefaria/`
- [x] Timeline/parasha cross-interaction strategy documented
- [x] `data/timeline.json.key_events[]` has stable `id` fields
- [x] Genesis pilot links timeline events to parashiot/facts (`creation`, `flood`, `avraham-lech-lecha`)
- [x] Runtime parasha mart derives `byId` and `byCharacter` from book `index.json`
- [x] Timeline pilot events open the parasha drawer with linked fact highlights
- [x] `drawerOpen()` accepts book/deep-link context: `{ bookKey, parashaId, factIds }`
- [x] `data/milestones/chumash.json` added as the Chumash Atlas milestone layer
- [x] Chumash tab renders a 5-book milestone atlas; Genesis/Exodus milestones can open the drawer
- [x] Estrutura tab chips for Bereshit and Shemot open their respective parasha drawers
- [x] White UI foundation added through global theme tokens
- [x] Estrutura page now has a 5-level drill rail
- [x] White UI / multi-level drill strategy documented

---

## In Progress

- [ ] Extend timeline links beyond the Genesis pilot
- [ ] Finish drawer behavior for books beyond Genesis

---

## Next Actions (Short Horizon)

1. Make drawer-to-Pessukim navigation book-aware instead of Genesis-only
2. Add selected-state breadcrumb across book, milestone, parasha, and fact levels
3. Validate milestone `fact_ids` in a repeatable script/check
4. Add selected/highlight state from drawer back to the Timeline tab
5. Show linked global timeline events inside the Parasha drawer
6. Extend timeline event links beyond the Genesis pilot
7. Add fallback/error messaging that distinguishes Sefaria failure from proxy/CORS failure

---

## Risks / Blockers

- Sefaria API access depends on a public external service.
- Local development may still use `corsproxy.io`; production uses the same-origin Nginx proxy.
- `data/parashiot/exodus/index.json` currently references 2 files that do not exist, so an Exodus drawer would 404 for Vayakhel and Pekudei until those files are created.
- Further parasha population is intentionally deprioritized until the timeline/parasha interaction model is stable.
- Git commands are blocked in this workspace by Git's `dubious ownership` safety check until `safe.directory` is configured.

---

## Technical Debt

- Drawer implementation is book-specific even though the data model is book-oriented.
- `ERA` styling in the drawer only defines Genesis-era labels (`pre-diluvio`, `pos-diluvio`, `patriarcas`); Exodus eras fall back incorrectly.
- Inline fact chapter detection currently matches `Genesis` refs only.
- `drawerGoToPessukim()` always selects `Genesis`.
- No validation script checks missing files, `facts_count` drift, Sefaria ref shape, or required schema fields.
- Timeline key events do not yet have stable IDs or routing metadata into parashiot/facts.
- Timeline tab and parasha drawer do not yet share selected/highlight state.
- Milestone validation is manual; no script checks broken milestone-to-fact links yet.
- No validation exists yet for visual asset paths, captions, or marker shape.
- No local content editor exists yet; JSON editing is still manual.
- CapRover package generation is local-only; deployment upload is still manual through CapRover.
- `ARCHITECTURE.md`, `DOMAIN_MODEL.md`, backlog, and known issues were reconciled, but future implementation must keep `07_progress.md` as the source of truth.
