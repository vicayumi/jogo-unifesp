############################################################################
#  EFEITOS SONOROS (MIDI)
#
#  O FPGRARS só toca som por MIDI, com a ecall 31:
#       a0 = nota (0 a 127; 60 = dó central)     a1 = duração em ms
#       a2 = instrumento (General MIDI, 0 a 127)  a3 = volume (0 a 127)
#  A ecall 31 não espera a nota acabar: o jogo continua rodando.
#
#  CUIDADO COM AS ECALLS: no fpgrars.exe do Windows cada ecall deixa um resto
#  na pilha do simulador. Testamos: ele cai com "has overflowed its stack"
#  depois de uns 8000 ecalls. Por isso:
#    - cada efeito usa poucas notas (1 nota = 1 ecall);
#    - o jogo guarda um "orçamento" (som_restantes, começa em SOM_LIMITE).
#      Quando ele acaba, o som desliga sozinho e o jogo continua sem cair.
#    - M liga/desliga o som (desligado não gasta ecall nenhuma).
#
#  COMO UM EFEITO É GUARDADO
#       NOME_DO_EFEITO:
#       .word canal                                  (0 a 3)
#       .word espera, nota, duração, instrumento, volume     <- uma linha por nota
#       ...
#       .word -1                                     (fim)
#    espera = quadros (1/60 s) depois da nota anterior; 0 = junto com ela (acorde).
#    Um efeito novo num canal substitui o que estava tocando nesse canal,
#    mas não mexe nos outros canais:
#       canal 0 = estudante (pulo, pisão, item)
#       canal 1 = eventos (dano, menu, fase, porta, golpe no chefão, game over)
#       canal 2 = cinema, explosões e entrada do chefão
#       canal 3 = monstrinhos e ataques do chefão (integrais caindo)
#
#  Para tocar:   la a0, SFX_JUMP  /  call tocar_som
#  (tocar_som só mexe em t0 e t1; os registradores a0..a7 e s* ficam iguais)
#  atualizar_som roda uma vez por quadro, no laço principal (main.s).
#
#  Alguns instrumentos General MIDI (numerados a partir de 0):
#     9 glockenspiel   13 xilofone   19 órgão     38 baixo synth   47 tímpano
#    48 cordas         54 voz sintética   55 orquestra (hit)        56 trompete       61 metais
#    68 oboé           80 onda quadrada (chiptune)  81 dente de serra
#   116 taiko         118 tambor synth   121 respiração (chiado)   119 prato ao contrário   127 tiro
############################################################################

.eqv SOM_CANAIS   4
.eqv SOM_LIMITE   2600           # notas dos efeitos (a música tem as dela: MUSICA_LIMITE,
                                 # musica.s; somadas ficam abaixo das ~8000 ecalls)

.data
.align 2
som_ligado:     .word 1
som_restantes:  .word SOM_LIMITE
som_canais:     .space 32        # SOM_CANAIS x (próxima nota, quadros desde a última nota)

# ---------------------------- os efeitos ----------------------------------
#      espera nota  ms  instr vol

# pulo: chirp curto subindo
SFX_JUMP:
.word 0
.word 0,  72,  60, 80,  60
.word 2,  79,  90, 80,  55
.word -1

# pisar no monstro: pop grave + plink agudo
SFX_STOMP:
.word 0
.word 0,  40, 110, 38, 110
.word 3,  88, 160, 13, 100
.word -1

# perder coração: queda dissonante com tímpano
SFX_HURT:
.word 1
.word 0,  66, 140, 81,  90
.word 0,  36, 350, 47, 120
.word 6,  60, 260, 81,  90
.word -1

# coletar item (e resposta certa): glockenspiel
SFX_PICKUP:
.word 0
.word 0,  84, 120,  9, 100
.word 4,  88, 120,  9, 100
.word 4,  91, 300,  9, 110
.word -1

# porta da UNIFESP / fim do treino: arpejo e acorde
SFX_FLAG:
.word 1
.word 0,  60, 130, 56, 100
.word 6,  64, 130, 56, 100
.word 6,  67, 130, 56, 100
.word 6,  72, 200, 56, 105
.word 10, 72, 900, 61, 110
.word 0,  76, 900, 61, 100
.word 0,  79, 900, 61, 100
.word -1

