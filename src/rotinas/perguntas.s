############################################################################
#  PERGUNTAS DOS CHEFÕES
#
#  As perguntas ficam em dados/perguntas.s, numa tabela por matéria:
#       perguntas_calculo:
#       .word quantidade
#       .word texto, alternativa_1, alternativa_2, alternativa_3, alternativa_4, certa
#  (certa = 0 a 3).  Cada pergunta é sorteada uma vez só por luta
#  (perguntas_usadas guarda 1 bit por pergunta já feita).
#
#  Na tela de pergunta a ação congela. O estudante responde com 1, 2, 3, 4
#  O resultado aparece por PERGUNTA_RESULTADO quadros e
#  depois chefe_resposta (chefes.s) aplica o acerto ou o erro.
############################################################################

.eqv TAM_PERGUNTA        24
.eqv PERGUNTA_RESULTADO  150            # 2,5 s mostrando o resultado (ENTER pula)

.data
.align 2
perguntas_usadas:  .word 0
pergunta_atual:    .word 0             # endereço da pergunta sorteada
pergunta_fase:     .word 0             # 0 = esperando resposta, 1 = mostrando o resultado
pergunta_escolha:  .word 0             # alternativa escolhida (0 a 3)
pergunta_timer:    .word 0
rotulos_alt:       .word txt_alt_1, txt_alt_2, txt_alt_3, txt_alt_4
teclas_alt:        .word T_RESP_A, T_RESP_B, T_RESP_C, T_RESP_D

.text

# --------------------------------------------------------------------------
# iniciar_pergunta: sorteia uma pergunta e abre a tela de pergunta
#   a0 = tabela de perguntas da matéria
# --------------------------------------------------------------------------
iniciar_pergunta:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    mv   s1, a0
    lw   s2, 0(s1)                     # s2 = quantas perguntas existem
    la   t0, perguntas_usadas          # todas já foram feitas? recomeça
    lw   t1, 0(t0)
    li   t2, 1
    sll  t2, t2, s2
    addi t2, t2, -1                    # t2 = máscara com todas
    and  t3, t1, t2
    bne  t3, t2, ip_sorteia
    sw   zero, 0(t0)
ip_sorteia:
    call misturar_semente
    call aleatorio
    remu t0, a0, s2                    # t0 = sorteada
    la   t1, perguntas_usadas
    lw   t1, 0(t1)
ip_procura:                            # se já saiu, pega a próxima livre
    srl  t2, t1, t0
    andi t2, t2, 1
    beqz t2, ip_achou
    addi t0, t0, 1
    blt  t0, s2, ip_procura
    li   t0, 0
    j    ip_procura
ip_achou:
    li   t2, 1
    sll  t2, t2, t0
    or   t1, t1, t2
    la   t3, perguntas_usadas
    sw   t1, 0(t3)
    li   t2, TAM_PERGUNTA
    mul  t0, t0, t2
    add  t0, t0, s1
    addi t0, t0, 4
    la   t1, pergunta_atual
    sw   t0, 0(t1)
    la   t0, pergunta_fase
    sw   zero, 0(t0)
    la   t0, pergunta_timer
    sw   zero, 0(t0)
    la   t0, estado_jogo
    li   t1, ESTADO_PERGUNTA
    sw   t1, 0(t0)
    call limpar_teclas_novas
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# estado_pergunta: a tela de pergunta (chamada a cada quadro)
# --------------------------------------------------------------------------
estado_pergunta:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    la   t0, pergunta_fase
    lw   t0, 0(t0)
    bnez t0, ep2_resultado

    # ---- esperando: qual tecla de resposta foi apertada? ----
    la   t0, pergunta_timer            # nos primeiros quadros ignora o teclado
    lw   t1, 0(t0)                     # (quem estava segurando A para andar
    addi t1, t1, 1                     #  não responde sem querer)
    sw   t1, 0(t0)
    li   t2, 20
    blt  t1, t2, ep2_desenha
    li   s1, 0
ep2_tecla:
    la   t0, teclas_alt
    slli t1, s1, 2
    add  t0, t0, t1
    lw   a0, 0(t0)
    call tecla_nova
    bnez a0, ep2_respondeu
    addi s1, s1, 1
    li   t0, 4
    blt  s1, t0, ep2_tecla
    j    ep2_desenha
