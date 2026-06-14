# Upload de imagens (autor) via volume CapRover + filebrowser

**Decisão (2026-06-14):** só o autor sobe imagens; abordagem **sidecar filebrowser**.
O app principal continua **100% estático** — ele apenas *serve* e *referencia*
`assets/user/`. Um container separado (filebrowser, protegido por senha)
*escreve* no mesmo volume. Nada de backend dentro do Torá Explorer.

```
  navegador do autor ──▶ filebrowser (senha) ──escreve──▶ ┌──────────────┐
                                                          │ VOLUME       │
  navegador do visitante ◀── nginx (app) ──serve────────  │ tora-user    │
                                                          └──────────────┘
                                       (mesmo diretório no host, 2 apps)
```

## Por que funciona sem mudar o app

As funções de render (`visualMarkerHTML` / `illustrationHTML` em `index.html`)
já usam `visual.asset` direto. Referenciar uma imagem do volume é só apontar
`"asset": "assets/user/<arquivo>.jpg"` num bloco `visual`. Zero código novo.

O nginx já serve `assets/user/` (está sob `root`), e foi adicionado um bloco
`location ^~ /assets/user/ { Cache-Control: no-cache; }` para que imagens
trocadas apareçam na hora (revalidação por ETag).

---

## Passo a passo no painel CapRover (feito por você — eu não tenho acesso)

### 1. Escolher um diretório compartilhado no host
Os dois apps vão montar **o mesmo caminho no host**. Ex.:
```
/captain/data/tora-user-images
```

### 2. App principal (`tora-explorer`) → Persistent Directory
App Configs → **Persistent Directories** → adicionar:
- **Path in App:** `/usr/share/nginx/html/assets/user`
- Alternar para **"specific path on host"** e usar: `/captain/data/tora-user-images`

Salvar e fazer redeploy. (O volume começa vazio; o `.gitkeep` do repo é
sobreposto pelo volume — normal.)

### 3. Criar o app filebrowser
- Apps → **Create New App** → nome `tora-files` (habilitar "Has Persistent Data").
- Deployment → imagem: `filebrowser/filebrowser:latest`.
- **Persistent Directories** do `tora-files`:
  - **Path in App:** `/srv` → **specific path on host:** `/captain/data/tora-user-images`
    *(o MESMO caminho do passo 2 — é isso que compartilha os arquivos)*
  - **Path in App:** `/database` → label próprio (ex.: `tora-files-db`) — guarda o banco/login do filebrowser.
- Habilitar HTTPS e um subdomínio (ex.: `files.tora-explorer.lion.app.br`).

### 4. Senha
O filebrowser sobe com `admin` / `admin`. **Troque imediatamente** no painel
dele (Settings → User Management). Mantenha o `tora-files` atrás de HTTPS.

### 5. Testar
1. Suba uma imagem `.jpg` pelo filebrowser (cai em `/srv` = volume).
2. Acesse `https://tora-explorer.lion.app.br/assets/user/<arquivo>.jpg` —
   deve abrir (o app serve do mesmo volume).
3. Referencie no JSON e recarregue.

---

## Fluxo de autoria (uso no dia a dia)

1. **Otimize** a imagem localmente (o filebrowser sobe o arquivo cru):
   ```powershell
   pwsh scripts/optimize-image.ps1 -In "C:\Downloads\foto.png" -Out "ester-banquete.jpg"
   ```
2. **Suba** `ester-banquete.jpg` pelo filebrowser.
3. **Referencie** num bloco `visual`:
   ```json
   "visual": {
     "marker_type": "image",
     "asset": "assets/user/ester-banquete.jpg",
     "caption": "O banquete de Achashverosh",
     "importance": 4
   }
   ```
4. Como JSONs são `no-cache`, basta recarregar a página.

> Edição do JSON ainda é manual (autor-only). Um `editor.html` local que
> lista o conteúdo do volume e gera o bloco `visual` é um próximo passo
> possível, mas não necessário agora.

## Pontos em aberto / futuros
- Resize automático no upload exigiria um pequeno serviço — por ora, o script local resolve.
- Smoke-check de que um `asset: assets/user/...` referenciado resolve (404 silencioso hoje cai no `onerror` que esconde a imagem).
