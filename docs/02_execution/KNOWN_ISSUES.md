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

## BUG-02 — Parasha drawer is hardcoded to Genesis

**Symptom:** Only the Bereshit chip opens the drawer. The drawer always loads `data/parashiot/genesis/index.json` and labels the panel as Genesis.

**Root cause:** `drawerOpen()` has no book parameter, and `_drawerFetchIndex()` fetches a fixed Genesis path.

**Impact:** Existing Exodus data cannot be explored through the drawer UI.

**Fix:** Refactor drawer state to track `bookKey`, load `data/parashiot/{bookKey}/index.json`, and update titles/ruler labels from the loaded index.

---

## BUG-03 — Drawer era labels do not support Exodus eras

**Symptom:** If Exodus data is rendered through the current drawer, eras like `egito` and `saida-egito` will fall back to the `patriarcas` label/style.

**Root cause:** The drawer `ERA` map only defines `pre-diluvio`, `pos-diluvio`, and `patriarcas`.

**Impact:** Exodus historical context would display misleading labels/colors.

**Fix:** Add all eras used by visible parasha data, starting with `egito` and `saida-egito`, or derive era metadata from `data/timeline.json`.

---

## BUG-04 — Drawer-to-Pessukim navigation assumes Genesis

**Symptom:** Fact buttons that navigate to Pessukim always set the book selector to `Genesis`.

**Root cause:** `drawerGoToPessukim(chapterNum)` hardcodes `bookSel.value = 'Genesis'`, and fact chapter extraction matches only `Genesis`.

**Impact:** Exodus facts would open the wrong book in the Pessukim reader.

**Fix:** Pass the book name from the parasha/fact context into `drawerGoToPessukim(book, chapterNum, verseStart?)`.

---

## DEV-01 — Git status/diff blocked by safe.directory

**Symptom:** Running `git status --short` fails with Git's `dubious ownership` error.

**Root cause:** The repository directory is owned by a different Windows SID than the current process user.

**Impact:** Git-based verification and diff reporting are blocked until the workspace is marked safe for this user.

**Fix:** Configure Git safe directory for this repository when appropriate:
`git config --global --add safe.directory C:/Users/Sobel/projetos/claude/tora-explorer`
