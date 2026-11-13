############################################################################
#  MONSTROS
#
#  A lista de cada fase fica em dados/monstros.s:
#       .word quantidade
#       .word tipo, comportamento, coluna, linha     (uma linha por monstro)
#
#  No começo da fase cada um é copiado para o vetor 'monstros' (TAM_MONSTRO bytes):
#     +0 x   +4 y   +8 direção (1/-1)   +12 vivo   +16 tipo   +20 comportamento
#     +24 vy (1/16 px)   +28 resto de y   +32 contador   +36 y base   +40 resto de x
#     +44 já apareceu na tela (para o som de "apareceu" tocar uma vez só)
#
#  Comportamentos:
#     COMP_ANDA  patrulha o chão; vira na parede ou quando o chão acaba
#     COMP_PULA  anda devagar e dá um pulo a cada MONSTRO_PULO_INTERVALO quadros
#     COMP_VOA   voa em onda (ignora a gravidade); vira só nas paredes
#
#  Todos têm 16 x 16 pixels. Pisar em cima mata; encostar de lado tira vida.
############################################################################

.data
# onda dos monstros voadores: 32 valores entre -10 e 10
tabela_onda: .byte 0,2,4,6,7,8,9,10,10,10,9,8,7,6,4,2,0,-2,-4,-6,-7,-8,-9,-10,-10,-10,-9,-8,-7,-6,-4,-2
.align 2
som_vira_ultimo: .word -999         # quando tocou o último som de "virar"
som_voz_timer:   .word 90           # quadros até a próxima "voz" de monstro
som_voz_vez:     .word 0            # de qual monstro começar a procurar (rodízio)

.text

# --------------------------------------------------------------------------
# iniciar_monstros: copia a lista da fase para o vetor 'monstros'
#   a0 = endereço da lista (dados/monstros.s)
# --------------------------------------------------------------------------
iniciar_monstros:
    lw   t1, 0(a0)                     # t1 = quantos monstros a fase tem
    li   t2, MAX_MONSTROS
    ble  t1, t2, im_ok
    mv   t1, t2
im_ok:
    la   t3, monstros_total
    sw   t1, 0(t3)
    addi t0, a0, 4                     # t0 = primeira entrada (4 words cada)
    la   t3, monstros                  # t3 = onde gravar
    li   t4, 0
im_loop:
    bge  t4, t1, im_fim
    lw   t5, 0(t0)
    sw   t5, 16(t3)                    # tipo
    lw   t5, 4(t0)
    sw   t5, 20(t3)                    # comportamento
    lw   t5, 8(t0)
    slli t5, t5, 4
    sw   t5, 0(t3)                     # x = coluna * 16
    lw   t5, 12(t0)
    slli t5, t5, 4
    sw   t5, 4(t3)                     # y = linha * 16
    sw   t5, 36(t3)                    # y base (voadores)
    li   t5, -1
    sw   t5, 8(t3)                     # nasce andando para a esquerda
    li   t5, 1
    sw   t5, 12(t3)                    # vivo
    sw   zero, 24(t3)
    sw   zero, 28(t3)
    slli t5, t4, 3                     # contadores diferentes: não pulam todos juntos
    sw   t5, 32(t3)
    sw   zero, 40(t3)
    sw   zero, 44(t3)                  # ainda não apareceu na tela
    addi t0, t0, 16
    addi t3, t3, TAM_MONSTRO
    addi t4, t4, 1
    j    im_loop
im_fim:
    ret


# --------------------------------------------------------------------------
# atualizar_monstros: move todos os monstros vivos
# --------------------------------------------------------------------------
atualizar_monstros:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)

    la   t0, monstros_total
    lw   s2, 0(t0)
    la   s1, monstros
    li   s3, 0
am_loop:
    bge  s3, s2, am_fim
    lw   t0, 12(s1)
    beqz t0, am_prox
    mv   a0, s1                        # entrou na tela agora? toca o som dele
    call monstro_apareceu
    mv   a0, s1
    lw   t0, 20(s1)                    # comportamento
    li   t1, COMP_PULA
    beq  t0, t1, am_pula
    li   t1, COMP_VOA
    beq  t0, t1, am_voa
    call monstro_andar
    j    am_prox
am_pula:
    call monstro_pular
    j    am_prox
am_voa:
    call monstro_voar
am_prox:
    addi s1, s1, TAM_MONSTRO
    addi s3, s3, 1
    j    am_loop
am_fim:
    call vozes_monstros                # de vez em quando um monstro da tela "fala"
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret


# --------------------------------------------------------------------------
# passo_x_monstro: decide se o monstro anda 1 pixel neste quadro
#   a0 = monstro   a1 = velocidade (1/16 de pixel por quadro)
#   devolve a0 = 1 se é para andar 1 pixel agora
# --------------------------------------------------------------------------
passo_x_monstro:
    lw   t0, 40(a0)
    add  t0, t0, a1
    li   t1, 16
    blt  t0, t1, px_nao
    sub  t0, t0, t1
    sw   t0, 40(a0)
    li   a0, 1
    ret
px_nao:
    sw   t0, 40(a0)
    li   a0, 0
    ret


# --------------------------------------------------------------------------
# frente_livre: o monstro pode andar 1 pixel para a frente?
#   a0 = monstro   a1 = 1 para exigir chão à frente (quem anda no chão)
#   devolve a0 = 1 se pode; senão o monstro já vira para o outro lado
# --------------------------------------------------------------------------
frente_livre:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    mv   s1, a0
    mv   s3, a1
    lw   t0, 8(s1)
    lw   s2, 0(s1)
    add  s2, s2, t0                    # s2 = x da borda da frente depois do passo
    blez t0, fl_testa
    addi s2, s2, 15
fl_testa:
    mv   a0, s2
    lw   a1, 4(s1)
    addi a1, a1, 1
    call ponto_solido
    bnez a0, fl_vira                   # parede (parte de cima)
    mv   a0, s2
    lw   a1, 4(s1)
    addi a1, a1, 14
    call ponto_solido
    bnez a0, fl_vira                   # parede (parte de baixo)
    beqz s3, fl_sim
    mv   a0, s2
    lw   a1, 4(s1)
    addi a1, a1, 16
    call ponto_solido
    beqz a0, fl_vira                   # o chão acaba: vira
fl_sim:
    li   a0, 1
    j    fl_fim
fl_vira:
    lw   t0, 8(s1)
    sub  t0, zero, t0
    sw   t0, 8(s1)
    li   a0, 0
fl_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret


# --------------------------------------------------------------------------
# monstro_andar (COMP_ANDA): a0 = monstro
# --------------------------------------------------------------------------
monstro_andar:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    mv   s1, a0
    li   a1, MONSTRO_VEL_ANDA
    call passo_x_monstro
    beqz a0, man_fim
    mv   a0, s1
    li   a1, 1
    call frente_livre
    beqz a0, man_virou
    lw   t0, 0(s1)
    lw   t1, 8(s1)
    add  t0, t0, t1
    sw   t0, 0(s1)
    j    man_fim
man_virou:                             # virou (beirada ou parede): som do tipo
    la   t0, tempo                     # no máximo um som de "virar" a cada 3 s
    lw   t0, 0(t0)                     # (monstro em plataforma pequena vira toda hora)
    la   t1, som_vira_ultimo
    lw   t2, 0(t1)
    sub  t2, t0, t2
    li   t3, 180
    blt  t2, t3, man_fim
    sw   t0, 0(t1)
    lw   t0, 16(s1)                    # (tabela sons_monstros_vira, dados/monstros.s)
    slli t0, t0, 2
    la   t1, sons_monstros_vira
    add  t0, t0, t1
    lw   a1, 0(t0)
    beqz a1, man_fim
    mv   a0, s1
    call som_monstro
man_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# som_monstro: toca um efeito (a1) só se o monstro (a0) estiver na tela
#   (monstro longe não faz barulho e não gasta o orçamento de notas; sfx.s)
#   Muda a0, t0 e t1.
# --------------------------------------------------------------------------
som_monstro:
    lw   t0, 0(a0)
    la   t1, camera_x
    lw   t1, 0(t1)
    sub  t0, t0, t1                    # x na tela
    li   t1, -16
    blt  t0, t1, smo_fim               # saiu pela esquerda
    li   t1, LARGURA_TELA
    bge  t0, t1, smo_fim               # ainda não chegou na tela
    mv   a0, a1
    tail tocar_som
