############################################################################
#  CENÁRIO DE FUNDO EM CAMADAS (entardecer com o prédio da UNIFESP)
#
#  O fundo é montado no buffer 'fundo', de trás para a frente:
#
#     céu (degradê)  ->  sol  ->  nuvens  ->  serra  ->  morros  ->  PRÉDIO  ->  arbustos
#
#  e só depois os blocos do mapa (desenhar_mapa) são desenhados por cima.
#
#  PARALLAX: cada camada anda numa fração da velocidade da câmera. Quanto
#  mais longe, mais devagar. A fração é K / 256:
#
#     céu e sol : 0                 (parados)
#     nuvens    : 26/256  (~10%)  + deriva própria (andam sozinhas)
#     serra     : 30/256  (~12%)
#     morros    : 64/256  (25%)
#     prédio    : 123/256 (~48%)    (aparece pela direita conforme a fase avança)
#     arbustos  : 160/256 (~62%)
#
#  As imagens (img_fundo_*) estão desenhadas em texto em dados/graficos.s.
#  O fundo só é refeito quando a câmera ou as nuvens se mexem.
############################################################################

.eqv PARALLAX_LIGADO  1              # 0 = fundo parado (use se o jogo ficar lento)

.eqv K_SERRA          30
.eqv K_MORROS         64
.eqv K_PREDIO         123
.eqv K_ARBUSTOS       160

.eqv Y_CHAO_FUNDO     216            # linha onde a base das camadas se apoia (8 pixels abaixo do chão)
.eqv SOL_X            44
.eqv SOL_Y            152
.eqv PREDIO_X         360            # x do prédio na tela quando a câmera está no começo da fase
# (NUVEM_VOLTA fica no main.s)

.text

# --------------------------------------------------------------------------
# desenhar_ceu: pinta o céu em degradê num frame inteiro
#   a0 = endereço do frame (ou do buffer 'fundo')
#   A imagem fundo_ceu tem 4 pixels de largura e 240 de altura: cada linha é
#   uma word que se repete 80 vezes na horizontal (o pontilhado do degradê).
# --------------------------------------------------------------------------
desenhar_ceu:
    la   a1, img_fundo_ceu

# desenhar_degrade: igual a desenhar_ceu, com outra imagem de 4 x 240
#   a0 = destino   a1 = imagem (4 pixels de largura, 240 de altura)
desenhar_degrade:
    addi t0, a1, 8                     # pula a largura e a altura
    li   t4, 0                         # t4 = linha
    li   t5, ALTURA_TELA
dce_linha:
    lw   t2, 0(t0)                     # os 4 pixels desta linha
    li   t3, 20                        # 20 voltas de 4 words = 80 words por linha
dce_col:                               # 4 words (16 pixels) por volta
    sw   t2, 0(a0)
    sw   t2, 4(a0)
    sw   t2, 8(a0)
    sw   t2, 12(a0)
    addi a0, a0, 16
    addi t3, t3, -1
    bnez t3, dce_col
    addi t0, t0, 4
    addi t4, t4, 1
    blt  t4, t5, dce_linha
    ret


# --------------------------------------------------------------------------
# desenhar_camada: desenha uma imagem no buffer 'fundo', com recorte e transparência
#   a0 = imagem (.word largura, altura + 1 byte por pixel; 0xC7 = transparente)
#   a1 = x na tela (pode ser negativo ou maior que 320)
#   a2 = y na tela
#   Só percorre a parte que aparece na tela.
# --------------------------------------------------------------------------
desenhar_camada:
    lw   t0, 0(a0)                     # t0 = largura da imagem
    lw   t1, 4(a0)                     # t1 = altura
    addi a0, a0, 8                     # a0 = primeiro pixel

    # colunas visíveis da imagem: de t2 até t3 (sem incluir t3)
    li   t2, 0
    bgez a1, dcm_x0
    sub  t2, zero, a1                  # começou fora da tela pela esquerda
dcm_x0:
    li   t3, LARGURA_TELA
    sub  t3, t3, a1                    # t3 = 320 - x
    ble  t3, t0, dcm_x1
    mv   t3, t0                        # não passa da largura da imagem
dcm_x1:
    bge  t2, t3, dcm_fim               # nada aparece na horizontal

    # linhas visíveis da imagem: de t4 até t5 (sem incluir t5)
    li   t4, 0
    bgez a2, dcm_y0
    sub  t4, zero, a2
dcm_y0:
    li   t5, ALTURA_TELA
    sub  t5, t5, a2
    ble  t5, t1, dcm_y1
    mv   t5, t1
dcm_y1:
    bge  t4, t5, dcm_fim               # nada aparece na vertical

    # a3 = onde começar na imagem; a4 = onde começar no 'fundo'
    mul  a3, t4, t0
    add  a3, a3, a0
    add  a3, a3, t2
    add  a4, a2, t4
    li   a5, LARGURA_TELA
    mul  a4, a4, a5
    add  a4, a4, a1
    add  a4, a4, t2
    la   a5, fundo
    add  a4, a4, a5

    sub  a6, t3, t2                    # a6 = pixels visíveis por linha
    sub  t0, t0, a6                    # t0 = quanto pular na imagem para a linha seguinte
    li   a2, LARGURA_TELA
    sub  a2, a2, a6                    # a2 = quanto pular no 'fundo' para a linha seguinte
    sub  t5, t5, t4                    # t5 = linhas a desenhar
    li   t6, COR_TRANSPARENTE
dcm_linha:
    srli a7, a6, 2
    slli a7, a7, 2                     # a7 = pixels da linha em grupos de 4
    add  a5, a3, a7                    # a5 = fim dos grupos de 4
    add  a0, a3, a6                    # a0 = fim da linha
    bge  a3, a5, dcm_resto
dcm_grupo:                             # 4 pixels por volta (menos instruções por pixel)
    lbu  a1, 0(a3)
    beq  a1, t6, dcm_g1                # transparente: deixa o que já estava
    sb   a1, 0(a4)
dcm_g1:
    lbu  a1, 1(a3)
    beq  a1, t6, dcm_g2
    sb   a1, 1(a4)
dcm_g2:
    lbu  a1, 2(a3)
    beq  a1, t6, dcm_g3
    sb   a1, 2(a4)
dcm_g3:
    lbu  a1, 3(a3)
    beq  a1, t6, dcm_g4
    sb   a1, 3(a4)
dcm_g4:
    addi a3, a3, 4
    addi a4, a4, 4
    blt  a3, a5, dcm_grupo
dcm_resto:                             # os 0 a 3 pixels que sobraram
    bge  a3, a0, dcm_prox
dcm_pixel:
    lbu  a1, 0(a3)
    beq  a1, t6, dcm_pula
    sb   a1, 0(a4)
dcm_pula:
    addi a3, a3, 1
    addi a4, a4, 1
    blt  a3, a0, dcm_pixel
dcm_prox:
    add  a3, a3, t0
    add  a4, a4, a2
    addi t5, t5, -1
    bnez t5, dcm_linha
dcm_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_camada_rep: camada que se repete na horizontal (serra, morros, arbustos)
#   a0 = imagem   a1 = deslocamento em pixels (>= 0)   a2 = y
#   A imagem é desenhada quantas vezes forem precisas para cobrir a tela;
#   por isso as pontas dela precisam "emendar" (o gerador já faz isso).
# --------------------------------------------------------------------------
desenhar_camada_rep:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    mv   s1, a0
    mv   s3, a2
    lw   t0, 0(a0)                     # largura da imagem
dcr_mod:
    blt  a1, t0, dcr_ok                # deslocamento mod largura
    sub  a1, a1, t0
    j    dcr_mod
dcr_ok:
    sub  s2, zero, a1                  # x = -deslocamento
dcr_loop:
    mv   a0, s1
    mv   a1, s2
    mv   a2, s3
    call desenhar_camada
    lw   t0, 0(s1)
    add  s2, s2, t0                    # próxima cópia, logo à direita
    li   t1, LARGURA_TELA
    blt  s2, t1, dcr_loop
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret


# --------------------------------------------------------------------------
# desenhar_nuvem: uma nuvem que anda com o parallax + a deriva própria
#   a0 = imagem   a1 = x inicial   a2 = y   a3 = K do parallax
#   Usa s1 = câmera e s2 = deriva das nuvens (preenchidos por desenhar_cenario).
#   A nuvem sai pela esquerda e reaparece pela direita (volta de NUVEM_VOLTA).
# --------------------------------------------------------------------------
desenhar_nuvem:
    addi sp, sp, -4
    sw   ra, 0(sp)
    mul  t0, s1, a3
    srli t0, t0, 8
    sub  a1, a1, t0
    sub  a1, a1, s2
dnu_baixo:
    addi t1, a1, 100
    bgez t1, dnu_alto                  # enquanto x < -100: soma a volta
    li   t2, NUVEM_VOLTA
    add  a1, a1, t2
    j    dnu_baixo
dnu_alto:
    addi t1, a1, -380
    bltz t1, dnu_ok                    # enquanto x >= 380: tira a volta
    li   t2, NUVEM_VOLTA
    sub  a1, a1, t2
    j    dnu_alto
dnu_ok:
    call desenhar_camada
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# cenario_campus: monta o fundo do campus (sem os blocos) no buffer 'fundo'
#   (é a rotina de cenário do treino; cada fase aponta para a sua em F_CENARIO)
# --------------------------------------------------------------------------
cenario_campus:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    la   t0, camera_x
    lw   s1, 0(t0)                     # s1 = câmera
    li   t0, PARALLAX_LIGADO
    bnez t0, dcn_ok
    li   s1, 0                         # parallax desligado: o fundo não anda
dcn_ok:
    la   t0, nuvem_x
    lw   s2, 0(t0)                     # s2 = deriva das nuvens

    la   a0, fundo
    call desenhar_ceu

    la   a0, img_fundo_sol
    li   a1, SOL_X
    li   a2, SOL_Y
    call desenhar_camada

    la   a0, img_fundo_nuvem_1
    li   a1, 70
    li   a2, 40
    li   a3, 26
    call desenhar_nuvem
    la   a0, img_fundo_nuvem_2
    li   a1, 215
    li   a2, 66
    li   a3, 26
    call desenhar_nuvem
    la   a0, img_fundo_nuvem_3
    li   a1, 330
    li   a2, 24
    li   a3, 20
    call desenhar_nuvem

    la   a0, img_fundo_serra
    li   t0, K_SERRA
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 152                       # Y_CHAO_FUNDO - altura da imagem (64)
    call desenhar_camada_rep

    la   a0, img_fundo_morros
    li   t0, K_MORROS
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 184                       # 216 - 32
    call desenhar_camada_rep

    la   a0, img_fundo_predio          # o prédio da UNIFESP: aparece pela direita
    li   t0, K_PREDIO
    mul  t1, s1, t0
    srli t1, t1, 8
    li   a1, PREDIO_X
    sub  a1, a1, t1
    li   a2, 96                        # 216 - 120
    call desenhar_camada

    la   a0, img_fundo_arbustos
    li   t0, K_ARBUSTOS
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 194                       # 216 - 22
    call desenhar_camada_rep

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# cenario_sala: fundo da FASE 1 (Cálculo 1) - uma sala de aula
#   parede (degradê)  ->  quadros-negros com fórmulas  ->  carteiras
# --------------------------------------------------------------------------
.eqv K_QUADRO         96             # o quadro anda a 3/8 da câmera
.eqv K_CARTEIRAS      176            # as carteiras do fundo, a ~69%

cenario_sala:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    la   t0, camera_x
    lw   s1, 0(t0)

    la   a0, fundo
    la   a1, img_fundo_sala_parede
    call desenhar_degrade

    la   a0, img_fundo_sala_quadro
    li   t0, K_QUADRO
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 28
    call desenhar_camada_rep

    la   a0, img_fundo_sala_carteiras
    li   t0, K_CARTEIRAS
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 176                       # 208 (chão) - 32
    call desenhar_camada_rep

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# cenario_lab: fundo da FASE 2 (AED) - o laboratório de computação
#   parede (degradê azul)  ->  quadro branco com a árvore e cartaz da pilha
#   ->  mesas com computadores
#   (desenhos em dados/graficos_fases23.s)
# --------------------------------------------------------------------------
cenario_lab:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    la   t0, camera_x
    lw   s1, 0(t0)

    la   a0, fundo
    la   a1, img_fundo_lab_parede
    call desenhar_degrade

    la   a0, img_fundo_lab_quadro
    li   t0, K_QUADRO
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 30
    call desenhar_camada_rep

    la   a0, img_fundo_lab_mesas
    li   t0, K_CARTEIRAS
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 176                       # 208 (chão) - 32
    call desenhar_camada_rep

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# cenario_circuito: fundo da FASE 3 (AOC) - dentro do computador
#   parede (degradê azul-esverdeado)  ->  trilhas da placa com CPU, ALU e RAM
#   ->  servidores
# --------------------------------------------------------------------------
.eqv K_TRILHAS        64             # as trilhas andam a 1/4 da câmera (bem longe)
.eqv K_SERVIDORES     144            # os servidores a ~56%

cenario_circuito:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    la   t0, camera_x
    lw   s1, 0(t0)

    la   a0, fundo
    la   a1, img_fundo_circuito_parede
    call desenhar_degrade

    la   a0, img_fundo_circuito_trilhas
    li   t0, K_TRILHAS
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 24
    call desenhar_camada_rep

    la   a0, img_fundo_circuito_servidores
    li   t0, K_SERVIDORES
    mul  a1, s1, t0
    srli a1, a1, 8
    li   a2, 160                       # 208 (chão) - 48
    call desenhar_camada_rep

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret
