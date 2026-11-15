############################################################################
#  CINEMA: o "filminho" do golpe final contra o chefão
#
#  Como os "ataques especiais" de jogos de luta: a ação congela, a tela
#  escurece, entram faixas pretas (cinema), uma faixa colorida atravessa a
#  tela com o retrato GRANDE de quem deu o golpe e o nome do golpe; um clarão
#  branco; e o retrato de quem levou o golpe, tremendo, com o resultado.
#
#    CINEMA_DERROTA   o chefão derrota o estudante com o golpe dele (Stewart:
#                     "PROVA SURPRESA!", Grafo: "SEGMENTATION FAULT!", Professor:
#                     "PROVA DE ASSEMBLY!") -> "REPROVADO!" e depois a queda
#                     normal (ESTADO_MORTE)
#    CINEMA_VITORIA   o estudante derrota o chefão: "RESPOSTA CERTA!"
#                     -> "APROVADO!" e depois o chefão explode (ESTADO_JOGANDO)
#  Os retratos, o nome e o golpe do chefão vêm do registro dele (chefes.s).
#    CINEMA_MONSTRO   um monstrinho derrotou o estudante: retrato do monstro e
#                     o golpe dele (tabela cin_monstros) -> "REPROVADO!"
#    CINEMA_PERIGO    espinhos / curto-circuito derrotaram o estudante
#    CINEMA_TEMPO     o cronômetro zerou: o despertador usa "FIM DO TEMPO!"
#                     -> "REPROVOU POR FALTA!"
#  Todas as derrotas terminam com a queda normal (ESTADO_MORTE) e o GAME OVER.
#
#  Linha do tempo (quadros, 60 por segundo):
#     0 ..  12   faixas pretas entrando, cena escurecida
#    12 ..  96   parte 1: faixa com o atacante (entra pela direita)
#    96 .. 102   clarão branco (SFX_IMPACTO)
#   102 .. 200   parte 2: a vítima tremendo e o resultado
#  ENTER pula o filminho (depois de meio segundo).
############################################################################

# (CINEMA_DERROTA e CINEMA_VITORIA ficam no main.s: são usados antes deste arquivo)

.eqv CIN_BARRA        44               # altura das faixas pretas (em cima e embaixo)
.eqv CIN_ENTRA        12               # quadro em que a faixa colorida começa a entrar
.eqv MENOS_CIN_ENTRA  -12              # (o assembler não aceita "-CIN_ENTRA")
.eqv CIN_CORTE        96               # quadro do clarão
.eqv CIN_CLARAO       6                # duração do clarão
.eqv CIN_FIM          200              # duração total
.eqv CIN_FAIXA_Y      64               # faixa colorida: y e altura
.eqv CIN_FAIXA_ALT    112
.eqv CIN_VEL_FAIXA    24               # pixels por quadro da faixa entrando

.data
.align 2
cinema_tipo:      .word 0
cin_vitoria:      .word 0              # 1 = o estudante venceu (as outras são derrotas)
cin_img:          .word 0              # retrato de quem atacou
cin_escala:       .word 0              # quantas vezes maior (o retrato fica com ~96 px)
cin_txts:         .word 0, 0, 0        # "Fulano usa:", golpe, resultado
cin_res_escala:   .word 3              # tamanho do resultado (2 para textos compridos)
cin_proj:         .word 0              # projétil que voa embaixo do golpe (0 = nenhum)

# monstrinhos (na ordem dos tipos TIPO_*): "Fulano usa:", golpe
cin_monstros:
.word txt_cin_m_calculo,  txt_cin_g_calculo
.word txt_cin_m_aoc,      txt_cin_g_aoc
.word txt_cin_m_integral, txt_cin_g_integral
.word txt_cin_m_lim,      txt_cin_g_lim
.word txt_cin_m_derivada, txt_cin_g_derivada
.word txt_cin_m_ponteiro, txt_cin_g_ponteiro
.word txt_cin_m_pilha,    txt_cin_g_pilha
.word txt_cin_m_no,       txt_cin_g_no
.word txt_cin_m_bit,      txt_cin_g_bit
.word txt_cin_m_bug,      txt_cin_g_bug
.word txt_cin_m_porta,    txt_cin_g_porta
# blocos que machucam (bloco 28 = espinhos, 29 = curto-circuito)
cin_perigos:
.word txt_cin_m_espinhos, txt_cin_g_espinhos
.word txt_cin_m_curto,    txt_cin_g_curto

