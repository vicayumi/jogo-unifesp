############################################################################
#  TELAS DO JOGO (um "estado" por tela)
#
#  O laço principal (main.s) chama, a cada quadro, a rotina do estado atual:
#     estado_menu        tela inicial
#     estado_historia    explicação: história e controles (HISTORIA_PAGINAS telas)
#     estado_transicao   nome da fase antes de começar
#     estado_jogando     o jogo em si
#     estado_pergunta    pergunta do chefão (perguntas.s)
#     estado_morte       animação de morte
#     estado_game_over   GAME OVER; ENTER recomeça a mesma fase
#     estado_concluida   fase concluída; ENTER vai para a próxima
#     estado_porta       o estudante entra pela porta da UNIFESP (fases.s)
#     estado_cinema      "filminho" do golpe final contra o chefão (cinema.s)
############################################################################

.eqv HISTORIA_PAGINAS  2

.data
.align 2
historia_pagina:  .word 0
paginas_historia: .word txt_historia_1, txt_historia_2

.text

# --------------------------------------------------------------------------
# mudar_estado: a0 = novo estado (zera o contador do estado e as teclas novas)
# --------------------------------------------------------------------------
mudar_estado:
    la   t0, estado_jogo
    sw   a0, 0(t0)
    la   t0, estado_timer
    sw   zero, 0(t0)
    j    limpar_teclas_novas

# piscar: a0 = 1 na metade "acesa" de um pisca-pisca de meio segundo
piscar:
    la   t0, tempo
    lw   t0, 0(t0)
    srli t0, t0, 5
    andi a0, t0, 1
    xori a0, a0, 1
    ret


# --------------------------------------------------------------------------
# estado_menu: cenário do campus passando ao fundo, título e "PRESSIONE ENTER"
# --------------------------------------------------------------------------
estado_menu:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)

    # a câmera passeia devagar pelo campus (vai e volta)
    la   t0, tempo
    lw   t1, 0(t0)
    srli t1, t1, 2
    li   t2, 1280                      # 2 x 640 (largura do campus - 320)
    remu t1, t1, t2
    li   t2, 640
    blt  t1, t2, me_cam
    li   t3, 1280
    sub  t1, t3, t1
me_cam:
    la   t0, camera_x
    sw   t1, 0(t0)
    la   t0, camera_ultimo
    lw   t2, 0(t0)
    beq  t1, t2, me_desenha
    sw   t1, 0(t0)
    call redesenhar_fundo

me_desenha:
    call frame_escondido
    mv   s1, a0
    call copiar_fundo

    # estudante correndo no lugar
    la   a0, anim_estudante_corrida
    la   t0, tempo
    lw   t1, 0(t0)
    li   t2, 5
    div  t1, t1, t2
    andi t1, t1, 7
    addi t1, t1, 1
    slli t1, t1, 2
    add  a0, a0, t1
    lw   a0, 4(a0)
    li   a1, 144
    li   a2, 176
    li   a3, 0
    mv   a4, s1
    call desenhar_imagem

    la   a0, txt_titulo_1
    li   a1, CENTRO
    li   a2, 30
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 3
    call desenhar_texto_sombra
    la   a0, txt_titulo_2
    li   a1, CENTRO
    li   a2, 70
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 2
    call desenhar_texto_sombra
    la   a0, txt_subtitulo
    li   a1, CENTRO
    li   a2, 100
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    call piscar
    beqz a0, me_rodape
    la   a0, txt_pressione_enter
    li   a1, CENTRO
    li   a2, 134
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 2
    call desenhar_texto_sombra
me_rodape:
    la   a0, txt_rodape_menu
    li   a1, CENTRO
    li   a2, 224
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    call mostrar_frame

    li   a0, T_ENTER
    call tecla_nova
    beqz a0, me_fim
    la   a0, SFX_MENU
    call tocar_som
    la   t0, historia_pagina
    sw   zero, 0(t0)
    li   a0, ESTADO_HISTORIA
    call mudar_estado
