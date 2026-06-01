# Schema de Parashiot — Torá Explorer

## Estrutura de arquivos

```
data/
  timeline.json                    ← Régua global (eras + eventos-chave)
  parashiot/
    genesis/
      index.json                   ← Índice das 12 parashiot de Gênesis (metadados leves)
      01-bereshit.json             ← Dados completos com facts
      02-noach.json
      ...
    exodus/
      index.json
      01-shemot.json
      ...
    leviticus/
      index.json
      01-vayikra.json
      ...
    numbers/
      index.json
      01-bamidbar.json
      ...
```

---

## Schema completo de uma parasha (`XX-nome.json`)

```json
{
  "meta": {
    "schema_version": "1.0",
    "book": "Genesis",                     // nome em inglês (para Sefaria API)
    "book_he": "בְּרֵאשִׁית",
    "book_sefaria": "Genesis",             // exatamente como a Sefaria usa
    "parasha_index": 1,                    // número global (1-54)
    "parasha_of_book": 1,                  // número dentro do livro
    "total_parashiot_in_book": 12
  },

  "identity": {
    "id": "bereshit",                      // slug único, sem acentos
    "name": "Bereshit",
    "name_pt": "No princípio",             // tradução portuguesa
    "hebrew": "בְּרֵאשִׁית",
    "transliteration": "Bereshit",
    "aliyot_count": 7
  },

  "range": {
    "ref_start": "Genesis 1:1",           // primeiro versículo
    "ref_end": "Genesis 6:8",             // último versículo
    "sefaria_ref": "Genesis 1:1-6:8",    // para chamada direta à API
    "chapters_covered": [1, 2, 3, 4, 5, 6],
    "chapter_start": 1,
    "chapter_end": 6,
    "verse_start": 1,
    "verse_end": 8
  },

  "timeline": {
    "period_name": "Criação e primeiras gerações",
    "anno_mundi_start": 0,               // ano judaico de início
    "anno_mundi_end": 1056,              // ano judaico de fim
    "era": "pre-diluvio",               // id da era em timeline.json
    "position_pct": 0,                  // posição % na régua 0-100
    "description": "..."
  },

  "summary": {
    "short": "...",                      // 1 frase
    "medium": "...",                     // 2-3 parágrafos
    "characters_main": [],              // personagens principais
    "characters_secondary": [],
    "themes": []
  },

  "facts": [
    {
      "id": "b001",                     // prefixo da parasha + número
      "order": 1,                       // ordem de exibição
      "text": "...",                    // resumo do fato em português
      "text_he": "...",                // passuk-chave em hebraico (opcional)
      "refs": ["Genesis 1:1-2"],       // array de refs (pode ter mais de uma)
      "ref_start": "Genesis 1:1",      // para abrir no leitor
      "ref_end": "Genesis 1:2",
      "chapter": 1,                    // capítulo principal
      "verse_start": 1,
      "verse_end": 2,
      "sefaria_ref": "Genesis 1:1-2", // ref pronta para a API
      "day_of_creation": 1,           // null se não aplicável
      "tags": ["criação", "luz"],
      "topic": "Criação — Yom 1"      // agrupador temático
    }
  ],

  "aliyot": [
    {
      "number": 1,
      "ref_start": "Genesis 1:1",
      "ref_end": "Genesis 2:3",
      "sefaria_ref": "Genesis 1:1-2:3"
    }
  ],

  "haftarah": {
    "ref": "Isaiah 42:5-43:10",
    "sefaria_ref": "Isaiah 42:5-43:10",
    "note": "..."
  },

  "connections": {
    "next_parasha": "noach",
    "prev_parasha": null,
    "thematic_links": [
      { "parasha": "yitro", "theme": "..." }
    ]
  }
}
```

---

## Regras de preenchimento dos `facts`

### `refs` — formato Sefaria
Use sempre o nome em inglês conforme a Sefaria reconhece:

| Livro       | Sefaria name   |
|-------------|---------------|
| Gênesis     | `Genesis`     |
| Êxodo       | `Exodus`      |
| Levítico    | `Leviticus`   |
| Números     | `Numbers`     |
| Deuteronômio| `Deuteronomy` |
| Josué       | `Joshua`      |
| Ester       | `Esther`      |
| Salmos      | `Psalms`      |

Formato da ref: `"Book Chapter:Verse"` ou `"Book Chapter:VerseStart-VerseEnd"`

### Spans entre capítulos
Quando o fato atravessa capítulos (ex: Gen 4:17 → Gen 6:8), use:
```json
{
  "ref_start": "Genesis 4:17",
  "ref_end": "Genesis 6:8",
  "sefaria_ref": "Genesis 4:17-6:8",
  "chapter": 4,
  "verse_start": 17,
  "verse_end_chapter": 6,
  "verse_end": 8
}
```

### `id` — convenção de prefixos por parasha

| Parasha       | Prefixo |
|---------------|---------|
| Bereshit      | `b`     |
| Noach         | `n`     |
| Lech Lecha    | `ll`    |
| Vayera        | `va`    |
| Chayei Sarah  | `cs`    |
| Toldot        | `tl`    |
| Vayetze       | `vtz`   |
| Vayishlach    | `vs`    |
| Vayeshev      | `vsh`   |
| Miketz        | `mk`    |
| Vayigash      | `vg`    |
| Vayechi       | `vc`    |
| Vayikra       | `vy`    |
| Tzav          | `tzv`   |
| Shemini       | `shm`   |
| Tazria        | `tzr`   |
| Metzora       | `mtz`   |
| Achrei Mot    | `am`    |
| Kedoshim      | `kd`    |
| Emor          | `em`    |
| Behar         | `bh`    |
| Bechukotai    | `bc`    |
| Bamidbar      | `bm`    |
| Nasso         | `ns`    |
| Behaalotecha  | `bhlt`  |
| Shelach       | `sl`    |
| Korach        | `kr`    |
| Chukat        | `chk`   |
| Balak         | `blk`   |
| Pinchas       | `pn`    |
| Matot         | `mt`    |
| Masei         | `ms`    |

---

## Como adicionar uma nova parasha

1. Copie o template acima
2. Preencha `meta`, `identity`, `range`, `timeline`, `summary`
3. Adicione os `facts` — um por tópico, com `ref_start`/`ref_end` precisos
4. Atualize `data/parashiot/[livro]/index.json` com `facts_count` correto
5. O drawer e o leitor de Pessukim usarão os dados automaticamente

---

## Conexão com o leitor de Pessukim

Cada `fact` com `ref_start` definido gera automaticamente um botão
**"Abrir versículos"** no drawer da parasha. Ao clicar:

1. O leitor de Pessukim muda para o livro/capítulo correto
2. Carrega os versículos da Sefaria API
3. Rola até o `verse_start` e destaca o range `verse_start → verse_end`

---

## Régua histórica (`position_pct`)

Cada parasha tem um `position_pct` de 0 a 100 indicando sua posição
na régua completa (da Criação até hoje ~5785 AM).

```
Bereshit (0 AM)  →  pos: 0%
Sinai (2448 AM)  →  pos: 44%
Hoje (5785 AM)   →  pos: 100%
```

Fórmula: `position_pct = (anno_mundi_start / 5785) * 100`
