############################################################################
#  FASES
#
#  Um registro por fase, na ordem dos campos F_* (main.s):
#    mapa, monstros, porta de chegada, início x, início y, coluna da arena, chefão,
#    tiro, cenário, nome, título, frase, dicas, próxima fase, texto de conclusão,
#    música de fundo
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
.word 0                                # próxima fase ainda não existe: volta ao menu
.word txt_calculo_concluido
.word musica_calculo                   # trilha animada (o chefão tem a dele: musica_chefe)

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
