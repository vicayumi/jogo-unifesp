############################################################################
#  O ESTUDANTE: movimento, pulo, dano, morte e desenho
#
#  FRAÇÕES DE PIXEL ("subpixel")
#    A tela só tem pixels inteiros, mas andar 2 pixels por quadro é rápido
#    demais e 1 é lento demais. Por isso as velocidades são contadas em
#    1/16 de pixel (SUB = 16):  VEL_ANDAR = 22  ->  22/16 = 1,375 pixel/quadro.
#    Cada quadro a velocidade é somada a um "resto" (jogador_frac_x / _y);
#    a parte inteira do resto (resto / 16) é quanto o estudante anda de
#    verdade, e o que sobra fica guardado para o próximo quadro.
#
#  PULO
#    - pulo_buffer: apertar o pulo um pouquinho antes de encostar no chão
#      ainda vale (o pedido fica guardado por PULO_BUFFER quadros);
#    - chao_timer: dá para pular até PULO_COYOTE quadros depois de sair da
#      beirada (o "tempo do coiote" dos jogos de plataforma);
#    - soltar o botão no meio da subida deixa o pulo mais baixo (a gravidade
#      fica mais forte enquanto ele sobe sem o botão).
############################################################################

.text

# --------------------------------------------------------------------------
# atualizar_jogador: lê o teclado, aplica gravidade/pulo e move o estudante
# --------------------------------------------------------------------------
atualizar_jogador:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)

    # ---- contadores ----
    la   t0, jogador_invuln
    lw   t1, 0(t0)
    blez t1, aj_direcao
    addi t1, t1, -1
    sw   t1, 0(t0)

    # ---- 1) direção: s1 = -1 (esquerda), 0 (parado) ou +1 (direita) ----
aj_direcao:
    li   s1, 0
    li   s2, VEL_ANDAR                 # s2 = velocidade (em 1/16 de pixel)
    la   t0, item_energetico           # energético: anda mais rápido
    lw   t0, 0(t0)
    blez t0, aj_empurrao
    li   s2, VEL_ANDAR_RAPIDO
aj_empurrao:
    la   t0, jogador_empurrao          # empurrão do dano: ignora o teclado
    lw   t1, 0(t0)
    blez t1, aj_teclas
    addi t1, t1, -1
    sw   t1, 0(t0)
    la   t0, jogador_empurrao_dir
    lw   s1, 0(t0)
    li   s2, VEL_EMPURRAO
    j    aj_mover_x
aj_teclas:
    li   a0, T_ESQ
    call tecla_segurada
    beqz a0, aj_dir_direita
    addi s1, s1, -1
    la   t0, jogador_espelhar
    li   t1, 1
    sw   t1, 0(t0)                     # olhando para a esquerda
aj_dir_direita:
    li   a0, T_DIR
    call tecla_segurada
    beqz a0, aj_mover_x
    addi s1, s1, 1
    la   t0, jogador_espelhar
    sw   zero, 0(t0)                   # olhando para a direita

    # ---- 2) horizontal: resto += direção * velocidade; anda a parte inteira ----
aj_mover_x:
    la   t0, jogador_frac_x
    bnez s1, aj_x_soma
    sw   zero, 0(t0)                   # parado: zera o resto
    j    aj_gravidade
aj_x_soma:
    lw   t1, 0(t0)
    mul  t2, s1, s2
    add  t1, t1, t2
    srai s3, t1, 4                     # s3 = pixels inteiros a andar (com sinal)
    slli t2, s3, 4
    sub  t1, t1, t2                    # o que sobra fica para o próximo quadro
    sw   t1, 0(t0)
aj_x_loop:
    beqz s3, aj_gravidade
    mv   a0, s1
    call mover_x_um_pixel
    bnez a0, aj_x_bateu
    sub  s3, s3, s1                    # um pixel a menos para andar
    j    aj_x_loop
aj_x_bateu:
    la   t0, jogador_frac_x
    sw   zero, 0(t0)

    # ---- 3) gravidade ----
aj_gravidade:
    la   t0, jogador_vy
    lw   t1, 0(t0)
    addi t1, t1, GRAVIDADE
    bgez t1, aj_vy_limite              # subindo sem segurar o pulo: freia mais
    li   a0, T_PULO
    call tecla_segurada
    la   t0, jogador_vy
    lw   t1, 0(t0)
    addi t1, t1, GRAVIDADE
    bnez a0, aj_vy_limite
    addi t1, t1, GRAVIDADE_SOLTO