# textos de cada tipo:  atacante (pequeno), golpe (grande), resultado (enorme)
#   (na derrota, os dois primeiros vêm do registro do chefão: CB_CIN_USA e CB_CIN_GOLPE)
cin_textos:
.word txt_cin_stewart_usa, txt_cin_prova, txt_cin_reprovado      # CINEMA_DERROTA
.word txt_cin_aluno_usa,  txt_cin_resposta, txt_cin_aprovado    # CINEMA_VITORIA
# cores de cada tipo: faixa da parte 1, riscos, faixa da parte 2, resultado
cin_cores:
.word 0x02, 0x17, 0x01, COR_VERMELHO_CLARO                      # vermelho
.word 0x90, 0xF5, 0x48, COR_AMARELO                             # azul

.text

# --------------------------------------------------------------------------
# iniciar_cinema: a0 = tipo (CINEMA_*)
#   a1 = tipo do monstro (CINEMA_MONSTRO) ou número do bloco (CINEMA_PERIGO)
#   Escolhe o retrato, os textos e o projétil do filminho.
# --------------------------------------------------------------------------
iniciar_cinema:
    addi sp, sp, -4
    sw   ra, 0(sp)
    la   t0, cinema_tipo
    sw   a0, 0(t0)
    la   t0, cin_vitoria               # padrão: derrota, "REPROVADO!" grande
    sw   zero, 0(t0)
    la   t0, cin_proj
    sw   zero, 0(t0)
    la   t0, cin_res_escala
    li   t1, 3
    sw   t1, 0(t0)
    la   t0, cin_txts
    la   t1, txt_cin_reprovado
    sw   t1, 8(t0)
    li   t1, CINEMA_VITORIA
    beq  a0, t1, ic_vitoria
    li   t1, CINEMA_MONSTRO
    beq  a0, t1, ic_monstro
    li   t1, CINEMA_PERIGO
    beq  a0, t1, ic_perigo
    li   t1, CINEMA_TEMPO
    beq  a0, t1, ic_tempo

    # ---- o chefão derrotou o estudante ----
    la   t2, chefe_dados
    lw   t2, 0(t2)
    lw   t1, CB_IMG_ABERTO(t2)         # 48 x 48, dobrado = 96 x 96
    li   t3, 2
    lw   t4, CB_CIN_USA(t2)
    lw   t5, CB_CIN_GOLPE(t2)
    lw   t6, CB_PROJ(t2)
    la   t0, cin_proj
    sw   t6, 0(t0)
    j    ic_guarda

    # ---- o estudante derrotou o chefão ----
ic_vitoria:
    la   t0, cin_vitoria
    li   t1, 1
    sw   t1, 0(t0)
    la   t1, anim_estudante_pulo       # 32 x 32, triplicado = 96 x 96
    lw   t1, 4(t1)
    li   t3, 3
    la   t4, txt_cin_aluno_usa
    la   t5, txt_cin_resposta
    la   t0, cin_txts
    la   t6, txt_cin_aprovado
    sw   t6, 8(t0)
    j    ic_guarda

    # ---- um monstrinho (a1 = tipo) ----
ic_monstro:
    slli t2, a1, 2
    la   t1, imagens_monstros
    add  t1, t1, t2
    lw   t1, 0(t1)                     # 16 x 16, 6 vezes maior = 96 x 96
    li   t3, 6
    slli t2, a1, 3
    la   t0, cin_monstros
    add  t0, t0, t2
    lw   t4, 0(t0)
    lw   t5, 4(t0)
    j    ic_guarda

    # ---- espinhos / curto-circuito (a1 = número do bloco) ----
ic_perigo:
    slli t2, a1, 2
    la   t1, blocos
    add  t1, t1, t2
    lw   t1, 0(t1)                     # o desenho do bloco, 6 vezes maior
    li   t3, 6
    addi t2, a1, -28                   # 28 = espinhos, 29 = curto-circuito
    slli t2, t2, 3
    la   t0, cin_perigos
    add  t0, t0, t2
    lw   t4, 0(t0)
    lw   t5, 4(t0)
    j    ic_guarda

    # ---- o cronômetro zerou ----
