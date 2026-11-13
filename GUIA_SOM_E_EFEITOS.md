# Guia: som, música, porta da UNIFESP e o "filminho" do chefão

Este guia explica **tudo o que foi acrescentado ao jogo**: o que mudou em cada arquivo, como cada parte funciona por dentro, o que ela pode afetar no resto do jogo, o que dá para mudar e as perguntas que um professor provavelmente faria (com as respostas).

Os números de linha citados podem mudar um pouco se você editar os arquivos; os **nomes das rotinas** (`tocar_som`, `atualizar_musica`...) não mudam, então procure por eles.

---

## Sumário

1. [Resumo do que mudou](#1-resumo-do-que-mudou)
2. [Conceitos básicos: MIDI, ecall 31 e quadros](#2-conceitos-básicos-midi-ecall-31-e-quadros)
3. [O grande problema: o limite de ecalls](#3-o-grande-problema-o-limite-de-ecalls)
4. [O motor de efeitos sonoros (`sfx.s`)](#4-o-motor-de-efeitos-sonoros-sfxs)
5. [Onde cada efeito toca](#5-onde-cada-efeito-toca)
6. [Os sons dos monstrinhos](#6-os-sons-dos-monstrinhos)
7. [A música de fundo (`musica.s`)](#7-a-música-de-fundo-musicas)
8. [A música tem parallax?](#8-a-música-tem-parallax)
9. [A música (ou os efeitos) atrapalham alguma outra função?](#9-a-música-ou-os-efeitos-atrapalham-alguma-outra-função)
10. [A porta da UNIFESP (fim do treino)](#10-a-porta-da-unifesp-fim-do-treino)
11. [O "filminho" do golpe final](#11-o-filminho-do-golpe-final)
12. [Como tudo foi testado](#12-como-tudo-foi-testado)
13. [O que poderia ser mudado ou melhorado](#13-o-que-poderia-ser-mudado-ou-melhorado)
14. [Perguntas que o professor pode fazer](#14-perguntas-que-o-professor-pode-fazer)
15. [Gráficos sem Python: desenhos em texto](#15-gráficos-sem-python-desenhos-em-texto)

---

## 1. Resumo do que mudou

### Arquivos novos

| Arquivo | O que faz |
|---|---|
| `src/rotinas/sfx.s` | Motor de **efeitos sonoros**: guarda os efeitos (pulo, pisão, dano...) e toca as notas na hora certa. Também lê a tecla **M** (liga/desliga o som). |
| `src/rotinas/musica.s` | Motor da **música de fundo** e as três trilhas (treino, fase, chefão). |
| `src/rotinas/cinema.s` | O **"filminho"** do golpe final contra o chefão (estilo ataque especial). |
| `src/rotinas/desenhos.s` | Monta os **desenhos em texto** (sprites, mapas, fonte) quando o jogo abre. Foi o que permitiu tirar o Python do projeto (seção 15). |
| `GUIA_SOM_E_EFEITOS.md` | Este guia. |

### Arquivos alterados

| Arquivo | O que mudou |
|---|---|
| `src/main.s` | Novas constantes (`SC_M`, `T_MUDO`, `ESTADO_PORTA`, `ESTADO_CINEMA`, `CINEMA_DERROTA/VITORIA`, `F_MUSICA`), a variável `jogador_oculto`, dois estados novos na `tabela_estados`, a chamada `call atualizar_som` no laço principal e os `.include` de `cinema.s`, `sfx.s` e `musica.s`. O atalho `FASE_TESTE` também liga a música. |
| `src/rotinas/teclado.s` | A tecla **M** entrou na `tabela_teclas`. |
| `src/rotinas/jogador.s` | Som do pulo; som do dano; a morte para a música e, se o chefão estiver na tela, chama o filminho; o estudante não é desenhado quando `jogador_oculto = 1` (entrou na porta). |
| `src/rotinas/monstros.s` | Som do pisão; "voz" dos monstros (ao aparecer e de vez em quando); som ao virar; "bóing" da derivada. |
| `src/rotinas/chefes.s` | Sons do chefão (entrada, raio, raio no chão, golpe, suspense da pergunta); música do chefão; o golpe final chama o filminho de vitória. |
| `src/rotinas/perguntas.s` | Som de acerto ("plim") quando a resposta está certa. |
| `src/rotinas/telas.s` | Sons de ENTER e de começo de fase; liga a música da fase; som de game over; desenha a porta no lugar da bandeira. |
| `src/rotinas/fases.s` | A **bandeira virou a porta da UNIFESP** (desenho, colisão e animação de entrada). `carregar_fase` agora para a música e já posiciona a câmera. |
| `src/dados/fases.s` | A porta do treino (`meta_tutorial`) e o campo `F_MUSICA` de cada fase. |
| `src/dados/monstros.s` | Tabelas `sons_monstros` (voz de cada tipo) e `sons_monstros_vira` (som ao virar). |
| `src/dados/textos.s` | Textos da porta, do filminho e a dica da tecla M. |
| `LEIA-ME.md` | Seções de som, música e controles atualizadas. |

---

## 2. Conceitos básicos: MIDI, ecall 31 e quadros

### O que é MIDI

MIDI **não é um arquivo de áudio** como MP3. MIDI é uma lista de **comandos para um sintetizador**: "toque a nota 60, no instrumento 80, com volume 100, por 200 ms". Quem produz o som de verdade é o sintetizador do sistema (no Windows, o *Microsoft GS Wavetable Synth*). Por isso o mesmo MIDI pode soar um pouco diferente em computadores diferentes.

### A ecall 31 do FPGRARS

O FPGRARS só tem som por MIDI, com a **ecall 31**:

| Registrador | Significado | Exemplo |
|---|---|---|
| `a0` | nota (0 a 127). 60 = dó central; +12 = uma oitava acima | `72` = dó uma oitava acima |
| `a1` | duração em milissegundos | `200` |
| `a2` | instrumento General MIDI (0 a 127) | `80` = onda quadrada (som de videogame) |
| `a3` | volume (0 a 127) | `110` |
| `a7` | 31 (o número da ecall) | |

**Importante:** a ecall 31 **não espera a nota terminar**. Ela manda a nota e o programa continua na hora (medimos: 20 notas de 800 ms levaram 0 ms). Por isso o jogo não "trava" enquanto toca som.

### Instrumentos usados (General MIDI, numerados a partir de 0)

| Nº | Instrumento | Onde é usado |
|---|---|---|
| 4 | piano elétrico | "pá" da música do treino |
| 9 | glockenspiel | resposta certa, "plim" da pergunta |
| 12 | marimba | (antigo "bóing", trocado) |
| 33 / 38 | baixo / baixo sintetizado | linhas de baixo das músicas |
| 36 | baixo de *slap* | "bóing" da derivada |
| 47 | tímpano | dano, entrada do chefão, vitória |
| 54 | voz sintética | "uuuu" do fantasma |
| 55 | *orchestra hit* | golpe no chefão, impacto do filminho |
| 56 / 61 / 62 | trompete / metais / metais sintetizados | fanfarras, melodia da fase |
| 57 | trombone | "bwah-bwah" do monstro de Cálculo |
| 68 | oboé | melodia triste do game over |
| 80 / 81 | onda quadrada / dente de serra | pulo, menu, raio do chefão, melodias |
| 116 / 118 | taiko / tambor sintetizado | percussão |
| 119 | prato ao contrário | "tsss" da cobra, "vuuush" do filminho |
| 127 | tiro | explosões, trovão do raio |

### Quadros (a "régua de tempo" do jogo)

O jogo roda a ~60 **quadros por segundo** (`MS_POR_QUADRO = 16`). Todo o tempo do som é contado em **quadros**: "espera 6" quer dizer 6/60 s = 0,1 s. É a mesma régua que o jogo usa para tudo (piscar, pulo, animação), então o som fica **sincronizado com a imagem** de graça.

---

## 3. O grande problema: o limite de ecalls

O `main.s` já avisava: no `fpgrars.exe` do Windows **cada ecall deixa um resto na pilha do simulador**, e depois de muitas o programa cai com:

```
thread 'FPGRARS Simulator' has overflowed its stack
```

Por isso o jogo original não usava ecall nenhuma (o texto tem fonte própria, o relógio é lido com `csrr time`...). Mas **cada nota de som é uma ecall 31**, então não tinha como fugir.

**Como medimos o limite:** escrevemos um programinha que só faz ecall 31 em laço e imprime o contador. Ele caiu depois de **cerca de 8000 ecalls**. Também testamos colocar a ecall dentro de uma sub-rotina (`call`/`ret`): caiu do mesmo jeito. Ou seja, o limite é do simulador, não do nosso código.

**A solução: um "orçamento" de notas.** Cada nota gasta 1 do orçamento; quando ele acaba, aquele som simplesmente **para de tocar e o jogo continua** (em vez de cair):

| Orçamento | Constante | Valor | Arquivo |
|---|---|---|---|
| Efeitos sonoros | `SOM_LIMITE` | 2600 notas | `sfx.s` |
| Música | `MUSICA_LIMITE` | 4900 notas | `musica.s` |
| **Total** | | **7500** (abaixo das ~8000) | |

A verificação está em `nota_midi` (efeitos) e `nota_musica` (música):

```asm
nota_midi:
    la   t0, som_ligado
    lw   t0, 0(t0)
    beqz t0, nm_fim            # som desligado (tecla M): não gasta nada
    la   t0, som_restantes
    lw   t1, 0(t0)
    blez t1, nm_fim            # orçamento acabou: fica em silêncio
    addi t1, t1, -1            # gasta 1
    sw   t1, 0(t0)
    li   a7, 31
    ecall                      # toca a nota (a0..a3 já preparados)
nm_fim:
    ret
```

Por causa desse limite, **todo o design do som foi pensado para gastar poucas notas**: efeitos curtos (1 a 3 notas), monstros só fazem som quando estão na tela, a música pausa quando o jogo não está rodando, etc.

**Por que não usamos os MP3?** O FPGRARS não toca áudio (MP3/WAV), só MIDI. Daria para tocar MP3 com um programa externo do Windows, mas aí a música não seria feita em Assembly; a escolha foi fazer **tudo em MIDI dentro do Assembly**. E não dá para converter um MP3 em notas MIDI automaticamente, por isso as músicas foram compostas nota por nota.

---

## 4. O motor de efeitos sonoros (`sfx.s`)

### A ideia geral: um "sequenciador"

Um efeito como o pulo tem **várias notas em momentos diferentes** (uma agora, outra 2 quadros depois). Como não podemos parar o jogo para esperar (seria `sleep`, que é ecall e travaria a imagem), o motor funciona como um **sequenciador**: a cada quadro ele olha "já é hora da próxima nota?". Se for, toca; se não, conta mais um quadro.

### Como um efeito é guardado (dados)

```asm
# pulo: chirp curto subindo
SFX_JUMP:
.word 0                          # canal 0
.word 0,  72,  60, 80,  60       # espera 0 quadros: nota 72, 60 ms, onda quadrada, volume 60
.word 2,  79,  90, 80,  55       # 2 quadros depois: nota 79 (mais aguda), 90 ms
.word -1                         # fim
```

Cada nota é uma linha de 5 words (20 bytes): **espera, nota, duração, instrumento, volume**. A **espera** é contada **a partir da nota anterior**. `espera = 0` quer dizer "junto com a anterior", e é assim que se faz **acorde** (várias notas ao mesmo tempo).

Isso é **programação orientada a dados**: para mudar um som, você mexe só na tabela, sem tocar no código.

### Os canais

Se o estudante pula enquanto o chefão explode, um som não pode cortar o outro. Por isso existem **4 canais** independentes, cada um tocando no máximo um efeito por vez:

| Canal | Para quê |
|---|---|
| 0 | estudante (pulo, pisão, item) |
| 1 | eventos (dano, menu, começo de fase, porta, golpe no chefão, game over) |
| 2 | cinema, explosões, entrada do chefão, suspense da pergunta |
| 3 | monstrinhos e raios do chefão |

Um efeito novo **substitui** o que estava tocando **no mesmo canal**, mas não mexe nos outros. Cada canal ocupa 8 bytes em `som_canais`:

```
som_canais:  [canal 0: próxima nota | quadros desde a última]  [canal 1: ...]  [canal 2: ...]  [canal 3: ...]
```

### `tocar_som`: começa um efeito

```asm
tocar_som:                     # a0 = endereço do efeito (ex.: la a0, SFX_JUMP)
    lw   t0, 0(a0)             # canal do efeito
    slli t0, t0, 3             # canal * 8 (cada canal tem 8 bytes)
    la   t1, som_canais
    add  t0, t0, t1            # t0 = registro deste canal
    addi t1, a0, 4             # primeira nota (pula a word do canal)
    sw   t1, 0(t0)             # "próxima nota" = a primeira
    sw   zero, 4(t0)           # contador = 0
    ret
```

Ela **não toca nada**: só aponta o canal para a primeira nota. Quem toca é o `atualizar_som`. Ela foi feita para mexer **só em `t0` e `t1`**, então pode ser chamada no meio de qualquer rotina sem estragar os registradores `a*` e `s*` de quem chamou.

### `atualizar_som`: roda uma vez por quadro

Fica no laço principal (`main.s`), logo depois da rotina da tela atual:

```
loop_jogo:
    ler teclado
    contadores (tempo, nuvens)
    chama a rotina do estado atual (menu, jogando, pergunta...)
    call atualizar_som      <-- NOVO: efeitos + música
    espera o resto do quadro (16 ms)
```

Para cada canal ela faz:

```
se o canal está vazio: pula
repita:
    espera = espera da próxima nota
    se espera == -1:  o efeito acabou, esvazia o canal
    se contador < espera:  contador++ e vai para o próximo canal
    senão:  contador = 0, toca a nota (nota_midi), avança para a nota seguinte
            e REPETE (a próxima pode ter espera 0 = acorde)
```

**Exemplo com o pulo** (o estudante pula no quadro 100):

| Quadro | O que acontece |
|---|---|
| 100 | `tocar_som(SFX_JUMP)`; no mesmo quadro o `atualizar_som` toca a nota 72; a próxima tem espera 2, o contador vai a 1 |
| 101 | contador 1 < 2, vai a 2 |
| 102 | contador 2 ≥ 2, toca a nota 79; a próxima é `-1`, o canal fica vazio |

No fim, `atualizar_som` também chama `atualizar_musica` (seção 7).

### A tecla M

No começo do `atualizar_som`, se a tecla M acabou de ser apertada, `som_ligado` troca entre 0 e 1. Com o som desligado os canais **continuam andando** (os efeitos "tocam em silêncio"), mas `nota_midi` não faz ecall nenhuma, então **não gasta o orçamento**.

> Existe também a rotina `parar_sons` (esvazia os 4 canais), que ficou pronta para uso mas não é chamada hoje.

---

## 5. Onde cada efeito toca

| Efeito | Quando | Onde está a chamada |
|---|---|---|
| `SFX_JUMP` | o estudante pula | `jogador.s`, `atualizar_jogador` (depois de "PULA!") |
| `SFX_STOMP` | pisa num monstro | `monstros.s`, `colidir_monstros` |
| `SFX_HURT` | perde um coração | `jogador.s`, `dano_jogador` |
| `SFX_PICKUP` | acerta a pergunta (e servirá para itens) | `perguntas.s`, `estado_pergunta` |
| `SFX_FLAG` | entra na porta da UNIFESP | `fases.s`, `iniciar_porta` |
| `SFX_MENU` | ENTER no menu, explicação, game over e fase concluída | `telas.s` |
| `SFX_PHASE` | ENTER na tela "FASE 1 / CÁLCULO 1" | `telas.s`, `estado_transicao` |
| `SFX_BOSS_HIT` | o livro perde uma página | `chefes.s`, `chefe_resposta` |
| `SFX_BOSS_DEFEAT` | fim do filminho de vitória (explosões + fanfarra) | `cinema.s` |
| `SFX_GAMEOVER` | aparece o GAME OVER | `telas.s`, `estado_morte` |
| `SFX_ESPECIAL` | começa o filminho ("vuuush") | `cinema.s`, `iniciar_cinema` |
| `SFX_IMPACTO` | o clarão do filminho | `cinema.s`, `estado_cinema` |
| `SFX_CHEFE_ENTRA` | o chefão aparece | `chefes.s`, `chefe_iniciar` |
| `SFX_CHEFE_TIRO` | o chefão lança um raio (a integral) | `chefes.s`, `stewart_atualizar` |
| `SFX_INTEGRAL_CHAO` | o raio bate no chão (trovão) | `chefes.s`, `atualizar_projeteis` |
| `SFX_CHEFE_ABRE` | o livro abre para perguntar | `chefes.s`, `stewart_atualizar` |
| sons dos monstros | veja a seção 6 | `monstros.s` |

**Detalhe do `SFX_BOSS_DEFEAT`:** as primeiras notas têm espera de 8 quadros entre si porque o `chefes.s` solta uma explosão a cada 8 quadros (`andi t2, t1, 7`). Assim **cada explosão na tela tem o seu estouro no som**.

---

## 6. Os sons dos monstrinhos

Três mecanismos, todos em `monstros.s`:

### a) "Apareceu" (uma vez por monstro)

Cada monstro ocupa 48 bytes. O campo **`+44`** foi criado para guardar "já apareceu na tela?". A rotina `monstro_apareceu` roda para cada monstro vivo, todo quadro:

```
se +44 == 1: nada (já apareceu antes)
se o monstro está na tela (x - camera_x entre -16 e 320):
    +44 = 1
    toca sons_monstros[tipo]
```

A tabela fica em `dados/monstros.s`, na **mesma ordem dos tipos** (igual às tabelas de imagens e cores):

```asm
sons_monstros:
.word SFX_MONSTRO_CALCULO, SFX_MONSTRO_AOC, SFX_MONSTRO_INTEGRAL, SFX_MONSTRO_LIM, SFX_MONSTRO_DERIVADA
```

### b) "Voz" de vez em quando (rodízio)

`vozes_monstros` roda uma vez por quadro, no fim de `atualizar_monstros`:

- tem um **cronômetro** (`som_voz_timer`) que conta para trás;
- quando chega a zero, sorteia o próximo intervalo: **120 a 183 quadros (2 a 3 s)**, usando a rotina `aleatorio` que o jogo já tinha;
- procura **um** monstro vivo que esteja na tela, começando de onde parou da última vez (`som_voz_vez`), em **rodízio**, e toca a voz dele.

Por que só um por vez? Para não virar barulheira e para não estourar o orçamento de notas.

### c) Ao virar e ao pular

- Monstros que andam no chão chamam `frente_livre`; quando ela devolve 0, o monstro **virou** (beirada ou parede) e toca `sons_monstros_vira[tipo]`. Há um **intervalo mínimo de 3 s** (`som_vira_ultimo`) porque o monstro de AOC, num degrau pequeno, vira a cada ~0,7 s.
- A derivada toca `SFX_DERIVADA_PULO` a cada pulo.

### A regra "só na tela": `som_monstro`

```asm
som_monstro:                   # a0 = monstro, a1 = efeito
    lw   t0, 0(a0)             # x do monstro no mundo
    la   t1, camera_x
    lw   t1, 0(t1)
    sub  t0, t0, t1            # x na tela = x no mundo - câmera
    li   t1, -16
    blt  t0, t1, smo_fim       # saiu pela esquerda: quieto
    li   t1, LARGURA_TELA
    bge  t0, t1, smo_fim       # ainda não chegou: quieto
    mv   a0, a1
    tail tocar_som             # está na tela: toca
smo_fim:
    ret
```

É a **mesma conta que o desenho usa** para saber onde pôr o monstro na tela (`x - camera_x`). Ou seja, o som "enxerga" o mesmo que a câmera.

### O bug que foi corrigido

Os monstros do treino não faziam som porque, no primeiro quadro do treino, a **câmera ainda estava onde o menu tinha deixado** (no menu a câmera passeia pelo campus). Os monstros eram marcados como "já apareceram" com a câmera errada (fora da tela de verdade) e nunca mais tocavam. A correção foi chamar `atualizar_camera` no fim de `carregar_fase`. Além disso, os primeiros sons eram **graves demais** (73 a 98 Hz, que caixinhas de notebook não reproduzem) ou de timbre muito fraco; foram refeitos em frequências médias e volume alto.

---

## 7. A música de fundo (`musica.s`)

### As três trilhas

| Trilha | Onde | Andamento | Tom e acordes (8 compassos) | Camadas (vozes) | Notas por segundo |
|---|---|---|---|---|---|
| `musica_treino` | treino | ~128 BPM, alegre | dó maior: C C Am G F C G C | melodia em onda quadrada; baixo "um" nos tempos 1 e 3; piano "pá" nos tempos 2 e 4 | 4,6 |
| `musica_calculo` | Fase 1 | ~150 BPM, agitada | lá menor: Am F C G (2x) | melodia em metais; baixo pulando de oitava; caixa nos tempos 2 e 4 | 6,7 |
| `musica_chefe` | chefão | ~200 BPM, frenética | mi menor: Em C D B (2x) | escalas rápidas em dente de serra; baixo martelando oitavas; taiko nos tempos 1 e 3 | 9,7 |

A lógica é a dos jogos de plataforma: **quanto maior o perigo, mais rápida a música**. O acorde **B (si maior)** no fim da música do chefão é o "quinto grau" de mi menor; ele cria tensão e "puxa" de volta para o começo do loop, por isso a música parece não ter fim.

### Formato (igual ao dos efeitos, com uma diferença)

```asm
musica_treino:
# compasso 1 (C)
.word  0,  67,  214,  80,  66   # G4  (melodia)
.word  0,  48,  858,  33,  90   # C3  (baixo, junto: espera 0)
.word 14,  72,  429,  80,  66   # C5
...
.word -2, 28                    # fim: espera 28 quadros e VOLTA PARA O COMEÇO
```

O fim de um efeito é `-1` (para). O fim de uma música é **`-2, espera`**: espera o resto do último compasso e **volta para a primeira nota** (loop).

### Como `atualizar_musica` funciona

É o mesmo sequenciador dos efeitos, com 3 diferenças:

1. **Loop:** ao achar `-2`, espera o tempo dado e aponta de novo para `musica_inicio`.
2. **Pausa automática:** logo no começo ela confere o estado do jogo:
   ```asm
   la   t0, estado_jogo
   lw   t0, 0(t0)
   li   t1, ESTADO_JOGANDO
   bne  t0, t1, amu_fim       # não está jogando: não anda
   ```
   Como o contador **não anda**, a música **congela no lugar** e continua do mesmo ponto quando o jogo volta. Na tela de pergunta do chefão, ela pausa e depois continua.
3. **Atraso no começo:** `tocar_musica` põe o contador em **-60**. Ele precisa subir até 0 antes da primeira nota, ou seja, **1 segundo de silêncio** para a fanfarra de começo de fase tocar sozinha.

### Onde a música liga e desliga

| Momento | O que acontece | Onde |
|---|---|---|
| ENTER na tela de transição | toca a música da fase (`F_MUSICA`) | `telas.s`, `estado_transicao` |
| o chefão aparece | troca para `musica_chefe` | `chefes.s`, `chefe_iniciar` |
| pergunta do chefão | pausa (continua depois) | automático (estado ≠ JOGANDO) |
| morte | para | `jogador.s`, `iniciar_morte` |
| filminho | para | `cinema.s`, `iniciar_cinema` |
| entrar na porta | para | `fases.s`, `iniciar_porta` |
| carregar uma fase (inclusive recomeçar) | para | `fases.s`, `carregar_fase` |
| menu e telas de texto | não toca (economia de notas) | |

### Como as músicas foram escritas (e como mudar)

As músicas foram compostas como **partituras**: cada voz (melodia, baixo, percussão) com **uma nota por colcheia**, 8 colcheias por compasso. Essas partituras viraram as linhas `.word` do `musica.s`, em ordem de tempo:

1. o nome da nota vira número: `(oitava + 1) × 12 + posição` (C=0, D=2, E=4, F=5, G=7, A=9, B=11; `#` soma 1). Ex.: `C4` = 5×12+0 = **60**, `A4` = 5×12+9 = **69**;
2. a duração de cada nota é quantas colcheias ela segura × quadros por colcheia;
3. as vozes são intercaladas em ordem de tempo e a `espera` de cada nota é a distância (em quadros) até a nota anterior; notas no mesmo instante ficam com espera 0.

Para **mudar uma nota**, troque o número da nota na linha `.word` (o comentário diz qual é: `# G4`). Para **mudar o ritmo**, mexa nas esperas, lembrando que elas são relativas: aumentar a espera de uma nota atrasa todas as que vêm depois dela.

**Andamento:** chamando de `passo` quantos quadros dura uma colcheia (14 no treino, 12 na fase, 9 no chefão). Uma semínima (1 tempo) = 2 colcheias, então:

```
BPM = 60 segundos / (2 × passo / 60) = 1800 / passo
passo 14 → 128 BPM    passo 12 → 150 BPM    passo 9 → 200 BPM
```

**Custo:** com 4900 notas, a música dura uns **17 min de treino, 12 de fase ou 8 de chefão**. Uma partida inteira (treino + fase + chefão) gasta perto de 4000. Se acabar, só a música para.

---

## 8. A música tem parallax?

### Primeiro: o que é o parallax do cenário

Em `cenario.s`, cada camada do fundo anda numa **fração da velocidade da câmera**:

```
deslocamento da camada = camera_x × K / 256      (a divisão por 256 é um srli 8)

céu e sol  K = 0     parados
nuvens     K = 26    ~10%   + deriva própria
serra      K = 30    ~12%
morros     K = 64     25%
prédio     K = 123   ~48%
arbustos   K = 160   ~62%
```

O que está "longe" anda devagar e o que está "perto" anda rápido, e isso dá a **ilusão de profundidade**. As **nuvens** têm duas coisas somadas:

1. **parallax** (dependem da câmera: só andam quando o estudante anda);
2. **deriva própria** (dependem do **tempo**: `nuvem_x` aumenta 1 a cada 8 quadros no `main.s`, mesmo com o estudante parado).

### E a música?

**A música não tem parallax.** Ela não olha a câmera nem a posição do estudante: depende **só do tempo** (do contador de quadros). Se for comparar com as nuvens, ela parece com a **deriva própria** (a parte que anda sozinha com o tempo), **não** com o parallax.

Mas existe uma **analogia** que vale a pena saber explicar:

| Cenário (parallax) | Música |
|---|---|
| várias **camadas** (céu, serra, morros, prédio, arbustos) | várias **vozes** (melodia, baixo, percussão) |
| cada camada anda numa **velocidade** diferente | cada voz anda num **ritmo** diferente (o baixo toca a cada 2 tempos, a melodia em colcheias, a percussão nos tempos 2 e 4) |
| todas usam a **mesma câmera** | todas usam o **mesmo relógio** (quadros) |
| sobrepostas dão a ilusão de **profundidade** | sobrepostas dão a sensação de **música "cheia"** |

E **o que depende da câmera no som?** Os **monstros**: eles só fazem som quando `x - camera_x` cai dentro da tela (a mesma conta do desenho). Isso é parecido com o parallax no sentido de que **o som "segue" a câmera**, mas é liga/desliga, não uma velocidade proporcional.

### Daria para fazer um "parallax sonoro"?

Daria fazer algo parecido: **o volume de um monstro depender da distância** até o estudante (longe = baixinho, perto = alto), com uma conta do mesmo tipo do parallax:

```
volume = 127 - |x_monstro - x_jogador| × K / 256
```

A ecall 31 aceita volume (`a3`), então é possível. O que **não** dá é som em estéreo (esquerda/direita), porque a ecall 31 não tem esse parâmetro. Isso não foi feito; está na lista de melhorias (seção 13).

---

## 9. A música (ou os efeitos) atrapalham alguma outra função?

Pontos que foram verificados, um por um:

**1. Tempo do quadro.** O jogo tem 16 ms por quadro. A ecall 31 não espera a nota (medido: 0 ms para 20 notas), e o sequenciador faz só algumas comparações por canal. Ou seja, **não deixa o jogo mais lento**.

**2. Ordem no laço.** `atualizar_som` roda **depois** da rotina da tela. Então, se no quadro 100 o estudante pula, a nota sai **no mesmo quadro 100** (sem atraso de um quadro).

**3. Registradores.**

- `tocar_som` e `tocar_musica` só usam `t0`/`t1`, então podem ser chamadas no meio de qualquer rotina.
- `atualizar_som` salva `ra`, `s1`, `s2` na pilha.
- A ecall usa `a0`–`a3` e `a7`. Isso não atrapalha porque `atualizar_som` roda no laço principal, entre um quadro e outro, quando nenhuma rotina do jogo está no meio do caminho.
- Em `dano_jogador`, que precisa do `a0` (direção do empurrão), o `a0` é salvo na pilha antes de `tocar_som` e restaurado depois.

**4. Estado do jogo.** O som **só lê** `estado_jogo`, `camera_x`, `tempo` e as teclas. Ele **não escreve** em nada do jogo (posição, vidas, estados). Ou seja, tirar o som não muda a jogabilidade.

**5. As ecalls (o único efeito "global").** É o único jeito do som afetar o resto: se gastasse ecalls demais, o **simulador inteiro cairia**. Por isso os dois orçamentos (seção 3).

**6. Teclado.** A tecla M entrou na tabela de teclas. Ela não conflita com nenhuma outra (as respostas são 1–4 e A–D).

**7. O que mudou de verdade em funções antigas:**

- `carregar_fase` agora também chama `parar_musica` e `atualizar_camera`. O `atualizar_camera` redesenha o fundo uma vez a mais ao carregar a fase (custo de um quadro, sem efeito visível).
- `iniciar_morte` agora para a música e, se houver chefão, desvia para o filminho antes da queda.
- `desenhar_jogador` agora respeita `jogador_oculto`.
- `verificar_meta` virou a colisão com a porta (antes era com a bandeira).

---

## 10. A porta da UNIFESP (fim do treino)

### Onde fica

Em `dados/fases.s`:

```asm
meta_tutorial:
.word 896, 176      # x do canto esquerdo do prédio e y do chão, em pixels
```

896 = coluna 56 × 16 e 176 = linha 11 × 16: o prédio fica **em cima das pedras do fim do mapa**, onde antes estava a bandeira.

### Como é desenhado (sem imagem PNG)

Em vez de desenhar o prédio pixel a pixel, ele é desenhado com **retângulos**, a partir de uma tabela (`predio_unifesp` em `fases.s`):

```asm
predio_unifesp:     # .word dx, dy, largura, altura, cor
.word  0, -8, 10,  8, COR_PREDIO_AZUL  # ameias (castelinho)
.word -2,  0, 68,  6, COR_PREDIO_AZUL  # telhado
.word  0,  6, 64, 66, COR_PREDIO       # parede
...
.word  0,  0,  0,  0, 0                # fim (largura 0)
```

`desenhar_porta` percorre a tabela chamando `preencher_retangulo` (que o jogo já tinha). Depois escreve "UNIFESP" no letreiro com a fonte do jogo e, por último, desenha a **folha da porta** (madeira, almofadas e maçaneta). A largura da folha é `20 - porta_abertura`: quando `porta_abertura` cresce, a folha "some" para o lado da dobradiça, e é isso que dá a impressão de abrir.

### A máquina de estados

Ao encostar na porta **com os pés no chão** (`verificar_meta`), o jogo vai para o estado novo **`ESTADO_PORTA`**:

```
fase 0  ABRINDO    porta_abertura vai de 0 a 20 (1 por quadro)
fase 1  ANDANDO    o estudante anda 1 pixel por quadro até o meio da porta
                   (animação de corrida). Ao chegar: jogador_oculto = 1, confete
fase 2  FECHANDO   porta_abertura volta de 20 a 0
fase 3  ESPERANDO  50 quadros com a porta fechada -> "TREINO CONCLUÍDO"
```

Por que "com os pés no chão"? Para o estudante não entrar no meio de um pulo, flutuando.

---

## 11. O "filminho" do golpe final

### Quando aparece

- **Derrota:** o estudante perde o último coração **com o chefão na tela** (`iniciar_morte` confere `chefe_estado ≠ 0`). Mostra "PROVA SURPRESA!", depois "REPROVADO!" e então a queda normal e o GAME OVER.
- **Vitória:** o estudante acerta a última pergunta (`chefe_resposta`). Mostra "RESPOSTA CERTA!", depois "APROVADO!" e então o livro explode e a fase termina.

Ele é um **estado próprio** (`ESTADO_CINEMA`). Enquanto ele roda, o jogo fica **congelado** (ninguém chama `atualizar_jogador`, `atualizar_chefe` etc.), por isso o filminho pode "parar o tempo".

### Linha do tempo (em quadros, 60 = 1 s)

```
  0 ─ 12   faixas pretas entrando, cena escurecida
 12 ─ 96   PARTE 1: faixa colorida entra pela direita com o retrato do atacante + nome do golpe
 96 ─ 102  CLARÃO branco  (SFX_IMPACTO)
102 ─ 200  PARTE 2: retrato da vítima tremendo, faíscas, resultado na faixa de baixo
     200   acabou -> ESTADO_MORTE (derrota) ou ESTADO_JOGANDO + explosões (vitória)
```

ENTER pula o filminho (depois de meio segundo).

### As técnicas usadas

**1. Escurecer a tela (manipulação de bits).** A cor de cada pixel é um byte `BBGGGRRR` (2 bits de azul, 3 de verde, 3 de vermelho). Para deixar tudo com **metade do brilho**, cada canal é dividido por 2. Deslocar o byte inteiro 1 bit para a direita (`srli 1`) divide os três canais de uma vez, mas o bit mais baixo de cada canal "vaza" para o canal vizinho. A **máscara** apaga esses bits que vazaram:

```
cor original:      B B G G G R R R
depois do srli 1:  0 B B G G G R R
máscara 0x5B:      0 1 0 1 1 0 1 1      (apaga o B que caiu no G e o G que caiu no R)
resultado:         0 B 0 G G 0 R R  =  cada canal dividido por 2
```

E isso é feito **4 pixels por vez**, numa word, com a máscara `0x5B5B5B5B` (rotina `escurecer_frame`): são 19.200 words por tela, só um `lw`, `srli`, `and`, `sw` em cada.

**2. Retratos grandes (escala).** `desenhar_imagem_escala` desenha cada pixel da imagem como um **quadrado** de `escala × escala`. O livro (48×48) vira 96×96 com escala 2; o estudante (32×32) vira 96×96 com escala 3. São as **mesmas imagens** do jogo, só ampliadas.

**3. Faixas de cinema.** Dois retângulos pretos (em cima e embaixo) cuja altura cresce 4 pixels por quadro até 44, e diminui no final.

**4. Faixa que entra pela direita.** `x = 320 - (quadro - 12) × 24`, até chegar em 0. O retrato acompanha a faixa.

**5. Riscos de velocidade.** A cada quadro, 12 linhas finas em posições e comprimentos **sorteados** (`aleatorio`). Como mudam todo quadro, parecem passar voando.

**6. Tremida.** Na parte 2, o retrato é desenhado deslocado de -3 a +3 pixels (sorteado) a cada quadro, durante 60 quadros.

**7. Clarão.** Durante 6 quadros a tela inteira é pintada de branco (`preencher_frame`).

**8. Textos.** Usam a fonte do jogo com escala 1, 2 e 3 (o "REPROVADO!" usa escala 3). Os textos e as cores de cada tipo ficam em tabelas (`cin_textos`, `cin_cores`), então o mesmo código serve para a derrota e para a vitória.

**9. Som.** `SFX_ESPECIAL` ("vuuush") quando começa, `SFX_IMPACTO` no clarão e `SFX_BOSS_DEFEAT` quando acaba (vitória). A música para durante o filminho para dar o impacto do silêncio.

---

## 12. Como tudo foi testado

Como não dá para "olhar" a tela de dentro do terminal, foi montado um **roteiro de teste automático** (numa cópia do projeto, sem mexer no original):

1. Uma rotina `teste_roteiro` finge apertar teclas em quadros certos. Por exemplo: segurar para a direita, pular a cada 32 quadros, ou chamar `dano_jogador` no quadro 220.
2. Uma rotina `teste_dump` salva a tela em arquivo (ecalls de arquivo 1024/64/57) em quadros escolhidos.
3. Um script do PowerShell converte esses arquivos em imagens PNG, usando a mesma paleta `BBGGGRRR`.
4. Para o som, a ecall 31 foi trocada por um **contador** que imprime `instrumento:nota@quadro`. Assim deu para conferir que cada nota sai no quadro certo (ex.: as 7 notas da porta nos quadros 6, 12, 18, 24 e o acorde no 34), sem tocar nada no alto-falante.

Também foi testado o **limite de ecalls** (seção 3) e que a ecall 31 **não bloqueia**.

---

## 13. O que poderia ser mudado ou melhorado

| Ideia | Como | Onde |
|---|---|---|
| Trocar um som | mudar notas/instrumento/volume na tabela do efeito | `sfx.s` |
| Mudar a música | trocar os números das notas nas linhas `.word` (o comentário diz o nome da nota) | `musica.s` |
| Música mais lenta/rápida | multiplicar todas as esperas por um mesmo fator (BPM = 1800 / passo) | `musica.s` |
| Música mais longa sem acabar o orçamento | menos notas por segundo (tirar as linhas da percussão, somando a espera delas na nota seguinte) | `musica.s` |
| Dividir diferente o orçamento | `SOM_LIMITE` e `MUSICA_LIMITE` (a soma deve ficar abaixo de ~7500) | `sfx.s`, `musica.s` |
| Música no menu | pôr `tocar_musica` no menu e trocar o teste de estado em `atualizar_musica` (cuidado: gasta notas com o jogo parado) | `telas.s`, `musica.s` |
| Música para uma fase nova | escrever a trilha (mesmo formato, terminando em `-2, espera`) e pôr no campo `F_MUSICA` da fase | `musica.s`, `dados/fases.s` |
| Som de monstro novo | criar `SFX_...` e pôr nas tabelas `sons_monstros` / `sons_monstros_vira` | `sfx.s`, `dados/monstros.s` |
| Monstros falarem mais ou menos | mudar o sorteio de `vozes_monstros` (`andi a0, a0, 63` / `addi a0, a0, 120`) | `monstros.s` |
| "Parallax sonoro" | volume do monstro proporcional à distância (seção 8) | `som_monstro` em `monstros.s` |
| Itens (energético etc.) | usar o `SFX_PICKUP`, que já existe | onde o item for coletado |
| Mudar o filminho | tempos (`CIN_*`), textos (`textos.s`), cores (`cin_cores`) | `cinema.s` |
| Filminho também contra monstros comuns | chamar `iniciar_cinema` em `iniciar_morte` sem exigir chefão (não recomendado: fica repetitivo) | `jogador.s` |
| Porta em outras fases | preencher `F_META` com `.word x, y` do prédio | `dados/fases.s` |
| Trilhas em MP3 de verdade | só com um programa externo tocando o áudio (fora do Assembly); o jogo escreveria num arquivo qual trilha tocar | `jogar.bat` + script |
| Outra versão do FPGRARS | talvez uma versão diferente não tenha o problema da pilha; precisaria testar com o mesmo programinha da seção 3 | `fpgrars.exe` |

---

## 14. Perguntas que o professor pode fazer

**"Como vocês fizeram som se o FPGRARS não toca áudio?"**
Com MIDI pela ecall 31. Cada nota é uma ecall com nota, duração, instrumento e volume. Quem gera o som é o sintetizador MIDI do Windows.

**"A ecall de som não trava o jogo?"**
Não: ela não espera a nota acabar (medimos 0 ms para 20 notas). Para tocar uma nota **depois** de outra, a gente não usa `sleep`. Usamos um **sequenciador** que, a cada quadro, vê se já é hora da próxima nota (seção 4).

**"Por que vocês têm um limite de notas?"**
Porque o `fpgrars.exe` do Windows cai depois de ~8000 ecalls (medimos com um programa de teste). Então o som tem um orçamento: 2600 notas de efeitos e 4900 de música. Quando acaba, o som para e o jogo continua.

**"O que é um canal no seu código?"**
Um "tocador" independente: guarda qual é a próxima nota e há quantos quadros tocou a última. São 4, para que um som não corte o outro (ex.: o pulo não corta a explosão do chefão).

**"Como sai um acorde?"**
Várias notas com `espera = 0`. O sequenciador toca uma e, como a próxima também tem espera 0, toca ela no mesmo quadro (o laço `j as_nota` repete).

**"Como a música repete?"**
A última linha da trilha é `-2, espera`: o motor espera o resto do compasso e aponta de volta para a primeira nota (`musica_inicio`).

**"A música tem parallax como as nuvens?"**
Não. Ela depende só do tempo (quadros), não da câmera; nisso parece com a **deriva** das nuvens, não com o parallax. A analogia é que a música tem **camadas** (melodia, baixo, percussão) em ritmos diferentes, como o cenário tem camadas em velocidades diferentes. O que depende da câmera é o som dos monstros: eles só tocam se `x - camera_x` está dentro da tela (seção 8).

**"Como vocês escureceram a tela no filminho?"**
Cada canal da cor `BBGGGRRR` é dividido por 2: `srli 1` mais a máscara `0x5B` apaga os bits que vazam entre canais. Fazemos 4 pixels por vez com `0x5B5B5B5B` (seção 11).

**"O som atrapalha a jogabilidade?"**
Não: o som só **lê** variáveis do jogo (estado, câmera, teclas) e nunca escreve nelas. Roda uma vez por quadro, depois da lógica, e não deixa o quadro mais lento.

**"Por que a música para na pergunta?"**
`atualizar_musica` só anda quando `estado_jogo == ESTADO_JOGANDO`. Na pergunta o contador fica parado, e quando volta continua do mesmo ponto. Isso também economiza notas.

**"Como vocês compuseram as músicas?"**
Como partituras (uma nota por colcheia, 8 por compasso) que viraram as tabelas `.word` do `musica.s`: o nome da nota vira número MIDI (`(oitava+1)×12 + posição`), a duração é quantas colcheias ela segura e a espera é a distância até a nota anterior. Os acordes seguem progressões comuns (ex.: Am–F–C–G), e cada fase tem um andamento: 128, 150 e 200 BPM (BPM = 1800 / passo).

**"Por que a porta é desenhada com retângulos e não com imagem?"**
Porque é um prédio de formas retas: 17 retângulos ocupam bem menos memória que 64 × 72 pixels, e dá para animar a porta só mudando uma largura. Ela é uma tabela de retângulos (dados) percorrida por uma rotina, igual ao padrão de tabelas do resto do jogo. A animação de abrir é só a largura da folha diminuindo.

**"O que é `ESTADO_PORTA` / `ESTADO_CINEMA`?"**
Dois estados novos na `tabela_estados` do `main.s`. O laço principal chama a rotina do estado atual a cada quadro; os estados novos só acrescentaram duas entradas nessa tabela, sem mudar o laço.

---

## 15. Gráficos sem Python: desenhos em texto

Antes, os gráficos eram PNGs convertidos por programas em Python (`converter.py`, `gerar_fonte.py`...) para milhares de linhas `.byte 0x94,0x9D,...`, impossíveis de ler. Agora **o projeto é todo em assembly**: os `.py` foram apagados e os desenhos estão escritos **em texto, dentro dos `.s`**, com uma letra por pixel:

```asm
pal_coracao_cheio:
.byte '.',0xC7, 'R',0x0E, 'r',0x03, '1',0xAF, 0     # paleta: letra -> cor
.align 2
img_coracao_cheio:
.word 9, 8                                          # largura, altura
.ascii "..rr.rr.."
.ascii ".rRRrRRr."
...
```

**Como vira imagem:** a rotina `montar_desenhos` (`src/rotinas/desenhos.s`) roda **uma vez**, no começo do `main`:

1. para cada imagem da `tabela_desenhos`, monta uma tabela de tradução de 256 bytes (`traducao[letra] = cor`) a partir da paleta;
2. troca **no próprio lugar** cada letra pela cor (1 letra = 1 byte = 1 pixel, então o tamanho não muda);
3. faz o mesmo com os mapas (`'.'` = 0, `'1'..'9'`, `'A'..'Z'` = 10 a 35);
4. monta a tabela `fonte`: cada linha de 5 letras (`#` = aceso) vira 1 byte, deslocando um bit por coluna (`slli` + `ori`).

Depois disso a memória fica **igual** a como era antes, então `desenhar_imagem`, `desenhar_mapa` e `desenhar_letra` não mudaram nada. **Verificamos:** rodamos o jogo antigo e o novo com os mesmos roteiros de teste e as telas saíram **idênticas byte a byte** (27 telas: menu, treino, porta, chefão e filminho).

**Perguntas prováveis:**

**"Por que trocar no próprio lugar e não guardar em outro lugar?"**
Porque cada letra ocupa 1 byte, igual à cor que ela representa. Trocando no lugar não gastamos memória extra: a imagem em texto **vira** a imagem em cores.

**"E se rodar `montar_desenhos` duas vezes?"**
Daria errado, porque na segunda vez as cores seriam tratadas como letras. Por isso ela só é chamada uma vez, na primeira linha do `main`.

**"Como sai uma letra da fonte?"**
Para cada uma das 12 linhas, começa com 0 e, para cada uma das 5 colunas, faz `byte = byte << 1` e, se o caractere for `#`, `byte = byte | 1`. No fim, a coluna da esquerda está no bit 4, que é o que `desenhar_letra` espera.

Mais detalhes de como editar e criar desenhos estão no `GUIA_GRAFICOS.md`.
