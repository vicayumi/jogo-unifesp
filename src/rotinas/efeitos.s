############################################################################
#  EFEITOS: partículas e números aleatórios
#
#  Partícula (TAM_PARTICULA bytes):  +0 x  +4 y  (em 1/16 de pixel, no mundo)
#                                    +8 vx +12 vy (1/16 de pixel por quadro)
#                                    +16 vida (quadros que faltam)  +20 cor
#  Cada uma é um quadradinho 2 x 2 que voa, cai com gravidade e some.
############################################################################

.eqv MAX_PARTICULAS   48
.eqv TAM_PARTICULA    24

.data
.align 2
semente:      .word 12345
particulas:   .space 1152              # MAX_PARTICULAS * TAM_PARTICULA

.text

# --------------------------------------------------------------------------
# aleatorio: a0 = número "aleatório" de 0 a 32767 (gerador congruente linear)
# --------------------------------------------------------------------------
aleatorio:
    la   t0, semente
    lw   t1, 0(t0)
    li   t2, 1103515245
    mul  t1, t1, t2
    li   t2, 12345
    add  t1, t1, t2
    sw   t1, 0(t0)
    srli a0, t1, 16
    li   t2, 0x7FFF
    and  a0, a0, t2
    ret

# misturar_semente: usa o relógio para a sequência não ser sempre igual
misturar_semente:
    csrr t1, time
    la   t0, semente
    lw   t2, 0(t0)
    xor  t2, t2, t1
    sw   t2, 0(t0)
    ret


# --------------------------------------------------------------------------
# explodir: solta partículas a partir de um ponto
#   a0 = x   a1 = y   (pixels, no mundo)   a2 = cor   a3 = quantidade
# --------------------------------------------------------------------------
explodir:
    addi sp, sp, -28
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    sw   s5, 20(sp)
    sw   s6, 24(sp)
    slli s1, a0, 4
    slli s2, a1, 4
    mv   s3, a2
    mv   s4, a3                        # s4 = quantas faltam soltar
    la   s5, particulas
    li   s6, MAX_PARTICULAS            # s6 = quantas posições faltam olhar
ex_procura:                            # procura partículas livres (vida = 0)
    blez s4, ex_fim
    blez s6, ex_fim
    lw   t0, 16(s5)
    bnez t0, ex_prox
    sw   s1, 0(s5)
    sw   s2, 4(s5)
    sw   s3, 20(s5)
    call aleatorio
    andi a0, a0, 63
    addi a0, a0, -32                   # vx entre -32 e 31 (até 2 px por quadro)
    sw   a0, 8(s5)
    call aleatorio
    andi a0, a0, 31
    addi a0, a0, -48                   # vy para cima
    sw   a0, 12(s5)
    call aleatorio
    andi a0, a0, 15
    addi a0, a0, 20                    # vive 20 a 35 quadros
    sw   a0, 16(s5)
    addi s4, s4, -1
ex_prox:
    addi s5, s5, TAM_PARTICULA
    addi s6, s6, -1
    j    ex_procura
ex_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    lw   s5, 20(sp)
    lw   s6, 24(sp)
    addi sp, sp, 28
    ret


# --------------------------------------------------------------------------
# atualizar_particulas: move todas e diminui a vida
# --------------------------------------------------------------------------
atualizar_particulas:
    la   t0, particulas
    li   t6, MAX_PARTICULAS
ap_loop:
    lw   t1, 16(t0)
    blez t1, ap_prox
    addi t1, t1, -1
    sw   t1, 16(t0)
    lw   t2, 0(t0)
    lw   t3, 8(t0)
    add  t2, t2, t3
    sw   t2, 0(t0)
    lw   t2, 4(t0)
    lw   t3, 12(t0)
    addi t3, t3, 3                     # gravidade
    sw   t3, 12(t0)
    add  t2, t2, t3
    sw   t2, 4(t0)
ap_prox:
    addi t0, t0, TAM_PARTICULA
    addi t6, t6, -1
    bnez t6, ap_loop
    ret

# limpar_particulas: apaga todas (ao trocar de fase)
limpar_particulas:
    la   t0, particulas
    li   t6, MAX_PARTICULAS
lp_loop:
    sw   zero, 16(t0)
    addi t0, t0, TAM_PARTICULA
    addi t6, t6, -1
    bnez t6, lp_loop
    ret


# --------------------------------------------------------------------------
# desenhar_particulas: a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_particulas:
    la   t0, particulas
    li   t6, MAX_PARTICULAS
    la   t1, camera_x
    lw   a5, 0(t1)                     # a5 = câmera
dp_loop:
    lw   t1, 16(t0)
    blez t1, dp_prox
    lw   t2, 0(t0)
    srai t2, t2, 4
    sub  t2, t2, a5                    # x na tela
    lw   t3, 4(t0)
    srai t3, t3, 4                     # y na tela
    bltz t2, dp_prox
    bltz t3, dp_prox
    li   t4, 318
    bgt  t2, t4, dp_prox
    li   t4, 238
    bgt  t3, t4, dp_prox
    li   t4, LARGURA_TELA
    mul  t5, t3, t4
    add  t5, t5, t2
    add  t5, t5, a0
    lw   t1, 20(t0)
    sb   t1, 0(t5)
    sb   t1, 1(t5)
    sb   t1, 320(t5)
    sb   t1, 321(t5)
dp_prox:
    addi t0, t0, TAM_PARTICULA
    addi t6, t6, -1
    bnez t6, dp_loop
    ret
