# O que foi feito: Fases 2 (AED) e 3 (AOC), chefão final e atalhos de teste

Este arquivo descreve todas as mudanças feitas no jogo nesta etapa. Resumo:

- **Saíram do plano** a fase de PAA e a fase bônus (bandejão). O jogo agora é: treino → Fase 1 (Cálculo 1) → **Fase 2 (AED)** → **Fase 3 (AOC, a última)** → formatura.
- Os chefões das Fases 2 e 3 são vencidos **com perguntas**, igual ao Livro do Stewart na Fase 1.
- Cada fase é **mais difícil** que a anterior e as novas fases são **mais longas**.
- O chefão final (AOC) foi desenhado **parecido com o nosso professor** (pela foto).
- Há **atalhos de teclado para testar** o jogo e achar bugs rápido.

Tudo continua em assembly RISC-V, com os desenhos em texto dentro dos `.s` (nenhum programa externo é necessário para rodar ou editar o jogo).

---

## 1. As fases novas

### Comparação de dificuldade

| | Fase 1: Cálculo 1 | Fase 2: AED | Fase 3: AOC |
|---|---|---|---|
| Tamanho do mapa | 80 colunas (4 telas) | 110 colunas (5,5 telas) | 140 colunas (7 telas) |
| Monstros | 9 | 16 | 22 |
| Velocidade dos monstros | normal | +25% | +50% |
| Blocos que machucam | não | espinhos (9 trechos) | curto-circuito (16 trechos) |
| Chefão | Livro do Stewart | O Grafo | Professor Cappa |
| Vidas do chefão (acertos para vencer) | 3 | 4 | 5 |
| Pergunta a cada | 8 s | 7 s | 6,5 s |
| Ataque | 1 integral reta, a cada 80 quadros | 2 setas em leque, a cada 72 quadros | 3 bits (0 e 1) em leque, a cada 64 quadros |
| Ataque acelera por acerto | 18 quadros | 10 quadros | 8 quadros |
| Velocidade do chefão | 1 px/quadro | 1 px/quadro | 2 px/quadro |
| Perguntas diferentes | 10 | 13 | 14 |

### Fase 2: AED (Algoritmos e Estruturas de Dados)

- **Cenário:** um laboratório de computação: parede azul, quadro branco com uma **árvore binária** e "O(log n)", cartaz da **pilha** (push / pop) e mesas com computadores ao fundo (com parallax).
- **Blocos:** piso de laboratório (`J`/`K`), bancadas (`L`, plataformas), caixas (`M`, formam escadinhas e pilares) e **espinhos** (`S`, machucam).
- **Monstros:**
  - **pilha** (anda): três blocos empilhados com olhos;
  - **nó de grafo** (pula): uma bolinha azul com duas arestas e dois nós pequenos;
  - **ponteiro** (voa): uma seta laranja com olho.
- **Chefão: O GRAFO.** Um grafo com 6 nós numerados ligados ao nó central (roxo, com cara brava). Quando vai perguntar, ele fica vermelho/amarelo e abre a boca. Joga **setas (ponteiros)** que caem abrindo em leque. Golpe no filminho da derrota: **"SEGMENTATION FAULT!"**.
- **Perguntas (13):** pilha/fila (LIFO/FIFO), busca binária, merge sort, quicksort, árvore binária de busca, percurso em ordem, BFS, ponteiros em C (`*p`), grafo completo, lista ligada, heap, altura de árvore.

### Fase 3: AOC (Arquitetura e Organização de Computadores) — a fase final

- **Cenário:** "dentro do computador": fundo azul-escuro, trilhas de uma placa com **CPU, ALU e RAM**, e uma fileira de **servidores** com LEDs (com parallax).
- **Blocos:** placa de circuito (`N`/`O`), chips (`P`, plataformas), servidores (`Q`, colunas e escadas), capacitor (`R`, enfeite) e **curto-circuito** (`T`, machuca).
- **Monstros:**
  - **bit** (pula): um cubo verde escrito "01";
  - **bug** (voa): uma joaninha vermelha (o "bug" do computador);
  - **porta lógica** (anda): uma porta E com entradas e saída;
  - **chip** (anda): o monstro de AOC que já existia no treino.
- **Chefão final: PROFESSOR CAPPA.** Desenhado a partir da foto: cabelo castanho-escuro curto penteado para cima, sobrancelhas grossas, sorrisão mostrando os dentes, barba bem curtinha, jaqueta escura acolchoada com o detalhe vermelho e branco no peito e gola clara. Quando vai perguntar, ele arregala os olhos, levanta as sobrancelhas e abre a boca. Joga **bits 0 e 1** em leque (três por vez) e anda mais rápido que os outros chefões. Golpe no filminho da derrota: **"PROVA DE ASSEMBLY!"**. Ele usa uma música própria, mais épica.
  - O nome "Cappa" veio do plano antigo do LEIA-ME ("Fase 4: AOC (Cappa)"). Para trocar o nome, mudem os textos `txt_professor_*` e `txt_cin_professor_*` em `src/dados/textos.s`.
- **Perguntas (14):** `lw`/`sw`, binário, hexadecimal, registrador `x0`, complemento de 2, PC, pipeline de 5 estágios, hazard de dados, cache, `addi`, `beq`, porta AND, little-endian e o uso da pilha (`sp`) nas funções.

### Formatura

Depois de vencer o Professor aparece **"PARABÉNS! VOCÊ SE FORMOU!"** (painel com borda dourada e fogos de artifício). ENTER volta ao menu.

---

## 2. Mudanças no código

### Chefões genéricos (`src/rotinas/chefes.s`, reescrito)

Antes o código do chefão era só do Livro do Stewart. Agora **os três chefões usam o mesmo código** e o que muda entre eles fica num **registro de dados** (`chefe_stewart`, `chefe_grafo`, `chefe_professor`), com os campos `CB_*`:

desenho normal e "aberto" · vida · tempo até a 1ª pergunta e entre perguntas · intervalo de ataque e quanto ele acelera por acerto · quantos projéteis e a abertura do leque · velocidade · desenhos dos projéteis · tabela de perguntas · nome, subtítulo, título da pergunta, texto de acerto · textos do filminho · música · cor do nome.

Para deixar um chefão mais fácil ou mais difícil, basta mudar esses números. O Livro do Stewart ficou **exatamente com os mesmos valores de antes**.

Outras mudanças nesse arquivo:
- `F_CHEFE` da fase continua sendo um número (`CHEFE_STEWART`, `CHEFE_GRAFO`, `CHEFE_PROFESSOR`); `tabela_chefes` liga o número ao registro.
- Os **projéteis** agora andam também de lado (velocidade `vx` com frações de pixel) e cada um guarda o próprio desenho. `lancar_integral` virou `lancar_projetil` (x, y, vx, desenho) e `chefe_atacar` lança o leque.
- As "páginas" de vida no alto da tela se ajustam à vida de cada chefão (3, 4 ou 5) e ficam centralizadas.

### Perguntas e filminho

- `src/rotinas/perguntas.s`: o título ("O GRAFO PERGUNTA:"...) e o texto de acerto vêm do registro do chefão.
- `src/rotinas/cinema.s`: os retratos grandes, o nome e o golpe do chefão e os projéteis que voam no filminho da derrota vêm do registro do chefão.

### Fases (`src/dados/fases.s`, `src/rotinas/fases.s`)

- Novo campo no registro da fase: **`F_VEL_MONSTROS`** (velocidade a mais dos monstros, em 1/16 de pixel por quadro): 0 no treino e na Fase 1, 4 na Fase 2, 8 na Fase 3. `carregar_fase` guarda o valor em `monstros_vel_extra`, que `rotinas/monstros.s` soma às velocidades.
- Novos registros `fase_aed` e `fase_aoc`. A Fase 1 agora leva para a Fase 2 e a Fase 2 para a Fase 3.
- `MAX_MONSTROS` passou de 20 para 24 (`main.s`).

### Blocos que machucam (`src/rotinas/colisao.s`, `src/rotinas/jogador.s`)

- Nova tabela `bloco_perigo` e rotina `ponto_perigo`. Os blocos `S` (espinhos) e `T` (curto-circuito) são sólidos **e** machucam.
- `verificar_perigo` (em `jogador.s`) roda quando o estudante está de pé: se um dos pés está num bloco de perigo, ele perde um coração (se não estiver piscando) e é **jogado para cima**. Os pés são testados um pouco para dentro das bordas, para não machucar quem só raspou na beirada.

### Monstros novos (`src/dados/monstros.s`, `main.s`)

Seis tipos novos: `TIPO_PONTEIRO`, `TIPO_PILHA`, `TIPO_NO` (AED) e `TIPO_BIT`, `TIPO_BUG`, `TIPO_PORTA` (AOC), com desenho, cor das partículas, som de "voz", som ao virar e se o desenho espelha. As listas `monstros_aed` e `monstros_aoc` dizem onde cada um nasce.

### Cenários (`src/rotinas/cenario.s`)

Novas rotinas `cenario_lab` (Fase 2) e `cenario_circuito` (Fase 3), no mesmo esquema do `cenario_sala` (degradê + camadas que se repetem com parallax).

### Gráficos (`src/dados/graficos_fases23.s`, arquivo novo)

Todos os desenhos novos, no mesmo formato de texto do `graficos.s`: 6 monstros, 3 projéteis, 4 desenhos de chefão (48×48), 11 blocos (19 a 29, letras `J` a `T`), 5 imagens de cenário e os mapas `mapa_aed` e `mapa_aoc`. Eles foram ligados às tabelas `tabela_desenhos`, `blocos` e `tabela_mapas` do `graficos.s`. Prévias em PNG estão na pasta `previa/` (`fases23_chefoes.png`, `fases23_monstros.png`, `fases23_blocos.png`, `mapa_aed.png`, `mapa_aoc.png` e prints do jogo `jogo_*.png`).

### Sons e músicas

- `src/rotinas/sfx.s`: vozes dos 6 monstros novos (ponteiro "fiiu", pilha "pof-pof-pof", nó "bloop", bit "bip-bop", bug zumbindo, porta lógica "clic-clac").
- `src/rotinas/musica.s`: 3 trilhas novas: `musica_aed` (ré menor, vibrafone), `musica_aoc` (lá menor, chiptune) e `musica_chefe_final` (dó menor, guitarra distorcida e tímpano, só do Professor). O Grafo usa a mesma música de chefão do Livro do Stewart.
- As trilhas novas têm **menos notas por segundo** (4 a 6) para gastar menos do orçamento de ecalls do `fpgrars.exe` (ele cai perto de 8000 ecalls). Como o jogo ficou maior, numa partida muito longa a música (ou os efeitos) pode acabar antes do fim; o jogo continua normalmente, só fica em silêncio.

### Textos (`src/dados/textos.s`) e perguntas (`src/dados/perguntas.s`)

Textos das Fases 2 e 3, dos chefões, da formatura e dos avisos de teste; `perguntas_aed` (13) e `perguntas_aoc` (14). Todos foram conferidos para caber na tela (até 46 letras por linha no enunciado e 42 nas alternativas).

---

## 3. Atalhos para testar (achar bugs mais rápido)

Ficam em `src/rotinas/debug.s` e só funcionam com **`DEBUG_ATALHOS = 1`** (começo do `main.s`). **Mudem para 0 antes de entregar.**

| Tecla | Quando | O que faz |
|---|---|---|
| **5** | qualquer tela | vai direto para o treino |
| **6** | qualquer tela | vai direto para a Fase 1 (Cálculo) |
| **7** | qualquer tela | vai direto para a Fase 2 (AED) |
| **8** | qualquer tela | vai direto para a Fase 3 (AOC) |
| **9** | jogando | teleporta para a porta da arena do chefão (no treino: perto da porta da UNIFESP) |
| **0** | jogando | vence a fase na hora (tela de fase concluída) |
| **I** | jogando | invencível liga/desliga (nem monstro, nem projétil, nem espinho, nem resposta errada tira coração) |
| **V** | jogando | enche os corações |
| **K** | jogando | derrota todos os monstros da fase |
| **J** | jogando | pulo infinito liga/desliga (pula até no ar; bom para testar os mapas) |
| **G** | jogando | mostra a posição do estudante: x e y em pixels, coluna e linha do mapa (bom para posicionar monstros e plataformas) |
| **N** | jogando | perde todas as vidas (testa o filminho de derrota e o GAME OVER) |
| **T** | jogando | deixa só 5 segundos no cronômetro (testa o "REPROVOU POR FALTA!") |
| **B** | luta com o chefão | dá um golpe no chefão, como se tivesse acertado uma pergunta |
| **P** | luta com o chefão | o chefão faz a pergunta agora |
| **C** | tela de pergunta | responde a alternativa certa |

Com I ou J ligados aparece um aviso no canto de baixo da tela ("INVENCÍVEL", "PULO INFINITO").

Também dá para **começar o jogo direto numa fase** com `FASE_TESTE` no `main.s`:
`0` normal · `1` treino · `2` Fase 1 · `3` arena do Stewart · `4` Fase 2 · `5` arena do Grafo · `6` Fase 3 · `7` arena do Professor. **Voltem para 0 antes de entregar.**

Exemplos de uso:
- Testar só o chefão final: aperte **8**, depois **9**, ande para a direita até a arena fechar.
- Ver todas as perguntas de um chefão: na arena, aperte **P** várias vezes (e **C** para responder).
- Testar o filminho de vitória: na arena, aperte **B** até o chefão acabar.
- Ajustar um mapa: ligue **J** (pulo infinito) e **G** (posição) e passeie pela fase.

---

## 4. Como foi testado

- O jogo **monta sem erros** no `fpgrars.exe` (`fpgrars.exe --no-video src/main.s`), e um erro de propósito numa cópia confirmou que o simulador acusa rótulos que não existem.
- Rodamos o jogo começando em cada fase (`FASE_TESTE` de 1 a 7) sem travar.
- Com um **roteiro de teclas automático** numa cópia do jogo (fora do projeto), que apertava teclas em quadros definidos e salvava a tela em arquivo, conferimos pelas imagens:
  - a entrada do Grafo e do Professor (nome grande), as 4 e 5 páginas de vida, as setas e os bits em leque;
  - a tela de pergunta com o título de cada chefão, a resposta certa (tecla C) e o texto de acerto;
  - os golpes, o filminho de vitória, a explosão, "FASE 2 CONCLUÍDA!" e a passagem para a Fase 3;
  - o filminho de derrota com o retrato do Professor ("PROVA DE ASSEMBLY!" → "REPROVADO!") e o GAME OVER;
  - os espinhos tirando coração e jogando o estudante para cima;
  - a tela da formatura com fogos e a volta ao menu;
  - a luta do Livro do Stewart continua igual a antes.
- Os dois mapas novos foram conferidos com uma **simulação da física do estudante** (os mesmos números do `jogador.s`: velocidade, gravidade, pulo, tempo do coiote) testando todos os pulos possíveis: nas duas fases **dá para chegar na arena sem levar nenhum dano** e **não existe lugar onde o estudante fique preso**. (A Fase 1 original também passa nesse teste.) Alguns pulos que estavam no limite foram facilitados por causa disso.

**O que não deu para testar daqui:** o som (MIDI) e o jogo inteiro jogado do começo ao fim por uma pessoa. Vale jogar tudo uma vez na janela do jogo para conferir a dificuldade.

---

## 5. Correção: espinhos impossíveis de pular na Fase 2

