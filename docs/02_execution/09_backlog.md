# Backlog

## Strategic Objectives (2026-06-12)

- [ ] **Visual layer at every level** — allow user-added images/icons attached to nodes both broadly (structure areas, books, eras/timeline phases — *lato sensu*) and strictly (milestones, parashiot/units, facts, people — *stricto sensu*), used as icons or visual references. Follow `docs/04_technical/CONTENT_VISUAL_STRATEGY.md`: optional `visual` metadata in JSON, binary files under `assets/`, pilot before broad rollout.
- [ ] **Design/appearance improvement pass** — raise the visual quality of the whole app: typography scale, spacing rhythm, color hierarchy, per-era visual language, Atlas 2D polish, drawer refinement, and responsive review across the 6 tabs.

## Strategic Objectives (2026-06-14)

- [ ] **Internationalization (multi-language site)** — support PT-BR (base), English, Hebrew (RTL), Spanish, and possibly more (user flagged an additional language via "Other" — to confirm). **Scope: interface + curated content** (facts, summaries, captions, themes), not only UI strings. Verse text already arrives HE/EN from Sefaria. Implies: a language switcher; an i18n key system for UI strings; content schema holding per-language fields (e.g. `text` becomes `text_i18n.{lang}` or parallel localized files) with **fallback to PT** when a translation is missing; RTL layout handling for Hebrew. This is a large content-translation effort — stage UI first, then content field-by-field.
- [ ] **User image uploads via CapRover persistent volume** — let the user add passage illustrations (like the burning bush) without a redeploy. **Mechanism: a CapRover persistent volume mounted over a subdirectory** (e.g. `assets/user/`), NOT over all of `assets/` (that would hide the baked-in icons shipped in the image). Open points to design: how the JSON references the uploaded file, how captions/metadata are entered, and whether a small local `editor.html` helps tag images. Each uploaded image must declare a visual style (ties into the themes objective below) so the gallery keeps a consistent identity.
- [ ] **Visual identity themes (selectable global styles)** — group both SVG icons and illustration images into **named, globally selectable themes**. The JSON keeps only a *semantic id* (e.g. `ark`, `burning-bush`); a theme registry resolves which file/style actually renders. The current gold line-art SVG set becomes the default theme (e.g. `linha`); future sets (e.g. `preenchido`, `pintura clássica`) swap the whole look at once. The same mechanism tags uploaded images by style so a chosen theme stays coherent across icons and photos. Needs: a theme registry, asset resolution by `(theme, semantic-id)`, and a UI control to switch the active theme.

## Immediate (Next Cycle)

- [ ] Create `data/parashiot/exodus/10-vayakhel.json` and `11-pekudei.json` (drawer 404s for these)
- [ ] Add regression tests for fact chapter parsing and Pessukim routing across Chumash and multi-book Nach/Ketuvim sets
- [ ] Review and refine Vayikra, Bamidbar, and Devarim fact wording and refs after first-pass exposure
- [ ] Add `fact_ids` to Vayikra, Bamidbar, and Devarim Chumash milestones so drawer highlights match Genesis/Exodus depth
- [ ] Review and refine Joshua, Judges, Samuel, Kings, Isaiah, Jeremiah, and Ezekiel unit wording and refs after first-pass exposure
- [ ] Review and refine the new Trei Assar and Ketuvim first-pass wording, refs, and timeline placement
- [ ] Add selected-state breadcrumb across structure, book, milestone, parasha, and fact
- [ ] Extend timeline links beyond the Genesis pilot (`brit-milah`, `yitzchak-born`, `yaakov-born`, `yosef-born`, `yaakov-egypt`)
- [ ] Add repeatable validation for `data/milestones/chumash.json` and `data/timeline_groups.json` parasha/fact links
- [ ] Add selected/highlight state from Parasha drawer back to Timeline tab
- [ ] Show linked global timeline events inside the Parasha drawer
- [ ] Show linked timeline groups inside the Parasha drawer

## Recently Completed

