############################################################################
#  MÚSICA DE FUNDO (MIDI, ecall 31)
#
#  Cada fase tem a sua trilha (campo F_MUSICA do registro da fase) e o chefão
#  tem outra, mais rápida, como nos jogos de plataforma:
#     musica_treino    alegre    (~128 BPM, dó maior: onda quadrada, baixo "um-pá" e piano)
#     musica_calculo   agitada   (~150 BPM, lá menor: metais, baixo de oitavas e caixa)
#     musica_chefe     frenética (~200 BPM, mi menor: dente de serra, baixo e taiko)
#  As trilhas são loops: no fim voltam para o começo.
#
#  FORMATO (igual ao dos efeitos de sfx.s):
#       .word espera, nota, duração (ms), instrumento, volume     <- uma nota
#       .word -2, espera                                          <- volta ao começo
#  espera = quadros (1/60 s) depois da nota anterior; 0 = junto (acorde).
#  Cada linha tem um comentário com o nome da nota (C4 = dó central = 60;
#  +1 = meio tom; +12 = uma oitava) e os compassos estão marcados com o acorde.
#  Para mudar a música é só mudar as notas aqui. Andamento: uma colcheia dura
#  14 quadros no treino (~128 BPM), 12 na fase (~150 BPM) e 9 no chefão (~200 BPM).
#
#  ORÇAMENTO: cada nota é uma ecall e o fpgrars.exe cai perto de 8000 ecalls.
#  A música tem um orçamento só dela (MUSICA_LIMITE notas, separado do dos efeitos).
#  Para economizar:
#    - a música só anda durante o jogo (ESTADO_JOGANDO): pausa na pergunta do
#      chefão e não toca no menu, nas telas de texto, no filminho nem na morte;
#    - com o som desligado (M) ela continua andando, mas sem gastar ecall.
#  Quando o orçamento acaba a música para (os efeitos continuam).
#  Dá uns 17 min de treino, 12 min de fase ou 8 min de chefão (uma partida
#  inteira gasta perto de 4000).
#
#  Para tocar:  la a0, musica_treino / call tocar_musica      (só muda t0 e t1)
#  Para parar:  call parar_musica
############################################################################

.eqv MUSICA_LIMITE    4900
.eqv MUSICA_ATRASO    60               # quadros de silêncio antes de começar (deixa a fanfarra tocar)

.data
.align 2
musica_inicio:     .word 0             # primeira nota da trilha (0 = sem música)
musica_ptr:        .word 0             # próxima nota
musica_cont:       .word 0             # quadros desde a última nota
musica_restantes:  .word MUSICA_LIMITE

.text

# --------------------------------------------------------------------------
# tocar_musica: a0 = trilha.  Começa do início depois de MUSICA_ATRASO quadros.
# --------------------------------------------------------------------------
tocar_musica:
    la   t0, musica_inicio
    sw   a0, 0(t0)
    la   t0, musica_ptr
    sw   a0, 0(t0)
    la   t0, musica_cont
    li   t1, MUSICA_ATRASO
    sub  t1, zero, t1                  # contador negativo = espera antes de começar
    sw   t1, 0(t0)
    ret

# parar_musica: silêncio (as notas que já saíram terminam sozinhas)
parar_musica:
    la   t0, musica_ptr
    sw   zero, 0(t0)
    ret


# --------------------------------------------------------------------------
# atualizar_musica: uma vez por quadro (chamada por atualizar_som)
# --------------------------------------------------------------------------
atualizar_musica:
    la   t0, estado_jogo               # só durante o jogo
    lw   t0, 0(t0)
    li   t1, ESTADO_JOGANDO
    bne  t0, t1, amu_fim
    la   t0, musica_ptr
    lw   t0, 0(t0)
    beqz t0, amu_fim
    addi sp, sp, -4
    sw   ra, 0(sp)
