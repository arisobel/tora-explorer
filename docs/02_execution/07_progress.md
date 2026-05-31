# Project Progress

## Current State
- **Phase:** Data population + Drawer implementation
- **Last update:** 2026-05-31

---

## Completed

- [x] `index.html` — full 5-tab SPA (Estrutura, Timeline, Mishna/Guemara, Chumash, Pessukim)
- [x] CSS design system with tokens, responsive layout, dark theme
- [x] Tab 1 (Estrutura): Written + Oral Torah visual map, flow diagram, book chips
- [x] Tab 2 (Linha do Tempo): Vertical timeline + oral-law horizontal bar
- [x] Tab 3 (Mishna & Guemara): Tanaim/Amoraim panels, academies, braitot
- [x] Tab 4 (Chumash): All 5 books with events + characters
- [x] Tab 5 (Pessukim): Live Sefaria API reader with parallel view, chapter nav, verse jump
- [x] `data/timeline.json` — 14 eras, 16 key events (complete)
- [x] `data/SCHEMA.md` — full parasha JSON schema documented
- [x] `data/parashiot/genesis/index.json` — all 12 Genesis parashiot metadata
- [x] `data/parashiot/genesis/01-bereshit.json` — 20 facts
- [x] `data/parashiot/genesis/02-noach.json` — 21 facts
- [x] `data/parashiot/genesis/03-lech-lecha.json` — 17 facts
- [x] `data/parashiot/genesis/04-vayera.json` — 15 facts
- [x] `data/parashiot/genesis/05-chayei-sarah.json` — 12 facts
- [x] `data/parashiot/genesis/06-toldot.json` — 14 facts
- [x] `data/parashiot/genesis/07-vayetze.json` — 12 facts
- [x] `data/parashiot/genesis/08-vayishlach.json` — 13 facts
- [x] `data/parashiot/genesis/09-vayeshev.json` — 12 facts
- [x] `data/parashiot/genesis/10-miketz.json` — 12 facts
- [x] `data/parashiot/genesis/11-vayigash.json` — 9 facts
- [x] `data/parashiot/genesis/12-vayechi.json` — 11 facts
- [x] `index.json` — all facts_count fields updated
- [x] Parasha drawer — fully implemented (slide-in panel, historical ruler, facts list, inline Sefaria passages, "→ Capítulo N" nav to Pessukim tab, Escape/overlay close)

---

## In Progress

- (nothing — all Genesis parashiot are now populated)

---

## Next Actions (Short Horizon)

1. Create `data/parashiot/exodus/index.json` + individual JSONs for Shemot (11 parashiot)
2. Wire drawer to support other books beyond Bereshit (Shemot chip → Exodus drawer)

---

## Risks / Blockers

- Sefaria API is external/public — no SLA; drawer uses corsproxy.io as intermediary
- 10 of 12 Genesis parasha JSONs are missing — drawer shows a graceful "JSON não adicionado" state for those entries

---

## Technical Debt

- No error boundary for failed Sefaria fetches in the Pessukim tab (UI shows empty, no user message) — BUG-04
- `02-noach.json` exists but has no facts — drawer renders the parasha header but empty facts section