aj_vy_limite:
    li   t2, VEL_QUEDA_MAX
    ble  t1, t2, aj_vy_ok
    mv   t1, t2
aj_vy_ok:
    sw   t1, 0(t0)

    # ---- 4) pulo (com buffer e tempo do coiote) ----
    la   t0, pulo_buffer
    lw   t1, 0(t0)
    blez t1, aj_pb_novo
    addi t1, t1, -1
aj_pb_novo:
    sw   t1, 0(t0)
    li   a0, T_PULO
    call tecla_nova
    beqz a0, aj_pulo_testa
    la   t0, pulo_buffer
    li   t1, PULO_BUFFER
    sw   t1, 0(t0)
aj_pulo_testa:
    la   t0, pulo_buffer
    lw   t1, 0(t0)
    blez t1, aj_mover_y                # nenhum pulo pedido
    la   t0, chao_timer
    lw   t1, 0(t0)
    li   t2, PULO_COYOTE
    bgt  t1, t2, aj_mover_y            # faz tempo que saiu do chão
    li   t1, FORCA_PULO                # PULA!
    la   t0, item_energetico
    lw   t0, 0(t0)
    blez t0, aj_pulo_forca
    li   t1, FORCA_PULO_RAPIDO
aj_pulo_forca:
    sub  t1, zero, t1                  # negativo = para cima
    la   t0, jogador_vy
    sw   t1, 0(t0)
    la   t0, jogador_frac_y
    sw   zero, 0(t0)
    la   t0, pulo_buffer
    sw   zero, 0(t0)
    la   t0, chao_timer
    li   t1, 99                        # já pulou: não vale pular de novo no ar
    sw   t1, 0(t0)

    la   a0, SFX_JUMP                  # som do pulo
    call tocar_som

    # ---- 5) vertical: resto += vy; anda a parte inteira ----
aj_mover_y:
    la   t0, jogador_no_chao
    sw   zero, 0(t0)
    la   t0, jogador_frac_y
    lw   t1, 0(t0)
    la   t2, jogador_vy
    lw   t2, 0(t2)
    add  t1, t1, t2
    srai s3, t1, 4                     # s3 = pixels inteiros (com sinal)
    slli t2, s3, 4
    sub  t1, t1, t2
    sw   t1, 0(t0)
    li   s2, 1                         # s2 = direção (+1 desce, -1 sobe)
    bgez s3, aj_y_loop
    li   s2, -1
aj_y_loop:
    beqz s3, aj_chao
    mv   a0, s2
    call mover_y_um_pixel              # a0 = 1 se bateu em algo
    bnez a0, aj_chao
    sub  s3, s3, s2
    j    aj_y_loop

    # ---- 6) está no chão? (olha o pixel logo abaixo dos pés) ----
aj_chao:
    la   t0, jogador_vy
    lw   t1, 0(t0)
    bltz t1, aj_no_ar                  # subindo: não está no chão
    la   t0, jogador_x
    lw   a0, 0(t0)
    la   t0, jogador_y
    lw   a1, 0(t0)
    addi a1, a1, HIT_Y1
    addi a1, a1, 1
    call linha_bate
    beqz a0, aj_no_ar
    la   t0, jogador_no_chao
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, jogador_vy
    sw   zero, 0(t0)
    la   t0, jogador_frac_y
    sw   zero, 0(t0)
    la   t0, chao_timer
    sw   zero, 0(t0)
    j    aj_animacao
aj_no_ar:
    la   t0, chao_timer
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)

    # ---- 7) animação de andar ----
aj_animacao:
    la   t0, jogador_anda
    beqz s1, aj_parado
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    j    aj_fim
aj_parado:
    sw   zero, 0(t0)

aj_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret


# --------------------------------------------------------------------------
# mover_x_um_pixel: tenta mover o estudante 1 pixel na horizontal
#   a0 = direção (+1 direita, -1 esquerda)
#   devolve a0 = 1 se bateu (não andou), 0 se andou
# --------------------------------------------------------------------------
mover_x_um_pixel:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    mv   s1, a0
    la   t0, jogador_x
    lw   t1, 0(t0)
    add  s2, t1, s1                    # s2 = novo x

    li   t2, HIT_X1                    # indo p/ direita: borda da frente = lado direito
    blt  zero, s1, mx_borda
    li   t2, HIT_X0                    # indo p/ esquerda: lado esquerdo