smo_fim:
    ret

# --------------------------------------------------------------------------
# monstro_apareceu: a0 = monstro.  Na primeira vez que ele entra na tela,
#   toca o som do tipo dele (tabela sons_monstros, em dados/monstros.s).
# --------------------------------------------------------------------------
monstro_apareceu:
    lw   t0, 44(a0)
    bnez t0, mapa_fim                  # já apareceu antes
    lw   t0, 0(a0)
    la   t1, camera_x
    lw   t1, 0(t1)
    sub  t0, t0, t1
    li   t1, -16
    blt  t0, t1, mapa_fim
    li   t1, LARGURA_TELA
    bge  t0, t1, mapa_fim
    li   t0, 1
    sw   t0, 44(a0)
    lw   t0, 16(a0)                    # tipo
    slli t0, t0, 2
    la   t1, sons_monstros
    add  t0, t0, t1
    lw   a0, 0(t0)
    beqz a0, mapa_fim                  # tipo sem som
    tail tocar_som
mapa_fim:
    ret

# --------------------------------------------------------------------------
# vozes_monstros: a cada 2 a 3 s, um monstro vivo que está na tela toca a
#   "voz" do tipo dele (sons_monstros). Um por vez, em rodízio, para não virar
#   barulheira nem gastar o orçamento de notas (sfx.s).
# --------------------------------------------------------------------------
vozes_monstros:
    la   t0, som_voz_timer
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, vm2_fim
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    call aleatorio                     # próxima voz daqui a 120 a 183 quadros
    andi a0, a0, 63
    addi a0, a0, 120
    la   t0, som_voz_timer
    sw   a0, 0(t0)
    la   t0, monstros_total
    lw   s2, 0(t0)                     # s2 = quantos monstros
    beqz s2, vm2_sai
    li   s3, 0                         # s3 = quantos já olhamos
vm2_loop:
    bge  s3, s2, vm2_sai               # nenhum na tela
    la   t0, som_voz_vez
    lw   t1, 0(t0)
    remu t1, t1, s2                    # t1 = qual monstro olhar
    addi t2, t1, 1
    sw   t2, 0(t0)                     # o próximo da fila
    li   t2, TAM_MONSTRO
    mul  t1, t1, t2
    la   s1, monstros
    add  s1, s1, t1                    # s1 = o monstro
    addi s3, s3, 1
    lw   t0, 12(s1)
    beqz t0, vm2_loop                  # morto
    lw   t0, 0(s1)                     # está na tela?
    la   t1, camera_x
    lw   t1, 0(t1)
    sub  t0, t0, t1
    li   t1, -8
    blt  t0, t1, vm2_loop
    li   t1, 312
    bge  t0, t1, vm2_loop
    lw   t0, 16(s1)                    # achou: toca a voz do tipo dele
    slli t0, t0, 2
    la   t1, sons_monstros
    add  t0, t0, t1
    lw   a0, 0(t0)
    beqz a0, vm2_sai
    call tocar_som
vm2_sai:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
vm2_fim:
    ret


# --------------------------------------------------------------------------
# monstro_voar (COMP_VOA): a0 = monstro
#   Anda na horizontal (vira só em parede) e sobe/desce seguindo tabela_onda.
# --------------------------------------------------------------------------
monstro_voar:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    mv   s1, a0
    lw   t0, 32(s1)                    # contador = fase da onda
    addi t0, t0, 1
    sw   t0, 32(s1)
    srli t0, t0, 2
    andi t0, t0, 31
    la   t1, tabela_onda
    add  t1, t1, t0
    lb   t1, 0(t1)
    lw   t2, 36(s1)
    add  t2, t2, t1
    sw   t2, 4(s1)                     # y = y base + onda
    mv   a0, s1
    li   a1, MONSTRO_VEL_VOA
    call passo_x_monstro
    beqz a0, mvo_fim
    mv   a0, s1
    li   a1, 0                         # não precisa de chão
    call frente_livre
    beqz a0, mvo_fim
    lw   t0, 0(s1)
    lw   t1, 8(s1)
    add  t0, t0, t1
    sw   t0, 0(s1)
