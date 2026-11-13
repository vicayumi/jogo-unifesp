############################################################################
#  ROTINAS DE VÍDEO
#
#  Toda imagem na memória tem o formato:
#       .word largura, altura
#       .byte pixel, pixel, pixel ...   (largura * altura bytes, linha a linha)
#  O endereço de um pixel (x, y) dentro de uma tela de 320 de largura é:
#       base + y * 320 + x
############################################################################

.text

# --------------------------------------------------------------------------
# desenhar_imagem
#   a0 = endereço da imagem
#   a1 = x na tela (canto superior esquerdo; pode ser negativo)
#   a2 = y na tela (idem)
#   a3 = espelhar: 0 = normal, 1 = espelhado na horizontal
#   a4 = endereço base do destino (frame de vídeo ou buffer 'fundo')
#
#   - pula pixels com COR_TRANSPARENTE
#   - pula pixels que cairiam fora da tela (pode desenhar metade de um sprite)
# --------------------------------------------------------------------------
desenhar_imagem:
    lw   t0, 0(a0)                     # t0 = largura
    lw   t1, 4(a0)                     # t1 = altura
    addi a0, a0, 8                     # a0 = primeiro pixel da imagem
    li   t2, 0                         # t2 = linha da imagem (l)

di_linha:
    bge  t2, t1, di_fim                # desenhou todas as linhas
    add  t3, a2, t2                    # t3 = y na tela = y + l
    bltz t3, di_prox_linha             # linha acima da tela: pula
    li   t4, ALTURA_TELA
    bge  t3, t4, di_fim                # linha abaixo da tela: acabou

    li   t4, LARGURA_TELA
    mul  t5, t3, t4
    add  t5, t5, a4                    # t5 = início da linha no destino
    mul  t6, t2, t0
    add  t6, t6, a0                    # t6 = início da linha na imagem
    li   a5, 0                         # a5 = coluna (c)

di_coluna:
    bge  a5, t0, di_prox_linha
    mv   a6, a5                        # a6 = coluna de onde lemos o pixel
    beqz a3, di_le_pixel
    sub  a6, t0, a5                    # espelhado: lê de trás para frente
    addi a6, a6, -1                    #   coluna = largura - 1 - c
di_le_pixel:
    add  a6, a6, t6
    lbu  a7, 0(a6)                     # a7 = cor do pixel
    li   a6, COR_TRANSPARENTE
    beq  a7, a6, di_prox_coluna        # transparente: não desenha

    add  a6, a1, a5                    # a6 = x na tela = x + c
    bltz a6, di_prox_coluna            # fora pela esquerda
    bge  a6, t4, di_prox_coluna        # fora pela direita (t4 = 320)
    add  a6, a6, t5
    sb   a7, 0(a6)                     # pinta!

di_prox_coluna:
    addi a5, a5, 1
    j    di_coluna

di_prox_linha:
    addi t2, t2, 1
    j    di_linha

di_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_mapa: desenha os blocos visíveis do mapa no buffer 'fundo'
#   (por cima do cenário de fundo, que desenhar_cenario já deixou lá)
#   a0 = endereço do mapa (.word colunas, linhas  + 1 byte por bloco)
#   a1 = coluna do mapa que aparece na borda esquerda da tela
#   a2 = deslocamento em pixels (0 a 15): quanto dessa coluna já saiu da tela
#
#   Rolagem suave: a câmera (em pixels) é dividida assim
#       a1 = camera_x / 16        a2 = camera_x mod 16
#   Quando a2 > 0, aparece um bloco extra (parcial) na borda direita.
#   Para trocar de tela de uma vez (estilo Pitfall): a1 = tela * 20, a2 = 0.
# --------------------------------------------------------------------------
desenhar_mapa:
    addi sp, sp, -28
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)
    sw   s3, 16(sp)
    sw   s4, 20(sp)
    sw   s5, 24(sp)

    lw   s0, 0(a0)                     # s0 = colunas do mapa inteiro
    addi s1, a0, 8                     # s1 = primeiro bloco do mapa
    mv   s2, a1                        # s2 = coluna inicial (câmera)
    mv   s5, a2                        # s5 = deslocamento em pixels (0..15)

    # desenha cada bloco (por cima do que já está no 'fundo': céu, montanhas, prédio...)
    li   s3, 0                         # s3 = linha (0..14)
dm_linha:
    li   s4, 0                         # s4 = coluna na tela (0..19)
dm_coluna:
    add  t0, s2, s4                    # t0 = coluna no mapa
    bge  t0, s0, dm_prox               # passou do fim do mapa: fica céu
    mul  t1, s3, s0
    add  t1, t1, t0
    add  t1, t1, s1
    lbu  t1, 0(t1)                     # t1 = número do bloco
    beqz t1, dm_prox                   # 0 = vazio

    la   t2, blocos                    # tabela: blocos[n] = endereço da imagem
    slli t1, t1, 2                     # cada entrada tem 4 bytes
    add  t2, t2, t1
    lw   a0, 0(t2)
    slli a1, s4, 4                     # x = coluna * 16 ...
    sub  a1, a1, s5                    # ... menos o deslocamento da câmera
    slli a2, s3, 4                     # y = linha * 16
    call desenhar_camada               # (rotina rápida do cenario.s: desenha no 'fundo' com recorte)

dm_prox:
    addi s4, s4, 1
    li   t0, COLUNAS_TELA              # com deslocamento, desenha 1 coluna a mais
    beqz s5, dm_limite
    addi t0, t0, 1
dm_limite:
    blt  s4, t0, dm_coluna
    addi s3, s3, 1
    li   t0, LINHAS_TELA
    blt  s3, t0, dm_linha

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    lw   s3, 16(sp)
    lw   s4, 20(sp)
    lw   s5, 24(sp)
    addi sp, sp, 28
    ret


# --------------------------------------------------------------------------
# copiar_fundo: copia o buffer 'fundo' para um frame de vídeo
#   a0 = endereço do frame de destino
#   Copia 4 pixels por instrução (lw/sw), por isso é rápido.
# --------------------------------------------------------------------------
copiar_fundo:
    la   t0, fundo
    li   t1, TAMANHO_TELA
    add  t1, t1, t0                    # t1 = fim do buffer
cf_loop:                               # 32 bytes por volta
    lw   t2, 0(t0)
    lw   t3, 4(t0)
    lw   t4, 8(t0)
    lw   t5, 12(t0)
    lw   t6, 16(t0)
    lw   a1, 20(t0)
    lw   a2, 24(t0)
    lw   a3, 28(t0)
    sw   t2, 0(a0)
    sw   t3, 4(a0)
    sw   t4, 8(a0)
    sw   t5, 12(a0)
    sw   t6, 16(a0)
    sw   a1, 20(a0)
    sw   a2, 24(a0)
    sw   a3, 28(a0)
    addi t0, t0, 32
    addi a0, a0, 32
    blt  t0, t1, cf_loop
    ret