mx_borda:
    add  a0, s2, t2
    la   t0, jogador_y
    lw   a1, 0(t0)
    call coluna_bate
    bnez a0, mx_fim                    # bateu: não anda (a0 = 1)
    la   t0, jogador_x
    sw   s2, 0(t0)
    li   a0, 0

mx_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# mover_y_um_pixel: tenta mover o estudante 1 pixel na vertical
#   a0 = direção (+1 desce, -1 sobe)
#   devolve a0 = 1 se bateu (e já zera a velocidade), 0 se andou
# --------------------------------------------------------------------------
mover_y_um_pixel:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    mv   s1, a0
    la   t0, jogador_y
    lw   t1, 0(t0)
    add  s2, t1, s1                    # s2 = novo y

    li   t2, HIT_Y1                    # descendo: borda da frente = pés
    blt  zero, s1, my_borda
    li   t2, HIT_Y0                    # subindo: cabeça
my_borda:
    add  a1, s2, t2
    la   t0, jogador_x
    lw   a0, 0(t0)
    call linha_bate
    bnez a0, my_bateu
    la   t0, jogador_y
    sw   s2, 0(t0)
    li   a0, 0
    j    my_fim

my_bateu:
    la   t0, jogador_vy
    sw   zero, 0(t0)
    la   t0, jogador_frac_y
    sw   zero, 0(t0)
    li   a0, 1

my_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# dano_jogador: o estudante leva um golpe
#   a0 = direção do empurrão (+1, -1, ou 0 = sem empurrão)
#   Se estiver invencível, nada acontece (devolve a0 = 0).
#   Perde 1 vida, pisca por INVULN_QUADROS e, sem vidas, começa a morte.
# --------------------------------------------------------------------------
dano_jogador:
    la   t0, jogador_invuln
    lw   t1, 0(t0)
    bnez t1, dj_nada
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    li   t1, INVULN_QUADROS
    sw   t1, 0(t0)
    la   a0, SFX_HURT                  # som de perder coração
    call tocar_som                     # (tocar_som só mexe em t0 e t1)
    lw   a0, 4(sp)
    la   t0, jogador_vidas
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bnez t1, dj_empurra
    call iniciar_morte                 # acabaram as vidas
    j    dj_fim
dj_empurra:
    beqz a0, dj_fim
    la   t0, jogador_empurrao_dir
    sw   a0, 0(t0)
    la   t0, jogador_empurrao
    li   t1, EMPURRAO_QUADROS
    sw   t1, 0(t0)
    la   t0, jogador_vy                # pulinho para trás
    li   t1, QUIQUE_DANO
    sub  t1, zero, t1
    sw   t1, 0(t0)
dj_fim:
    li   a0, 1
    lw   ra, 0(sp)
    addi sp, sp, 8
    ret
dj_nada:
    li   a0, 0
    ret


# --------------------------------------------------------------------------
# iniciar_morte: animação de morte (o estudante salta e cai para fora da tela)
# --------------------------------------------------------------------------
iniciar_morte:
    la   t0, musica_ptr                # a música para (parar_musica, sem precisar de call)
    sw   zero, 0(t0)
    la   t0, estado_jogo
    li   t1, ESTADO_MORTE
    sw   t1, 0(t0)
    la   t0, estado_timer
    sw   zero, 0(t0)
    la   t0, jogador_vy
    li   t1, MORTE_SALTO
    sub  t1, zero, t1
    sw   t1, 0(t0)
    la   t0, jogador_frac_y
    sw   zero, 0(t0)
    la   t0, jogador_invuln
    sw   zero, 0(t0)
    la   t0, jogador_empurrao
    li   t1, 999                       # mantém a pose de dano durante a queda
    sw   t1, 0(t0)
    la   t0, chefe_estado              # morreu lutando com o chefão?
    lw   t0, 0(t0)
    beqz t0, im_fim
    li   a0, CINEMA_DERROTA            # passa o "filminho" antes da queda
    tail iniciar_cinema                #   (cinema.s; no fim ele volta para ESTADO_MORTE)
im_fim:
    ret

# mover_morte: um quadro da queda (sem colisão nenhuma)
mover_morte:
    la   t0, jogador_vy
    lw   t1, 0(t0)
    addi t1, t1, GRAVIDADE
    sw   t1, 0(t0)
    la   t0, jogador_frac_y
    lw   t2, 0(t0)
    add  t2, t2, t1
    srai t3, t2, 4
    slli t4, t3, 4
    sub  t2, t2, t4
    sw   t2, 0(t0)
    la   t0, jogador_y
    lw   t1, 0(t0)
    add  t1, t1, t3
    li   t2, 400
    ble  t1, t2, mm_y_ok               # já saiu da tela: para de cair
    mv   t1, t2
mm_y_ok:
    sw   t1, 0(t0)
    la   t0, tempo                     # "gira": vira de lado a cada 6 quadros
    lw   t1, 0(t0)
    li   t2, 6
    div  t1, t1, t2
    andi t1, t1, 1
    la   t0, jogador_espelhar
    sw   t1, 0(t0)
    ret


# --------------------------------------------------------------------------
# escolher_pose: qual desenho do estudante usar agora?  (devolve a0 = imagem)
#   Prioridade: dano > no ar > correndo > parado.
#   Cada animação é uma tabela (dados/graficos.s): [quantidade, img0, img1, ...]
# --------------------------------------------------------------------------
escolher_pose:
    la   t0, jogador_empurrao
    lw   t1, 0(t0)
    blez t1, ep_ar
    la   a0, anim_estudante_dano
    li   a1, 0
    j    ep_pega

ep_ar:
    la   t0, jogador_no_chao
    lw   t1, 0(t0)
    bnez t1, ep_chao
    la   t0, chao_timer                # acabou de sair da beirada: ainda conta como chão
    lw   t1, 0(t0)
    li   t2, 3
    blt  t1, t2, ep_chao
    la   t0, jogador_vy                # no ar: a pose depende da velocidade vertical
    lw   t1, 0(t0)
    la   a0, anim_estudante_pulo
    li   a1, 0
    addi t2, t1, 40
    bltz t2, ep_pega                   # subindo rápido
    li   a1, 1
    addi t2, t1, -40
    blez t2, ep_pega                   # perto do topo do pulo
    li   a1, 2                         # caindo
    j    ep_pega

ep_chao:
    la   t0, jogador_anda
    lw   t1, 0(t0)
    bnez t1, ep_correndo
    la   t0, tempo                     # parado: respira e pisca de vez em quando
    lw   t1, 0(t0)
    srli t1, t1, 3
    andi t1, t1, 15
    la   t2, idle_sequencia
    add  t2, t2, t1
    lbu  a1, 0(t2)
    la   a0, anim_estudante_idle
    j    ep_pega

ep_correndo:
    la   a0, anim_estudante_corrida
    li   a1, 0
    li   t2, 6
    ble  t1, t2, ep_pega               # primeiros quadros: passo inicial (pose 0)
    addi t1, t1, -7
    li   t2, 5
    div  t1, t1, t2                    # cada pose dura 5 quadros (anda mais devagar agora)
    andi t1, t1, 7
    addi a1, t1, 1

ep_pega:
    slli a1, a1, 2
    add  a0, a0, a1
    lw   a0, 4(a0)                     # pula a "quantidade" e pega o endereço da imagem
    ret


# --------------------------------------------------------------------------
# desenhar_jogador: a0 = frame de destino
#   Pisca enquanto está invencível (some a cada 4 quadros).
# --------------------------------------------------------------------------
desenhar_jogador:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    mv   s1, a0
    la   t0, jogador_oculto            # entrou pela porta: não aparece
    lw   t0, 0(t0)
    bnez t0, dj_sai
    la   t0, jogador_invuln
    lw   t1, 0(t0)
    beqz t1, dj_desenha
    srli t1, t1, 2
    andi t1, t1, 1
    bnez t1, dj_sai
dj_desenha:
    call escolher_pose
    la   t0, jogador_x
    lw   a1, 0(t0)
    la   t0, camera_x
    lw   t1, 0(t0)
    sub  a1, a1, t1
    li   t1, SPR_OFF_X                 # o desenho (32 x 32) é maior que a hitbox
    sub  a1, a1, t1
    la   t0, jogador_y
    lw   a2, 0(t0)
    li   t1, SPR_OFF_Y
    sub  a2, a2, t1
    la   t0, jogador_espelhar
    lw   a3, 0(t0)
    mv   a4, s1
    call desenhar_imagem
dj_sai:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret
