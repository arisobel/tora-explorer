# Design Proposal 01 - Review and Adoption Plan

## Fonte da proposta

Referencia principal:

- `screenshots/atlas-full.png` - norte visual da implementacao.
- `Atlas.dc.html` - HTML/CSS/JS base da proposta.
- `screenshots/chumash-full.png` - referencia do primeiro aprofundamento do
  Atlas para Chumash.
- `chumash.dc_files/_bootstrap.html` - export renderizado com a logica util do
  mock de Chumash (`state = { focus:null }`).

Arquivos de apoio analisados:

- `chumash.dc.html`
- `Estrutura.dc.html`
- `screenshots/01-v2.png`
- `screenshots/02-drill.png`

Esta proposta deve ser tratada como referencia visual e direcional, nao como
codigo pronto para substituir o app atual. O app existente ja tem navegacao,
i18n, drawer, Sefaria, dados JSON e Atlas 2D funcionando; a incorporacao deve
absorver os ganhos visuais sem quebrar estes fluxos.

## Leitura da proposta

### Identidade visual

A proposta desloca a identidade para uma experiencia mais editorial, clara e
institucional:

- fundo claro e levemente quente na aba Estrutura;
- superfícies brancas com bordas finas e sombras suaves;
- azul profundo como acento principal, com dourado reservado para destaque;
- mais presenca do hebraico como elemento visual e semantico;
- tipografia serifada mais elegante para titulos e termos hebraicos;
- textos auxiliares menores, mais discretos e mais hierarquizados.

### Aba Estrutura

Principais melhorias propostas:

- transformar a pagina inicial da Estrutura em uma narrativa de drill-down;
- explicitar os 5 niveis: Estrutura, 5 Livros/Nach, Milestones, Parasha,
  Pessukim;
- apresentar Mikra, Talmud e Halacha como grandes cartoes de decisao;
- abrir detalhes abaixo do nivel selecionado, sem trocar a pagina inteira;
- usar hebraico grande como ancora visual dos conceitos;
- organizar Chumash, Neviim e Ketuvim como grupos de cards escaneaveis.

Esta parte encaixa bem no app atual e pode ser absorvida em etapas pequenas,
porque preserva o modelo de abas e os dados que ja existem.

### Atlas

Principais melhorias propostas:

- um Atlas mais espacial, com header de ferramenta, busca, camadas, zoom,
  cards centrais e painel lateral;
- camadas conceituais visiveis: area da Tora, linha do tempo e personagens;
- linha do tempo horizontal acoplada ao Atlas;
- painel de contexto para personagens e foco atual;
- linguagem de produto mais rica, proxima de uma ferramenta de exploracao.

Esta parte e mais ambiciosa. Deve nascer como prototipo controlado do Atlas 2D,
nao como troca direta da tela atual.

### Interacao de zoom/drill

A proposta original sugere usar o scroll do mouse para aprofundar o Atlas. Esse
comportamento deve ser opcional, porque pode conflitar com a expectativa normal
de rolagem vertical da pagina.

Decisao de UX:

- por padrao, o scroll do mouse deve continuar rolando a pagina normalmente;
- o zoom/drill via scroll so deve funcionar quando o usuario ativar um controle
  explicito, como um checkbox ou toggle "Usar scroll para aprofundar";
- ao desativar o controle, o Atlas volta imediatamente ao comportamento normal
  de navegacao vertical;
- botoes `+`, `-`, breadcrumb e cards continuam sendo os meios principais e
  previsiveis de drill.

Essa regra deve ser aplicada antes de qualquer implementacao baseada no
`onwheel` do mock.

### Drill coordenado por foco

O aprofundamento mostrado em `screenshots/chumash-full.png` sugere que o Atlas
nao deve apenas "aumentar zoom". O comportamento esperado e um **drill
coordenado**: quando o usuario posiciona o mouse ou seleciona uma secao, todo o
contexto visual se reorganiza em torno dela.

Modelo recomendado:

- **Hover / foco leve:** ao passar o mouse sobre uma secao macro, como "Tora
  Escrita", o Atlas mostra uma pre-visualizacao: a secao ganha enfase, as demais
  reduzem opacidade, a linha do tempo destaca o recorte relevante e o painel de
  personagens troca para personagens ligados a esse contexto.
- **Clique / drill confirmado:** ao clicar, a secao toma a tela e vira o novo
  nivel de trabalho. Exemplo: "Tora Escrita" aprofunda para Chumash/Nach; dentro
  de Chumash, um livro em foco abre a visao dos cinco livros com eventos e
  personagens.
- **Timeline sincronizada:** a timeline nao e decorativa; ela deve aprofundar
  junto com o drill. No nivel Chumash, ela mostra os livros e seus marcos; em
  niveis seguintes, deve reduzir para parashiot, fatos ou eventos relacionados.
- **Personagens sincronizados:** o painel de personagens deve concentrar os
  personagens principais do foco atual e abrir uma camada secundaria de
  relacionados, como no mock de Chumash.
- **Voltar um nivel:** cada drill confirmado precisa ter retorno claro via
  breadcrumb ou botao "Voltar ao Atlas".

Esse modelo deve ser implementado sobre o estado real do app, preferindo uma
distincao entre `hoverFocus` e `selectedFocus` para evitar que uma simples
passada de mouse mude permanentemente a navegacao.

## Como encaixar no que ja existe

O caminho recomendado e separar a transformacao em tres frentes:

1. **Foundation visual**
   Ajustar tokens de cor, fonte, superficies e estados sem mudar comportamento.

2. **Estrutura editorial**
   Reorganizar a aba Estrutura para comunicar o drill-down de forma mais clara,
   preservando os chips, botoes e rotas atuais.

3. **Atlas experimental**
   Criar um prototipo incremental do Atlas com camadas, zoom e paineis de
   contexto, validando em paralelo com o Atlas 2D existente.

## Baby-steps de implementacao

### Step 1 - Documentar tokens visuais

Criar ou atualizar uma secao tecnica com:

- cores-alvo: paper, surface, ink, ink-soft, line, accent, accent-soft,
  accent-ink, gold;
- fontes pretendidas e fallback;
- regra de uso: serifada para titulos/hebraico, sans para interface;
- raio, borda e sombra padrao;
- criterio para nao criar uma paleta monotematica.

Resultado esperado: nenhuma mudanca funcional.

### Step 2 - Aplicar foundation sem alterar layout

Atualizar `:root`, `body`, `nav`, `.page`, `.card`, `.sec-title` e componentes
basicos para aproximar o app da proposta.

Resultado esperado: o app parece mais refinado, mas todas as abas continuam com
a mesma estrutura e os mesmos comportamentos.

### Step 3 - Estrutura: faixa introdutoria

Adicionar na aba Estrutura uma introducao editorial compacta:

- etiqueta "Estrutura da Tora";
- titulo curto sobre o caminho da transmissao;
- texto de apoio;
- regua dos 5 niveis do drill-down.

Resultado esperado: melhora de orientacao sem mexer nos dados.

### Step 4 - Estrutura: cards principais

Refinar Mikra, Talmud e Halacha como cards maiores, com:

- termo hebraico em destaque;
- transliteracao/nome;
- descricao curta;
- estado selecionado;
- detalhe aberto abaixo.

Resultado esperado: a aba Estrutura ganha a logica visual da proposta, mantendo
os mesmos destinos atuais.

### Step 5 - Estrutura: detalhe em grupos

Reorganizar os detalhes de Mikra para aproximar do modelo:

- Chumash;
- Neviim;
- Ketuvim;
- cards com hebraico, transliteracao e nome em portugues.

Resultado esperado: melhor escaneabilidade para o usuario sem alterar schema.

### Step 6 - Drawer e timeline dentro da Estrutura

Conectar a transformacao aos proximos passos do projeto:

- drawer lateral na aba Estrutura;
- carregamento de `index.json` das parashiot/unidades;
- regua historica visual no drawer;
- fatos com botao "Ver versiculos" conectado ao leitor Sefaria.

Resultado esperado: a proposta visual passa a servir a navegacao real.

### Step 7 - Atlas: prototipo protegido

Criar um modo ou branch visual para o Atlas novo:

- header/toolbars apenas se agregarem funcao real;
- painel de camadas simples;
- linha do tempo horizontal reaproveitando dados existentes;
- painel lateral de contexto;
- checkbox/toggle para habilitar zoom/drill por scroll, deixando a rolagem
  vertical normal como comportamento padrao;
- estado separado para hover/pre-foco e selecao/drill confirmado;
- sincronizacao entre area central, timeline e personagens ao focar uma secao
  ou livro;
- sem remover o Atlas 2D atual ate validar usabilidade.

Resultado esperado: aprendizado visual sem risco para a tela existente.

## Estado implementado ate agora - 2026-06-28

### Referencias aceitas como norte

- Referencia principal de imagem: `screenshots/atlas-full.png`.
- HTML/CSS/JS de estudo: `Atlas.dc.html`.
- Referencia de drill futuro para Chumash: `screenshots/chumash-full.png` e
  `chumash.dc_files/_bootstrap.html`.

### Implementado no `index.html`

- A aba Atlas 2D recebeu um shell visual isolado com prefixo CSS
  `atlas-ref-*`, evitando misturar a nova base de aparencia com os componentes
  antigos.
- Foi adicionada uma topbar no estilo da referencia, com identidade, busca,
  ferramentas e perfil de estudante.
- A area macro passou a usar tres cards principais inspirados no target:
  **Tora Escrita**, **Tora Oral** e **Halacha**, com badges circulares,
  chips internos e rodape contextual.
- O painel lateral foi preservado e ganhou um card escuro de **Visao atual**,
  preparando a ideia de contexto sincronizado.
- O scroll do mouse deixou de fazer drill por padrao. O comportamento de
  aprofundamento via scroll agora depende do checkbox **Usar scroll para
  aprofundar**.
- O hover/drill dos cards macro foi ajustado para funcionar com os novos cards
  visuais sem quebrar a grade antiga de nos.
- A linha do tempo inferior continua usando os dados e renderizacao existentes,
  mas ja foi reposicionada dentro do shell visual novo.
- Foi criado `scripts/local-static-server.ps1` para testar o app localmente sem
  depender de Node/framework.

### Protecoes mantidas

- O app continua sendo HTML/CSS/JS puro.
- O Atlas antigo nao foi removido; a mudanca esta encapsulada dentro da aba
  existente.
- Rotas, drawer, i18n, Sefaria reader e dados JSON nao foram substituidos.
- O arquivo de dados aberto pelo usuario
  `data/parashiot/genesis/03-lech-lecha.json` nao faz parte deste passo visual.

### Proximo baby-step recomendado

Refinar a linha do tempo inferior para ficar mais proxima do target:

- transformar a regua atual em um dock horizontal mais legivel e premium;
- destacar periodos/segmentos com marcadores visuais e estados ativos;
- sincronizar a enfase da timeline com o card macro selecionado ou em hover;
- manter a timeline alimentada pelos dados atuais, sem criar uma segunda fonte
  de verdade.

### Baby-step concluido - timeline inferior

- A timeline inferior passou a ter um dock com faixa de eras clicaveis acima da
  regua AM.
- Os marcos de era sao renderizados a partir de `data/timeline_groups.json`,
  reutilizando `phases[]`, `visual.asset`, `label`, `am_start` e `am_end`.
- As setas laterais navegam para a fase anterior/proxima sem criar estado ou
  fonte de dados paralela.
- Hover e selecao da timeline agora compartilham o mesmo mecanismo
  `atlasSetHoverTarget` usado pelos cards do Atlas.
- A barra AM antiga foi preservada como regua de precisao abaixo dos marcos.

### Evolucao planejada - timeline como zoom semantico

A timeline inferior deve evoluir para uma lente de drill sincronizada com o
Atlas, baseada na estrutura multi-nivel dos JSONs:

- zoom 0: fases macro da tradicao;
- zoom 1: era/livro selecionado;
- zoom 2: milestones e agrupadores;
- zoom 3: parasha/unidade com marcadores de fatos;
- zoom 4: fato selecionado e referencia textual.

O mesmo principio vale para imagens: `visual.importance` deve decidir em que
nivel uma imagem aparece. Imagens de importancia alta podem representar um
periodo ou milestone em zoom generico; imagens mais locais aparecem apenas no
drill de parasha/fato.

### Baby-step concluido - timeline zoom 1 Chumash

- Quando o Atlas esta na lente Chumash em zoom 1, o dock inferior passa a
  renderizar os 5 livros do Chumash em vez das eras globais.
- Os cards da timeline usam `data/milestones/chumash.json` para a lista de
  livros e os `index.json` de cada livro para os ranges AM.
- Hover e clique nos livros da timeline usam os mesmos `kind: "book"` e
  `atlasSelect` dos cards centrais.
- Os badges dos tres macro cards passaram a usar paths SVG embutidos inspirados
  no `Atlas.dc.html`: `scroll`, `users` e `scale`. Os icones de rodape tambem
  seguem a mesma base (`bookOpen`, `leaf`, `heart`), sem adicionar novos
  arquivos.

### Ajuste concluido - Tora Escrita como TaNaCh

- O macro card **Tora Escrita** agora apresenta tres entradas coerentes com
  TaNaCh: **Chumash / 5 Livros**, **Profetas** e **Escritos**.
- Clicar em Chumash continua abrindo a lente dos 5 livros do Pentateuco.
- Clicar em Profetas abre uma lente propria baseada nos livros `data/nach/*`
  cuja `division` comeca com `neviim`.
- Clicar em Escritos abre uma lente propria baseada nos livros `data/nach/*`
  cuja `division` e `ketuvim`.
- Os livros de Profetas/Escritos abrem o drawer existente via `BOOK_META`, sem
  criar um segundo modelo de dados.

### Baby-step concluido - responsivo + dedup de zoom (2026-07-03)

- O dock inferior da timeline deixou de ser `position: fixed` e passou a viver
  no fluxo do documento: quando tudo cabe na tela o visual e identico ao mock;
  quando nao cabe, nada fica escondido atras do dock (corrige o BUG-04 de
  sobreposicao em ~1366px).
- O rail lateral esquerdo (Navegar / Zoom + / Zoom - / Centralizar) foi
  removido: duplicava a regua de zoom do topo e o Reset. A regua de pontos no
  topo e agora a unica affordance de zoom, com o `Reset` mantido na toolbar.
  O rail so retorna se agregar funcoes reais (centralizar, tela cheia).
- Breakpoints novos: topbar reflui em 2 linhas <=1280px (ferramentas
  decorativas ocultas); painel lateral desce abaixo do mapa e os tres macro
  cards empilham <=1100px; lista de eras do dock rola horizontalmente em telas
  estreitas.
- Validado com screenshots headless em 1366x768, 1920x1080, 768x1024 e na
  menor largura que o headless permite (~460px), com probe de overflow
  confirmando ausencia de scroll horizontal do documento.

### Baby-step concluido - timeline contextual expandida, fatia 1 (2026-07-04)

Referencia nova aceita: mock "Timeline contextual expandida - Melachim"
(fornecido pelo usuario em 2026-07-04): timeline do Atlas como painel
multi-faixa - eixo de anos, faixa de livros, acontecimentos, profetas/
personagens e reinados, com painel lateral de personagens do periodo.
Fonte HTML da proposta: `estrutura_tora_atlas_visual.html` (mesma pasta).

- Com um livro do Chumash selecionado (zoom >= 2), o dock troca os chips de
  era por um painel multi-faixa: eixo AM com ticks adaptativos, faixa
  **Parashiot** (barras posicionadas por `anno_mundi_start/end`, clique abre o
  drawer), faixa **Acontecimentos** (losangos de milestones filtrados por
  `visual.importance` - primeira aplicacao real da regra de promocao visual:
  zoom 2 mostra 4-5, zoom 3+ mostra 3-5) e faixa **Personagens** (spans
  derivados de `byCharacter`, top 8, ate 3 linhas empacotadas).
- Nenhuma fonte de dados nova: tudo deriva dos `index.json`, de
  `milestones/chumash.json` e do mart em runtime. A regua AM de precisao
  continua abaixo do painel.
- Pendencias mapeadas no backlog: estado de livro selecionado para Nach (hoje
  `nach-book` abre o drawer direto), faixas de reinados (exigem dados novos) e
  refinamento de barras em recortes densos.

### Baby-step concluido - quick wins do HTML da proposta (2026-07-04)

Com o fonte `estrutura_tora_atlas_visual.html` em maos, tres detalhes do mock
foram absorvidos no mesmo dia:

- **Niveis de zoom nomeados** sob a regua de pontos (Macro, Geral, Contexto,
  Detalhe, Profundidade), com o nivel ativo destacado em azul a cada render.
- **Labels de texto nos losangos** da faixa Acontecimentos, alternando acima/
  abaixo do marcador para reduzir colisao (alem do tooltip que ja existia).
- **Card "Sobre o periodo"** no painel lateral quando um livro esta em foco:
  nome + hebraico, `timeline.description`, periodo aproximado em AM e
  abrangencia principal (ref inicial-final), tudo derivado do `index.json`.

Nao absorvido de proposito: o rail lateral de Navegar/Zoom/Centralizar do mock
(duplicaria a regua canonica - decisao de 2026-07-03) e o eixo em a.E.C.
(o projeto usa AM como calendario canonico; conversao dupla fica para
avaliacao futura).

## Guardrails

- Nao copiar HTML exportado diretamente para `index.html`; converter ideias em
  componentes CSS/JS compativeis com o app atual.
- Nao remover fluxos existentes: abas, drawer, i18n, Sefaria e rotas de dados.
- Nao introduzir framework.
- Nao depender de fontes externas sem avaliar fallback e deploy offline.
- Nao capturar o scroll do mouse para zoom/drill por padrao; exigir ativacao
  explicita por checkbox/toggle.
- Nao trocar o Atlas atual por uma versao nova antes de validar em desktop e
  mobile.
- Preferir pequenas PRs/commits: foundation, Estrutura intro, Estrutura cards,
  drawer, Atlas prototipo.

## Decisao recomendada

Adotar a proposta como direcao visual para a proxima fase, com prioridade para
a aba Estrutura. O Atlas deve ser tratado como exploracao de produto em paralelo
e absorvido somente depois que as ideias de camadas, zoom e painel lateral
forem testadas com os dados reais do projeto.