me_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# estado_historia: as telas de explicação (história e como jogar)
# --------------------------------------------------------------------------
estado_historia:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    call frame_escondido
    mv   s1, a0
    call copiar_fundo                  # o campus parado, por trás
    li   a0, 12
    li   a1, 10
    li   a2, 296
    li   a3, 220
    li   a4, COR_PAINEL
    mv   a5, s1
    li   a6, COR_AMARELO
    call desenhar_painel

    la   t0, historia_pagina
    lw   t1, 0(t0)
    slli t1, t1, 2
    la   t0, paginas_historia
    add  t0, t0, t1
    lw   a0, 0(t0)
    li   a1, 26
    li   a2, 22
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto

    call piscar
    beqz a0, eh_mostra
    la   a0, txt_enter_continuar
    li   a1, CENTRO
    li   a2, 210
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
eh_mostra:
    call mostrar_frame

    li   a0, T_ENTER
    call tecla_nova
    beqz a0, eh_fim
    la   a0, SFX_MENU
    call tocar_som
    la   t0, historia_pagina
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    li   t2, HISTORIA_PAGINAS
    blt  t1, t2, eh_fim
    la   a0, fase_tutorial             # acabou a explicação: começa o treino
    call carregar_fase
    li   a0, ESTADO_TRANSICAO
    call mudar_estado
eh_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# estado_transicao: "FASE 1 / CÁLCULO 1" e a frase da fase
# --------------------------------------------------------------------------
estado_transicao:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    call frame_escondido
    mv   s1, a0
    li   a1, COR_FUNDO_TRANSICAO
    call preencher_frame
    la   t0, fase_atual
    lw   s2, 0(t0)

    lw   a0, F_NOME(s2)
    li   a1, CENTRO
    li   a2, 58
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 2
    call desenhar_texto_sombra
    lw   a0, F_TITULO(s2)
    li   a1, CENTRO
    li   a2, 86
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 3
    call desenhar_texto_sombra
    lw   a0, F_FRASE(s2)
    li   a1, CENTRO
    li   a2, 140
    li   a3, COR_CINZA
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
    call piscar
    beqz a0, et_mostra
    la   a0, txt_enter_comecar
    li   a1, CENTRO
    li   a2, 200
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
et_mostra:
    call mostrar_frame

    li   a0, T_ENTER
    call tecla_nova
    beqz a0, et_fim
    la   a0, SFX_PHASE
    call tocar_som
    lw   a0, F_MUSICA(s2)              # música da fase
    beqz a0, et_sem_musica
    call tocar_musica
et_sem_musica:
    la   t0, camera_ultimo             # força o cenário da fase a ser desenhado
    li   t1, 99999
    sw   t1, 0(t0)
    li   a0, ESTADO_JOGANDO
    call mudar_estado
et_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# estado_jogando: um quadro de jogo
# --------------------------------------------------------------------------
estado_jogando:
    addi sp, sp, -4
    sw   ra, 0(sp)
    li   a0, 0
    call atualizar_tempo_fase          # cronômetro (se zerar: reprovou por falta)
    la   t0, estado_jogo
    lw   t0, 0(t0)
    li   t1, ESTADO_JOGANDO
    bne  t0, t1, ej_desenha
    call atualizar_jogador
    call atualizar_monstros
    call colidir_monstros
    call atualizar_chefe
    call atualizar_projeteis
    call atualizar_particulas
    call verificar_meta
    call verificar_arena
ej_desenha:
    call atualizar_camera
    call frame_escondido
    call desenhar_cena
    call mostrar_frame
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# CRONÔMETRO DA FASE
#   fase_tempo = quadros que faltam (carregar_fase põe F_TEMPO x 60).
#   atualizar_tempo_fase roda a cada quadro do jogo (estado_jogando) e das
#   perguntas (estado_pergunta, com a0 = 1: aí ele só desconta, sem matar; se
#   zerar durante a pergunta, o estudante reprova assim que ela fechar).
#   Não corre com o chefão já derrotado (explodindo). Nos últimos 10 s faz
#   "tique" a cada segundo. Se zerar: morte_causa = CAUSA_TEMPO e iniciar_morte
#   (jogador.s), que passa o filminho "REPROVOU POR FALTA!".
# --------------------------------------------------------------------------
atualizar_tempo_fase:
    la   t0, fase_atual                # fase sem cronômetro
    lw   t0, 0(t0)
    lw   t0, F_TEMPO(t0)
    beqz t0, atf_fim
    la   t0, chefe_estado              # chefão derrotado: o tempo para
    lw   t0, 0(t0)
    li   t1, CH_MORRENDO
    beq  t0, t1, atf_fim
    la   t0, fase_tempo
    lw   t1, 0(t0)
    blez t1, atf_zerou
    addi t1, t1, -1
    sw   t1, 0(t0)
    li   t2, 600                       # últimos 10 s: tique a cada segundo
    bgt  t1, t2, atf_fim
    li   t2, 60
    remu t2, t1, t2
    bnez t2, atf_fim
    beqz t1, atf_fim
    la   a0, SFX_TIQUE                 # (tocar_som só mexe em t0 e t1)
    tail tocar_som
