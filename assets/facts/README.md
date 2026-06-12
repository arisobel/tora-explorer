# Ilustrações de fatos — convenção

Estrutura: `assets/facts/<livro>/<parasha-ou-unidade>/<slug>.jpg|png|webp`

```
assets/facts/
  exodus/
    shemot/
      sarca-ardente.jpg     ← referenciada em data/parashiot/exodus/01-shemot.json (fato sm010)
```

## Como adicionar uma ilustração

1. Salve a imagem aqui seguindo a convenção de pastas (slug sem acentos, minúsculo).
2. No JSON do fato (ou no nível raiz da parashá, para banner), adicione:

```json
"visual": {
  "marker_type": "image",
  "asset": "assets/facts/<livro>/<parasha>/<slug>.jpg",
  "caption": "Legenda curta (obrigatória)",
  "importance": 5
}
```

3. Render automático:
   - **Fato** → bloco de ilustração com legenda dentro do card do fato.
   - **Parashá (nível raiz)** → banner no topo do cabeçalho do drawer.
   - Se o arquivo não existir, o bloco se esconde sozinho (`onerror`) — nada quebra.
4. Rode `scripts/build-caprover.ps1` e publique (a pasta `assets/` inteira vai no tar).

Recomendações: JPG/WebP ≤ 300 KB, largura ~1024px. Nunca base64 dentro do JSON.
