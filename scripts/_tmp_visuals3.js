// One-off: ícones de fato (Êxodo→Devarim) + visual nos milestones do Chumash Atlas
const fs = require('fs');
const path = require('path');
const root = path.join(__dirname, '..');
const dir = p => path.join(root, p);
const V = (icon, caption, imp) =>
  `{ "marker_type": "icon", "icon": "${icon}", "asset": "assets/icons/${icon}.svg", "caption": "${caption}"${imp ? `, "importance": ${imp}` : ''} }`;

// ===== 1. Ícones de fato =====
const FACTS = {
  'exodus/01-shemot.json': {
    "A Escravidão — Trabalho Forçado": ['chains', 'A escravidão no Egito', 4],
    "Nascimento de Moshe — A Cesta no Nilo": ['basket', 'O cesto no Nilo', 5],
    "Revelação do Nome Divino — Ehyeh Asher Ehyeh": ['light', 'Ehyeh Asher Ehyeh', 4],
  },
  'exodus/02-vaera.json': {
    "Revelação do Nome יהוה — A Aliança Renovada": ['covenant', 'A aliança renovada', 4],
    "O Bastão-Serpente — Sinal Inicial": ['staff', 'O bastão de Moshe', 4],
    "Praga 1 — Sangue (Dam)": ['drop', 'As águas em sangue', 5],
  },
  'exodus/03-bo.json': {
    "O Korban Pessach — Sangue, Maror e Matzá": ['door', 'O Korban Pessach', 5],
    "O Êxodo — 600 Mil Homens Partem": ['journey', 'A saída do Egito', 5],
    "O Primeiro Mandamento — Qidush HaChodesh": ['star', 'Qidush HaChodesh', 3],
  },
  'exodus/04-beshalach.json': {
    "Coluna de Nuvem e de Fogo": ['cloud', 'Coluna de nuvem e fogo', 4],
    "A Divisão do Mar dos Juncos": ['sea', 'O mar se abre', 5],
    "Shirat HaYam — O Cântico do Mar": ['harp', 'O Cântico do Mar', 4],
    "O Maná — Pão do Céu": ['wheat', 'O maná', 4],
  },
  'exodus/05-yitro.json': {
    "O Conselho de Yitro — Delegação da Justiça": ['scales', 'O conselho de Yitro', 3],
    "Israel Chega ao Sinai — Terceiro Mês": ['mountains', 'Ao pé do Sinai', 4],
    "Os Dez Mandamentos — Aseret HaDibrot": ['tablets', 'Os Dez Mandamentos', 5],
  },
  'exodus/06-mishpatim.json': {
    "Leis de Homicídio e Danos — 'Olho por Olho'": ['scales', 'As leis civis', 4],
    "'Faremos e Ouviremos' — Na'aseh veNishmah": ['covenant', "Na'aseh veNishmah", 5],
    "Moshe Sobe — Quarenta Dias na Nuvem": ['cloud', 'Quarenta dias na nuvem', 4],
  },
  'exodus/07-terumah.json': {
    "'Farão para Mim um Santuário' — A Shechina entre Israel": ['light', 'A Shechiná entre Israel', 4],
    "A Arca da Aliança — Aron HaBrit": ['mishkan', 'O Aron HaBrit', 5],
    "A Menorá — Sete Braços de Ouro Puro": ['menorah', 'A Menorá', 4],
  },
  'exodus/08-tetzaveh.json': {
    "O Azeite Puro — Luz Permanente da Menorá": ['menorah', 'Ner tamid', 4],
    "O Choshen — Peitoral com Urim e Tumim": ['crown', 'O Choshen do Cohen Gadol', 4],
    "A Oferta Tamid — Dois Cordeiros Diários": ['altar', 'A oferta Tamid', 3],
  },
  'exodus/09-ki-tisa.json': {
    "Machatzit HaShekel — O Meio-Shekel do Censo": ['coins', 'O meio-shekel', 3],
    "As Primeiras Tábuas — Escritas pelo Dedo de Deus": ['tablets', 'As primeiras Tábuas', 5],
    "O Bezerro de Ouro — Um Deus Visível": ['calf', 'O bezerro de ouro', 5],
    "Os 13 Atributos de Misericórdia": ['light', 'Os 13 atributos', 4],
  },
  'leviticus/01-vayikra.json': {
    "Olah — Entrega total": ['altar', 'A Olah', 4],
    "Minchah — Oferta vegetal": ['wheat', 'A Minchá', 3],
  },
  'leviticus/02-tzav.json': {
    "Fogo contínuo do altar": ['fire', 'O fogo perpétuo', 5],
    "Miluim — Sete dias de consagração": ['crown', 'Os Miluim', 3],
  },
  'leviticus/03-shemini.json': {
    "A Presença aparece": ['light', 'A glória aparece', 5],
    "Fogo estranho": ['fire', 'O fogo estranho', 4],
    "Kashrut — Animais permitidos e proibidos": ['scales', 'As leis de kashrut', 3],
  },
  'leviticus/04-tazria.json': {
    "Brit Milah no oitavo dia": ['covenant', 'Brit Milá', 4],
    "Primeiro diagnóstico de tzaraat": ['drop', 'O diagnóstico de tzaraat', 3],
  },
  'leviticus/05-metzora.json': {
    "Aves e símbolos de purificação": ['olive-branch', 'A purificação', 4],
    "Tzaraat nas casas": ['door', 'Tzaraat nas casas', 3],
  },
  'leviticus/06-achrei-mot.json': {
    "O bode para Azazel": ['mountains', 'O bode para Azazel', 4],
    "Yom Kippur para todas as gerações": ['shofar', 'Yom Kipur', 5],
  },
  'leviticus/07-kedoshim.json': {
    "Kedoshim tihyu": ['tzaddik', 'Sede santos', 5],
    "Peah e leket": ['wheat', 'Peah e leket', 3],
    "Ama teu próximo": ['covenant', 'Veahavta lereacha', 5],
  },
  'leviticus/08-emor.json': {
    "Moedim — Tempos sagrados": ['candles', 'Os Moedim', 5],
    "Luz e pão diante de Deus": ['menorah', 'Luz e pão diante de Deus', 3],
  },
  'leviticus/09-behar.json': {
    "Shemitá — Descanso da terra": ['wheat', 'A Shemitá', 4],
    "Yovel — Liberdade proclamada": ['shofar', 'O Yovel', 5],
  },
  'leviticus/10-bechukotai.json': {
    "Chuva e abundância": ['drop', 'As chuvas de bênção', 3],
    "Memória da aliança": ['covenant', 'A memória da aliança', 4],
  },
  'numbers/01-bamidbar.json': {
    "Censo nacional": ['banner', 'O censo', 4],
    "Mapa das tribos": ['tent', 'O acampamento das tribos', 4],
  },
  'numbers/02-nasso.json': {
    "Nazir": ['vine', 'O Nazir', 3],
    "Bênção sacerdotal": ['light', 'Birkat Cohanim', 5],
  },
  'numbers/03-behaalotecha.json': {
    "Acendimento da menorah": ['menorah', 'Ao acenderes as lâmpadas', 5],
    "Nuvem orientadora": ['cloud', 'A nuvem orientadora', 4],
    "Trombetas de prata": ['shofar', 'As trombetas de prata', 3],
  },
  'numbers/04-shelach.json': {
    "Frutos de Canaã": ['vine', 'O cacho de Eshkol', 5],
    "Sentença da geração": ['journey', 'Quarenta anos no deserto', 4],
  },
  'numbers/05-korach.json': {
    "Teste dos incensários": ['fire', 'Os incensários', 5],
    "Abertura da terra": ['mountains', 'A terra se abre', 4],
    "Vara florescida": ['staff', 'A vara de Aharon floresce', 4],
  },
  'numbers/06-chukat.json': {
    "Novilha vermelha": ['calf', 'A pará adumá', 4],
    "Águas de Merivah": ['drop', 'As águas de Merivá', 5],
    "Serpente de cobre": ['serpent', 'A serpente de cobre', 4],
  },
  'numbers/07-balak.json': {
    "Tendas de Israel": ['tent', 'Ma tovu ohalecha', 5],
    "Oráculos finais": ['star', 'A estrela de Yaakov', 5],
  },
  'numbers/08-pinchas.json': {
    "Aliança de Pinchas": ['covenant', 'A aliança de paz', 5],
    "Filhas de Tzelofchad": ['scales', 'As filhas de Tzelofchad', 4],
    "Nomeação de Yehoshua": ['banner', 'Yehoshua nomeado', 4],
  },
  'numbers/09-matot.json': {
    "Leis de votos": ['scroll', 'Os votos', 4],
    "Herança transjordânica": ['mountains', 'As terras a leste', 3],
  },
  'numbers/10-masei.json': {
    "Registro das jornadas": ['journey', 'As 42 jornadas', 5],
    "Cidades de refúgio": ['door', 'As cidades de refúgio', 4],
  },
  'deuteronomy/01-devarim.json': {
    "Abertura dos discursos": ['scroll', 'As palavras de Moshe', 4],
    "Crise dos espiões": ['vine', 'A memória dos espiões', 3],
  },
  'deuteronomy/02-vaetchanan.json': {
    "Súplica de Moshe": ['mountains', 'Vaetchanan — a súplica', 3],
    "Dez Mandamentos": ['tablets', 'Os Dez Mandamentos repetidos', 5],
    "Shema e amor a Deus": ['light', 'Shemá Yisrael', 5],
  },
  'deuteronomy/03-eikev.json': {
    "Maná e dependência": ['wheat', 'O maná e a dependência', 4],
    "Memória do bezerro": ['calf', 'A memória do bezerro', 3],
    "Circuncidar o coração": ['covenant', 'Circuncidar o coração', 4],
  },
  'deuteronomy/04-reeh.json': {
    "Escolha diante de Israel": ['mountains', 'Bênção e maldição', 5],
    "Shemitah e tsedakah": ['coins', 'Shemitá e tsedacá', 3],
    "Festas de peregrinação": ['candles', 'As três festas', 4],
  },
  'deuteronomy/05-shoftim.json': {
    "Justiça local": ['scales', 'Tzedek tzedek tirdof', 5],
    "Lei do rei": ['crown', 'A lei do rei', 4],
    "Cidades de refúgio": ['door', 'As cidades de refúgio', 3],
  },
  'deuteronomy/06-ki-teitzei.json': {
    "Cuidado com o outro": ['olive-branch', 'O ninho de pássaros', 4],
    "Justiça e Amalek": ['scroll', 'Lembrar Amalek', 3],
  },
  'deuteronomy/07-ki-tavo.json': {
    "Primeiros frutos": ['basket', 'Os bikurim', 5],
    "Torá em pedras": ['tablets', 'A Torá nas pedras', 4],
    "Cerimônia da aliança": ['mountains', 'Grizim e Eival', 4],
  },
  'deuteronomy/08-nitzavim.json': {
    "Todos de pé": ['covenant', 'Nitzavim — todos diante de Deus', 5],
    "Escolhe a vida": ['tree', 'Escolhe a vida', 5],
  },
  'deuteronomy/09-vayeilech.json': {
    "Torá entregue": ['scroll', 'A Torá entregue', 5],
    "Hakhel": ['banner', 'Hakhel', 3],
  },
  'deuteronomy/10-haazinu.json': {
    "Chamado ao testemunho": ['harp', 'O cântico-testemunha', 5],
    "Deus como Rocha": ['mountains', 'HaTzur — a Rocha', 4],
  },
  'deuteronomy/11-vezot-haberakhah.json': {
    "Bênçãos finais das tribos": ['scroll', 'As bênçãos das tribos', 5],
    "Morte de Moshe": ['mountains', 'Moshe no monte Nevo', 5],
    "Conclusão da Torá": ['tablets', 'A conclusão da Torá', 4],
  },
};