- [x] **Nach visual layer (book + unit levels)** — 8 new SVGs (54 total: sword, lion, fish, heart, wall, mask, eye, hourglass); all 15 Nach/Ketuvim `index.json` files carry a book-level icon + per-unit icons (109 units); drawer index list shows mini icons per unit and the book icon in the ruler label; `_drawerRenderParasha` now falls back to the index entry's `visual` so the unit header badge renders without editing the 109 individual unit files (2026-06-14)
- [x] **Fact-level icons for Exodus→Deuteronomy + Chumash/Atlas milestone SVGs** — 103 fact markers added across the 4 books (29 Exodus multi-line + 74 inline format); 50 of 52 Chumash milestones carry `visual` (kashrut/miriam keep emoji); Chumash tab and Atlas 2D node grid render the SVG icons with emoji fallback; `chains.svg` added (46 icons); burning-bush illustration installed at `assets/facts/exodus/shemot/sarca-ardente.jpg` (resized 1024px JPG, 422 KB) (2026-06-12)
- [x] **Illustration support (`marker_type: "image"`)** — fact-level images render as captioned illustration blocks, parasha-level images as a header banner in the drawer; `assets/facts/<book>/<parasha>/` convention documented in `assets/facts/README.md`; burning-bush fact (`sm010`) wired to `assets/facts/exodus/shemot/sarca-ardente.jpg` (image file to be added by the author); nginx now sends `Cache-Control: no-cache` for HTML/JSON/SVG so deploys show up without stale cache (2026-06-12)
- [x] **Chumash + Timeline visual layer** — 14 new SVGs (45 total); book + parasha icons for Exodus/Leviticus/Numbers/Deuteronomy (index.json + parasha files); `timeline_groups.json` carries `visual` on all 7 phases and 34/41 groups with emoji fallback; Timeline group cards and phase panels render SVG icons (2026-06-12)
- [x] **Genesis visual layer complete** — 23 new semantic SVGs (31 total in `assets/icons/`); all 12 parashiot carry parasha-level + fact-level `visual` markers (67 blocks); `genesis/index.json` has book-level + per-parasha icons; drawer renders mini icons in the index list and the book icon in the ruler label (2026-06-12)
- [x] **Visual-layer pilot (Noach)** — `visual` block documented in `data/SCHEMA.md` (parasha + fact levels), `assets/icons/` with 8 semantic SVGs (ark, flood, rainbow, olive-branch, altar, vine, tower, tzaddik), markers in `02-noach.json`, drawer renders theme-colored icon badges via CSS mask; `build-caprover.ps1` already packages `assets/` (2026-06-12)
- [x] **Chumash milestone routing for all 5 books** — Vayikra, Bamidbar, and Devarim milestones now include `parasha_ids`, so Chumash and Atlas 2D drill paths can open the drawer beyond Genesis/Exodus (2026-06-08)
- [x] **drawer→Pessukim book-aware** — `drawerGoToPessukim(chapterNum, bookKey)` now resolves Sefaria book name from bookKey; button in `_drawerRenderParasha` passes `bookKey` captured at render time (2026-06-01)
- [x] **Devarim JSON set** — `data/parashiot/deuteronomy/index.json` + all 11 individual parasha JSONs generated and synced to SQLite (2026-06-01)
- [x] **Joshua/Nach pilot JSON set** — `data/nach/joshua/index.json` + 8 narrative-unit JSONs generated and synced to SQLite (2026-06-01)
- [x] **Judges/Nach JSON set** — `data/nach/judges/index.json` + 7 narrative-unit JSONs generated and synced to SQLite (2026-06-01)
- [x] **Estrutura Nach chips** — Yehoshua and Shoftim chips open the drawer using `data/nach/*` unit indexes (2026-06-01)
- [x] **Samuel/Nach JSON set** — `data/nach/samuel/index.json` + 8 narrative-unit JSONs generated and synced to SQLite; Shmuel I/II chip opens the drawer (2026-06-01)
- [x] **Kings/Nach JSON set** — `data/nach/kings/index.json` + 8 narrative-unit JSONs generated and synced to SQLite; Malachim I/II chip opens the drawer and the First Temple timeline phase expands into Kings groups (2026-06-01)
- [x] **Timeline Nach clickability** — Yehoshua, Shoftim, Shemuel, and Malachim are reachable from Timeline drill-down groups without replacing the current timeline structure (2026-06-01)
- [x] **Isaiah/Nach JSON set** — `data/nach/isaiah/index.json` + 8 prophetic-unit JSONs generated and synced to SQLite; Yeshaya chip opens the drawer and First Temple timeline groups link into Isaiah (2026-06-01)
- [x] **Jeremiah/Nach JSON set** — `data/nach/jeremiah/index.json` + 8 prophetic-unit JSONs generated and synced to SQLite; Yirmiya chip opens the drawer and First Temple/Exile timeline groups link into Jeremiah (2026-06-02)
- [x] **Ezekiel/Nach JSON set** — `data/nach/ezekiel/index.json` + 8 prophetic-unit JSONs generated and synced to SQLite; Yechezkel chip opens the drawer and Exile timeline groups link into Ezekiel (2026-06-03)
- [x] **Remaining Nach/Ketuvim JSON sets** — Trei Assar, Tehilim, Mishlei, Iyov, Meguilot, Daniel, Ezra/Nechemia, and Divrei Hayamim indexes + 54 unit JSONs generated and synced to SQLite; Estrutura and Timeline groups open each set (2026-06-03)

