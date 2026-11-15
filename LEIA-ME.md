# O Estudante da UNIFESP: Assembly RISC-V

Jogo de plataforma 2D feito em assembly RISC-V para rodar no simulador **FPGRARS** (versão de cor de 8 bits, a "unb").

## Como jogar (Windows)

Dê dois cliques em **`jogar.bat`**.

| Tecla | Ação |
|---|---|
| A / ← | andar para a esquerda |
| D / → | andar para a direita |
| W / ↑ / ESPAÇO | pular (segure para pular mais alto) |
| 1, 2, 3, 4 | responder as perguntas do chefão |
| ENTER | confirmar / avançar (e pular o filminho do golpe final) |
| M | liga / desliga o som |
| ESC | sair |

Há também **atalhos de teste** (5, 6, 7, 8, 9, 0, I, V, K, J, G, N, T, B, P, C) para achar bugs mais rápido: veja a seção *Para testar rápido*. **Desligue-os antes de entregar** (`DEBUG_ATALHOS = 0` no `main.s`).

O jogo tem hoje:

1. **Tela inicial** e **explicação** (história e como jogar).
2. **Treino no campus**: dicas na tela ensinam os comandos; termina na **porta da UNIFESP**: o estudante encosta na porta, ela abre, ele entra e a porta fecha (como o herói entrando no castelo).
3. **Fase 1: Cálculo 1**: sala de aula com a cobra da integral (anda), o fantasma do limite (voa) e a derivada (pula). No fim da sala, a arena do **Livro do Stewart**: ele derruba integrais e, a cada 8 segundos, faz uma pergunta de Cálculo. Três acertos vencem o livro; cada erro tira um coração. O golpe final (de um lado ou do outro) passa um **filminho** de ataque especial: faixas de cinema, retrato grande de quem atacou ("PROVA SURPRESA!" ou "RESPOSTA CERTA!"), clarão e o resultado ("REPROVADO!" ou "APROVADO!").
4. **Fase 2: AED** (Algoritmos e Estruturas de Dados): laboratório de computação, mais comprido (110 colunas), com pilhas (andam), nós de grafo (pulam) e ponteiros (voam), todos 25% mais rápidos, e **espinhos** no chão que tiram coração. No fim, **O GRAFO**: 4 vidas, pergunta a cada 7 s e joga 2 setas em leque.
5. **Fase 3: AOC** (Arquitetura e Organização de Computadores), a fase final: dentro do computador, ainda mais comprida (140 colunas), com bits (pulam), bugs (voam), portas lógicas e chips (andam), 50% mais rápidos, e muitos **curtos-circuitos** no chão. No fim, o chefão final, o **PROFESSOR CAPPA** (desenhado parecido com o nosso professor): 5 vidas, pergunta a cada 6,5 s, joga 3 bits (0 e 1) em leque e anda mais rápido.
6. **Formatura**: tela de parabéns com fogos de artifício; ENTER volta ao menu.

**Cronômetro:** cada fase tem um tempo, mostrado no alto da tela ao lado dos corações: treino 1 min, Fase 1 3 min, Fase 2 4 min e Fase 3 4 min e 30 s. Ele corre durante o jogo e durante as perguntas, fica amarelo no último minuto e vermelho (com "tique") nos últimos 10 s. Se zerar, passa o filminho do relógio ("FIM DO TEMPO!") e o estudante **"REPROVOU POR FALTA!"**: GAME OVER e a fase recomeça. Para mudar os tempos, edite o último número de cada fase em `src/dados/fases.s` (`F_TEMPO`, em segundos).

**Filminho em toda derrota:** além do chefão, quando o estudante perde o último coração para um monstrinho, para os espinhos ou para o curto-circuito, também passa o filminho de derrota, com o retrato de quem venceu e o golpe dele (ex.: "A PILHA usa: STACK OVERFLOW!", "O BUG usa: TELA AZUL!").

Todos os chefões são vencidos do mesmo jeito: respondendo perguntas da matéria (acerto = o chefão perde 1 vida; erro = o estudante perde 1 coração).

