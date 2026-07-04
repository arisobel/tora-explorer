# Backlog

## Strategic Objectives (2026-06-12)

- [ ] **Visual layer at every level** — allow user-added images/icons attached to nodes both broadly (structure areas, books, eras/timeline phases — *lato sensu*) and strictly (milestones, parashiot/units, facts, people — *stricto sensu*), used as icons or visual references. Follow `docs/04_technical/CONTENT_VISUAL_STRATEGY.md`: optional `visual` metadata in JSON, binary files under `assets/`, pilot before broad rollout.
- [ ] **Design/appearance improvement pass** — raise the visual quality of the whole app: typography scale, spacing rhythm, color hierarchy, per-era visual language, Atlas 2D polish, drawer refinement, and responsive review across the 6 tabs.

## Strategic Objectives (2026-06-14)

- [ ] **Internationalization (multi-language site)** — support PT-BR (base), English, Hebrew (RTL), Spanish, and possibly more (user flagged an additional language via "Other" — to confirm). **Scope: interface + curated content** (facts, summaries, captions, themes), not only UI strings. Verse text already arrives HE/EN from Sefaria. Implies: a language switcher; an i18n key system for UI strings; content schema holding per-language fields (e.g. `text` becomes `text_i18n.{lang}` or parallel localized files) with **fallback to PT** when a translation is missing; RTL layout handling for Hebrew. This is a large content-translation effort — stage UI first, then content field-by-field.
- [ ] **User image uploads via CapRover persistent volume** — let the user add passage illustrations (like the burning bush) without a redeploy. **Mechanism: a CapRover persistent volume mounted over a subdirectory** (e.g. `assets/user/`), NOT over all of `assets/` (that would hide the baked-in icons shipped in the image). Open points to design: how the JSON references the uploaded file, how captions/metadata are entered, and whether a small local `editor.html` helps tag images. Each uploaded image must declare a visual style (ties into the themes objective below) so the gallery keeps a consistent identity.
- [ ] **Visual identity themes (selectable global styles)** — group both SVG icons and illustration images into **named, globally selectable themes**. The JSON keeps only a *semantic id* (e.g. `ark`, `burning-bush`); a theme registry resolves which file/style actually renders. The current gold line-art SVG set becomes the default theme (e.g. `linha`); future sets (e.g. `preenchido`, `pintura clássica`) swap the whole look at once. The same mechanism tags uploaded images by style so a chosen theme stays coherent across icons and photos. Needs: a theme registry, asset resolution by `(theme, semantic-id)`, and a UI control to switch the active theme.

## Strategic Objectives (2026-06-15) — SQLite source-of-truth & online admin

> **Análise de maturidade (não é problema de performance).** O projeto já tem a infra de autoria SQLite (`db/migrations`, import ~3707 nós) e a camada `DrillDataSource` isola o app dos dados. Nesta escala o SQLite é **trivialmente rápido** — a query **não** seria gargalo. O trade-off real é **arquitetural**: sair de "estático puro no nginx" para "ter um backend". **Recomendação:** SQLite vira a **fonte de verdade**; o **JSON estático continua sendo o runtime do público** (artefato/cache gerado, não fallback); o site público **nunca** consulta o DB ao vivo. Só introduzir backend para a camada de **admin**.

- [ ] **SQLite como fonte de verdade + JSON como cache de runtime** — formalizar o pipeline que o `docs/04_technical/DATABASE_EXPORT_SPEC.md` já esboça: autoria no SQLite → step de geração → JSON estático servido ao público. (O "quando promover" já está no Long Term; este item é a decisão de torná-lo o fluxo padrão.)
- [ ] **editor.html online (admin) — exige backend** *(ponto de inflexão)* — pôr o editor no site sob login de admin, escrevendo no SQLite via uma API mínima (Node/FastAPI), com write-through gerando o JSON. Aceita-se um backend **só para autoria**. Avaliar custo de ops (hospedar serviço, auth, backup do `.db`) vs. ganho de editar online em vez de local. Graças ao `DrillDataSource`, o app público muda pouco.
- [ ] **Upload de imagem pelo editor via backend/API** — fechar o loop (hoje: baixar otimizada → subir manual no filebrowser). Preferir: o **mesmo backend de admin** recebe o upload, otimiza server-side (ex.: `sharp`) e grava no volume `assets/user/`. Alternativa: chamar a **API REST do filebrowser** com token — descartada como 1ª opção por expor credencial no JS do navegador. **Funde-se** no backend do item acima.

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

## Design Reference Adoption (2026-06-28)

Source: `docs/05_references/design_proposal_01/ADOPTION_PLAN.md`.

Goal: absorb the visual improvements from the reference proposal without
breaking the existing static HTML/CSS/JS app, current tabs, drawer behavior,
i18n, Sefaria reader, JSON data flow, or Atlas 2D.

- [ ] **Visual foundation from reference proposal** - document and apply the safer shared tokens first: paper/surface/ink/accent colors, border/shadow rhythm, typography hierarchy, nav polish, and card surfaces. No behavior changes in this step.
- [ ] **Estrutura editorial intro** - add a compact orientation block for the five drill-down levels: Estrutura, 5 Livros/Nach, Milestones, Parasha, Pessukim.
- [ ] **Estrutura primary cards** - refine Mikra, Talmud, and Halacha into stronger decision cards with Hebrew anchor text, concise copy, selected state, and detail panel below, preserving current click targets.
- [ ] **Estrutura detail groups** - reorganize Chumash, Neviim, and Ketuvim details into scan-friendly groups inspired by the proposal, using existing data and routes.
- [ ] **Estrutura drawer integration** - continue the existing next step: side drawer loading parasha/unit `index.json`, visual historical ruler, facts, and "Ver versiculos" actions into the Sefaria reader.
- [~] **Atlas reference prototype** - macro shell documented and started in `index.html`: isolated `atlas-ref-*` CSS base, reference-style topbar, three target-inspired macro cards (Tora Escrita, Tora Oral, Halacha), contextual side panel with "Visao atual", hover/drill support for macro cards, bottom timeline dock first pass, and opt-in checkbox for mouse-wheel zoom/drill. Next baby-step: browser visual validation and then Chumash drill. Do not replace the current Atlas 2D before validation.
- [x] **Atlas bottom timeline target pass** - first pass done: lower timeline now has a target-style dock with clickable era markers from `data/timeline_groups.json`, previous/next controls, active/hover states synchronized with Atlas focus, and the existing AM ruler preserved as the precision bar.
- [~] **Atlas timeline semantic zoom** - first Chumash slice implemented: when the Atlas is on `lens=chumash` and `zoom=1`, the bottom dock renders the 5 Chumash books from `data/milestones/chumash.json` plus each book `index.json` timeline range; book hover/click is synchronized with the central Atlas cards. Remaining levels: zoom 2 milestone groups, zoom 3 parasha/unit fact markers, zoom 4 selected fact/source refs. Avoid a parallel timeline data source.
- [ ] **Atlas visual promotion by importance** - plan and later implement image/icon visibility rules based on `visual.importance`: macro shows only importance 5, book/era 4-5, milestone 3-5, parasha/unit 2-5, fact detail 1-5. Start as backlog/schema guidance before changing UI behavior.
- [ ] **Atlas coordinated drill model** - implement focus as a coordinated context change: hover previews a section/book by dimming siblings and updating timeline/person panels; click confirms the drill so the focused section takes the main canvas. Keep separate `hoverFocus` and `selectedFocus` state, with breadcrumb/back control for returning one level.
- [ ] **Chumash drill reference slice** - use `screenshots/chumash-full.png` as the first concrete drill target: five Chumash book headers, event columns by book, synchronized timeline spine, primary characters, secondary related characters, and clear "Voltar ao Atlas" navigation.
- [ ] **Validation pass for each baby-step** - after each slice, check desktop/mobile layout, tab navigation, language switcher, drawer open/close, and Sefaria routing.

## Direção Atlas 2D + Linha do Tempo (2026-07-03)

Fonte: revisão do usuário sobre o Atlas em produção (`tora-explorer.lion.app.br`)
comparado ao mock `Atlas.pdf`/`atlas-full.png`, em telas de menor e maior
resolução. Direção confirmada: seguir o design da proposta. Modelo mental do
drill: **Google Earth** — quanto mais zoom-in, mais detalhamento focado em um
recorte menor; um único gesto de zoom, contexto sempre reorganizado ao redor
do foco.

- [ ] **Expandir o design do Atlas 2D para todo o app (mobile-first)** — a
  fundação visual `atlas-ref-*` (paper/surface/ink/accent, serifada para
  títulos/hebraico, bordas finas, sombras suaves) deve virar a linguagem de
  todo o projeto: nav, Estrutura, Linha do Tempo, Mishna & Guemara, Chumash,
  Pessukim e drawer. Premissa inegociável: funcionar bem no celular E no
  desktop — cada componente promovido precisa de comportamento responsivo
  definido, não só o visual.