atf_zerou:
    bnez a0, atf_fim                   # na pergunta: espera ela fechar
    la   t0, morte_causa
    li   t1, CAUSA_TEMPO
    sw   t1, 0(t0)
    la   t0, jogador_vidas             # os corações ficam vazios
    sw   zero, 0(t0)
    tail iniciar_morte
atf_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_tempo: o cronômetro "m:ss" no alto da tela, ao lado dos corações.
#   Branco; amarelo no último minuto; vermelho piscando nos últimos 10 s.
#   a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_tempo:
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t0, F_TEMPO(t0)
    beqz t0, dte_fim
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    mv   s1, a0
    la   t0, fase_tempo                # s2 = segundos (arredondando para cima)
    lw   t0, 0(t0)
    bgez t0, dte_pos
    li   t0, 0
dte_pos:
    addi t0, t0, 59
    li   t1, 60
    divu s2, t0, t1
    la   t0, texto_tempo               # monta "m:ss"
    divu t2, s2, t1                    # minutos
    addi t2, t2, '0'
    sb   t2, 0(t0)
    li   t2, ':'
    sb   t2, 1(t0)
    remu t2, s2, t1                    # segundos
    li   t1, 10
    divu t3, t2, t1
    addi t3, t3, '0'
    sb   t3, 2(t0)
    remu t3, t2, t1
    addi t3, t3, '0'
    sb   t3, 3(t0)
    sb   zero, 4(t0)
    la   a0, img_relogio_mini
    li   a1, 44
    li   a2, 6
    li   a3, 0
    mv   a4, s1
    call desenhar_imagem
    li   a3, COR_BRANCO
    li   t0, 60
    bgt  s2, t0, dte_texto
    li   a3, COR_AMARELO
    li   t0, 10
    bgt  s2, t0, dte_texto
    li   a3, COR_VERMELHO_CLARO        # últimos 10 s: vermelho piscando
    la   t0, tempo
    lw   t0, 0(t0)
    andi t0, t0, 16
    beqz t0, dte_texto
    li   a3, COR_BRANCO
dte_texto:
    la   a0, texto_tempo
    li   a1, 56
    li   a2, 5
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
dte_fim:
    ret

.data
texto_tempo: .space 8
.align 2
.text


# --------------------------------------------------------------------------
# desenhar_cena: tudo o que aparece durante o jogo.  a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_cena:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    mv   s1, a0
    call copiar_fundo                  # cenário + blocos
    mv   a0, s1
    call desenhar_porta                # prédio da UNIFESP no fim do treino
    mv   a0, s1
    call desenhar_monstros
    mv   a0, s1
    call desenhar_chefe
    mv   a0, s1
    call desenhar_projeteis
    mv   a0, s1
    call desenhar_jogador
    mv   a0, s1
    call desenhar_particulas
    mv   a0, s1
    call desenhar_hud
    mv   a0, s1
    call desenhar_tempo                # cronômetro da fase
    mv   a0, s1
    call desenhar_dica
    mv   a0, s1
    call desenhar_hud_chefe
    mv   a0, s1
    call desenhar_debug                # indicadores dos atalhos de teste (debug.s)
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# estado_morte: o estudante cai para fora da tela; depois GAME OVER
# --------------------------------------------------------------------------
estado_morte:
    addi sp, sp, -4
    sw   ra, 0(sp)
    call mover_morte
    call atualizar_particulas
    call frame_escondido
    call desenhar_cena
    call mostrar_frame
    la   t0, estado_timer
    lw   t1, 0(t0)
    li   t2, MORTE_QUADROS
    blt  t1, t2, emo_fim
    li   a0, ESTADO_GAME_OVER
    call mudar_estado
    la   a0, SFX_GAMEOVER              # melodia triste do game over
    call tocar_som
emo_fim:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# estado_game_over: painel GAME OVER; ENTER recomeça a mesma fase
# --------------------------------------------------------------------------
estado_game_over:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    call frame_escondido
    mv   s1, a0
    li   a1, COR_PRETO
    call preencher_frame
    la   a0, img_tela_game_over
    li   a1, 56                        # (320 - 208) / 2
    li   a2, 72
    li   a3, 0
    mv   a4, s1
    call desenhar_imagem
    la   a0, txt_game_over_dica
    li   a1, CENTRO
    li   a2, 160
    li   a3, COR_CINZA
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
    call mostrar_frame
    li   a0, T_ENTER
    call tecla_nova
    beqz a0, ego_fim
    la   a0, SFX_MENU
    call tocar_som
    la   t0, fase_atual
    lw   a0, 0(t0)
    call carregar_fase
    li   a0, ESTADO_TRANSICAO
    call mudar_estado
ego_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# estado_concluida: fase concluída; ENTER vai para a próxima (ou para o menu)
# --------------------------------------------------------------------------
estado_concluida:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    la   t0, fase_atual                # última fase (a formatura): fogos de artifício
    lw   t0, 0(t0)
    lw   t0, F_PROXIMA(t0)
    bnez t0, ec_particulas
    call fogos_formatura
ec_particulas:
    call atualizar_particulas
    call frame_escondido
    mv   s1, a0
    call desenhar_cena                 # a fase parada por trás
    la   t0, fase_atual
    lw   s2, 0(t0)
    li   a0, 30
    li   a1, 56
    li   a2, 260
    li   a3, 128
    li   a4, COR_PAINEL
    mv   a5, s1
    li   a6, COR_VERDE
    lw   t0, F_PROXIMA(s2)             # formatura: borda dourada
    bnez t0, ec_painel
    li   a6, COR_AMARELO
ec_painel:
    call desenhar_painel
    lw   a0, F_CONCLUIDA(s2)
    li   a1, CENTRO
    li   a2, 68
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
    la   t0, estado_timer
    lw   t0, 0(t0)
    li   t1, 40
    blt  t0, t1, ec_mostra             # espera um pouco antes de aceitar ENTER
    call piscar
    beqz a0, ec_mostra
    la   a0, txt_enter_continuar
    li   a1, CENTRO
    li   a2, 166
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
ec_mostra:
    call mostrar_frame
    la   t0, estado_timer
    lw   t0, 0(t0)
    li   t1, 40
    blt  t0, t1, ec_fim
    li   a0, T_ENTER
    call tecla_nova
    beqz a0, ec_fim
    la   a0, SFX_MENU
    call tocar_som
    lw   a0, F_PROXIMA(s2)
    beqz a0, ec_menu
    call carregar_fase
    li   a0, ESTADO_TRANSICAO
    call mudar_estado
    j    ec_fim
ec_menu:                               # acabou o jogo (formatura): volta ao menu
    la   a0, fase_tutorial
    call carregar_fase
    li   a0, ESTADO_MENU
    call mudar_estado
ec_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# fogos_formatura: na tela da formatura, a cada 12 quadros estoura um fogo de
#   artifício (explosão de partículas) num lugar e numa cor sorteados
# --------------------------------------------------------------------------
fogos_formatura:
    la   t0, estado_timer
    lw   t0, 0(t0)
    li   t1, 12
    remu t0, t0, t1
    bnez t0, ff_fim
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    call aleatorio
    andi t0, a0, 3
    la   t1, cores_fogos
    slli t0, t0, 2
    add  t1, t1, t0
    lw   s1, 0(t1)                     # s1 = cor
    call aleatorio
    li   t0, 280
    remu t0, a0, t0
    addi t0, t0, 20
    la   t1, camera_x                  # (as partículas ficam no mundo)
    lw   t1, 0(t1)
    add  t0, t0, t1
    la   t1, chefe_aux
    sw   t0, 0(t1)
    call aleatorio
    li   t0, 120
    remu a1, a0, t0
    addi a1, a1, 20
    la   t0, chefe_aux
    lw   a0, 0(t0)
    mv   a2, s1
    li   a3, 18
    call explodir
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
ff_fim:
    ret

.data
.align 2
cores_fogos: .word COR_AMARELO, COR_BRANCO, COR_VERMELHO_CLARO, 0xF8
.text

# --------------------------------------------------------------------------
# desenhar_hud: corações e nome da matéria.  a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_hud:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    mv   s1, a0
    li   s2, 0
    la   t0, jogador_vidas
    lw   s3, 0(t0)
dh_loop:
    li   t0, VIDAS_INICIAIS
    bge  s2, t0, dh_nome
    la   a0, img_coracao_cheio
    blt  s2, s3, dh_desenha
    la   a0, img_coracao_vazio
dh_desenha:
    li   t0, 11
    mul  a1, s2, t0
    addi a1, a1, 6
    li   a2, 6
    li   a3, 0
    mv   a4, s1
    call desenhar_imagem
    addi s2, s2, 1
    j    dh_loop
dh_nome:
    la   t0, chefe_estado              # com chefão na tela, o alto é dele
    lw   t0, 0(t0)
    bnez t0, dh_fim
    la   t0, fase_atual                # nome da matéria no canto direito
    lw   t0, 0(t0)
    lw   s2, F_TITULO(t0)
    mv   a0, s2
    call largura_linha
    li   t0, LARG_LETRA
    mul  t0, t0, a0
    li   a1, 314
    sub  a1, a1, t0
    mv   a0, s2
    li   a2, 5
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
dh_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret
