# assets/user — imagens adicionadas em runtime (volume CapRover)

Esta pasta é o ponto de montagem de um **volume persistente do CapRover**.
Imagens colocadas aqui **persistem entre deploys** (não vão para o git e não
incham a imagem Docker). Em produção o conteúdo desta pasta vem do volume,
não do repositório — o `.gitkeep` apenas garante que o caminho exista.

## Como referenciar uma imagem daqui

Num bloco `visual` de qualquer JSON (fato, parashá, livro, milestone…):

```json
"visual": {
  "marker_type": "image",
  "asset": "assets/user/<slug>.jpg",
  "caption": "Legenda da ilustração",
  "importance": 4
}
```

Nenhuma mudança de código é necessária — o render (`visualMarkerHTML` /
`illustrationHTML`) já usa `asset` diretamente.

## Convenção de nomes

`assets/user/<contexto>-<slug>.jpg` — ex.: `ester-banquete-achashverosh.jpg`,
`shemot-sarca-ardente.jpg`. Use minúsculas, sem espaços nem acentos.

## Otimize ANTES de subir

O filebrowser sobe o arquivo cru. Rode o otimizador local primeiro
(imagens grandes deixam a galeria pesada):

```powershell
pwsh scripts/optimize-image.ps1 -In "C:\Downloads\foto.png" -Out "saida.jpg"
```

Depois suba `saida.jpg` pelo filebrowser. Ver `docs/04_technical/USER_IMAGE_UPLOADS.md`
para o passo a passo completo (setup do volume e do filebrowser no CapRover).

## Curada vs. usuário

- **Curada (no git):** `assets/facts/<livro>/<parasha>/<slug>.jpg` — conteúdo
  oficial que vai embutido no deploy (ex.: a sarça ardente).
- **Runtime (volume):** `assets/user/<slug>.jpg` — esta pasta.