- [x] **Atlas 2D responsivo — eliminar sobreposição em telas menores**
  (BUG-04, corrigido 2026-07-03) — o dock da timeline saiu do `position:
  fixed` e entrou no fluxo do documento (visual idêntico quando tudo cabe na
  tela, sem sobreposição quando não cabe); macro cards empilham e o painel
  lateral desce abaixo do mapa sob 1100px; topbar reflui sob 1280px; lista de
  eras rola horizontalmente em telas estreitas. Validado com screenshots
  headless em 1366x768, 1920x1080, 768x1024 e ~460px + probe de overflow.
- [x] **Deduplicar controles de zoom/navegação do Atlas** (2026-07-03) — o
  rail lateral (Navegar/Zoom +/Zoom −/Centralizar) foi removido e o par
  "− Macro +" da toolbar reduzido ao label + `Reset`; a régua de pontos no
  topo é agora a única affordance de zoom, como no mock. O rail só volta se
  agregar funções reais (centralizar, tela cheia).
- [~] **Timeline dock acompanha o zoom com fatos e personagens** — evolução do
  item "Atlas timeline semantic zoom": além de re-renderizar níveis (eras →
  livros → milestones → parasha → fato), o dock deve trazer **fatos e
  personagens** do recorte focado nos zooms mais profundos, adicionando uma
  dimensão de entendimento ao que está sendo estudado nos cards acima. Fonte:
  os mesmos JSONs (`facts[]`, `summary.characters`) — sem segunda fonte de
  verdade.
  **Fatia 1 implementada (2026-07-04), inspirada no mock "Timeline contextual
  expandida — Melachim":** com um livro do Chumash selecionado (zoom ≥ 2), o
  dock troca os chips de era por um painel multi-faixa: eixo de anos AM com
  ticks, faixa **Parashiot** (barras clicáveis → drawer), faixa
  **Acontecimentos** (losangos de milestones filtrados por `visual.importance`
  — zoom 2 mostra 4-5, zoom 3+ mostra 3-5 — clique → `atlasSelect('milestone')`)
  e faixa **Personagens** (spans derivados de `mart.byCharacter`, top 8, até 3
  linhas empacotadas). Validado com screenshots headless (Gênesis).
  **Quick wins do fonte HTML da proposta (`estrutura_tora_atlas_visual.html`)
  absorvidos em 2026-07-04:** níveis de zoom nomeados sob a régua, labels de
  texto nos losangos de Acontecimentos (alternando acima/abaixo) e card
  "Sobre o período" no painel lateral derivado do `index.json`.
  **Faltam:** (a) livros do Nach — hoje `nach-book` abre o drawer direto, sem
  estado de livro selecionado no Atlas; a timeline expandida do Nach depende do
  "Nach atlas/drill view" do Mid Term (o fallback por `key_events` já está
  pronto no código); (b) faixas de **Reinados** (Yehudá/Israel rei a rei, como
  no mock) — exigem dados novos (ex.: `data/timeline_lanes/kingdoms.json`);
  (c) refinamento visual das barras comprimidas em recortes densos (parashiot
  patriarcais em 1948-2255 se sobrepõem no eixo linear).
- [ ] **Promoção visual por `visual.importance` — priorizada** — confirmada
  como diretriz do projeto: macro mostra só importância 5, livro/era 4–5,
  milestone 3–5, parasha/unidade 2–5, detalhe de fato 1–5. Combina com o item
  anterior: as imagens que aparecem no dock seguem a mesma regra.
