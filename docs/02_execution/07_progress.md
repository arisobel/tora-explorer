# Project Progress

## Current State
- **Phase:** Timeline/parasha interaction model + drawer generalization
- **Last update:** 2026-06-01
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
- [x] `data/parashiot/leviticus/index.json` - all 10 Vayikra parashiot metadata
- [x] `data/parashiot/leviticus/01-vayikra.json` through `10-bechukotai.json` - all Vayikra parashiot populated with 8 facts each
- [x] Vayikra `facts_count` values verified against actual JSON `facts[]` lengths
- [x] SQLite import re-run after Vayikra JSON generation
- [x] `data/parashiot/numbers/index.json` - all 10 Bamidbar parashiot metadata
- [x] `data/parashiot/numbers/01-bamidbar.json` through `10-masei.json` - all Bamidbar parashiot populated with 8 facts each
- [x] Bamidbar `facts_count` values verified against actual JSON `facts[]` lengths
- [x] SQLite import re-run after Bamidbar JSON generation
- [x] `data/parashiot/deuteronomy/index.json` - all 11 Devarim parashiot metadata
- [x] `data/parashiot/deuteronomy/01-devarim.json` through `11-vezot-haberakhah.json` - all Devarim parashiot populated with 8 facts each
- [x] Devarim `facts_count` values verified against actual JSON `facts[]` lengths
- [x] SQLite import re-run after Devarim JSON generation
- [x] `data/nach/joshua/index.json` - Yehoshua/Joshua metadata and 8 narrative-unit summaries
- [x] `data/nach/joshua/01-entry-into-canaan.json` through `08-farewell-covenant-shechem.json` - Joshua first pass with 64 facts
- [x] Joshua `facts_count` values verified against actual JSON `facts[]` lengths
- [x] `scripts/import-json-to-sqlite.ps1` imports `data/nach/*` books, narrative units, and facts
- [x] SQLite import re-run after Joshua JSON generation
- [x] `data/nach/judges/index.json` - Shoftim/Judges metadata and 7 narrative-unit summaries
- [x] `data/nach/judges/01-transition-and-first-judges.json` through `07-gibeah-civil-war.json` - Judges first pass with 56 facts
- [x] Judges `facts_count` values verified against actual JSON `facts[]` lengths
- [x] SQLite import re-run after Judges JSON generation
- [x] `data/nach/samuel/index.json` - Shemuel/Samuel I-II metadata and 8 narrative-unit summaries
- [x] `data/nach/samuel/01-samuel-birth-ark-crisis.json` through `08-david-restoration-final-appendix.json` - Samuel first pass with 64 facts
- [x] Samuel `facts_count` values verified against actual JSON `facts[]` lengths
- [x] SQLite import re-run after Samuel JSON generation
- [x] Estrutura tab chips for Yehoshua and Shoftim open the Nach unit drawer
- [x] Estrutura tab chip for Shmuel I/II opens the Nach unit drawer
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
- [x] `data/timeline_groups.json` added for Timeline phase drill-down
- [x] Timeline phases can expand into subject/milestone groups that open the parasha drawer
- [x] Horizontal database drill model documented with draft SQL schema
- [x] General screen-agnostic drill-down architecture documented
- [x] SQLite v0 authoring schema added under `db/migrations/`
- [x] `scripts/init-sqlite.ps1` creates local `db/tora-explorer.sqlite`
- [x] `scripts/import-json-to-sqlite.ps1` imports current JSON into SQLite
- [x] First JSON import validated with `PRAGMA foreign_key_check`
- [x] SQLite import re-run after Devarim JSON addition — counts: 2025 nodes, 3952 node_edges, 632 source_refs, 93 time_ranges, 67 visual_markers, 698 view_projections, 76 skipped_edges (2026-06-01)
- [x] `drawerGoToPessukim()` made book-aware — receives `bookKey`, resolves Sefaria name, sets correct book in Pessukim selector (2026-06-01)
- [x] `docs/04_technical/DATABASE_EXPORT_SPEC.md` — new doc specifying the SQLite→JSON export pipeline, field-by-field mapping, lossy fields, and new view file shapes (2026-06-01)
- [x] `GENERAL_DRILL_DOWN_ARCHITECTURE.md` open questions closed with resolved decisions
- [x] `ARCHITECTURE.md`, `DOMAIN_MODEL.md`, `db/README.md` updated to reflect current state

---

## In Progress

- [ ] Extend timeline links beyond the Genesis pilot
- [ ] Finish drawer behavior for books beyond Genesis (ERA colors, missing Exodus files)

---

## Next Actions (Short Horizon)

1. Resume parasha JSON population, starting with remaining Exodus files (`10-vayakhel.json`, `11-pekudei.json`)
2. Decide next Nach book after Samuel (`Malachim I/II` is the natural continuation)
3. Define generated `data/views/structure.json` and `data/views/timeline.json`
4. Create export script from SQLite back to runtime JSON
5. Expose Vayikra, Bamidbar, Devarim, Joshua, Judges, and Samuel only after UI review
6. Add selected-state breadcrumb across book, milestone, timeline group, parasha/unit, and fact levels
7. Validate milestone, timeline group, parasha, and Nach unit links in a repeatable script/check
8. Add selected/highlight state from drawer back to the Timeline tab

---

## Risks / Blockers

- Sefaria API access depends on a public external service.
- Local development may still use `corsproxy.io`; production uses the same-origin Nginx proxy.
- `data/parashiot/exodus/index.json` currently references 2 files that do not exist, so an Exodus drawer would 404 for Vayakhel and Pekudei until those files are created.
- Chumash data is complete except for the two remaining Exodus files; Nach data has Joshua, Judges, and Samuel first-pass sets. The UI still needs book/unit-aware drawer refinements before all books can be exposed safely.
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