ic_tempo:
    la   t1, img_relogio               # 32 x 32, triplicado = 96 x 96
    li   t3, 3
    la   t4, txt_cin_relogio_usa
    la   t5, txt_cin_relogio_golpe
    la   t0, cin_txts
    la   t6, txt_cin_reprovou_falta
    sw   t6, 8(t0)
    la   t0, cin_res_escala            # texto comprido: um pouco menor
    li   t6, 2
    sw   t6, 0(t0)

ic_guarda:
    la   t0, cin_img
    sw   t1, 0(t0)
    la   t0, cin_escala
    sw   t3, 0(t0)
    la   t0, cin_txts
    sw   t4, 0(t0)
    sw   t5, 4(t0)
    li   a0, ESTADO_CINEMA
    call mudar_estado
    call parar_musica
    la   a0, SFX_ESPECIAL              # "vuuush"
    call tocar_som
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# estado_cinema: um quadro do filminho
# --------------------------------------------------------------------------
estado_cinema:
    addi sp, sp, -28
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    sw   s5, 20(sp)
    sw   s6, 24(sp)

    la   t0, estado_timer
    lw   s2, 0(t0)                     # s2 = quadro do filminho
    la   t0, cin_vitoria
    lw   s6, 0(t0)                     # s6 = 1 vitória, 0 derrota

    li   t0, 30                        # ENTER pula
    blt  s2, t0, cin_segue
    li   a0, T_ENTER
    call tecla_nova
    beqz a0, cin_segue
    li   s2, CIN_FIM
cin_segue:
    li   t0, CIN_FIM
    bge  s2, t0, cin_terminar

    li   t0, CIN_CORTE                 # som do clarão
    bne  s2, t0, cin_desenha
    la   a0, SFX_IMPACTO
    call tocar_som

cin_desenha:
    call frame_escondido
    mv   s1, a0                        # s1 = frame de destino
    call desenhar_cena                 # a luta congelada...
    mv   a0, s1
    call escurecer_frame               # ...e escurecida

    # altura das faixas pretas: entram no começo e saem no fim
    li   t0, 4
    mul  s3, s2, t0
    li   t0, CIN_FIM
    sub  t0, t0, s2
    slli t0, t0, 2
    ble  s3, t0, cin_barra_max
    mv   s3, t0
cin_barra_max:
    li   t0, CIN_BARRA
    ble  s3, t0, cin_partes
    mv   s3, t0

cin_partes:
    li   t0, CIN_ENTRA
    blt  s2, t0, cin_barras            # ainda só as faixas pretas
    li   t0, CIN_CORTE
    blt  s2, t0, cin_parte1
    addi t0, t0, CIN_CLARAO
    bge  s2, t0, cin_parte2
    mv   a0, s1                        # clarão
    li   a1, COR_BRANCO
    call preencher_frame
    j    cin_barras

    # ---------------- parte 1: o atacante ----------------
cin_parte1:
    addi t0, s2, MENOS_CIN_ENTRA            # a faixa entra pela direita
    li   t1, CIN_VEL_FAIXA
    mul  t0, t0, t1
    li   s4, LARGURA_TELA
    sub  s4, s4, t0
    bgez s4, cin_p1_faixa
    li   s4, 0                         # s4 = x da faixa
cin_p1_faixa:
    li   a0, 0                         # cor da faixa (cin_cores[tipo][0])
    call cin_cor
    mv   a4, a0
    mv   a0, s4
    li   a1, CIN_FAIXA_Y
    li   a2, LARGURA_TELA
    li   a3, CIN_FAIXA_ALT
    mv   a5, s1
    call preencher_retangulo
    mv   a0, s4                        # bordas brancas da faixa
    li   a1, CIN_FAIXA_Y
    call cin_bordas
    li   a0, 1                         # riscos de velocidade
    call cin_cor
    mv   a1, a0
    mv   a0, s4
    call cin_riscos

    # retrato do atacante (vai escorregando devagar para a direita)
    addi t0, s2, MENOS_CIN_ENTRA
    srli t0, t0, 3
    add  a1, s4, t0
    addi a1, a1, 14
    li   a2, CIN_FAIXA_Y
    addi a2, a2, 8
    li   a3, 0
    mv   a4, s1
    la   t0, cin_img                   # retrato de quem atacou (iniciar_cinema)
    lw   a0, 0(t0)
    la   t0, cin_escala
    lw   a5, 0(t0)
    call desenhar_imagem_escala

    bnez s4, cin_barras                # textos só quando a faixa chegou
    li   a0, 0                         # "fulano usa:"
    call cin_texto
    li   a1, 140
    li   a2, 82
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    li   a0, 1                         # nome do golpe, grande
    call cin_texto
    li   a1, 140
    li   a2, 100
    li   a3, COR_AMARELO
    mv   a4, s1
    li   a5, 2
    call desenhar_texto_sombra

    la   t0, cin_proj                  # derrota pelo chefão: projéteis voando embaixo do nome
    lw   t0, 0(t0)
    beqz t0, cin_barras
    li   s5, 0
cin_p1_integrais:
    li   t0, 53
    mul  t0, t0, s5
    li   t1, 4
    mul  t1, t1, s2
    sub  t0, t0, t1
    addi t0, t0, 2040                  # (2040 = 12 x 170: deixa o número positivo)
    li   t1, 170
    remu t0, t0, t1
    addi a1, t0, 140
    andi t1, s5, 1
    slli t1, t1, 3
    li   a2, 150
    sub  a2, a2, t1
    la   a0, cin_proj
    lw   a0, 0(a0)
    li   a3, 0
    mv   a4, s1
    call desenhar_imagem
    addi s5, s5, 1
    li   t0, 4
    blt  s5, t0, cin_p1_integrais
    j    cin_barras

    # ---------------- parte 2: a vítima e o resultado ----------------
cin_parte2:
    li   a0, 2                         # faixa da tela inteira
    call cin_cor
    mv   a4, a0
    li   a0, 0
    li   a1, CIN_FAIXA_Y
    li   a2, LARGURA_TELA
    li   a3, CIN_FAIXA_ALT
    mv   a5, s1
    call preencher_retangulo
    li   a0, 0
    li   a1, CIN_FAIXA_Y
    call cin_bordas
    li   a0, 0
    li   a1, COR_BRANCO
    call cin_riscos

    li   s4, 0                         # tremida: nos primeiros 60 quadros
    li   s5, 0
    li   t0, CIN_CORTE
    addi t0, t0, 60
    bge  s2, t0, cin_p2_retrato
    call aleatorio
    li   t0, 7
    remu s4, a0, t0
    addi s4, s4, -3                    # s4 = tremida em x (-3 a 3)
    call aleatorio
    li   t0, 7
    remu s5, a0, t0
    addi s5, s5, -3                    # s5 = tremida em y
cin_p2_retrato:
    addi a1, s4, 112                   # centralizado: 160 - 48
    addi a2, s5, CIN_FAIXA_Y
    addi a2, a2, 8
    li   a3, 0
    mv   a4, s1
    bnez s6, cin_p2_livro
    la   a0, anim_estudante_dano       # o estudante levando o golpe
    lw   a0, 4(a0)
    li   a5, 3
    call desenhar_imagem_escala
    j    cin_p2_faiscas
cin_p2_livro:
    la   t0, tempo                     # o livro pisca, como quando leva dano
    lw   t0, 0(t0)
    andi t0, t0, 4
    bnez t0, cin_p2_faiscas
    la   a0, chefe_dados               # o chefão pisca, como quando leva dano
    lw   a0, 0(a0)
    lw   a0, CB_IMG(a0)
    li   a5, 2
    call desenhar_imagem_escala

cin_p2_faiscas:                        # faíscas em volta do retrato
    li   s5, 0
cin_p2_faisca:
    call aleatorio
    li   t0, 140
    remu s4, a0, t0
    addi s4, s4, 90                    # s4 = x
    call aleatorio
    li   t0, 104
    remu a1, a0, t0
    addi a1, a1, CIN_FAIXA_Y
    addi a1, a1, 4
    mv   a0, s4
    li   a2, 3
    li   a3, 3
    li   a4, COR_AMARELO
    andi t0, s5, 1
    beqz t0, cin_p2_fcor
    li   a4, COR_BRANCO
cin_p2_fcor:
    mv   a5, s1
    call preencher_retangulo
    addi s5, s5, 1
    li   t0, 10
    blt  s5, t0, cin_p2_faisca

    # ---------------- faixas pretas (e o resultado na de baixo) ----------------
cin_barras:
    li   a0, 0
    li   a1, 0
    li   a2, LARGURA_TELA
    mv   a3, s3
    li   a4, COR_PRETO
    mv   a5, s1
    call preencher_retangulo
    li   a0, 0
    li   a1, ALTURA_TELA
    sub  a1, a1, s3
    li   a2, LARGURA_TELA
    mv   a3, s3
    li   a4, COR_PRETO
    mv   a5, s1
    call preencher_retangulo

    li   t0, CIN_CORTE                 # resultado: um pouco depois do clarão
    addi t0, t0, 20
    blt  s2, t0, cin_mostra
    li   t0, CIN_FIM
    addi t0, t0, -12
    bge  s2, t0, cin_mostra            # (as faixas já estão saindo)
    li   a0, 3
    call cin_cor
    mv   s4, a0
    li   a0, 2
    call cin_texto
    li   a1, CENTRO
    li   a2, 201
    la   t0, cin_res_escala            # texto comprido ("REPROVOU POR FALTA!"): menor
    lw   a5, 0(t0)
    li   t0, 3
    beq  a5, t0, cin_res_y
    li   a2, 207
cin_res_y:
    mv   a3, s4
    mv   a4, s1
    call desenhar_texto
cin_mostra:
    call mostrar_frame
    j    cin_fim

    # ---------------- acabou o filminho ----------------
cin_terminar:
    bnez s6, cin_fim_vitoria
    li   a0, ESTADO_MORTE              # derrota: agora o estudante cai
    call mudar_estado
    j    cin_fim
cin_fim_vitoria:
    li   a0, ESTADO_JOGANDO            # vitória: o livro explode (chefes.s)
    call mudar_estado
    la   a0, SFX_BOSS_DEFEAT
    call tocar_som

cin_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    lw   s5, 20(sp)
    lw   s6, 24(sp)
    addi sp, sp, 28
    ret

# cin_cor: a0 = qual cor (0 a 3)  ->  a0 = cin_cores[tipo][qual]
cin_cor:
    la   t0, cin_vitoria
    lw   t0, 0(t0)
    slli t0, t0, 4
    slli a0, a0, 2
    add  t0, t0, a0
    la   t1, cin_cores
    add  t0, t0, t1
    lw   a0, 0(t0)
    ret

# cin_texto: a0 = qual texto (0 = "Fulano usa:", 1 = golpe, 2 = resultado)
#   ->  a0 = endereço do texto (escolhido por iniciar_cinema)
cin_texto:
    slli a0, a0, 2
    la   t0, cin_txts
    add  t0, t0, a0
    lw   a0, 0(t0)
    ret

# cin_bordas: linhas brancas em cima e embaixo da faixa.  a0 = x, a1 = y
#   (usa s1 = destino)
cin_bordas:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)
    li   a2, LARGURA_TELA
    li   a3, 2
    li   a4, COR_BRANCO
    mv   a5, s1
    call preencher_retangulo
    lw   a0, 4(sp)
    lw   a1, 8(sp)
    addi a1, a1, CIN_FAIXA_ALT
    addi a1, a1, -2
    li   a2, LARGURA_TELA
    li   a3, 2
    li   a4, COR_BRANCO
    mv   a5, s1
    call preencher_retangulo
    lw   ra, 0(sp)
    addi sp, sp, 12
    ret

# cin_riscos: 12 riscos de velocidade sorteados na faixa.  a0 = x da faixa, a1 = cor
#   (usa s1 = destino)
cin_riscos:
    addi sp, sp, -24
    sw   ra, 0(sp)
    sw   s4, 4(sp)
    sw   s5, 8(sp)
    sw   a0, 12(sp)                    # x da faixa
    sw   a1, 16(sp)                    # cor
    li   s5, 12