## Short Term

- [ ] Write `scripts/export-sqlite-to-json.ps1` per spec in `docs/04_technical/DATABASE_EXPORT_SPEC.md`
- [ ] Add `summary_medium`, `aliyot`, `haftarah` to the import script and schema to close lossy-field gaps
- [ ] Replace hand-authored `data/timeline_groups.json` with a generated timeline projection
- [ ] Add "ver na linha do tempo" action from parasha/fact views
- [ ] Remove remaining dark-theme assumptions from inline styles
- [ ] Add a fallback/error message that distinguishes Sefaria failure from proxy/CORS failure
- [ ] Add a smoke-check step after CapRover package generation to verify the tar contents
- [ ] Add validation for visual marker shape, missing assets, and missing captions
- [ ] Extend `visual` metadata to books (index.json) and timeline events (schema currently covers parasha + fact levels)
- [ ] Extend `visual` metadata beyond facts to the broad layers: structure areas, books, eras/timeline phases, milestones, and people
- [ ] Define the user-facing workflow for adding images (documented drop-into-`assets/` convention now; local editor with File System Access API later)
- [ ] Design pass: typography scale, spacing rhythm, and color hierarchy tokens reviewed across all 6 tabs
- [ ] Design pass: per-era/book visual language (colors, icons) consistent across Estrutura, Timeline, Atlas 2D, and drawer

> **Padrões de layout extraídos dos documentos de referência (2026-06-14).** Do mock "Stories Across the Sky": (1) **herói ilustração + texto lado a lado** com bastante respiro — evolução do `dp-banner`; (2) **caixa de destaque colorida** (estilo "PR Angle") → reusar como bloco "Drash / Comentário" no fato: fundo suave, ícone à esquerda, uma frase-chave; (3) **três colunas com borda-accent à esquerda** para listar personagens/temas de forma escaneável. Da Meguilá autoral do usuário (protótipo de unidade plenamente realizada): ilustração embutida no fluxo por cena, **três camadas de texto empilhadas** (hebraico c/ nikud → transliteração → vernáculo) e **marginália** (resumos laterais). A camada **transliteração** não vem da Sefaria — é autoral; merece um campo próprio no schema (`text_translit`).
- [ ] Design pass: bloco "Drash/Comentário" colorido por fato (padrão "PR Angle")
- [ ] Design pass: layout cena = ilustração inline + texto (modelo Meguilá autoral)
- [ ] Schema: avaliar campo `text_translit` (transliteração autoral, não disponível na Sefaria)
- [ ] Refine the drawer visual language for additional books and historical periods
- [ ] Update drawer passage buttons so labels and behavior match the schema wording consistently
- [ ] Add a lightweight validation script or documented checklist for `facts_count`, missing files, required schema keys, and ref formatting

## Mid Term

