############################################################################
#  ROTINAS DE TECLADO
#
#  O FPGRARS mantém um "mapa de teclas" a partir de 0xFF200520:
#  1 bit por tecla, indexado pelo scancode da tecla.
#     tecla com scancode N  ->  byte N / 8,  bit N % 8
#  Bit = 1 enquanto a tecla está pressionada. Isso permite segurar
#  várias teclas ao mesmo tempo (andar + pular, por exemplo).
#
#  Uma vez por quadro, ler_teclado junta as teclas do jogo numa word de bits:
#     teclas_agora = teclas seguradas neste quadro
#     teclas_novas = teclas que ACABARAM de ser apertadas (não estavam no quadro
#                    anterior). Serve para ENTER, respostas e pulo: segurar a tecla
#                    não repete a ação.
#  Depois é só testar o bit:   la t0, teclas_novas / lw t0, 0(t0) / andi t0, t0, T_ENTER
#
#  Os scancodes abaixo valem para Windows e Linux.
############################################################################

# (as constantes SC_* e T_* ficam no main.s, porque precisam ser definidas antes do uso)

.data
.align 2
teclas_agora:     .word 0
teclas_antes:     .word 0
teclas_novas:     .word 0

# tabela: scancode, bit   (termina com 0, 0)
tabela_teclas:
.word SC_A, T_ESQ,   SC_ESQ_WIN, T_ESQ,   SC_ESQ_LINUX, T_ESQ
.word SC_D, T_DIR,   SC_DIR_WIN, T_DIR,   SC_DIR_LINUX, T_DIR
.word SC_W, T_PULO,  SC_ESPACO, T_PULO,   SC_CIMA_WIN, T_PULO,   SC_CIMA_LINUX, T_PULO
.word SC_ENTER, T_ENTER,   SC_ESC, T_ESC,   SC_M, T_MUDO
.word SC_1, T_RESP_A
.word SC_2, T_RESP_B
.word SC_3, T_RESP_C
.word SC_4, T_RESP_D
.word 0, 0

# tabela: caractere (byte), -, bit (half)   (termina com 0)
# Só ENTER e os números: letras e espaço ficam de fora porque, segurando a tecla,
# o teclado repete o caractere sozinho (e uma pergunta seria respondida sem querer).
tabela_caracteres:
.byte 10, 0
.half T_ENTER
.byte 13, 0
.half T_ENTER
.byte '1', 0
.half T_RESP_A
.byte '2', 0
.half T_RESP_B
.byte '3', 0
.half T_RESP_C
.byte '4', 0
.half T_RESP_D
.byte 0, 0
.half 0
.align 2

.text

# --------------------------------------------------------------------------
# tecla_pressionada: a0 = scancode  ->  a0 = 1 se está pressionada, 0 se não
# --------------------------------------------------------------------------
tecla_pressionada:
    li   t0, MAPA_TECLAS
    srli t1, a0, 3                     # byte = scancode / 8
    add  t0, t0, t1
    lbu  t1, 0(t0)
    andi t2, a0, 7                     # bit  = scancode % 8
    srl  t1, t1, t2
    andi a0, t1, 1
    ret

# --------------------------------------------------------------------------
# ler_teclado: atualiza teclas_agora, teclas_novas e teclas_antes (1x por quadro)
# --------------------------------------------------------------------------
ler_teclado:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)

    la   s1, tabela_teclas
    li   s2, 0                         # s2 = bits das teclas seguradas
lt_loop:
    lw   a0, 0(s1)
    beqz a0, lt_fim
    call tecla_pressionada
    beqz a0, lt_prox
    lw   t0, 4(s1)
    or   s2, s2, t0
lt_prox:
    addi s1, s1, 8
    j    lt_loop
lt_fim:
    la   t0, teclas_agora
    sw   s2, 0(t0)
    la   t1, teclas_antes
    lw   t2, 0(t1)                     # t2 = teclas do quadro anterior
    not  t3, t2
    and  t3, t3, s2                    # novas = agora E NÃO antes
    sw   s2, 0(t1)                     # antes = agora (para o próximo quadro)

    # Um toque muito rápido (apertar e soltar dentro de um quadro) não aparece no
    # mapa de teclas. Mas o FPGRARS também guarda o último CARACTERE digitado em
    # 0xFF200000 (controle: bit 0 = tem caractere) e 0xFF200004 (o caractere).
    # Esse caractere fica guardado até ser lido, então somamos ele às teclas novas.
    li   t0, KD_CONTROLE
    lw   t1, 0(t0)
    andi t1, t1, 1
    beqz t1, lt_guarda
    lw   t1, 4(t0)                     # ler o caractere já limpa o controle
    andi t1, t1, 255
    la   t4, tabela_caracteres
lt_char:
    lbu  t5, 0(t4)
    beqz t5, lt_guarda                 # caractere que o jogo não usa
    bne  t5, t1, lt_char_prox
    lhu  t5, 2(t4)
    or   t3, t3, t5
    j    lt_guarda
lt_char_prox:
    addi t4, t4, 4
    j    lt_char
lt_guarda:
    la   t4, teclas_novas
    sw   t3, 0(t4)

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret

# a0 = bit  ->  a0 = 1 se a tecla está segurada agora
tecla_segurada:
    la   t0, teclas_agora
    lw   t0, 0(t0)
    and  a0, a0, t0
    snez a0, a0
    ret

# a0 = bit  ->  a0 = 1 se a tecla acabou de ser apertada neste quadro
tecla_nova:
    la   t0, teclas_novas
    lw   t0, 0(t0)
    and  a0, a0, t0
    snez a0, a0
    ret

# esquece as teclas apertadas neste quadro (ao trocar de tela, para o mesmo
# ENTER não valer duas vezes)
limpar_teclas_novas:
    la   t0, teclas_novas
    sw   zero, 0(t0)
    ret
