############################################################################
#  TEXTO NA TELA (sem ecall)
#
#  O texto é escrito com .string no próprio assembly, com acentos normais:
#       msg_ola: .string "Olá, calouro!\nBoa sorte."
#  O assembler guarda os acentos em UTF-8 (2 ou 3 bytes por letra);
#  proximo_caractere converte isso para a posição da letra na tabela 'fonte'
#  (dados/fonte.s, onde cada letra está desenhada em texto).
#
#  Cada letra ocupa 6 x 12 pixels (vezes a escala). '\n' pula de linha.
############################################################################

.eqv LARG_LETRA   6
.eqv ALT_LETRA    12
.eqv CENTRO       -1                   # use como x para centralizar cada linha

.text

# --------------------------------------------------------------------------
# proximo_caractere: lê uma letra (UTF-8) do texto
#   a0 = endereço   ->   a0 = código da letra na fonte (0 = fim do texto)
#                         a1 = endereço da letra seguinte
# --------------------------------------------------------------------------
proximo_caractere:
    lbu  t0, 0(a0)
    addi a1, a0, 1
    li   t1, 0x80
    bltu t0, t1, pc_pronto             # ASCII comum: o código é o próprio byte
    li   t1, 0xC2
    beq  t0, t1, pc_c2
    li   t1, 0xC3
    beq  t0, t1, pc_c3
    li   t1, 0xCE
    beq  t0, t1, pc_ce
    li   t1, 0xCF
    beq  t0, t1, pc_cf
    li   t1, 0xE2
    beq  t0, t1, pc_e2
    li   t0, '?'                       # qualquer outra coisa vira '?'
    j    pc_pronto
pc_c2:                                 # C2 xx -> xx       (², ³, °, ·)
    lbu  t0, 1(a0)
    addi a1, a0, 2
    j    pc_pronto
pc_c3:                                 # C3 xx -> xx + 0x40 (á, é, ç, Ã...)
    lbu  t0, 1(a0)
    addi t0, t0, 0x40
    addi a1, a0, 2
    j    pc_pronto
pc_ce:                                 # Ω (CE A9) e Θ (CE 98)
    lbu  t2, 1(a0)
    addi a1, a0, 2
    li   t0, 0x81
    li   t1, 0xA9
    beq  t2, t1, pc_pronto
    li   t0, 0x82
    li   t1, 0x98
    beq  t2, t1, pc_pronto
    li   t0, '?'
    j    pc_pronto
pc_cf:                                 # π (CF 80)
    addi a1, a0, 2
    li   t0, 0x84
    j    pc_pronto
pc_e2:                                 # símbolos de 3 bytes: E2 b1 b2
    lbu  t2, 1(a0)
    lbu  t3, 2(a0)
    addi a1, a0, 3
    slli t2, t2, 8
    or   t2, t2, t3                    # t2 = b1 b2
    li   t0, 0x80                      # ∫  (E2 88 AB)
    li   t1, 0x88AB
    beq  t2, t1, pc_pronto
    li   t0, 0x83                      # √  (E2 88 9A)
    li   t1, 0x889A
    beq  t2, t1, pc_pronto
    li   t0, 0x85                      # ∞  (E2 88 9E)
    li   t1, 0x889E
    beq  t2, t1, pc_pronto
    li   t0, 0x86                      # →  (E2 86 92)
    li   t1, 0x8692
    beq  t2, t1, pc_pronto
    li   t0, 0x87                      # ≤  (E2 89 A4)
    li   t1, 0x89A4
    beq  t2, t1, pc_pronto
    li   t0, 0x88                      # ≥  (E2 89 A5)
    li   t1, 0x89A5
    beq  t2, t1, pc_pronto
    li   t0, '?'
pc_pronto:
    mv   a0, t0
    ret


# --------------------------------------------------------------------------
# largura_linha: quantas letras tem a linha que começa em a0 (até '\n' ou o fim)
#   a0 = endereço  ->  a0 = número de letras
# --------------------------------------------------------------------------
largura_linha:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    li   s1, 0
ll_loop:
    call proximo_caractere
    beqz a0, ll_fim
    li   t0, 10
    beq  a0, t0, ll_fim
    addi s1, s1, 1
    mv   a0, a1
    j    ll_loop
ll_fim:
    mv   a0, s1
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# desenhar_texto
#   a0 = endereço do texto (.string)
#   a1 = x  (ou CENTRO = -1 para centralizar cada linha na tela)
#   a2 = y
#   a3 = cor
#   a4 = destino (frame de vídeo ou buffer 'fundo')
#   a5 = escala (1 = normal, 2 = dobro, 3 = triplo)
# --------------------------------------------------------------------------
desenhar_texto:
    addi sp, sp, -40
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    sw   s5, 20(sp)
    sw   s6, 24(sp)
    sw   s7, 28(sp)
    sw   s8, 32(sp)

    mv   s1, a0                        # s1 = texto
    mv   s2, a1                        # s2 = x de cada começo de linha (ou CENTRO)
    mv   s4, a2                        # s4 = y atual
    mv   s5, a3                        # s5 = cor
    mv   s6, a4                        # s6 = destino
    mv   s7, a5                        # s7 = escala
dt_nova_linha:
    mv   s3, s2                        # s3 = x atual
    bgez s2, dt_letra
    mv   a0, s1                        # centralizar: x = (320 - letras * 6 * escala) / 2
    call largura_linha
    li   t0, LARG_LETRA
    mul  t0, t0, s7
    mul  t0, t0, a0
    li   s3, LARGURA_TELA
    sub  s3, s3, t0
    srai s3, s3, 1
dt_letra:
    mv   a0, s1
    call proximo_caractere
    mv   s1, a1
    beqz a0, dt_fim
    li   t0, 10
    bne  a0, t0, dt_desenha
    li   t0, ALT_LETRA                 # '\n': próxima linha
    mul  t0, t0, s7
    add  s4, s4, t0
    j    dt_nova_linha
dt_desenha:
    mv   a1, s3
    mv   a2, s4
    call desenhar_letra
    li   t0, LARG_LETRA
    mul  t0, t0, s7
    add  s3, s3, t0
    j    dt_letra
dt_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    lw   s5, 20(sp)
    lw   s6, 24(sp)
    lw   s7, 28(sp)
    lw   s8, 32(sp)
    addi sp, sp, 40
    ret

# desenhar_letra: a0 = código, a1 = x, a2 = y; usa s5 = cor, s6 = destino, s7 = escala
# (só é chamada por desenhar_texto)
desenhar_letra:
    la   t0, fonte
    li   t1, ALT_LETRA
    mul  t1, t1, a0
    add  t0, t0, t1                    # t0 = 12 bytes desta letra
    li   t1, 0                         # t1 = linha da letra
dl_linha:
    lbu  t2, 0(t0)                     # t2 = bits da linha
    beqz t2, dl_prox_linha
    li   t3, 0                         # t3 = coluna (0 = esquerda)
dl_coluna:
    li   t4, 4
    sub  t4, t4, t3
    srl  t4, t2, t4
    andi t4, t4, 1
    beqz t4, dl_prox_coluna
    # pixel aceso: pinta um quadrado escala x escala em (x + col*esc, y + lin*esc)
    mul  t5, t3, s7
    add  t5, t5, a1                    # t5 = x do quadrado
    mul  t6, t1, s7
    add  t6, t6, a2                    # t6 = y do quadrado
    li   a3, 0                         # a3 = dy
dl_dy:
    add  a5, t6, a3
    bltz a5, dl_dy_prox
    li   a6, ALTURA_TELA
    bge  a5, a6, dl_dy_prox
    li   a6, LARGURA_TELA
    mul  a5, a5, a6
    add  a5, a5, s6                    # a5 = início da linha no destino
    li   a4, 0                         # a4 = dx
dl_dx:
    add  a7, t5, a4
    bltz a7, dl_dx_prox
    bge  a7, a6, dl_dx_prox
    add  a7, a7, a5
    sb   s5, 0(a7)
dl_dx_prox:
    addi a4, a4, 1
    blt  a4, s7, dl_dx
dl_dy_prox:
    addi a3, a3, 1
    blt  a3, s7, dl_dy
dl_prox_coluna:
    addi t3, t3, 1
    li   t4, 5
    blt  t3, t4, dl_coluna
dl_prox_linha:
    addi t0, t0, 1
    addi t1, t1, 1
    li   t4, ALT_LETRA
    blt  t1, t4, dl_linha
    ret


# --------------------------------------------------------------------------
# desenhar_texto_sombra: igual a desenhar_texto, com uma sombra preta embaixo
#   (a sombra fica 1 pixel x escala para a direita e para baixo)
# --------------------------------------------------------------------------
desenhar_texto_sombra:
    addi sp, sp, -28
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)
    sw   a2, 12(sp)
    sw   a3, 16(sp)
    sw   a4, 20(sp)
    sw   a5, 24(sp)
    # sombra
    add  a2, a2, a5
    li   a3, COR_PRETO
    bltz a1, dts_centro
    add  a1, a1, a5
    call desenhar_texto
    j    dts_texto
dts_centro:                            # centralizado: desloca a sombra mudando o y só
    call desenhar_texto                # (fica embaixo; ainda dá o efeito)
dts_texto:
    lw   a0, 4(sp)
    lw   a1, 8(sp)
    lw   a2, 12(sp)
    lw   a3, 16(sp)
    lw   a4, 20(sp)
    lw   a5, 24(sp)
    call desenhar_texto
    lw   ra, 0(sp)
    addi sp, sp, 28
    ret


# --------------------------------------------------------------------------
# preencher_retangulo: pinta um retângulo de uma cor só (com recorte na tela)
#   a0 = x   a1 = y   a2 = largura   a3 = altura   a4 = cor   a5 = destino
# --------------------------------------------------------------------------
preencher_retangulo:
    add  t0, a0, a2                    # t0 = x final (exclusivo)
    add  t1, a1, a3                    # t1 = y final (exclusivo)
    bgez a0, pr_x0
    li   a0, 0
pr_x0:
    bgez a1, pr_y0
    li   a1, 0
pr_y0:
    li   t2, LARGURA_TELA
    ble  t0, t2, pr_x1
    mv   t0, t2
pr_x1:
    li   t2, ALTURA_TELA
    ble  t1, t2, pr_y1
    mv   t1, t2
pr_y1:
    bge  a0, t0, pr_fim
    bge  a1, t1, pr_fim
pr_linha:
    li   t2, LARGURA_TELA
    mul  t3, a1, t2
    add  t3, t3, a5                    # t3 = início da linha
    add  t4, t3, t0                    # t4 = fim
    add  t3, t3, a0
pr_px:
    sb   a4, 0(t3)
    addi t3, t3, 1
    blt  t3, t4, pr_px
    addi a1, a1, 1
    blt  a1, t1, pr_linha
pr_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_painel: retângulo com borda (caixa de texto)
#   a0 = x   a1 = y   a2 = largura   a3 = altura   a4 = cor do fundo
#   a5 = destino   a6 = cor da borda
#   A borda tem 2 pixels: uma linha clara (a6) e uma escura por fora.
# --------------------------------------------------------------------------
desenhar_painel:
    addi sp, sp, -32
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)
    sw   a2, 12(sp)
    sw   a3, 16(sp)
    sw   a4, 20(sp)
    sw   a5, 24(sp)
    sw   a6, 28(sp)
    li   a4, COR_PRETO                 # contorno escuro
    call preencher_retangulo
    lw   a0, 4(sp)                     # borda clara
    lw   a1, 8(sp)
    lw   a2, 12(sp)
    lw   a3, 16(sp)
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -2
    addi a3, a3, -2
    lw   a4, 28(sp)
    lw   a5, 24(sp)
    call preencher_retangulo
    lw   a0, 4(sp)                     # miolo
    lw   a1, 8(sp)
    lw   a2, 12(sp)
    lw   a3, 16(sp)
    addi a0, a0, 3
    addi a1, a1, 3
    addi a2, a2, -6
    addi a3, a3, -6
    lw   a4, 20(sp)
    lw   a5, 24(sp)
    call preencher_retangulo
    lw   ra, 0(sp)
    addi sp, sp, 32
    ret
