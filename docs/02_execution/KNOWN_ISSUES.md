# Known Issues

## BUG-01 — 10 of 12 Genesis parasha JSON files are missing

**Symptom:** Drawer (once built) will show empty facts for parashiot 03–12.

**Root cause:** `index.json` references `data/parashiot/genesis/03-lech-lecha.json` through `12-vayechi.json` — none exist on disk.

**Impact:** Facts panels will be empty or throw 404 fetch errors.

**Fix:** Create the 10 missing JSON files — see backlog.

---

## BUG-03 — `02-noach.json` has no facts

**Symptom:** Noach parasha expands but shows no content in the facts panel.

**Root cause:** File was created as a shell; `facts[]` array is empty.

**Impact:** Low — drawer will render the parasha with metadata but no fact cards.

**Fix:** Populate `facts[]` in `02-noach.json` for Genesis 6:9–11:32.

---

## BUG-04 — No Sefaria error handling in Pessukim tab

**Symptom:** If Sefaria API is unreachable or returns an error, the Pessukim tab silently shows nothing (no user feedback beyond the empty state).

**Root cause:** `pkLoad()` fetch likely has no `.catch()` or only logs to console.

**Impact:** Low severity in normal conditions. Poor UX when network is slow or Sefaria is down.

**Fix:** Add a visible error message in `#pk-error` div on fetch failure.
