############################################################################
#  FASES
#
#  Um registro por fase, na ordem dos campos F_* (main.s):
#    mapa, monstros, porta de chegada, início x, início y, coluna da arena, chefão,
#    tiro, cenário, nome, título, frase, dicas, próxima fase, texto de conclusão,
#    música de fundo, velocidade extra dos monstros, tempo (cronômetro, em segundos)
#
#  CRONÔMETRO: cada fase tem um tempo (F_TEMPO). Ele aparece no alto da tela e
#  corre durante o jogo e nas perguntas dos chefões (para de correr quando o
#  chefão é derrotado). Se zerar, o estudante "REPROVOU POR FALTA!" (filminho
#  de derrota) e a fase recomeça. Treino 1 min, Fase 1 3 min, Fase 2 4 min,
#  Fase 3 4,5 min: uns 30% a mais que o tempo de um jogador médio.
#
#  As fases, em ordem:  treino (campus) -> Fase 1: Cálculo 1 -> Fase 2: AED
#                       -> Fase 3: AOC (chefão final) -> formatura (volta ao menu)
#  Cada fase é mais difícil que a anterior: mapa mais comprido, mais monstros
#  (e mais rápidos), blocos que machucam e um chefão com mais vida, mais
#  projéteis e perguntas mais frequentes (veja os registros em rotinas/chefes.s).
#
#  Para criar uma fase nova: desenhe o mapa em dados/graficos.s (mapa_xxx, uma letra
#  por bloco, e ponha o mapa na tabela_mapas),
#  ponha a lista de monstros em dados/monstros.s e os textos em dados/textos.s.
############################################################################

.data
.align 2

# ---------------------------- treino no campus ----------------------------
fase_tutorial:
.word mapa_fase1                       # F_MAPA      (graficos/mapas/fase1.txt)
.word monstros_tutorial                # F_MONSTROS
.word meta_tutorial                    # F_META      porta da UNIFESP (chegada)
.word 40, 180                          # F_INICIO_X, F_INICIO_Y  (de pé na grama)
.word 0                                # F_ARENA     sem chefão
.word CHEFE_NENHUM                     # F_CHEFE
.word 0                                # F_TIRO
.word cenario_campus                   # F_CENARIO
.word txt_tutorial_nome                # F_NOME
.word txt_tutorial_titulo              # F_TITULO
.word txt_tutorial_frase               # F_FRASE
.word dicas_tutorial                   # F_DICAS
.word fase_calculo                     # F_PROXIMA
.word txt_tutorial_concluido           # F_CONCLUIDA
.word musica_treino                    # F_MUSICA    trilha calma
.word 0                                # F_VEL_MONSTROS (1/16 px por quadro a mais)
.word 60                               # F_TEMPO     cronômetro: 1 minuto

# ---------------------------- Fase 1: Cálculo 1 ----------------------------
fase_calculo:
.word mapa_calculo                     # graficos/mapas/calculo.txt
.word monstros_calculo
.word 0                                # sem porta: termina vencendo o chefão
.word 40, 180
.word 60                               # a arena começa na coluna 60
.word CHEFE_STEWART
.word 0                                # Cálculo não tem tiro
.word cenario_sala
.word txt_calculo_nome
.word txt_calculo_titulo
.word txt_calculo_frase
.word 0
.word fase_aed                         # próxima: Fase 2
.word txt_calculo_concluido
.word musica_calculo                   # trilha animada (o chefão tem a dele: musica_chefe)
.word 0                                # monstros na velocidade normal
.word 180                              # cronômetro: 3 minutos

# ---------------------------- Fase 2: AED ----------------------------
# Laboratório de computação. Mapa de 110 colunas (5,5 telas), 16 monstros
# (pilhas, nós de grafo e ponteiros) 25% mais rápidos e espinhos no chão.
fase_aed:
.word mapa_aed                         # dados/graficos_fases23.s
.word monstros_aed
.word 0                                # sem porta: termina vencendo o chefão
.word 40, 180
.word 90                               # a arena começa na coluna 90
.word CHEFE_GRAFO
.word 0                                # sem tiro: o chefão é vencido com perguntas
.word cenario_lab
.word txt_aed_nome
.word txt_aed_titulo
.word txt_aed_frase
.word 0
.word fase_aoc                         # próxima: Fase 3
.word txt_aed_concluido
.word musica_aed
.word 4                                # monstros 4/16 de pixel por quadro mais rápidos
.word 240                              # cronômetro: 4 minutos

# ---------------------------- Fase 3: AOC (fase final) ----------------------------
# Dentro do computador: placas de circuito, chips e servidores. Mapa de 140
# colunas (7 telas), 22 monstros (bits, bugs, portas lógicas e chips) 50% mais
# rápidos, muitos curtos-circuitos no chão e o chefão final: o Professor de AOC.
fase_aoc:
.word mapa_aoc
.word monstros_aoc
.word 0
.word 40, 180
.word 120                              # a arena começa na coluna 120
.word CHEFE_PROFESSOR
.word 0
.word cenario_circuito
.word txt_aoc_nome
.word txt_aoc_titulo
.word txt_aoc_frase
.word 0
.word 0                                # última fase: depois da formatura volta ao menu
.word txt_aoc_concluido
.word musica_aoc
.word 8                                # monstros 8/16 de pixel por quadro mais rápidos
.word 270                              # cronômetro: 4 minutos e meio

# porta do treino (prédio da UNIFESP): .word x do canto esquerdo, y do chão (pixels)
# fica em cima das pedras das colunas 56 a 59 (x = 56 * 16 = 896; chão em 11 * 16 = 176)
meta_tutorial:
.word 896, 176

# dicas do treino:  .word x_inicio, x_fim (em pixels do mundo), texto  ...  0, 0, 0
dicas_tutorial:
.word 0,   150, txt_dica_andar
.word 150, 330, txt_dica_pulo
.word 330, 620, txt_dica_pisar
.word 620, 800, txt_dica_dano
.word 800, 2000, txt_dica_bandeira
.word 0, 0, 0
