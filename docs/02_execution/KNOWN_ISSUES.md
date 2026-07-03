# Known Issues

## BUG-01 — Exodus index references 2 missing JSON files

**Symptom:** `data/parashiot/exodus/index.json` lists Vayakhel and Pekudei, but their `data_file` targets do not exist on disk.

**Missing files:**
- `data/parashiot/exodus/10-vayakhel.json`
- `data/parashiot/exodus/11-pekudei.json`

**Root cause:** Exodus data population is partially complete: files `01` through `09` exist and match their `facts_count`; files `10` and `11` are metadata-only references.

**Impact:** Any future Exodus drawer/list expansion will hit fetch errors for these two parashiot until the files are created.

**Fix:** Create the two missing JSON files and verify their `facts[]` lengths match `index.json`.

---

## BUG-02 — Timeline phase for Moshe → Shlomo is too broad

**Symptom:** The Timeline event `Saída do Egito — Sinai — Israel` spans `2448–2928` and currently opens the broad `exodus-sinai` drill-down, which contains Exodus, Yehoshua, Shoftim, and Shemuel groups.

**Root cause:** The timeline was originally event-first. Nach books were later added horizontally, so Yehoshua, Shoftim, and Shemuel are currently represented as groups inside one broad phase instead of generated book/period lanes.

**Impact:** The books are clickable from the timeline, but the visual period still compresses Exodus, entry into the land, judges, and early monarchy into one large event. This is usable for navigation, but not yet the final organic structure.

**Fix:** Add a generated or curated Nach transition phase for Yehoshua → Shoftim → Shemuel, or split the existing event into smaller phases backed by `data/nach/*` units.

---

## BUG-03 — Timeline groups are still hand-authored runtime projections

**Symptom:** `data/timeline_groups.json` now includes Chumash plus all exposed Nach/Ketuvim timeline groups, but it is still manually maintained.

**Root cause:** SQLite import exists, but the SQLite→JSON export pipeline is not implemented yet.

**Impact:** Timeline drill-down can drift from book/unit/fact data unless links are validated after each content change.

**Fix:** Implement `scripts/export-sqlite-to-json.ps1` and add validation for `book_key`, `parasha_ids`, and `fact_ids` in timeline groups.

---

## BUG-04 — Atlas 2D elements overlap at lower resolutions — **FIXED 2026-07-03**

**Symptom:** On smaller screens (~1366px wide, verified by screenshot on
2026-07-03 at `tora-explorer.lion.app.br`), the Atlas 2D tab had overlapping
elements: the left tool rail (Navegar / Zoom + / Zoom −) overlapped the top
zoom ruler and the macro cards, and the fixed bottom timeline dock covered the
macro cards.

**Root cause:** The timeline dock used `position: fixed` with only a 230px
`padding-bottom` reservation (smaller than the dock's real height), and the
left rail occupied an 84px grid column while duplicating zoom/reset controls
already present in two other places.

**Fix applied:** The dock now lives in the document flow (identical look when
everything fits on screen, no overlap when it does not); the left rail was
removed and the zoom controls deduplicated to a single top ruler + Reset;
macro cards stack vertically and the side panel drops below the map under
1100px; the topbar reflows under 1280px; the era list scrolls horizontally on
narrow screens. Verified via headless-Chrome screenshots at 1366x768,
1920x1080, 768x1024, and ~460px (headless minimum), with an element-overflow
probe confirming no horizontal document overflow.

---

## DEV-01 — Git status/diff requires safe.directory handling

**Symptom:** Git commands may fail with Git's `dubious ownership` error unless an explicit `safe.directory` override is used.

**Root cause:** The repository directory is owned by a different Windows SID than the current process user.

**Impact:** Git-based verification and diff reporting are less reliable unless the workspace is marked safe or commands consistently pass the repository-specific override.

**Fix:** Configure Git safe directory for this repository when appropriate:
`git config --global --add safe.directory C:/Users/Sobel/projetos/claude/tora-explorer`