let errors = 0, totFacts = 0;
for (const [rel, map] of Object.entries(FACTS)) {
  const file = `data/parashiot/${rel}`;
  let txt = fs.readFileSync(dir(file), 'utf8');
  for (const [topic, [ic, cap, imp]] of Object.entries(map)) {
    const esc = topic.replace(/"/g, '\\"');
    const line = `      "topic": "${esc}"`;
    if (!txt.includes(line)) { console.error(`${file}: topic não encontrado: ${topic}`); errors++; continue; }
    if (txt.includes(`${line},\n      "visual"`)) continue;
    txt = txt.replace(line, `${line},\n      "visual": ${V(ic, cap, imp)}`);
    totFacts++;
  }
  fs.writeFileSync(dir(file), txt);
  JSON.parse(fs.readFileSync(dir(file), 'utf8'));
}
console.log(`Facts: ${totFacts} marcadores adicionados em ${Object.keys(FACTS).length} arquivos`);

// ===== 2. Milestones do Chumash Atlas =====
const MILESTONES = {
  'gen-creation': ['light', 'Criação do Mundo'], 'gen-eden-fall': ['tree', 'Eden e a queda'],
  'gen-cain-abel': ['altar', 'Kayin e Hevel'], 'gen-flood': ['ark', 'Dilúvio e Teivá'],
  'gen-babel': ['tower', 'Torre de Babel'], 'gen-avraham-call': ['journey', 'Chamado de Avraham'],
  'gen-brit-milah': ['covenant', 'Brit Milá'], 'gen-sedom-akedah': ['shofar', 'Sedom e Akedá'],
  'gen-rivka-toldot': ['bowl', 'Rivka, Yaakov e Essav'], 'gen-yaakov-tribes': ['ladder', 'As 12 tribos'],
  'gen-yosef': ['coat', 'Yossef'], 'gen-egypt-descent': ['wagon', 'Descida ao Egito'],
  'exo-slavery': ['chains', 'Escravidão'], 'exo-moshe-born': ['basket', 'Nascimento de Moshe'],
  'exo-burning-bush': ['fire', 'Sarça ardente'], 'exo-plagues': ['staff', 'As 10 pragas'],
  'exo-pesach': ['door', 'Pessach'], 'exo-sea': ['sea', 'Abertura do mar'],
  'exo-manna': ['wheat', 'Maná'], 'exo-sinai': ['tablets', 'Sinai'],
  'exo-laws': ['scales', 'Mishpatim'], 'exo-mishkan-design': ['mishkan', 'O Mishkan'],
  'exo-golden-calf': ['calf', 'Bezerro de Ouro'], 'exo-second-tablets': ['tablets', 'Segundas Tábuas'],
  'lev-offerings': ['altar', 'Korbanot'], 'lev-priests': ['crown', 'Os cohanim'],
  'lev-purity': ['drop', 'Pureza e cura'], 'lev-yom-kippur': ['scales', 'Yom Kipur'],
  'lev-holiness': ['tzaddik', 'Kedoshim'], 'lev-festivals': ['candles', 'As festas'],
  'lev-shemita-yovel': ['shofar', 'Shemitá e Yovel'],
  'num-census': ['banner', 'O censo'], 'num-camp': ['tent', 'O acampamento'],
  'num-complaints': ['bowl', 'Reclamações'], 'num-spies': ['vine', 'Os espiões'],
  'num-korach': ['fire', 'Korach'], 'num-bronze-serpent': ['serpent', 'Serpente de cobre'],
  'num-bilam': ['star', 'Bilam'], 'num-pinchas': ['covenant', 'Pinchas'],
  'num-daughters': ['scales', 'Filhas de Tzelofchad'],
  'deut-review': ['scroll', 'Revisão da jornada'], 'deut-ten-commandments': ['tablets', 'Os 10 Mandamentos'],
  'deut-shema': ['light', 'Shemá Yisrael'], 'deut-land-warning': ['wheat', 'A terra boa'],
  'deut-central-place': ['mishkan', 'O lugar escolhido'], 'deut-justice': ['scales', 'Justiça'],
  'deut-blessings-curses': ['mountains', 'Bênçãos e maldições'], 'deut-haazinu': ['harp', 'Haazinu'],
  'deut-final-blessing': ['scroll', 'A bênção final'], 'deut-moshe-death': ['mountains', 'Morte de Moshe'],
};
const msFile = 'data/milestones/chumash.json';
let ms = fs.readFileSync(dir(msFile), 'utf8');
if (!ms.includes('"visual"')) {
  const lines = ms.split('\n');
  let count = 0;
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^(\s+)"id": "([a-z0-9-]+)",$/);
    if (m && MILESTONES[m[2]]) {
      const [ic, cap] = MILESTONES[m[2]];
      lines[i] += `\n${m[1]}"visual": ${V(ic, cap)},`;
      count++;
    }
  }
  ms = lines.join('\n');
  fs.writeFileSync(dir(msFile), ms);
  JSON.parse(fs.readFileSync(dir(msFile), 'utf8'));
  console.log(`Milestones: ${count} blocos visual adicionados`);
}

// valida assets
const refs = new Set();
const scan = d => fs.readdirSync(d, { withFileTypes: true }).forEach(e => {
  const p = path.join(d, e.name);
  if (e.isDirectory()) scan(p);
  else if (e.name.endsWith('.json'))
    (fs.readFileSync(p, 'utf8').match(/assets\/icons\/[a-z-]+\.svg/g) || []).forEach(r => refs.add(r));
});
scan(dir('data'));
for (const r of refs) if (!fs.existsSync(dir(r))) { console.error('asset faltando: ' + r); errors++; }
console.log(errors ? `ERROS: ${errors}` : 'Assets OK');
process.exit(errors ? 1 : 0);
