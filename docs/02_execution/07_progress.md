# Project Progress

## Current State
- **Phase:** Exodus data completion + drawer generalization
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
- [x] Exodus `facts_count` verified for existing files `01` through `08`
- [x] Content/visual strategy documented: keep JSON as runtime format, add optional icons/images, defer database until authoring needs justify it
- [x] CapRover deploy packaging added: `captain-definition`, `Dockerfile`, `scripts/build-caprover.ps1`, and `dist/` output folder
- [x] Production Sefaria CORS fixed with same-origin Nginx proxy at `/api/sefaria/`

---

## In Progress

- [ ] Complete the missing Exodus parasha JSON files referenced by `data/parashiot/exodus/index.json`
- [ ] Generalize the drawer so it can render books beyond Genesis

---

## Next Actions (Short Horizon)

1. Create `data/parashiot/exodus/09-ki-tisa.json`
2. Create `data/parashiot/exodus/10-vayakhel.json`
3. Create `data/parashiot/exodus/11-pekudei.json`
4. Refactor `drawerOpen()` to accept a book key (`genesis`, `exodus`)
5. Wire the Shemot chip in the Estrutura tab to the Exodus drawer
6. Make drawer-to-Pessukim navigation book-aware instead of Genesis-only
7. Extend the parasha schema with optional visual marker metadata
8. Pilot visual markers on one Genesis parasha before broad rollout

---

## Risks / Blockers

- Sefaria API access depends on a public external service.
- Local development may still use `corsproxy.io`; production uses the same-origin Nginx proxy.
- `data/parashiot/exodus/index.json` currently references 3 files that do not exist, so an Exodus drawer would 404 for Ki Tisa, Vayakhel, and Pekudei until those files are created.
- Git commands are blocked in this workspace by Git's `dubious ownership` safety check until `safe.directory` is configured.

---

## Technical Debt

- Drawer implementation is book-specific even though the data model is book-oriented.
- `ERA` styling in the drawer only defines Genesis-era labels (`pre-diluvio`, `pos-diluvio`, `patriarcas`); Exodus eras fall back incorrectly.
- Inline fact chapter detection currently matches `Genesis` refs only.
- `drawerGoToPessukim()` always selects `Genesis`.
- No validation script checks missing files, `facts_count` drift, Sefaria ref shape, or required schema fields.
- No validation exists yet for visual asset paths, captions, or marker shape.
- No local content editor exists yet; JSON editing is still manual.
- CapRover package generation is local-only; deployment upload is still manual through CapRover.
- `ARCHITECTURE.md`, `DOMAIN_MODEL.md`, backlog, and known issues were reconciled, but future implementation must keep `07_progress.md` as the source of truth.
