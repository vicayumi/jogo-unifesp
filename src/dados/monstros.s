############################################################################
#  MONSTROS DE CADA FASE
#
#  Para colocar um monstro, escreva uma linha
#       .word tipo, comportamento, coluna, linha
#  e aumente o número da primeira linha (a quantidade de monstros).
#
#    tipo           TIPO_CALCULO, TIPO_AOC, TIPO_INTEGRAL, TIPO_LIM, TIPO_DERIVADA,
#                   TIPO_PONTEIRO, TIPO_PILHA, TIPO_NO (AED),
#                   TIPO_BIT, TIPO_BUG, TIPO_PORTA (AOC)
#    comportamento  COMP_ANDA (patrulha o chão), COMP_PULA (pula), COMP_VOA (voa em onda)
#    coluna, linha  célula do mapa onde ele nasce
#
#  O monstro ocupa a CÉLULA (coluna, linha), então a linha dele é a linha
#  logo ACIMA do bloco em que ele pisa. Ex.: o chão é a linha 13, então um
#  monstro no chão fica na linha 12. Máximo: MAX_MONSTROS (main.s).
#
#  Para criar um tipo novo: desenhe img_monstro_xxx (com a paleta pal_monstro_xxx)
#  em dados/graficos.s, ponha "img_monstro_xxx, pal_monstro_xxx" na tabela_desenhos, crie um TIPO_XXX no main.s e some img_monstro_xxx em
#  imagens_monstros (na posição igual ao número do tipo) e uma cor em
#  cores_monstros (a cor das partículas quando ele morre).
############################################################################

.data
.align 2

# imagens e cores, na ordem dos tipos (TIPO_CALCULO = 0, TIPO_AOC = 1, ...)
imagens_monstros:
.word img_monstro_calculo, img_monstro_aoc, img_monstro_integral, img_monstro_lim, img_monstro_derivada
.word img_monstro_ponteiro, img_monstro_pilha, img_monstro_no         # AED (dados/graficos_fases23.s)
.word img_monstro_bit, img_monstro_bug, img_monstro_porta             # AOC
cores_monstros:
.word 0xA7, 0x52, 0x38, 0xF7, 0x27
.word 0x27, 0xF8, 0xD9                                                # laranja, ciano, azul
.word 0x32, 0x07, 0xAD                                                # verde, vermelho, cinza
# som de quando cada tipo aparece na tela (rotinas/sfx.s; 0 = sem som)
sons_monstros:
.word SFX_MONSTRO_CALCULO, SFX_MONSTRO_AOC, SFX_MONSTRO_INTEGRAL, SFX_MONSTRO_LIM, SFX_MONSTRO_DERIVADA
.word SFX_MONSTRO_PONTEIRO, SFX_MONSTRO_PILHA, SFX_MONSTRO_NO
.word SFX_MONSTRO_BIT, SFX_MONSTRO_BUG, SFX_MONSTRO_PORTA
# som de quando um monstro que anda no chão vira (beirada ou parede; 0 = sem som)
sons_monstros_vira:
.word SFX_CALCULO_VIRA, SFX_AOC_VIRA, SFX_COBRA_VIRA, 0, 0
.word 0, SFX_MONSTRO_PILHA, 0
.word 0, 0, SFX_MONSTRO_PORTA
# 1 = vira o desenho quando anda para a esquerda; 0 = não (desenhos com letras)
#   (o ponteiro e o bug são desenhados olhando para a direita)
espelhar_monstros:
.byte 1, 1, 1, 0, 0
.byte 1, 0, 0
.byte 0, 1, 1
.align 2

# ---------------------------- treino no campus ----------------------------
monstros_tutorial:
.word 4
.word TIPO_CALCULO, COMP_ANDA, 27, 12      # no chão, depois dos degraus (dica do pisão)
.word TIPO_AOC,     COMP_ANDA, 15, 8       # no degrau alto (linha 9)
.word TIPO_CALCULO, COMP_ANDA, 24, 10      # na plataforma de tijolos (linha 11)
.word TIPO_AOC,     COMP_ANDA, 44, 12      # no chão, perto do poste