ep2_respondeu:
    la   t0, pergunta_escolha
    sw   s1, 0(t0)
    la   t0, pergunta_fase
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, pergunta_timer
    sw   zero, 0(t0)
    call resposta_certa                # acertou: plim! (errou: o som do dano vem depois)
    beqz a0, ep2_desenha
    la   a0, SFX_PICKUP
    call tocar_som
    j    ep2_desenha

    # ---- mostrando o resultado ----
ep2_resultado:
    la   t0, pergunta_timer
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    li   t2, PERGUNTA_RESULTADO
    bge  t1, t2, ep2_fecha
    li   t2, 30                        # depois de meio segundo, ENTER pula a espera
    blt  t1, t2, ep2_desenha
    li   a0, T_ENTER
    call tecla_nova
    beqz a0, ep2_desenha
ep2_fecha:
    la   t0, estado_jogo               # volta para a luta e aplica o resultado
    li   t1, ESTADO_JOGANDO
    sw   t1, 0(t0)
    call resposta_certa
    call chefe_resposta
    j    ep2_fim

ep2_desenha:
    call frame_escondido
    mv   s1, a0
    call desenhar_cena                 # o jogo congelado, por trás
    mv   a0, s1
    call desenhar_painel_pergunta
    call mostrar_frame
ep2_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret

# resposta_certa: a0 = 1 se a alternativa escolhida é a certa
resposta_certa:
    la   t0, pergunta_atual
    lw   t0, 0(t0)
    lw   t1, 20(t0)
    la   t2, pergunta_escolha
    lw   t2, 0(t2)
    sub  a0, t1, t2
    seqz a0, a0
    ret


# --------------------------------------------------------------------------
# desenhar_painel_pergunta: a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_painel_pergunta:
    addi sp, sp, -20
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    mv   s1, a0
    la   t0, pergunta_atual
    lw   s2, 0(t0)                     # s2 = pergunta

    li   a0, 10                        # o painel
    li   a1, 30
    li   a2, 300
    li   a3, 184
    li   a4, COR_PAINEL
    mv   a5, s1
    li   a6, COR_AMARELO
    call desenhar_painel

    la   a0, txt_pergunta_titulo
    li   a1, CENTRO
    li   a2, 38
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto

    lw   a0, 0(s2)                     # enunciado (até 3 linhas)
    li   a1, 22
    li   a2, 58
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto

    # ---- as 4 alternativas ----
    li   s3, 0
dpp_alt:
    li   t0, 20
    mul  s4, s3, t0
    addi s4, s4, 104                   # s4 = y desta alternativa
    la   t0, pergunta_fase
    lw   t0, 0(t0)
    beqz t0, dpp_texto_alt             # ainda sem resposta: sem destaque
    lw   t1, 20(s2)                    # resultado: a certa fica verde,
    li   a4, COR_VERDE_ESCURO          #            a errada escolhida fica vermelha
    beq  s3, t1, dpp_destaque
    la   t0, pergunta_escolha
    lw   t0, 0(t0)
    bne  s3, t0, dpp_texto_alt
    li   a4, COR_VERMELHO_ESCURO
dpp_destaque:
    li   a0, 18
    addi a1, s4, -3
    li   a2, 284
    li   a3, 17
    mv   a5, s1
    call preencher_retangulo
dpp_texto_alt:
    la   t0, rotulos_alt               # "1)" "2)" ...
    slli t1, s3, 2
    add  t0, t0, t1
    lw   a0, 0(t0)
    li   a1, 24
    mv   a2, s4
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
    slli t1, s3, 2                     # texto da alternativa
    add  t0, s2, t1
    lw   a0, 4(t0)
    li   a1, 48
    mv   a2, s4
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto
    addi s3, s3, 1
    li   t0, 4
    blt  s3, t0, dpp_alt

    # ---- rodapé: instrução ou resultado ----
    la   t0, pergunta_fase
    lw   t0, 0(t0)
    la   a0, txt_pergunta_ajuda
    li   a3, COR_CINZA
    beqz t0, dpp_rodape
    call resposta_certa
    la   t0, txt_pergunta_certo
    li   a3, COR_VERDE
    bnez a0, dpp_rodape_txt
    la   t0, txt_pergunta_errado
    li   a3, COR_VERMELHO_CLARO
dpp_rodape_txt:
    mv   a0, t0
dpp_rodape:
    li   a1, CENTRO
    li   a2, 190
    mv   a4, s1
    li   a5, 1
    call desenhar_texto

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    addi sp, sp, 20
    ret
