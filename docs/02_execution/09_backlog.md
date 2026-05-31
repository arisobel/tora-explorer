# Backlog

## Immediate (Next Cycle)

- [ ] Create `data/parashiot/exodus/09-ki-tisa.json` with 15 facts matching `index.json`
- [ ] Create `data/parashiot/exodus/10-vayakhel.json` with 11 facts matching `index.json`
- [ ] Create `data/parashiot/exodus/11-pekudei.json` with 10 facts matching `index.json`
- [ ] Generalize `drawerOpen()` to accept a book key and load `data/parashiot/{book}/index.json`
- [ ] Wire the Estrutura tab's `Shemot` chip to open the Exodus drawer

## Short Term

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
- [ ] Change `drawerGoToPessukim()` to accept book + chapter and set the correct Pessukim selector
- [ ] Update drawer passage buttons so labels and behavior match the schema wording consistently
- [ ] Add a lightweight validation script or documented checklist for `facts_count`, missing files, required schema keys, and ref formatting

## Mid Term

- [ ] Extend drawer support to Vayikra, Bamidbar, and Devarim once data folders exist
- [ ] Create `data/parashiot/leviticus/index.json` + individual JSONs
- [ ] Create `data/parashiot/numbers/index.json` + individual JSONs
- [ ] Create `data/parashiot/deuteronomy/index.json` + individual JSONs
- [ ] Make timeline events clickable and route to the relevant parasha drawer or Pessukim chapter
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
- [ ] Complete missing Exodus JSON files before exposing all Exodus parashiot in the UI
- [ ] Keep `docs/02_execution/07_progress.md` as the operational source of truth
- [ ] Keep `docs/02_execution/KNOWN_ISSUES.md` limited to real, verified issues
- [ ] Resolve local Git `dubious ownership` before relying on Git status/diff workflows
- [ ] Preserve JSON-first content publication while adding visual marker support