cr2_loop:
    call aleatorio
    li   t0, LARGURA_TELA
    remu s4, a0, t0
    lw   t0, 12(sp)
    add  s4, s4, t0                    # s4 = x do risco
    call aleatorio
    li   t0, 100
    remu t1, a0, t0
    addi t1, t1, CIN_FAIXA_Y
    addi t1, t1, 6
    sw   t1, 20(sp)                    # y do risco
    call aleatorio
    li   t0, 60
    remu a2, a0, t0
    addi a2, a2, 20                    # comprimento
    mv   a0, s4
    lw   a1, 20(sp)
    li   a3, 1
    lw   a4, 16(sp)
    mv   a5, s1
    call preencher_retangulo
    addi s5, s5, -1
    bnez s5, cr2_loop
    lw   ra, 0(sp)
    lw   s4, 4(sp)
    lw   s5, 8(sp)
    addi sp, sp, 24
    ret


# --------------------------------------------------------------------------
# escurecer_frame: deixa a tela inteira com metade do brilho.  a0 = frame
#   Cor BBGGGRRR: cada canal dividido por 2 = deslocar 1 bit para a direita e
#   apagar o bit que "vazou" de um canal para o outro (máscara 01011011 = 0x5B).
#   Fazemos 4 pixels de uma vez (uma word).
# --------------------------------------------------------------------------
escurecer_frame:
    li   t1, TAMANHO_TELA
    add  t1, a0, t1
    li   t2, 0x5B5B5B5B
ef_loop:
    lw   t0, 0(a0)
    srli t0, t0, 1
    and  t0, t0, t2
    sw   t0, 0(a0)
    addi a0, a0, 4
    blt  a0, t1, ef_loop
    ret


# --------------------------------------------------------------------------
# desenhar_imagem_escala: igual a desenhar_imagem, mas cada pixel vira um
#   quadrado de 'escala' x 'escala' (para os retratos grandes do filminho)
#   a0 = imagem   a1 = x   a2 = y   a3 = espelhar   a4 = destino   a5 = escala
# --------------------------------------------------------------------------
desenhar_imagem_escala:
    addi sp, sp, -48
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   s2, 12(sp)
    sw   s3, 16(sp)
    sw   s4, 20(sp)
    sw   s5, 24(sp)
    sw   s6, 28(sp)
    sw   s7, 32(sp)
    sw   s8, 36(sp)
    sw   s9, 40(sp)
    lw   s1, 0(a0)                     # s1 = largura
    lw   s2, 4(a0)                     # s2 = altura
    addi s0, a0, 8                     # s0 = pixels
    mv   s3, a1                        # s3 = x
    mv   s4, a2                        # s4 = y
    mv   s5, a3                        # s5 = espelhar
    mv   s6, a4                        # s6 = destino
    mv   s7, a5                        # s7 = escala
    li   s8, 0                         # s8 = linha
die_linha:
    bge  s8, s2, die_fim
    li   s9, 0                         # s9 = coluna
die_coluna:
    bge  s9, s1, die_prox_linha
    mv   t0, s9
    beqz s5, die_le
    sub  t0, s1, s9
    addi t0, t0, -1
die_le:
    mul  t1, s8, s1
    add  t0, t0, t1
    add  t0, t0, s0
    lbu  a4, 0(t0)                     # a4 = cor
    li   t1, COR_TRANSPARENTE
    beq  a4, t1, die_prox
    mul  a0, s9, s7
    add  a0, a0, s3
    mul  a1, s8, s7
    add  a1, a1, s4
    mv   a2, s7
    mv   a3, s7
    mv   a5, s6
    call preencher_retangulo
die_prox:
    addi s9, s9, 1
    j    die_coluna
die_prox_linha:
    addi s8, s8, 1
    j    die_linha
die_fim:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    lw   s3, 16(sp)
    lw   s4, 20(sp)
    lw   s5, 24(sp)
    lw   s6, 28(sp)
    lw   s7, 32(sp)
    lw   s8, 36(sp)
    lw   s9, 40(sp)
    addi sp, sp, 48
    ret