mvo_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# monstro_no_chao: a0 = monstro  ->  a0 = 1 se tem chão logo abaixo dos pés
# --------------------------------------------------------------------------
monstro_no_chao:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    mv   s1, a0
    lw   a0, 0(s1)
    addi a0, a0, 3
    lw   a1, 4(s1)
    addi a1, a1, 16
    call ponto_solido
    bnez a0, mnc_fim
    lw   a0, 0(s1)
    addi a0, a0, 12
    lw   a1, 4(s1)
    addi a1, a1, 16
    call ponto_solido
mnc_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# monstro_pular (COMP_PULA): a0 = monstro
# --------------------------------------------------------------------------
monstro_pular:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    mv   s1, a0

    # ---- vertical ----
    mv   a0, s1
    call monstro_no_chao
    mv   s2, a0                        # s2 = está no chão?
    lw   t0, 24(s1)                    # vy
    beqz s2, mp_ar
    bltz t0, mp_ar                     # acabou de pular: ainda subindo
    sw   zero, 24(s1)                  # no chão: espera a vez de pular
    sw   zero, 28(s1)
    lw   t1, 32(s1)
    addi t1, t1, 1
    sw   t1, 32(s1)
    li   t2, MONSTRO_PULO_INTERVALO
    blt  t1, t2, mp_horizontal
    sw   zero, 32(s1)
    li   t0, MONSTRO_PULO_FORCA        # pula!
    sub  t0, zero, t0
    sw   t0, 24(s1)
    li   s2, 0
    mv   a0, s1                        # boing!
    la   a1, SFX_DERIVADA_PULO
    call som_monstro
mp_ar:
    lw   t0, 24(s1)
    addi t0, t0, MONSTRO_GRAVIDADE
    li   t1, VEL_QUEDA_MAX
    ble  t0, t1, mp_vy_ok
    mv   t0, t1
mp_vy_ok:
    sw   t0, 24(s1)
    lw   t1, 28(s1)
    add  t1, t1, t0
    srai s3, t1, 4                     # s3 = pixels a mover (com sinal)
    slli t2, s3, 4
    sub  t1, t1, t2
    sw   t1, 28(s1)
mp_y_loop:
    beqz s3, mp_horizontal
    bltz s3, mp_sobe
    mv   a0, s1                        # descendo: para se tiver chão
    call monstro_no_chao
    bnez a0, mp_parou
    lw   t0, 4(s1)
    addi t0, t0, 1
    sw   t0, 4(s1)
    addi s3, s3, -1
    j    mp_y_loop
mp_sobe:
    lw   a0, 0(s1)
    addi a0, a0, 8
    lw   a1, 4(s1)
    addi a1, a1, -1
    call ponto_solido
    bnez a0, mp_parou                  # bateu a cabeça
    lw   t0, 4(s1)
    addi t0, t0, -1
    sw   t0, 4(s1)
    addi s3, s3, 1
    j    mp_y_loop
mp_parou:
    sw   zero, 24(s1)
    sw   zero, 28(s1)

    # ---- horizontal ----
mp_horizontal:
    mv   a0, s1
    li   a1, MONSTRO_VEL_PULA
    call passo_x_monstro
    beqz a0, mp_fim
    mv   a0, s1
    mv   a1, s2                        # no chão exige chão à frente; no ar não
    call frente_livre
    beqz a0, mp_fim
    lw   t0, 0(s1)
    lw   t1, 8(s1)
    add  t0, t0, t1
    sw   t0, 0(s1)
mp_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret


# --------------------------------------------------------------------------
# colidir_monstros: o estudante encostou em algum monstro?
#   Caindo e com os pés na metade de cima do monstro = PISÃO (monstro morre,
#   estudante quica). Qualquer outro contato = DANO.
# --------------------------------------------------------------------------
colidir_monstros:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    la   t0, monstros_total
    lw   s2, 0(t0)
    la   s1, monstros
    li   s3, 0