### i18n (multi-language)
- [ ] Add a UI string catalog (`data/i18n/{lang}.json`) and a `t(key)` helper; extract hardcoded PT strings from `index.html`
- [ ] Add a language switcher control (persist choice in localStorage) and PT fallback for missing keys
- [ ] Handle Hebrew RTL layout (dir attribute, mirrored components) when HE is active
- [ ] Extend the content schema for per-language fields (e.g. `text_i18n`, `summary_i18n`, `caption_i18n`) with PT as canonical fallback; document in `data/SCHEMA.md`
- [ ] Decide content-translation pipeline (manual vs assisted) and stage by book

> **Sefaria multilíngue a nível de versículo — CONFIRMADO (2026-06-14).** A v3 Texts API serve HE/EN/PT/ES. Sintaxe: `version=<nome da língua em inglês>` (`hebrew`, `english`, `portuguese`, `spanish` — o código curto `pt`/`es` retorna vazio). Múltiplos `version=` por chamada são aceitos. Esther tem as 4: PT = *Publicado em 5784, Saymon Pires da Silva*; ES = *Meguilá Ester — Seminario Rabínico*. **Quick win:** parametrizar `version` em `sefariaTextUrl()` (index.html:2772) + seletor de idioma na aba Pessukim → conteúdo bíblico nas 4 línguas sem traduzir nada. **Ressalva:** cobertura PT/ES varia por livro; detectar `warnings` (código 102 = língua ausente) e cair para EN/HE.
- [x] Quick win Pessukim: parametrizar `version` por língua + seletor de idioma + fallback via `warnings` (2026-06-14)

### User image uploads (CapRover volume)
- [ ] Configure a CapRover persistent volume mounted over a subdir (e.g. `assets/user/`) and document the path convention
- [ ] Define how uploaded images are referenced from JSON and how captions/style are tagged
- [ ] Add a smoke-check that a referenced image path resolves (icons baked in image vs user volume)

### Visual identity themes
- [ ] Design the theme registry: map `(theme, semantic-id)` → asset path; make the current gold line-art the default theme
- [ ] Refactor render to resolve assets by semantic id + active theme instead of hardcoded `assets/icons/<id>.svg` paths in JSON
- [ ] Add a second icon set as proof of concept (e.g. filled style) and a theme switcher
- [ ] Tag illustration images by style so a theme stays coherent across icons and photos

- [ ] Refine drawer support for all exposed Chumash, Nach, and Ketuvim sets after UI review
- [ ] Replace static Chumash event lists with parasha-driven book views
- [ ] Build a Nach atlas/drill view using `data/nach/*` narrative units
- [ ] Build the Chumash visual atlas view with book lanes, event lanes, character lanes, and visual markers
- [ ] Define the future image model for the Atlas: decide whether images attach to books, milestones, parashiot/units, facts, or multiple node types; store at least image addressing/metadata in SQLite and export JSON references for the static runtime
- [ ] Build a book/parasha overview view for Genesis using the complete Genesis data
- [ ] Add search/filter across facts, characters, themes, and refs
- [ ] Prototype a local `editor.html` / `admin.html` for editing or exporting JSON through forms

## Long Term

- [ ] Refine all 54 parashiot across all 5 Chumash books after first-pass data completion
- [ ] Add Haftarah display per parasha
- [ ] Add a commentary layer after the primary-text flow is stable
- [ ] Mishna & Guemara tab: clicking a sage opens a bio panel
- [ ] Offline mode / service worker cache for JSON files and Sefaria responses
- [ ] Portuguese translation layer for verse text where available
- [ ] Decide when SQLite should become the authoritative authoring source instead of an imported integration layer
- [ ] Keep static JSON export as the public app runtime format as SQLite authoring evolves

---

## Corrections Registered From Current State

- [ ] Remove remaining parasha-centric naming assumptions from the generic Chumash/Nach/Ketuvim drawer
- [ ] Complete remaining Exodus JSON files to eliminate drawer 404s
- [ ] Refine timeline boundaries and replace manually maintained projections with generated views
- [ ] Keep `docs/02_execution/07_progress.md` as the operational source of truth
- [ ] Keep `docs/02_execution/KNOWN_ISSUES.md` limited to real, verified issues
- [ ] Standardize the local Git `safe.directory` workflow for reliable status/diff verification
- [ ] Preserve JSON-first content publication while adding visual marker support
