############################################################################
#  COLISÃO COM OS BLOCOS DO MAPA
#
#  Cada bloco do mapa tem um número (0 = vazio). A tabela bloco_solido diz
#  quais números têm colisão (1) e quais são só enfeite (0). Para criar um
#  bloco sólido novo, desenhe graficos/blocos/N_nome.png e ponha 1 na posição N.
############################################################################

.data
#                  0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
bloco_solido: .byte 0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.align 2

.text

# --------------------------------------------------------------------------
# ponto_solido: o pixel (x, y) do MUNDO está dentro de um bloco sólido?
#   a0 = x    a1 = y     (coordenadas do mundo, em pixels)
#   devolve a0 = 1 se sólido, 0 se livre
#
#   - fora do mapa (esquerda, direita, cima, baixo) conta como sólido
#   - com a arena do chefão fechada, tudo à esquerda dela é parede
# --------------------------------------------------------------------------
ponto_solido:
    bltz a0, ps_sim
    bltz a1, ps_sim                    # teto: não deixa sair pelo topo da tela
    li   t0, ALTURA_TELA
    bge  a1, t0, ps_sim

    la   t0, arena_ativa
    lw   t0, 0(t0)
    beqz t0, ps_mapa
    la   t0, arena_x0
    lw   t0, 0(t0)
    blt  a0, t0, ps_sim                # parede invisível da arena

ps_mapa:
    la   t0, mapa_atual
    lw   t0, 0(t0)                     # t0 = endereço do mapa
    lw   t3, 0(t0)                     # t3 = largura do mapa (em blocos)
    srli t1, a0, 4                     # t1 = coluna no mapa  (x / 16)
    bge  t1, t3, ps_sim                # depois do fim do mapa: parede
    srli t2, a1, 4                     # t2 = linha           (y / 16)
    mul  t2, t2, t3
    add  t2, t2, t1                    # t2 = índice do bloco
    add  t2, t2, t0
    lbu  t2, 8(t2)                     # número do bloco (pula os 2 words do cabeçalho)
    la   t0, bloco_solido
    add  t0, t0, t2
    lbu  a0, 0(t0)                     # 1 = sólido, 0 = vazio/enfeite
    ret
ps_sim:
    li   a0, 1
    ret


# --------------------------------------------------------------------------
# coluna_bate: a borda vertical do estudante toca algum bloco?
#   a0 = x do pixel     a1 = y do topo do estudante
#   devolve a0 = 1 se algum dos 3 pontos (topo, meio, pés) está num bloco
# --------------------------------------------------------------------------
coluna_bate:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    mv   s1, a0
    mv   s2, a1

    mv   a0, s1
    addi a1, s2, HIT_Y0
    call ponto_solido
    bnez a0, cb_fim

    mv   a0, s1
    addi a1, s2, HIT_MEIO
    call ponto_solido
    bnez a0, cb_fim

    mv   a0, s1
    addi a1, s2, HIT_Y1
    call ponto_solido

cb_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# linha_bate: uma linha horizontal da hitbox toca algum bloco?
#   a0 = x do estudante     a1 = y da linha
#   devolve a0 = 1 se o canto esquerdo ou o direito da hitbox está num bloco
# --------------------------------------------------------------------------
linha_bate:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    mv   s1, a0
    mv   s2, a1

    addi a0, s1, HIT_X0
    mv   a1, s2
    call ponto_solido
    bnez a0, lb_fim

    addi a0, s1, HIT_X1
    mv   a1, s2
    call ponto_solido

lb_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# encosta_no_jogador: a caixa (x0, y0) - (x1, y1) encosta na hitbox do estudante?
#   a0 = x0   a1 = y0   a2 = x1   a3 = y1   (inclusivos, coordenadas do mundo)
#   devolve a0 = 1 se encosta
# --------------------------------------------------------------------------
encosta_no_jogador:
    la   t0, jogador_x
    lw   t0, 0(t0)
    la   t1, jogador_y
    lw   t1, 0(t1)
    addi t2, t0, HIT_X1                # direita do estudante
    blt  t2, a0, ej_nao
    addi t2, t0, HIT_X0                # esquerda
    blt  a2, t2, ej_nao
    addi t2, t1, HIT_Y1                # pés
    blt  t2, a1, ej_nao
    addi t2, t1, HIT_Y0                # topo
    blt  a3, t2, ej_nao
    li   a0, 1
    ret
ej_nao:
    li   a0, 0
    ret