cm_loop:
    bge  s3, s2, cm_fim
    lw   t0, 12(s1)
    beqz t0, cm_prox
    lw   a0, 0(s1)
    lw   a1, 4(s1)
    addi a2, a0, 15
    addi a3, a1, 15
    call encosta_no_jogador
    beqz a0, cm_prox

    # encostou! pisão = caindo e com os pés na metade de cima do monstro
    la   t0, jogador_vy
    lw   t1, 0(t0)
    blez t1, cm_dano
    la   t2, jogador_y
    lw   t2, 0(t2)
    addi t2, t2, HIT_Y1                # pés
    lw   t3, 4(s1)
    addi t3, t3, 8                     # meio do monstro
    blt  t3, t2, cm_dano
    sw   zero, 12(s1)                  # pisão: o monstro morre
    li   t1, QUIQUE_PISAO
    sub  t1, zero, t1
    sw   t1, 0(t0)                     # estudante quica
    la   t0, jogador_frac_y
    sw   zero, 0(t0)
    lw   a0, 0(s1)                     # explosão de partículas
    addi a0, a0, 8
    lw   a1, 4(s1)
    addi a1, a1, 8
    lw   t0, 16(s1)
    slli t0, t0, 2
    la   t1, cores_monstros
    add  t1, t1, t0
    lw   a2, 0(t1)
    li   a3, 14
    call explodir
    la   a0, SFX_STOMP                 # som do pisão
    call tocar_som
    j    cm_prox

cm_dano:
    la   t0, jogador_x                 # empurra para longe do monstro
    lw   t1, 0(t0)
    lw   t2, 0(s1)
    li   a0, 1
    bge  t1, t2, cm_dir_ok
    li   a0, -1
cm_dir_ok:
    call dano_jogador
    la   t0, estado_jogo
    lw   t0, 0(t0)
    li   t1, ESTADO_JOGANDO
    bne  t0, t1, cm_fim                # morreu: para de olhar os outros

cm_prox:
    addi s1, s1, TAM_MONSTRO
    addi s3, s3, 1
    j    cm_loop
cm_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret


# --------------------------------------------------------------------------
# desenhar_monstros: a0 = frame de destino
#   Os desenhos olham para a direita; espelha quando o monstro anda p/ a esquerda.
#   Quem anda no chão dá um pulinho de 1 pixel a cada 8 pixels andados.
# --------------------------------------------------------------------------
desenhar_monstros:
    addi sp, sp, -24
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    sw   s5, 20(sp)

    mv   s5, a0
    la   t0, monstros_total
    lw   s2, 0(t0)
    la   s1, monstros
    li   s3, 0
    la   t0, camera_x
    lw   s4, 0(t0)
dmo_loop:
    bge  s3, s2, dmo_fim
    lw   t0, 12(s1)
    beqz t0, dmo_prox
    lw   t1, 0(s1)
    sub  a1, t1, s4                    # x na tela
    addi t2, a1, 16
    blez t2, dmo_prox
    li   t2, LARGURA_TELA
    bge  a1, t2, dmo_prox
    lw   a2, 4(s1)
    lw   t2, 20(s1)
    bnez t2, dmo_imagem                # só COMP_ANDA (0) faz o pulinho
    srli t3, t1, 3
    andi t3, t3, 1
    sub  a2, a2, t3
dmo_imagem:
    lw   t4, 16(s1)
    slli t4, t4, 2
    la   t5, imagens_monstros
    add  t5, t5, t4
    lw   a0, 0(t5)
    lw   t6, 8(s1)
    li   a3, 0
    bgez t6, dmo_desenha
    lw   t4, 16(s1)                    # tipos com letras não espelham
    la   t5, espelhar_monstros
    add  t5, t5, t4
    lbu  a3, 0(t5)
dmo_desenha:
    mv   a4, s5
    call desenhar_imagem
dmo_prox:
    addi s1, s1, TAM_MONSTRO
    addi s3, s3, 1
    j    dmo_loop
dmo_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    lw   s5, 20(sp)
    addi sp, sp, 24
    ret