# ENTER e confirmações
SFX_MENU:
.word 1
.word 0,  76,  70, 80,  70
.word 3,  83, 110, 80,  70
.word -1

# começo de fase: fanfarra
SFX_PHASE:
.word 1
.word 0,  67, 140, 56, 105
.word 9,  67,  90, 56, 100
.word 5,  67,  90, 56, 100
.word 5,  72, 600, 56, 115
.word 0,  64, 600, 61,  95
.word 0,  48, 600, 47, 115
.word -1

# golpe no Livro do Stewart
SFX_BOSS_HIT:
.word 1
.word 0,  45, 300, 47, 127
.word 0,  72, 200, 55, 110
.word 6,  67, 250, 55, 100
.word -1

# Livro do Stewart derrotado: explosões em cascata (no ritmo das explosões
# de chefes.s, uma a cada 8 quadros) e depois a vitória
SFX_BOSS_DEFEAT:
.word 2
.word 0,  40, 300, 127, 120
.word 8,  36, 300, 118, 120
.word 8,  43, 300, 127, 120
.word 8,  31, 400, 47,  127
.word 8,  38, 300, 127, 120
.word 8,  28, 600, 47,  127
.word 40, 72, 150, 56, 110
.word 8,  76, 150, 56, 110
.word 8,  79, 150, 56, 110
.word 8,  84, 1000, 56, 120
.word 0,  72, 1000, 61, 105
.word 0,  48, 1000, 47, 120
.word -1

# GAME OVER: melodia descendente triste
SFX_GAMEOVER:
.word 1
.word 0,  67, 380, 68,  95
.word 22, 66, 380, 68,  95
.word 22, 65, 380, 68,  95
.word 22, 64, 1300, 68, 100
.word 0,  40, 1300, 48,  90
.word -1

# cinema (ataque especial): o "vuuush" de quando a faixa entra
SFX_ESPECIAL:
.word 2
.word 0,  60, 700, 119, 110
.word 30, 55, 250, 55,  115
.word 0,  43, 400, 47,  120
.word -1

# cinema: o clarão do golpe final
SFX_IMPACTO:
.word 2
.word 0,  36, 700, 55,  127
.word 0,  30, 900, 47,  127
.word 0,  45, 500, 127, 120
.word -1

# ---------------------------- monstrinhos ---------------------------------
# Só tocam se o monstro estiver na tela (som_monstro, em monstros.s).
# Cada tipo tem uma "voz" (tabela sons_monstros, dados/monstros.s): toca quando
# o monstro entra na tela e depois, de vez em quando, enquanto ele está na tela
# (um monstro por vez, a cada 2 a 3 s: veja vozes_monstros em monstros.s).

# monstro de Cálculo (treino): "bwah-bwah" de trombone
SFX_MONSTRO_CALCULO:
.word 3
.word 0,  58, 160, 57, 125
.word 9,  53, 320, 57, 125
.word -1

# monstro de AOC (treino): bipes de computador
SFX_MONSTRO_AOC:
.word 3
.word 0,  84,  80, 80, 115
.word 5,  91,  80, 80, 115
.word 5,  84, 120, 80, 115
.word -1

# cobra da integral: chiado "tsss" (prato ao contrário, curto)
SFX_MONSTRO_INTEGRAL:
.word 3
.word 0,  76, 380, 119, 127
.word 0,  88, 200, 80,   70
.word -1

# fantasma do limite: "uuuu-uuuu" descendo
SFX_MONSTRO_LIM:
.word 3
.word 0,  74, 350, 54, 127
.word 14, 69, 600, 54, 127
.word -1

# derivada saltitante: "bóing" (baixo de slap subindo rápido)
SFX_MONSTRO_DERIVADA:
.word 3
.word 0,  55,  70, 36, 127
.word 2,  62,  70, 36, 127
.word 2,  67, 160, 36, 127
.word -1

# derivada pulando (a cada pulo, se estiver na tela)
SFX_DERIVADA_PULO:
.word 3
.word 0,  60, 140, 36, 120
.word -1

# monstro de Cálculo virando: "bwah"
SFX_CALCULO_VIRA:
.word 3
.word 0,  55, 220, 57, 115
.word -1

# monstro de AOC virando: bipe
SFX_AOC_VIRA:
.word 3
.word 0,  88,  90, 80, 105
.word -1

# cobra virando na beirada: "tss"
SFX_COBRA_VIRA:
.word 3
.word 0,  80, 220, 119, 115
.word -1

# ---------------------------- Livro do Stewart -----------------------------
# entrada: acorde menor ameaçador com tímpano
SFX_CHEFE_ENTRA:
.word 2
.word 0,  36, 900, 47,  120
.word 0,  48, 900, 61,  105
.word 0,  51, 900, 61,  100
.word 24, 35, 900, 47,  120
.word 0,  47, 1200, 61, 110
.word 0,  50, 1200, 61, 105
.word -1

# lançou um raio (a integral): "ziuuu" elétrico descendo
SFX_CHEFE_TIRO:
.word 3
.word 0,  96,  60, 80, 120
.word 3,  76, 160, 80, 120
.word -1

# o raio bateu no chão: estalo de trovão
SFX_INTEGRAL_CHAO:
.word 3
.word 0,  50, 300, 127, 120
.word -1

# o livro abre para perguntar: suspense (trítono) e um "plim" na hora da pergunta
SFX_CHEFE_ABRE:
.word 2
.word 0,  60, 800, 119,  90
.word 0,  48, 800, 48,   85
.word 0,  54, 800, 48,   85
.word 45, 84, 350, 9,   105
.word -1

.text

# --------------------------------------------------------------------------
# tocar_som: a0 = efeito (ex.: la a0, SFX_JUMP).  Só muda t0 e t1.
# --------------------------------------------------------------------------
tocar_som:
    lw   t0, 0(a0)                     # canal do efeito
    slli t0, t0, 3
    la   t1, som_canais
    add  t0, t0, t1
    addi t1, a0, 4                     # primeira nota
    sw   t1, 0(t0)
    sw   zero, 4(t0)                   # nenhum quadro desde a "última nota"
    ret

# parar_sons: silencia os canais (as notas que já saíram terminam sozinhas)
parar_sons:
    la   t0, som_canais
    sw   zero, 0(t0)
    sw   zero, 8(t0)
    sw   zero, 16(t0)
    sw   zero, 24(t0)
    ret


# --------------------------------------------------------------------------
# atualizar_som: uma vez por quadro. Toca as notas cuja espera já passou.
#   Também lê a tecla M (liga/desliga o som).
# --------------------------------------------------------------------------
atualizar_som:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    li   a0, T_MUDO                    # M: liga/desliga
    call tecla_nova
    beqz a0, as_canais
    la   t0, som_ligado
    lw   t1, 0(t0)
    xori t1, t1, 1
    sw   t1, 0(t0)

as_canais:
    la   s1, som_canais
    li   s2, SOM_CANAIS
as_canal:
    lw   t0, 0(s1)                     # t0 = próxima nota deste canal
    beqz t0, as_prox                   # canal quieto
as_nota:
    lw   t1, 0(t0)                     # espera desta nota
    bltz t1, as_acabou                 # -1: fim do efeito
    lw   t2, 4(s1)                     # quadros desde a nota anterior
    blt  t2, t1, as_conta              # ainda não é a hora
    sw   zero, 4(s1)
    lw   a0, 4(t0)                     # nota
    lw   a1, 8(t0)                     # duração (ms)
    lw   a2, 12(t0)                    # instrumento
    lw   a3, 16(t0)                    # volume
    addi t0, t0, 20
    sw   t0, 0(s1)
    call nota_midi
    lw   t0, 0(s1)
    j    as_nota                       # a próxima pode ser junto (acorde)
as_acabou:
    sw   zero, 0(s1)
    j    as_prox
as_conta:
    addi t2, t2, 1
    sw   t2, 4(s1)
as_prox:
    addi s1, s1, 8
    addi s2, s2, -1
    bnez s2, as_canal

    call atualizar_musica              # música de fundo (musica.s)

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# nota_midi: toca uma nota (a0 nota, a1 ms, a2 instrumento, a3 volume)
#   Não toca se o som está desligado ou se o orçamento de ecalls acabou.
# --------------------------------------------------------------------------
nota_midi:
    la   t0, som_ligado
    lw   t0, 0(t0)
    beqz t0, nm_fim
    la   t0, som_restantes
    lw   t1, 0(t0)
    blez t1, nm_fim                    # acabou o orçamento: fica em silêncio
    addi t1, t1, -1
    sw   t1, 0(t0)
    li   a7, 31
    ecall
nm_fim:
    ret