# ---------------------------- Fase 1: Cálculo 1 ----------------------------
monstros_calculo:
.word 9
.word TIPO_INTEGRAL, COMP_ANDA, 11, 12     # embaixo da mesa do professor
.word TIPO_LIM,      COMP_VOA, 18, 6       # voando sobre a mesa alta
.word TIPO_DERIVADA, COMP_PULA, 25, 12
.word TIPO_INTEGRAL, COMP_ANDA, 27, 12
.word TIPO_LIM,      COMP_VOA, 36, 7
.word TIPO_INTEGRAL, COMP_ANDA, 43, 12
.word TIPO_DERIVADA, COMP_PULA, 47, 12
.word TIPO_LIM,      COMP_VOA, 49, 9
.word TIPO_INTEGRAL, COMP_ANDA, 56, 9      # na mesa antes da arena

# ---------------------------- Fase 2: AED ----------------------------
# (linha = a de cima do bloco em que ele pisa; os voadores ficam no ar)
monstros_aed:
.word 16
.word TIPO_PILHA   , COMP_ANDA,   9, 12
.word TIPO_NO      , COMP_PULA,  13, 12
.word TIPO_PONTEIRO, COMP_VOA ,  18,  7
.word TIPO_PILHA   , COMP_ANDA,  24,  8
.word TIPO_PILHA   , COMP_ANDA,  29, 12
.word TIPO_PONTEIRO, COMP_VOA ,  33,  8
.word TIPO_NO      , COMP_PULA,  35, 12
.word TIPO_PILHA   , COMP_ANDA,  45,  9
.word TIPO_NO      , COMP_PULA,  45, 12
.word TIPO_PONTEIRO, COMP_VOA ,  52,  8
.word TIPO_PILHA   , COMP_ANDA,  57, 12
.word TIPO_PONTEIRO, COMP_VOA ,  66,  4
.word TIPO_PILHA   , COMP_ANDA,  70, 12
.word TIPO_NO      , COMP_PULA,  80, 12
.word TIPO_PONTEIRO, COMP_VOA ,  82,  7
.word TIPO_PILHA   , COMP_ANDA,  86, 12

# ---------------------------- Fase 3: AOC ----------------------------
monstros_aoc:
.word 22
.word TIPO_AOC     , COMP_ANDA,   7, 12
.word TIPO_BIT     , COMP_PULA,  11, 10
.word TIPO_BUG     , COMP_VOA ,  15,  8
.word TIPO_PORTA   , COMP_ANDA,  25, 12
.word TIPO_BUG     , COMP_VOA ,  23,  5
.word TIPO_BIT     , COMP_PULA,  27,  9
.word TIPO_AOC     , COMP_ANDA,  33, 11
.word TIPO_BUG     , COMP_VOA ,  39,  5
.word TIPO_PORTA   , COMP_ANDA,  46, 12
.word TIPO_BIT     , COMP_PULA,  47, 12
.word TIPO_BUG     , COMP_VOA ,  52,  8
.word TIPO_AOC     , COMP_ANDA,  59, 10
.word TIPO_PORTA   , COMP_ANDA,  64,  8
.word TIPO_BUG     , COMP_VOA ,  70,  4
.word TIPO_BIT     , COMP_PULA,  73,  8
.word TIPO_PORTA   , COMP_ANDA,  76, 12
.word TIPO_BUG     , COMP_VOA ,  87,  5
.word TIPO_AOC     , COMP_ANDA,  92, 12
.word TIPO_BIT     , COMP_PULA,  96, 12
.word TIPO_BUG     , COMP_VOA , 104,  6
.word TIPO_PORTA   , COMP_ANDA, 102, 12
.word TIPO_BIT     , COMP_PULA, 114, 12