amu_nota:
    la   t2, musica_ptr
    lw   t0, 0(t2)                     # t0 = próxima nota
    lw   t1, 0(t0)                     # espera dela
    li   t3, -2
    beq  t1, t3, amu_volta
    la   t3, musica_cont
    lw   t4, 0(t3)
    blt  t4, t1, amu_conta             # ainda não é a hora
    sw   zero, 0(t3)
    lw   a0, 4(t0)
    lw   a1, 8(t0)
    lw   a2, 12(t0)
    lw   a3, 16(t0)
    addi t0, t0, 20
    sw   t0, 0(t2)
    call nota_musica
    j    amu_nota                      # a próxima pode ser junto (acorde)
amu_volta:                             # fim da trilha: espera o resto do compasso e volta
    lw   t1, 4(t0)
    la   t3, musica_cont
    lw   t4, 0(t3)
    blt  t4, t1, amu_conta
    sw   zero, 0(t3)
    la   t0, musica_inicio
    lw   t0, 0(t0)
    sw   t0, 0(t2)
    j    amu_nota
amu_conta:
    addi t4, t4, 1
    sw   t4, 0(t3)
    lw   ra, 0(sp)
    addi sp, sp, 4
amu_fim:
    ret

# nota_musica: como nota_midi (sfx.s), mas gasta o orçamento da música
nota_musica:
    la   t0, som_ligado
    lw   t0, 0(t0)
    beqz t0, nmu_fim
    la   t0, musica_restantes
    lw   t1, 0(t0)
    blez t1, nmu_fim
    addi t1, t1, -1
    sw   t1, 0(t0)
    li   a7, 31
    ecall
nmu_fim:
    ret


# ------------------------------ as trilhas --------------------------------
.data
.align 2
# musica_treino: 69 notas em 14.9 s (4.6 notas por segundo)
# musica_calculo: 86 notas em 12.8 s (6.7 notas por segundo)
# musica_chefe: 93 notas em 9.6 s (9.7 notas por segundo)

musica_treino:
# compasso 1 (C)
.word  0,  67,  214,  80,  66   # G4
.word  0,  48,  858,  33,  90   # C3
.word 14,  72,  429,  80,  66   # C5
.word 14,  64,  150,   4,  62   # E4
.word 14,  76,  214,  80,  66   # E5
.word 14,  79,  429,  80,  66   # G5
.word  0,  43,  858,  33,  90   # G2
.word 28,  76,  429,  80,  66   # E5
.word  0,  67,  150,   4,  62   # G4
# compasso 2 (C)
.word 28,  77,  214,  80,  66   # F5
.word  0,  48,  858,  33,  90   # C3
.word 14,  76,  214,  80,  66   # E5
.word 14,  74,  429,  80,  66   # D5
.word  0,  64,  150,   4,  62   # E4
.word 28,  72,  429,  80,  66   # C5
.word  0,  43,  858,  33,  90   # G2
.word 28,  67,  150,   4,  62   # G4
# compasso 3 (Am)
.word 28,  69,  214,  80,  66   # A4
.word  0,  45,  858,  33,  90   # A2
.word 14,  72,  429,  80,  66   # C5
.word 14,  60,  150,   4,  62   # C4
.word 14,  76,  214,  80,  66   # E5
.word 14,  81,  429,  80,  66   # A5
.word  0,  40,  858,  33,  90   # E2
.word 28,  79,  429,  80,  66   # G5
.word  0,  64,  150,   4,  62   # E4
# compasso 4 (G)
.word 28,  77,  214,  80,  66   # F5
.word  0,  43,  858,  33,  90   # G2
.word 14,  76,  214,  80,  66   # E5
.word 14,  74,  429,  80,  66   # D5
.word  0,  59,  150,   4,  62   # B3
.word 28,  67,  429,  80,  66   # G4
.word  0,  50,  858,  33,  90   # D3
.word 28,  62,  150,   4,  62   # D4
# compasso 5 (F)
.word 28,  69,  214,  80,  66   # A4
.word  0,  41,  858,  33,  90   # F2
.word 14,  72,  214,  80,  66   # C5
.word 14,  77,  429,  80,  66   # F5
.word  0,  57,  150,   4,  62   # A3
.word 28,  81,  429,  80,  66   # A5
.word  0,  48,  858,  33,  90   # C3
.word 28,  77,  429,  80,  66   # F5
.word  0,  60,  150,   4,  62   # C4
# compasso 6 (C)
.word 28,  79,  429,  80,  66   # G5
.word  0,  48,  858,  33,  90   # C3
.word 28,  76,  214,  80,  66   # E5
.word  0,  64,  150,   4,  62   # E4
.word 14,  72,  429,  80,  66   # C5
.word 14,  43,  858,  33,  90   # G2
.word 14,  76,  214,  80,  66   # E5
.word 14,  79,  429,  80,  66   # G5
.word  0,  67,  150,   4,  62   # G4
# compasso 7 (G)
.word 28,  77,  214,  80,  66   # F5
.word  0,  43,  858,  33,  90   # G2
.word 14,  76,  214,  80,  66   # E5
.word 14,  74,  429,  80,  66   # D5
.word  0,  59,  150,   4,  62   # B3
.word 28,  71,  214,  80,  66   # B4
.word  0,  50,  858,  33,  90   # D3
.word 14,  74,  429,  80,  66   # D5
.word 14,  62,  150,   4,  62   # D4
.word 14,  79,  214,  80,  66   # G5
# compasso 8 (C)
.word 14,  76,  429,  80,  66   # E5
.word  0,  48,  858,  33,  90   # C3
.word 28,  72,  429,  80,  66   # C5
.word  0,  64,  150,   4,  62   # E4
.word 28,  72,  429,  80,  66   # C5
.word  0,  43,  858,  33,  90   # G2
.word 28,  67,  150,   4,  62   # G4
.word -2, 28                       # volta para o começo

musica_calculo:
# compasso 1 (Am)
.word  0,  69,  368,  62,  72   # A4
.word  0,  45,  368,  38,  90   # A2
.word 24,  76,  368,  62,  72   # E5
.word  0,  57,  368,  38,  90   # A3
.word  0,  50,   90, 118,  95   # D3
.word 24,  81,  184,  62,  72   # A5
.word  0,  45,  368,  38,  90   # A2
.word 12,  79,  184,  62,  72   # G5
.word 12,  76,  368,  62,  72   # E5
.word  0,  57,  368,  38,  90   # A3
.word  0,  50,   90, 118,  95   # D3
# compasso 2 (F)
.word 24,  77,  368,  62,  72   # F5
.word  0,  41,  368,  38,  90   # F2
.word 24,  76,  184,  62,  72   # E5
.word  0,  53,  368,  38,  90   # F3
.word  0,  50,   90, 118,  95   # D3
.word 12,  72,  368,  62,  72   # C5
.word 12,  41,  368,  38,  90   # F2
.word 12,  69,  184,  62,  72   # A4
.word 12,  72,  368,  62,  72   # C5
.word  0,  53,  368,  38,  90   # F3
.word  0,  50,   90, 118,  95   # D3
# compasso 3 (C)
.word 24,  67,  368,  62,  72   # G4
.word  0,  48,  368,  38,  90   # C3
.word 24,  72,  184,  62,  72   # C5
.word  0,  60,  368,  38,  90   # C4
.word  0,  50,   90, 118,  95   # D3
.word 12,  76,  368,  62,  72   # E5
.word 12,  48,  368,  38,  90   # C3
.word 12,  79,  368,  62,  72   # G5
.word 12,  60,  368,  38,  90   # C4
.word  0,  50,   90, 118,  95   # D3
.word 12,  76,  184,  62,  72   # E5
# compasso 4 (G)
.word 12,  74,  368,  62,  72   # D5
.word  0,  43,  368,  38,  90   # G2
.word 24,  71,  368,  62,  72   # B4
.word  0,  55,  368,  38,  90   # G3
.word  0,  50,   90, 118,  95   # D3
.word 24,  67,  368,  62,  72   # G4
.word  0,  43,  368,  38,  90   # G2
.word 24,  74,  368,  62,  72   # D5
.word  0,  55,  368,  38,  90   # G3
.word  0,  50,   90, 118,  95   # D3
# compasso 5 (Am)
.word 24,  81,  368,  62,  72   # A5
.word  0,  45,  368,  38,  90   # A2
.word 24,  79,  184,  62,  72   # G5
.word  0,  57,  368,  38,  90   # A3
.word  0,  50,   90, 118,  95   # D3
.word 12,  76,  368,  62,  72   # E5
.word 12,  45,  368,  38,  90   # A2
.word 12,  81,  368,  62,  72   # A5
.word 12,  57,  368,  38,  90   # A3
.word  0,  50,   90, 118,  95   # D3
.word 12,  84,  184,  62,  72   # C6
# compasso 6 (F)
.word 12,  81,  368,  62,  72   # A5
.word  0,  41,  368,  38,  90   # F2
.word 24,  79,  184,  62,  72   # G5
.word  0,  53,  368,  38,  90   # F3
.word  0,  50,   90, 118,  95   # D3
.word 12,  77,  368,  62,  72   # F5
.word 12,  41,  368,  38,  90   # F2
.word 12,  76,  184,  62,  72   # E5
.word 12,  77,  368,  62,  72   # F5
.word  0,  53,  368,  38,  90   # F3
.word  0,  50,   90, 118,  95   # D3
# compasso 7 (C)
.word 24,  76,  368,  62,  72   # E5
.word  0,  48,  368,  38,  90   # C3
.word 24,  79,  368,  62,  72   # G5
.word  0,  60,  368,  38,  90   # C4
.word  0,  50,   90, 118,  95   # D3
.word 24,  84,  368,  62,  72   # C6
.word  0,  48,  368,  38,  90   # C3
.word 24,  79,  184,  62,  72   # G5
.word  0,  60,  368,  38,  90   # C4
.word  0,  50,   90, 118,  95   # D3
.word 12,  76,  184,  62,  72   # E5
# compasso 8 (G)
.word 12,  74,  368,  62,  72   # D5
.word  0,  43,  368,  38,  90   # G2
.word 24,  79,  368,  62,  72   # G5
.word  0,  55,  368,  38,  90   # G3
.word  0,  50,   90, 118,  95   # D3
.word 24,  83,  368,  62,  72   # B5
.word  0,  43,  368,  38,  90   # G2
.word 24,  86,  368,  62,  72   # D6
.word  0,  55,  368,  38,  90   # G3
.word  0,  50,   90, 118,  95   # D3
.word -2, 24                       # volta para o começo

