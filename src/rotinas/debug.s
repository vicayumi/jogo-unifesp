############################################################################
#  ATALHOS DE TESTE (para achar bugs mais rápido)
#
#  Ligados quando DEBUG_ATALHOS = 1 (começo do main.s). Antes de entregar
#  o jogo, mude para 0: aí nenhuma destas teclas faz nada.
#
#  Em QUALQUER tela:
#     5  vai direto para o TREINO          6  vai direto para a FASE 1 (Cálculo)
#     7  vai direto para a FASE 2 (AED)    8  vai direto para a FASE 3 (AOC)
#  Durante o jogo:
#     9  teleporta para a porta da arena do chefão (no treino: para a porta da UNIFESP)
#     0  vence a fase na hora (vai para a tela de "fase concluída")
#     I  invencível liga/desliga (nada tira coração: monstro, projétil, espinho, erro)
#     V  enche os corações de novo
#     K  derrota todos os monstros da fase
#     J  pulo infinito liga/desliga (pula até no ar: bom para testar os mapas)
#     G  mostra/esconde a posição do estudante (x, y em pixels; coluna, linha do mapa)
#     N  perde todas as vidas (testa o filminho de derrota e o GAME OVER)
#     T  deixa só 5 segundos no cronômetro (testa o "REPROVOU POR FALTA!")
#  Na luta contra o chefão:
#     B  dá um golpe no chefão (como se tivesse acertado uma pergunta)
#     P  o chefão faz a pergunta agora
#  Na tela de pergunta:
#     C  responde a alternativa certa
#
#  Para começar o jogo já numa fase, use FASE_TESTE (main.s).
#  Quando um modo está ligado, o nome dele aparece no canto de baixo da tela.
############################################################################

.data
.align 2
debug_invencivel:    .word 0
debug_pulo_infinito: .word 0
debug_info:          .word 0
debug_numero:        .space 16         # número convertido em texto
debug_reverso:       .space 16         # rascunho (os dígitos saem ao contrário)

# FASE_TESTE (main.s): fase, 1 = já na porta da arena do chefão
fases_teste:
.word fase_tutorial, 0                 # 1
.word fase_calculo, 0                  # 2
.word fase_calculo, 1                  # 3
.word fase_aed, 0                      # 4
.word fase_aed, 1                      # 5
.word fase_aoc, 0                      # 6
.word fase_aoc, 1                      # 7

# teclas que trocam de fase:  bit, fase
teclas_fases:
.word T_DBG_TREINO, fase_tutorial
.word T_DBG_FASE1,  fase_calculo
.word T_DBG_FASE2,  fase_aed
.word T_DBG_FASE3,  fase_aoc
.word 0, 0

.text

# --------------------------------------------------------------------------
# atalhos_debug: uma vez por quadro (laço principal), se DEBUG_ATALHOS = 1
#   Faz no máximo uma ação por quadro.
# --------------------------------------------------------------------------
atalhos_debug:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)

    # ---- 5, 6, 7, 8: trocar de fase (em qualquer tela) ----
    la   s1, teclas_fases
ad_fases:
    lw   a0, 0(s1)
    beqz a0, ad_jogando
    call tecla_nova
    bnez a0, ad_vai_fase
    addi s1, s1, 8
    j    ad_fases
ad_vai_fase:
    lw   a0, 4(s1)
    li   a1, 0
    call debug_ir_fase
    j    ad_fim

    # ---- o resto só vale durante o jogo ----
ad_jogando:
    la   t0, estado_jogo
    lw   t0, 0(t0)
    li   t1, ESTADO_JOGANDO
    bne  t0, t1, ad_fim

    li   a0, T_DBG_CHEFE               # 9: arena do chefão
    call tecla_nova
    beqz a0, ad_vencer
    call debug_ir_arena
    j    ad_fim
ad_vencer:
    li   a0, T_DBG_VENCER              # 0: vence a fase
    call tecla_nova
    beqz a0, ad_invenc
    la   t0, chefe_estado
    sw   zero, 0(t0)
    call limpar_projeteis
    call parar_musica
    la   a0, SFX_FLAG
    call tocar_som
    call concluir_fase
    j    ad_fim
ad_invenc:
    li   a0, T_DBG_INVENC              # I: invencível
    call tecla_nova
    beqz a0, ad_vida
    la   t0, debug_invencivel
    lw   t1, 0(t0)
    xori t1, t1, 1
    sw   t1, 0(t0)
    j    ad_som_menu
ad_vida:
    li   a0, T_DBG_VIDA                # V: corações cheios
    call tecla_nova
    beqz a0, ad_matar
    la   t0, jogador_vidas
    li   t1, VIDAS_INICIAIS
    sw   t1, 0(t0)
    la   a0, SFX_PICKUP
    call tocar_som
    j    ad_fim
ad_matar:
    li   a0, T_DBG_MATAR               # K: derrota todos os monstros
    call tecla_nova
    beqz a0, ad_pulo
    la   t0, monstros
    la   t1, monstros_total
    lw   t1, 0(t1)
ad_matar_loop:
    blez t1, ad_matar_som
    sw   zero, 12(t0)                  # vivo = 0
    addi t0, t0, TAM_MONSTRO
    addi t1, t1, -1
    j    ad_matar_loop
ad_matar_som:
    la   a0, SFX_STOMP
    call tocar_som
    j    ad_fim
ad_pulo:
    li   a0, T_DBG_PULO                # J: pulo infinito
    call tecla_nova
    beqz a0, ad_info
    la   t0, debug_pulo_infinito
    lw   t1, 0(t0)
    xori t1, t1, 1
    sw   t1, 0(t0)
    j    ad_som_menu
ad_info:
    li   a0, T_DBG_INFO                # G: mostra a posição
    call tecla_nova
    beqz a0, ad_morrer
    la   t0, debug_info
    lw   t1, 0(t0)
    xori t1, t1, 1
    sw   t1, 0(t0)
    j    ad_som_menu
ad_morrer:
    li   a0, T_DBG_MORRER              # N: perde todas as vidas
    call tecla_nova
    beqz a0, ad_tempo
    la   t0, morte_causa               # (o filminho mostra o 1º monstro da fase)
    la   t1, monstros_total
    lw   t1, 0(t1)
    beqz t1, ad_morrer_sem
    li   t1, CAUSA_MONSTRO
    sw   t1, 0(t0)
    la   t1, monstros
    lw   t1, 16(t1)
    la   t2, morte_info
    sw   t1, 0(t2)
    j    ad_morrer_vai
ad_morrer_sem:
    sw   zero, 0(t0)
ad_morrer_vai:
    la   t0, debug_invencivel
    sw   zero, 0(t0)
    la   t0, jogador_invuln
    sw   zero, 0(t0)
    la   t0, jogador_vidas
    li   t1, 1
    sw   t1, 0(t0)
    li   a0, 0
    call dano_jogador
    j    ad_fim
ad_tempo:
    li   a0, T_DBG_TEMPO               # T: só 5 segundos no cronômetro
    call tecla_nova
    beqz a0, ad_golpe
    la   t0, fase_tempo
    li   t1, 300
    sw   t1, 0(t0)
    j    ad_som_menu
ad_golpe:
    la   t0, chefe_estado              # B e P: só com o chefão lutando
    lw   t0, 0(t0)
    li   t1, CH_LUTA
    bne  t0, t1, ad_fim
    li   a0, T_DBG_GOLPE               # B: golpe no chefão
    call tecla_nova
    beqz a0, ad_pergunta
    li   a0, 1
    call chefe_resposta
    j    ad_fim
ad_pergunta:
    li   a0, T_DBG_PERGUNTA            # P: pergunta agora
    call tecla_nova
    beqz a0, ad_fim
    la   t0, chefe_pergunta
    li   t1, 1
    sw   t1, 0(t0)
    j    ad_fim

ad_som_menu:
    la   a0, SFX_MENU
    call tocar_som
ad_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# debug_ir_fase: começa uma fase direto, já jogando (com a música dela)
#   a0 = registro da fase   a1 = 1 para já começar na porta da arena do chefão
# --------------------------------------------------------------------------
debug_ir_fase:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a1, 4(sp)
    call parar_sons                    # corta os efeitos do que estava acontecendo
    call carregar_fase
    li   a0, ESTADO_JOGANDO
    call mudar_estado
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   a0, F_MUSICA(t0)
    beqz a0, dif_arena
    call tocar_musica
dif_arena:
    lw   t0, 4(sp)
    beqz t0, dif_fim
    call debug_ir_arena