**O problema:** na Fase 2 o estudante quase sempre caía nos espinhos. A física do jogo faz o pulo cobrir só uns **32 pixels** na horizontal. Os trechos de espinhos tinham **2 blocos** (32 pixels) e, pulando do chão, só existiam **2 pixels** de onde o pulo dava certo: era preciso pular no último pixel antes do espinho. A simulação de antes só verificava se *existia* algum pulo possível, por isso não pegou o problema.

**A correção** (nas duas fases novas, porque a Fase 3 tinha o mesmo problema):
- Todo trecho de espinhos/curto-circuito que precisa ser pulado agora tem **1 bloco**. Isso dá de **17 a 27 pixels** de folga para escolher onde pular (medido com a física do jogo).
- Trechos longos continuam só embaixo de plataformas. Os vãos entre plataformas no caminho são de **1 bloco**, com folga de 16 a 39 pixels.
- Na Fase 3, plataformas foram aproximadas das colunas de servidores (colunas 19-21 e 82-88) para não ter vão de 2 blocos.
- Para a fase continuar difícil, entraram trechos novos de 1 bloco: Fase 2 nas colunas 72 e 85, Fase 3 nas colunas 24, 44 e 93.
- Dois monstros que tinham ficado em cima de espinhos mudaram de lugar.
- A simulação completa foi rodada de novo: as duas fases continuam vencíveis sem dano e sem lugar onde ficar preso. Um teste no jogo com teclas automáticas mostrou o estudante pulando o primeiro espinho da Fase 2 sem perder coração.
- `previa/mapa_aed.png` e `previa/mapa_aoc.png` foram atualizados.

**Regra para quem for editar os mapas:** espinhos que precisam ser pulados = no máximo **1 bloco**. Vão entre plataformas no mesmo nível = no máximo **1 bloco** (com 2 blocos sobram de 2 a 8 pixels de folga).

## 6. Cronômetro e filminho em toda derrota

### Cronômetro por fase

| Fase | Tempo | Jogador médio (estimativa) |
|---|---|---|
| Treino | 1 min | ~45 s |
| Fase 1: Cálculo | 3 min | ~2,2 min |
| Fase 2: AED | 4 min | ~3 min |
| Fase 3: AOC | 4 min 30 s | ~3,7 min |

- O tempo aparece no alto da tela, ao lado dos corações, com um reloginho: branco, **amarelo** no último minuto e **vermelho piscando** nos últimos 10 s, com um "tique" a cada segundo.
- Ele corre durante o jogo e também durante as perguntas dos chefões (pensar demais custa tempo). Para de correr quando o chefão é derrotado, para a explosão não ser interrompida.
- Se zerar no meio de uma pergunta, o estudante só reprova quando a pergunta fecha.
- Quando zera: os corações esvaziam e passa o filminho do **despertador bravo** ("O RELÓGIO usa: FIM DO TEMPO!") → **"REPROVOU POR FALTA!"** → queda → GAME OVER. ENTER recomeça a fase com o tempo cheio.
- O tempo de cada fase é o campo novo `F_TEMPO` (segundos) no fim de cada registro em `src/dados/fases.s`. 0 = fase sem cronômetro.

### Filminho em toda derrota

Antes o filminho de derrota só aparecia contra o chefão. Agora ele aparece **sempre que o estudante perde o último coração**, com o retrato de quem venceu (6 vezes maior) e um golpe próprio:

| Quem venceu | Golpe |
|---|---|
| Monstro de Cálculo (treino) | CONTA ERRADA! |
| Chip maluco (treino / AOC) | SUPERAQUECIMENTO! |
| Cobra da integral | BOTE INTEGRAL! |
| Fantasma do limite | TENDE AO INFINITO! |
| Derivada | PULO DA TANGENTE! |
| Ponteiro | PONTEIRO NULO! |
| Pilha | STACK OVERFLOW! |
| Nó do grafo | LOOP INFINITO! |
| Bit | BIT INVERTIDO! |
| Bug | TELA AZUL! |
| Porta lógica | NAND FATAL! |
| Espinhos | ESPETADA DOLORIDA! |
| Curto-circuito | CHOQUE DE 220 VOLTS! |
| Relógio (tempo acabou) | FIM DO TEMPO! → REPROVOU POR FALTA! |

Os textos ficam em `src/dados/textos.s` (`txt_cin_m_*` = "Fulano usa:", `txt_cin_g_*` = golpe).

### Como funciona no código

- `main.s`: `F_TEMPO`, as variáveis `fase_tempo`, `morte_causa` e `morte_info`, e os tipos de filminho `CINEMA_MONSTRO`, `CINEMA_PERIGO` e `CINEMA_TEMPO`.
- Quem tira o coração anota a causa: `colidir_monstros` (monstros.s) guarda o tipo do monstro e `verificar_perigo` (jogador.s) o bloco. `iniciar_morte` escolhe o filminho: tempo > chefão > monstro > bloco.
- `telas.s`: `atualizar_tempo_fase` (desconta, faz o tique e reprova) e `desenhar_tempo` (o "m:ss" na tela).
- `cinema.s`: `iniciar_cinema` agora escolhe retrato, escala, textos e projétil para cada tipo de filminho; o resto do filminho só usa essas escolhas.
- Desenhos novos no fim de `graficos_fases23.s`: `img_relogio` (despertador, 32×32) e `img_relogio_mini` (9×9).
- Testado com prints automáticos: o cronômetro na tela, o filminho do relógio (inclusive no meio da luta com o Professor), o filminho da cobra da integral e o dos espinhos, todos terminando no GAME OVER.

## 7. Arquivos alterados

| Arquivo | O que mudou |
|---|---|
| `src/main.s` | constantes novas (tipos de monstro, `F_VEL_MONSTROS`, teclas e bits de teste, `DEBUG_ATALHOS`, `FASE_TESTE` até 7), `MAX_MONSTROS` 24, chamada dos atalhos, includes novos |
| `src/rotinas/chefes.s` | reescrito: chefões por registro de dados, leque de projéteis, projéteis com vx e desenho |
| `src/rotinas/perguntas.s` | título e acerto do chefão atual; tecla C |
| `src/rotinas/cinema.s` | retratos, golpe e projéteis do chefão atual |
| `src/rotinas/colisao.s` | `bloco_solido` com os blocos novos; `bloco_perigo` e `ponto_perigo` |
| `src/rotinas/jogador.s` | `verificar_perigo`; invencível e pulo infinito de teste |
| `src/rotinas/monstros.s` | velocidade extra por fase |
| `src/rotinas/fases.s` | `carregar_fase` lê `F_VEL_MONSTROS` |
| `src/rotinas/telas.s` | fogos e borda dourada na formatura; avisos de teste no HUD |
| `src/rotinas/cenario.s` | `cenario_lab` e `cenario_circuito` |
| `src/rotinas/sfx.s` | vozes dos monstros novos |
| `src/rotinas/musica.s` | 3 trilhas novas |
| `src/rotinas/teclado.s` | teclas de teste na tabela |
| `src/rotinas/debug.s` | **novo**: atalhos de teste |
| `src/dados/fases.s` | `fase_aed`, `fase_aoc`, campo de velocidade dos monstros |
| `src/dados/monstros.s` | tabelas dos tipos novos, `monstros_aed`, `monstros_aoc` |
| `src/dados/perguntas.s` | `perguntas_aed`, `perguntas_aoc` |
| `src/dados/textos.s` | textos das fases novas, chefões, formatura e testes |
| `src/dados/graficos.s` | tabelas ligadas aos desenhos novos |
| `src/dados/graficos_fases23.s` | **novo**: todos os desenhos e mapas das Fases 2 e 3 |
| `LEIA-ME.md`, `GUIA_GRAFICOS.md` | atualizados |
| `previa/` | PNGs novos dos desenhos, mapas e prints |