musica_chefe:
# compasso 1 (Em)
.word  0,  76,  138,  81,  64   # E5
.word  0,  40,  276,  38,  92   # E2
.word  0,  28,  150, 116, 105   # E1
.word  9,  79,  138,  81,  64   # G5
.word  9,  83,  276,  81,  64   # B5
.word  0,  52,  276,  38,  92   # E3
.word 18,  81,  138,  81,  64   # A5
.word  0,  40,  276,  38,  92   # E2
.word  0,  28,  150, 116, 105   # E1
.word  9,  79,  138,  81,  64   # G5
.word  9,  78,  138,  81,  64   # F#5
.word  0,  52,  276,  38,  92   # E3
.word  9,  76,  138,  81,  64   # E5
# compasso 2 (C)
.word  9,  79,  276,  81,  64   # G5
.word  0,  36,  276,  38,  92   # C2
.word  0,  28,  150, 116, 105   # E1
.word 18,  76,  276,  81,  64   # E5
.word  0,  48,  276,  38,  92   # C3
.word 18,  72,  276,  81,  64   # C5
.word  0,  36,  276,  38,  92   # C2
.word  0,  28,  150, 116, 105   # E1
.word 18,  76,  138,  81,  64   # E5
.word  0,  48,  276,  38,  92   # C3
.word  9,  79,  138,  81,  64   # G5
# compasso 3 (D)
.word  9,  78,  138,  81,  64   # F#5
.word  0,  38,  276,  38,  92   # D2
.word  0,  28,  150, 116, 105   # E1
.word  9,  81,  138,  81,  64   # A5
.word  9,  86,  276,  81,  64   # D6
.word  0,  50,  276,  38,  92   # D3
.word 18,  84,  138,  81,  64   # C6
.word  0,  38,  276,  38,  92   # D2
.word  0,  28,  150, 116, 105   # E1
.word  9,  81,  138,  81,  64   # A5
.word  9,  78,  276,  81,  64   # F#5
.word  0,  50,  276,  38,  92   # D3
# compasso 4 (B)
.word 18,  83,  276,  81,  64   # B5
.word  0,  35,  276,  38,  92   # B1
.word  0,  28,  150, 116, 105   # E1
.word 18,  81,  138,  81,  64   # A5
.word  0,  47,  276,  38,  92   # B2
.word  9,  79,  138,  81,  64   # G5
.word  9,  78,  276,  81,  64   # F#5
.word  0,  35,  276,  38,  92   # B1
.word  0,  28,  150, 116, 105   # E1
.word 18,  75,  276,  81,  64   # D#5
.word  0,  47,  276,  38,  92   # B2
# compasso 5 (Em)
.word 18,  76,  276,  81,  64   # E5
.word  0,  40,  276,  38,  92   # E2
.word  0,  28,  150, 116, 105   # E1
.word 18,  71,  138,  81,  64   # B4
.word  0,  52,  276,  38,  92   # E3
.word  9,  76,  138,  81,  64   # E5
.word  9,  79,  276,  81,  64   # G5
.word  0,  40,  276,  38,  92   # E2
.word  0,  28,  150, 116, 105   # E1
.word 18,  83,  276,  81,  64   # B5
.word  0,  52,  276,  38,  92   # E3
# compasso 6 (C)
.word 18,  84,  138,  81,  64   # C6
.word  0,  36,  276,  38,  92   # C2
.word  0,  28,  150, 116, 105   # E1
.word  9,  83,  138,  81,  64   # B5
.word  9,  81,  138,  81,  64   # A5
.word  0,  48,  276,  38,  92   # C3
.word  9,  79,  276,  81,  64   # G5
.word  9,  36,  276,  38,  92   # C2
.word  0,  28,  150, 116, 105   # E1
.word  9,  76,  276,  81,  64   # E5
.word  9,  48,  276,  38,  92   # C3
.word  9,  72,  138,  81,  64   # C5
# compasso 7 (D)
.word  9,  74,  138,  81,  64   # D5
.word  0,  38,  276,  38,  92   # D2
.word  0,  28,  150, 116, 105   # E1
.word  9,  78,  138,  81,  64   # F#5
.word  9,  81,  276,  81,  64   # A5
.word  0,  50,  276,  38,  92   # D3
.word 18,  86,  276,  81,  64   # D6
.word  0,  38,  276,  38,  92   # D2
.word  0,  28,  150, 116, 105   # E1
.word 18,  81,  276,  81,  64   # A5
.word  0,  50,  276,  38,  92   # D3
# compasso 8 (B)
.word 18,  83,  138,  81,  64   # B5
.word  0,  35,  276,  38,  92   # B1
.word  0,  28,  150, 116, 105   # E1
.word  9,  81,  138,  81,  64   # A5
.word  9,  79,  138,  81,  64   # G5
.word  0,  47,  276,  38,  92   # B2
.word  9,  78,  138,  81,  64   # F#5
.word  9,  75,  276,  81,  64   # D#5
.word  0,  35,  276,  38,  92   # B1
.word  0,  28,  150, 116, 105   # E1
.word 18,  71,  276,  81,  64   # B4
.word  0,  47,  276,  38,  92   # B2
.word -2, 18                       # volta para o começo