dif_fim:
    lw   ra, 0(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# debug_ir_arena: põe o estudante logo antes da arena do chefão
#   (dando uns passos para a direita a arena fecha e o chefão aparece).
#   No treino (sem chefão), põe o estudante perto da porta da UNIFESP.
# --------------------------------------------------------------------------
debug_ir_arena:
    la   t0, arena_ativa               # já está na arena
    lw   t0, 0(t0)
    bnez t0, dia_fim
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t1, F_ARENA(t0)
    beqz t1, dia_porta
    slli t1, t1, 4
    addi t1, t1, 24
    j    dia_poe
dia_porta:
    lw   t2, F_META(t0)
    beqz t2, dia_fim                   # nem chefão nem porta
    lw   t1, 0(t2)
    addi t1, t1, -40
dia_poe:
    la   t2, jogador_x
    sw   t1, 0(t2)
    lw   t1, F_INICIO_Y(t0)
    la   t2, jogador_y
    sw   t1, 0(t2)
    la   t2, jogador_vy
    sw   zero, 0(t2)
    la   t2, jogador_frac_y
    sw   zero, 0(t2)
    la   t2, jogador_empurrao
    sw   zero, 0(t2)
    tail atualizar_camera
dia_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_debug: no canto de baixo da tela, os modos de teste ligados
#   (INVENCÍVEL, PULO INFINITO) e, com G, a posição do estudante.
#   a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_debug:
    li   t0, DEBUG_ATALHOS
    beqz t0, dd2_fim
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    mv   s1, a0
    li   s2, 6                         # s2 = x do próximo aviso
    la   t0, debug_invencivel
    lw   t0, 0(t0)
    beqz t0, dd2_pulo
    la   a0, txt_dbg_invencivel
    mv   a1, s2
    li   a2, 212
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    addi s2, s2, 72
dd2_pulo:
    la   t0, debug_pulo_infinito
    lw   t0, 0(t0)
    beqz t0, dd2_info
    la   a0, txt_dbg_pulo
    mv   a1, s2
    li   a2, 212
    li   a3, 0xF8                      # ciano
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
dd2_info:
    la   t0, debug_info
    lw   t0, 0(t0)
    beqz t0, dd2_sai
    la   a0, txt_dbg_pos               # "X       Y       COL     LIN"
    li   a1, 6
    li   a2, 226
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    la   t0, jogador_x                 # x (pixels)
    lw   a0, 0(t0)
    li   a1, 18
    call dd2_numero
    la   t0, jogador_y                 # y (pixels)
    lw   a0, 0(t0)
    li   a1, 66
    call dd2_numero
    la   t0, jogador_x                 # coluna do meio do estudante
    lw   a0, 0(t0)
    addi a0, a0, 8
    srai a0, a0, 4
    li   a1, 126
    call dd2_numero
    la   t0, jogador_y                 # linha dos pés
    lw   a0, 0(t0)
    addi a0, a0, HIT_Y1
    srai a0, a0, 4
    li   a1, 174
    call dd2_numero
dd2_sai:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
dd2_fim:
    ret

# dd2_numero: escreve o número a0 em branco no x = a1, y = 226 (usa s1 = destino)
dd2_numero:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a1, 4(sp)
    la   a1, debug_numero
    call numero_texto
    la   a0, debug_numero
    lw   a1, 4(sp)
    li   a2, 226
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    lw   ra, 0(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# numero_texto: escreve o número a0 (com sinal) em decimal no endereço a1,
#   terminando com 0 (como um .string).
# --------------------------------------------------------------------------
numero_texto:
    mv   t2, a1
    bgez a0, nt_positivo
    li   t0, '-'
    sb   t0, 0(t2)
    addi t2, t2, 1
    sub  a0, zero, a0
nt_positivo:
    la   t3, debug_reverso
    li   t4, 0                         # t4 = quantos dígitos
nt_digito:                             # dígitos do fim para o começo
    li   t0, 10
    remu t1, a0, t0
    divu a0, a0, t0
    addi t1, t1, '0'
    add  t5, t3, t4
    sb   t1, 0(t5)
    addi t4, t4, 1
    bnez a0, nt_digito
nt_copia:                              # desvira
    addi t4, t4, -1
    add  t5, t3, t4
    lbu  t1, 0(t5)
    sb   t1, 0(t2)
    addi t2, t2, 1
    bnez t4, nt_copia
    sb   zero, 0(t2)
    ret