- [ ] **Aba Linha do Tempo horizontal com zoom expansivo** *(segundo momento,
  depois do Atlas)* — reorientar a aba dedicada de vertical para horizontal;
  ao fazer zoom-in a linha **expande horizontalmente** (mais espaço para o
  recorte focado); setas nas extremidades direita e esquerda navegam para
  trás/frente na história quando o zoom está focado em um ponto específico.
  Reaproveitar a mecânica de lente/zoom semântico validada no dock do Atlas —
  mesma engine, contêiner diferente.

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
- [~] Design pass: typography scale, spacing rhythm, and color hierarchy tokens — **foundation + component rhythm done (2026-06-14)**: `--text-xs…3xl`, `--lh-*`, `--space-1…8` tokens in `:root`; applied to page frame (`.page`, `.sec-title` 28px, `.sec-sub` hairline divider) AND components (`.card`/`.atlas-section` now carry `--shadow-1` soft lift + token padding; `.pillar-header`/`.mg-pillar-head` unified to `--text-xl`; `.oral-section-title`→`--text-lg`; grids/gaps/book-group/gen-block on `--space-*`). 0 undefined tokens. Next: per-tab polish (hover states, chip refinement, Timeline & Atlas card surfaces, drawer)
- [~] Design pass: interaction & surface polish — **first per-tab slice done (2026-06-14)**: chips + book buttons now lift (`translateY(-1px)` + `--shadow-1`) on hover with smoother prop-specific transitions; milestone cards + timeline titles got transitions; keyboard `:focus-visible` gold ring added to all real buttons (nav/lang/book/pk-view/atlas/drill-step) for a11y. Remaining per-tab deep polish: drawer internals (fact items, ruler, passage area), Pessukim verse rows, Atlas node typography tokens
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
- [x] Add a UI string catalog (`data/i18n/{lang}.json`) and a `t(key)` helper; extract hardcoded PT strings from `index.html` — PT is canonical (inline text); EN/ES/HE catalogs (81 keys each) keyed by exact PT string; selector-based engine translates static chrome via text nodes (preserves badges/icons); `t(key, ptDefault)` for dynamic strings (2026-06-14)
- [x] Add a language switcher control (persist choice in localStorage) and PT fallback for missing keys — global 🌐 PT/EN/ES/עב switch in `<nav>`; `setLang()` persists `site-lang`; unknown keys fall back to PT automatically (2026-06-14)
- [~] Handle Hebrew RTL layout — basic `dir=rtl` + `body.rtl` tweaks done; **drawer mirrors to the LEFT in HE** (anchored `left:0`, slides from left, border/shadow flipped) for RTL navigation coherence, while inner content stays LTR (still PT). Atlas + timeline spine mirroring still to review
- [ ] **RTL: Timeline misaligned (reported 2026-06-14)** — in HE the Timeline tab breaks layout: the spine/connectors shift to the left while the `.tl-event` grid (`100px 36px 1fr`) reverses, pushing the period column to the far right and flipping the dot column away from the spine; period ranges also read backwards ("1656 – 0" instead of "0 – 1656"). Needs explicit `body.rtl` handling of `.timeline-spine` position, `.tl-event` grid direction, and number/range ordering (or pin the whole Timeline LTR like the drawer until content is translated)
- [x] **Estrutura chips translated** — book/seder/halachah `.chip` labels + their `.tooltip` hints + category labels (Neviim·Profetas, Ketuvim·Escrituras) + Guemara description + Shulchan Aruch; `.chip`/`.tooltip` added to the i18n selectors; HE gets Hebrew forms for the transliterated names (EN/ES keep the transliteration). Catalogs: EN/ES 117 keys, HE 152, all verified present in HTML (2026-06-14)
- [x] **Dynamic chrome translated via `t()`** — Atlas map title/sub/zoom/breadcrumb/time-title + empty states + "Abrir fato"; drawer "Ver passagem"/"Carregando…" + ruler label + "→ Capítulo" buttons; timeline "Carregando fatos…"/"Parasha completa ›"/"Nenhum fato…"; Pessukim error + ref-label ("versículos" + fallback note). `setLang()` now re-renders the open Atlas (and pkRender) so a live language switch refreshes them. Catalogs: EN/ES 152, HE 187 keys, full parity, all verified in HTML, no double-wrap, JS OK (2026-06-14)
- [ ] **Remaining i18n tail (content-ish)** — Atlas node `meta`/`sub` count strings (X milestones/parashiot/fatos/AM), Timeline event titles/gerações, and a few `title=` attribute tooltips ("Voltar à lista", "Fechar"); these blur into content and need the schema's per-language fields or attribute-level i18n
- [x] Extend the content schema for per-language fields — adotado um bloco `i18n` aninhado (`{ en|es|he: { text, topic, caption } }` no fato; `summary.i18n.{lang}.short`) com PT canônico como fallback; `text_he` permanece como passuk hebraico (não tradução). Documentado em `data/SCHEMA.md`. App consome via `trContent(obj, field)` no drawer, atlas2d, drill cards e timeline drilldowns; `setLang` re-renderiza o drawer/timeline/drill abertos (2026-06-15)
- [x] **editor.html: campos de tradução EN/ES/HE** *(local, sem backend)* — seção *3 · Traduções*: seletor de alvo (Unidade `summary.short` ou cada fato), botão *Carregar alvo* mostra o PT-fonte + textareas EN/ES/HE (HE em RTL) pré-preenchidos do `i18n` existente; *Aplicar* escreve no objeto certo (vazio remove a tradução, limpa `i18n` órfão) e habilita *Salvar* (2026-06-15)
- [ ] Decide content-translation pipeline (manual vs assisted) and stage by book — autoria fato-a-fato já existe no editor; falta decidir se haverá assistência (LLM) e a ordem de cobertura por livro
- [x] **Livro-piloto traduzido (Ester) — EN/ES/HE** — `05-esther-purim-deliverance.json` ganhou `i18n` em todos os 22 facts (`text`+`topic`), nas 7 legendas e no `summary.short`; HE narrativo preenche o modo RTL. Paridade validada (nenhum fato sem `text`/`topic`/`caption`). Próximo piloto candidato: uma parashá do Chumash (2026-06-15)
- [x] **Bereshit traduzida (EN/ES/HE)** — primeiro piloto do Chumash: 20 facts + 5 legendas de ícone + `summary.short`. Ajuste de cobertura: legenda traduzida agora também em marcadores `icon` (`visualMarkerHTML` + editor) (2026-06-16)
- [x] **Noach traduzida (EN/ES/HE)** — 21 facts + 8 legendas de ícone + `summary.short` (2026-06-16)
- [x] **Lech Lecha + Vayera + Chayei Sarah traduzidas (EN/ES/HE)** — 44 facts + 10 legendas + 3 resumos (2026-06-16). Gênesis em 5/12.
- [ ] Traduzir o restante de Gênesis (próximas: Toldot, Vayetze, Vayishlach…) e demais livros; decidir ordem e se haverá assistência por LLM no editor

> **Sefaria multilíngue a nível de versículo — CONFIRMADO (2026-06-14).** A v3 Texts API serve HE/EN/PT/ES. Sintaxe: `version=<nome da língua em inglês>` (`hebrew`, `english`, `portuguese`, `spanish` — o código curto `pt`/`es` retorna vazio). Múltiplos `version=` por chamada são aceitos. Esther tem as 4: PT = *Publicado em 5784, Saymon Pires da Silva*; ES = *Meguilá Ester — Seminario Rabínico*. **Quick win:** parametrizar `version` em `sefariaTextUrl()` (index.html:2772) + seletor de idioma na aba Pessukim → conteúdo bíblico nas 4 línguas sem traduzir nada. **Ressalva:** cobertura PT/ES varia por livro; detectar `warnings` (código 102 = língua ausente) e cair para EN/HE.
- [x] Quick win Pessukim: parametrizar `version` por língua + seletor de idioma + fallback via `warnings` (2026-06-14)

### User image uploads (CapRover volume)
**Decision (2026-06-14): author-only + filebrowser sidecar.** App stays pure-static; a separate password-protected filebrowser container writes to a shared host volume; the app serves/references `assets/user/`. Repo side scaffolded; CapRover dashboard side is the author's to do. See `docs/04_technical/USER_IMAGE_UPLOADS.md`.
- [x] Repo scaffolding — `assets/user/.gitkeep` + `assets/user/README.md` (convention), `scripts/optimize-image.ps1` (resize/compress, tested), nginx `^~ /assets/user/` no-cache block, full setup doc with CapRover steps (2026-06-14)
- [x] How uploaded images are referenced — confirmed **zero app code**: existing `visualMarkerHTML`/`illustrationHTML` already render any `visual.asset` path; reference `assets/user/<file>.jpg` in a `visual` block (2026-06-14)
- [ ] **Author to do in CapRover dashboard** — shared persistent dir on both apps (host path e.g. `/captain/data/tora-user-images`), deploy `filebrowser/filebrowser`, set password + subdomain (steps in the doc)
- [ ] Add a smoke-check that a referenced `assets/user/...` path resolves (today a 404 silently hides via `onerror`)

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
- [~] Prototype a local `editor.html` / `admin.html` for editing or exporting JSON through forms — **v3 done (2026-06-15)**: (1) **image optimizer + interactive crop** (canvas; aspect presets landscape/square/portrait + drag/resize crop box, then resize + JPEG compress + download); (2) **direct JSON editing** via File System Access API (authorize `data/`, list/open/validate/save in place); (3) **interactive attach** — target selector (unit or each fact by id+topic) inserts the `visual` block into the right object automatically. Chromium-only; may need `http://localhost`. App side: `.fact-illus img` now renders **full-width / natural-height** (no crop, portrait & landscape both show fully). Future: structured fact text/summary editing, list volume contents

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
