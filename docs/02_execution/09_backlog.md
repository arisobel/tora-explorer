# Backlog

## Immediate (Next Cycle)

- [ ] Create `data/parashiot/exodus/10-vayakhel.json` and `11-pekudei.json` (drawer 404s for these)
- [ ] Generate Devarim JSON set (`data/parashiot/deuteronomy/index.json` + 11 individual JSONs)
- [ ] Add Exodus era labels/styles to the drawer `ERA` map (`egito`, `saida-egito`) — currently falls back to `patriarcas` color
- [ ] Make fact chapter parsing work for any Chumash book (regex currently correct, but `drawerGoToPessukim` now fixed)
- [ ] Review and refine Vayikra fact wording and refs before exposing drawer for that book
- [ ] Review and refine Bamidbar fact wording and refs before exposing drawer for that book
- [ ] Add selected-state breadcrumb across structure, book, milestone, parasha, and fact
- [ ] Extend timeline links beyond the Genesis pilot (`brit-milah`, `yitzchak-born`, `yaakov-born`, `yosef-born`, `yaakov-egypt`)
- [ ] Add repeatable validation for `data/milestones/chumash.json` and `data/timeline_groups.json` parasha/fact links
- [ ] Add selected/highlight state from Parasha drawer back to Timeline tab
- [ ] Show linked global timeline events inside the Parasha drawer
- [ ] Show linked timeline groups inside the Parasha drawer

## Recently Completed

- [x] **drawer→Pessukim book-aware** — `drawerGoToPessukim(chapterNum, bookKey)` now resolves Sefaria book name from bookKey; button in `_drawerRenderParasha` passes `bookKey` captured at render time (2026-06-01)

## Short Term

- [ ] Create export script from database draft schema back to runtime JSON
- [ ] Replace hand-authored `data/timeline_groups.json` with a generated timeline projection
- [ ] Add "ver na linha do tempo" action from parasha/fact views
- [ ] Remove remaining dark-theme assumptions from inline styles
- [ ] Add a fallback/error message that distinguishes Sefaria failure from proxy/CORS failure
- [ ] Add a smoke-check step after CapRover package generation to verify the tar contents
- [ ] Extend the parasha schema with optional `visual` metadata for facts, parashiot, books, and timeline events
- [ ] Define the initial `assets/` folder convention for icons, fact images, and book images
- [ ] Add validation for visual marker shape, missing assets, and missing captions
- [ ] Add visual markers to one Genesis pilot parasha before broad rollout
- [ ] Render fact-level visual markers inside the existing parasha drawer
- [ ] Make drawer titles, ruler labels, and total AM ranges book-aware
- [ ] Add Exodus era labels/styles to the drawer `ERA` map (`egito`, `saida-egito`)
- [ ] Make fact chapter parsing work for any Chumash book, not only `Genesis`
- [ ] Update drawer passage buttons so labels and behavior match the schema wording consistently
- [ ] Add a lightweight validation script or documented checklist for `facts_count`, missing files, required schema keys, and ref formatting

## Mid Term

- [ ] Extend drawer support to Vayikra, Bamidbar, and Devarim once data folders exist
- [ ] Create `data/parashiot/deuteronomy/index.json` + individual JSONs
- [ ] Replace static Chumash event lists with parasha-driven book views
- [ ] Build the Chumash visual atlas view with book lanes, event lanes, character lanes, and visual markers
- [ ] Build a book/parasha overview view for Genesis using the complete Genesis data
- [ ] Add search/filter across facts, characters, themes, and refs
- [ ] Prototype a local `editor.html` / `admin.html` for editing or exporting JSON through forms

## Long Term

- [ ] Complete all 54 parashiot across all 5 Chumash books
- [ ] Add Haftarah display per parasha
- [ ] Add a commentary layer after the primary-text flow is stable
- [ ] Mishna & Guemara tab: clicking a sage opens a bio panel
- [ ] Offline mode / service worker cache for JSON files and Sefaria responses
- [ ] Portuguese translation layer for verse text where available
- [ ] Consider a database-backed authoring system only if local JSON editing becomes insufficient
- [ ] If a database is introduced, keep static JSON export as the public app runtime format

---

## Corrections Registered From Current State

- [ ] Remove remaining Genesis-only assumptions from the drawer implementation
- [ ] Complete remaining Exodus JSON files before exposing all Exodus parashiot in the UI
- [ ] Prioritize timeline/parasha cross-interaction before further bulk parasha population
- [ ] Keep `docs/02_execution/07_progress.md` as the operational source of truth
- [ ] Keep `docs/02_execution/KNOWN_ISSUES.md` limited to real, verified issues
- [ ] Resolve local Git `dubious ownership` before relying on Git status/diff workflows
- [ ] Preserve JSON-first content publication while adding visual marker support