Sem corações, o estudante cai da tela (animação de morte), aparece o GAME OVER e ENTER recomeça a mesma fase.

### Som

O FPGRARS só tem som por MIDI (ecall 31), então os efeitos são notas MIDI, em `src/rotinas/sfx.s`: pulo, pisão, dano, item/resposta certa, porta, menu, começo de fase, golpe no chefão, chefão derrotado, game over e os dois do filminho.

Os **monstrinhos** têm "voz" (tabela `sons_monstros` de `dados/monstros.s`): ela toca quando o monstro entra na tela e depois, a cada 2 a 3 s, um monstro da tela "fala" (um por vez). Treino: o de Cálculo faz "bwah-bwah" de trombone, o de AOC faz bipes de computador. Fase 1: a cobra da integral faz "tsss", o fantasma do limite faz "uuuu", a derivada faz "bóing" (e um a cada pulo). Os que andam no chão também fazem som ao virar. Monstro fora da tela fica quieto. Os monstros das Fases 2 e 3 também têm voz: o ponteiro faz "fiiu", a pilha "pof-pof-pof", o nó do grafo "bloop", o bit "bip-bop", o bug zumbe e a porta lógica faz "clic-clac" de relé. O **Livro do Stewart** tem acorde ameaçador na entrada, um "ziu" elétrico quando lança um raio (a integral), estalo de trovão quando o raio bate no chão e suspense quando abre para perguntar.

### Música de fundo

Cada fase tem a sua trilha em MIDI, composta em Assembly (`src/rotinas/musica.s`), como nos jogos de plataforma: **alegre no treino** (~128 BPM, onda quadrada com baixo "um-pá"), **agitada na Fase 1** (~150 BPM, metais, baixo de oitavas e caixa), **frenética no chefão** (~200 BPM, dente de serra e taiko; Livro do Stewart e Grafo), **misteriosa na Fase 2** (~150 BPM, vibrafone), **eletrônica na Fase 3** (~164 BPM, chiptune) e **épica no chefão final** (~180 BPM, guitarra distorcida e tímpano). São loops que tocam só durante o jogo: pausam na pergunta do chefão e param no filminho, na morte e na porta. Para mudar as músicas, edite as notas direto no `musica.s` (cada linha tem o nome da nota no comentário e os compassos estão marcados com o acorde).

**Limite de ecalls:** no `fpgrars.exe` do Windows cada ecall deixa um resto na pilha e ele cai perto de **8000 ecalls** (medido). Cada nota é uma ecall, então há dois orçamentos por partida: **2600 notas de efeitos** (`SOM_LIMITE`) e **4900 de música** (`MUSICA_LIMITE`). A música dá uns 17 min de treino, 12 de fase ou 8 de chefão. As trilhas novas (Fases 2 e 3) têm menos notas por segundo para economizar, mas, como o jogo agora tem 4 fases, numa partida muito longa a música pode acabar antes do fim (o jogo continua normalmente, só fica sem música). Quando um acaba, aquele som para e o jogo continua sem cair. M desliga tudo e aí não gasta nada.

### No VS Code

Abra a pasta do projeto (Arquivo → Abrir Pasta). **Ctrl+Shift+B** roda o jogo.

## Estrutura

```
jogar.bat / fpgrars.toml
src/
  main.s               constantes, variáveis, laço principal e tabela de estados
  rotinas/
    telas.s            menu, explicação, transição, jogo, morte, game over, fase concluída
    cinema.s           "filminho" do golpe final contra o chefão (retrato e golpe de cada chefão)
    sfx.s              efeitos sonoros (MIDI, ecall 31)
    musica.s           música de fundo de cada fase e do chefão (MIDI)
    jogador.s          movimento com frações de pixel, pulo, dano, morte, desenho
    colisao.s          tabela de blocos sólidos e colisões
    monstros.s         monstros que andam, pulam e voam
    chefes.s           os 3 chefões (um registro de dados para cada) e os projéteis deles
    perguntas.s        tela de pergunta
    fases.s            carregar fase, câmera, arena do chefão, porta da UNIFESP, dicas
    texto.s            escrever na tela (fonte própria, sem ecall) e painéis
    desenhos.s         monta os desenhos em texto (sprites, mapas, fonte) quando o jogo abre
    efeitos.s          partículas e números aleatórios
    video.s            desenhar imagem, mapa, copiar fundo
    cenario.s          fundos com parallax: campus, sala de aula, laboratório e circuito
    debug.s            atalhos de teste (DEBUG_ATALHOS)
    teclado.s          leitura do teclado
  dados/
    fases.s            a lista de fases (mapa, monstros, chefão, textos...)
    monstros.s         onde fica cada monstro de cada fase
    textos.s           todos os textos do jogo (pode editar à vontade)
    perguntas.s        perguntas dos chefões: Cálculo, AED e AOC (pode editar à vontade)
    fonte.s            a fonte, desenhada em texto (# = pixel aceso)
    graficos.s         sprites, cenário, blocos e mapas, desenhados em texto (1 letra por pixel)
    graficos_fases23.s desenhos e mapas das Fases 2 e 3 (mesmo formato)
ferramentas/           paleta de cores (paleta_fpgrars.png) e licença do FPGRARS
graficos/ e previa/    PNGs só de referência (o jogo não usa); previa/ tem também os desenhos,
                       mapas e prints das Fases 2 e 3 (fases23_*.png, mapa_aed.png, mapa_aoc.png, jogo_*.png)
```

## Como o código funciona (resumo)

- **Tudo em assembly:** não há conversor nem Python. Os gráficos estão desenhados em texto nos próprios `.s` e a rotina `montar_desenhos` (`rotinas/desenhos.s`) troca as letras pelas cores quando o jogo abre. Veja o `GUIA_GRAFICOS.md`.
- **Estados:** a variável `estado_jogo` diz em que tela o jogo está; a cada quadro o laço chama a rotina daquela tela pela `tabela_estados`.
- **Quase sem ecall:** no `fpgrars.exe` do Windows cada ecall deixa memória presa e o jogo cai depois de alguns milhares. O relógio é lido com `csrr time`, a espera do quadro é ocupada e o texto é desenhado com uma fonte própria (`texto.s` + `dados/fonte.s`). As ecalls são só a de sair (ESC) e a de som (ecall 31, com limite; veja Som).
- **Frações de pixel:** velocidades em 1/16 de pixel. O estudante anda 1,375 px por quadro e o pulo sobe cerca de 56 px (3,5 blocos). Soltar o pulo cedo deixa o pulo mais baixo; dá para pular alguns quadros depois de sair da beirada, e um pulo apertado um pouco antes de encostar no chão também vale.
- **Regra dos mapas:** com esse pulo, cada plataforma deve ficar **no máximo 2 blocos acima** de onde o estudante pula (3 blocos dá, mas exige precisão). Na horizontal, o pulo cobre só uns 32 pixels: um trecho de espinhos que precisa ser pulado deve ter **1 bloco** de largura (dá de 17 a 27 pixels de folga para escolher onde pular). Com 2 blocos sobram só 2 pixels de folga: o estudante quase sempre cai. Trechos maiores só embaixo de plataformas, com vãos de 1 bloco entre elas. Uma plataforma na linha 11 (logo acima do chão) vira parede: é preciso pular nela. Não ponha espinhos logo depois de uma plataforma baixa (o teto não deixa pular).
- **Blocos que machucam:** a tabela `bloco_perigo` (`colisao.s`) diz quais blocos machucam quem pisa (espinhos `S` e curto-circuito `T`). Eles são sólidos: o estudante perde um coração e é jogado para cima.
- **Double buffering:** desenha no frame escondido e troca, para a tela não piscar.

## Para testar rápido

No começo do `main.s`, mude `FASE_TESTE`:
`0` = jogo normal · `1` = começa no treino · `2` = começa na Fase 1 · `3` = começa na porta da arena do Livro do Stewart · `4` = Fase 2 · `5` = arena do Grafo · `6` = Fase 3 · `7` = arena do Professor.
**Volte para 0 antes de entregar.**

Com `DEBUG_ATALHOS = 1` (também no começo do `main.s`), estas teclas funcionam durante o jogo (código em `rotinas/debug.s`):

| Tecla | O que faz |
|---|---|
| 5 / 6 / 7 / 8 | vai direto para o treino / Fase 1 / Fase 2 / Fase 3 (de qualquer tela) |
| 9 | teleporta para a porta da arena do chefão (no treino, para perto da porta da UNIFESP) |
| 0 | vence a fase na hora |
| I | invencível (liga/desliga) |
| V | enche os corações |
| K | derrota todos os monstros da fase |
| J | pulo infinito: pula até no ar (liga/desliga) |
| G | mostra a posição do estudante: x, y e coluna/linha do mapa (bom para editar mapas) |
| N | perde todas as vidas (testa o filminho de derrota e o GAME OVER) |
| T | deixa só 5 segundos no cronômetro (testa o "REPROVOU POR FALTA!") |
| B | (na luta) dá um golpe no chefão, como se tivesse acertado |
| P | (na luta) o chefão faz a pergunta agora |
| C | (na pergunta) responde a alternativa certa |

Quando I ou J estão ligados, aparece um aviso no canto de baixo da tela. **Mude `DEBUG_ATALHOS` para 0 antes de entregar.**

## Como editar

- **Textos:** `src/dados/textos.s`, com acentos normais. `\n` pula linha; cabem 46 letras por linha nas caixas de texto.
- **Perguntas:** `src/dados/perguntas.s` (`perguntas_calculo`, `perguntas_aed`, `perguntas_aoc`). Cada pergunta é uma linha `.word enunciado, alt1, alt2, alt3, alt4, certa` (certa = 0 a 3).
- **Chefões (dificuldade):** o registro de cada um no fim do `.data` de `src/rotinas/chefes.s` (`chefe_stewart`, `chefe_grafo`, `chefe_professor`): vida, tempo entre perguntas, velocidade do ataque, quantos projéteis, velocidade, textos e música.
- **Nome do chefão final:** `txt_professor_*` e `txt_cin_professor_*` em `src/dados/textos.s`.
- **Monstros:** `src/dados/monstros.s` (`tipo, comportamento, coluna, linha`).
- **Desenhos (sprites, cenário, blocos):** `src/dados/graficos.s`, uma letra por pixel (veja o `GUIA_GRAFICOS.md`).
- **Mapas:** também em `src/dados/graficos.s` (`mapa_fase1`, `mapa_calculo`) e em `src/dados/graficos_fases23.s` (`mapa_aed`, `mapa_aoc`), uma letra por bloco.
- **Letras do texto:** `src/dados/fonte.s`, desenhadas com `#`.
- **Músicas:** `src/rotinas/musica.s` (cada nota tem o nome no comentário).
- **Efeitos sonoros:** `src/rotinas/sfx.s`.

## Andamento

- [x] Cenário, estudante animado, rolagem com parallax
- [x] Física com frações de pixel (velocidade e pulo menores)
- [x] Tela inicial, explicação, transições, fase concluída
- [x] Treino no campus com dicas
- [x] Fase 1: Cálculo 1, com monstros que andam, pulam e voam
- [x] Chefão Livro do Stewart com perguntas
- [x] Animação de morte, game over e recomeço da fase
- [x] Fase 2: AED (chefão O Grafo, vencido com perguntas)
- [x] Fase 3: AOC (chefão final: Professor Cappa, vencido com perguntas)
- [x] Blocos que machucam (espinhos e curto-circuito)
- [x] Formatura (tela final com fogos)
- [x] Atalhos de teste (DEBUG_ATALHOS)
- [x] Efeitos sonoros (MIDI), porta da UNIFESP no fim do treino, filminho do golpe final
- [x] Música de fundo (MIDI): treino, fase e chefão

