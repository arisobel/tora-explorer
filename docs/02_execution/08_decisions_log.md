# Decisions Log

---

## 2026-05-31 — Zero-dependency stack

**Context:** Project is a personal/educational tool. Needs to be shareable as a plain file with no server.

**Decision:** Pure HTML/CSS/JS, no npm, no framework, single `index.html`.

**Impact:** No build step, instant open in browser. Constrains tooling (no TypeScript, no components library). All JS is inline in the HTML.

---

## 2026-05-31 — Sefaria as sole verse source

**Context:** Need a free, authoritative source for Hebrew + English text.

**Decision:** Use Sefaria public API (`sefaria.org/api/texts/{ref}`) with no auth token.

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
