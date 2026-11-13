############################################################################
#  CHEFÕES E PROJÉTEIS DOS INIMIGOS
#
#  O chefão da fase vem do campo F_CHEFE do registro da fase. Ele só aparece
#  quando o estudante entra na arena (verificar_arena, em fases.s).
#
#  Estados de um chefão (chefe_estado):
#     CH_INATIVO   ainda não apareceu
#     CH_ENTRADA   descendo do alto da tela, com o nome dele escrito
#     CH_LUTA      andando e atacando
#     CH_ABRINDO   o Livro do Stewart abre antes de fazer uma pergunta
#     CH_GOLPE     levou dano (pisca)
#     CH_MORRENDO  explodindo; no fim a fase é concluída
#
#  LIVRO DO STEWART (Cálculo 1)
#     Voa de um lado para o outro e derruba integrais (∫) no estudante.
#     A cada STEWART_PERGUNTA quadros ele abre e faz uma pergunta de Cálculo:
#     acerto = o livro perde 1 página (vida); erro = o estudante perde 1 vida.
#     Com STEWART_VIDA acertos ele é derrotado.
#
#  Projétil (TAM_PROJ bytes):  +0 x  +4 y  (pixels, no mundo)
#                              +8 vy (1/16 px por quadro)  +12 resto de y  +16 ativo
############################################################################

.eqv CH_INATIVO        0
.eqv CH_ENTRADA        1
.eqv CH_LUTA           2
.eqv CH_ABRINDO        3
.eqv CH_GOLPE          4
.eqv CH_MORRENDO       5

.eqv CHEFE_NENHUM      0
.eqv CHEFE_STEWART      1

.eqv STEWART_LARG       48
.eqv STEWART_ALT        48
.eqv STEWART_Y          36              # altura onde ele voa
.eqv STEWART_VIDA       3               # acertos para vencer
.eqv STEWART_PRIMEIRA   300             # primeira pergunta: 5 s depois de aparecer
.eqv STEWART_PERGUNTA   480             # depois: a cada 8 s
.eqv STEWART_ATAQUE     80              # quadros entre integrais (diminui com a raiva)

.eqv MAX_PROJ          10
.eqv TAM_PROJ          20

.data
.align 2
chefe_estado:     .word 0
chefe_x:          .word 0              # canto superior esquerdo, no mundo
chefe_y:          .word 0
chefe_dir:        .word 1
chefe_vida:       .word 0
chefe_timer:      .word 0              # uso geral de cada estado
chefe_ataque:     .word 0              # quadros até o próximo ataque
chefe_pergunta:   .word 0              # quadros até a próxima pergunta
chefe_aux:        .word 0              # rascunho
projeteis:        .space 200           # MAX_PROJ * TAM_PROJ

.text

# --------------------------------------------------------------------------
# chefe_reiniciar: some com o chefão e com os projéteis (ao carregar a fase)
# --------------------------------------------------------------------------
chefe_reiniciar:
    la   t0, chefe_estado
    sw   zero, 0(t0)
    j    limpar_projeteis

limpar_projeteis:
    la   t0, projeteis
    li   t1, MAX_PROJ
lpj_loop:
    sw   zero, 16(t0)
    addi t0, t0, TAM_PROJ
    addi t1, t1, -1
    bnez t1, lpj_loop
    ret


# --------------------------------------------------------------------------
# chefe_iniciar: o estudante entrou na arena; o chefão da fase aparece
# --------------------------------------------------------------------------
chefe_iniciar:
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t0, F_CHEFE(t0)
    li   t1, CHEFE_STEWART
    bne  t0, t1, ci_fim
    la   t0, arena_x0
    lw   t1, 0(t0)
    addi t1, t1, 136                   # aparece no meio da arena
    la   t0, chefe_x
    sw   t1, 0(t0)
    la   t0, chefe_y
    li   t1, -48                       # começa acima da tela (altura do livro)
    sw   t1, 0(t0)
    la   t0, chefe_dir
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, chefe_vida
    li   t1, STEWART_VIDA
    sw   t1, 0(t0)
    la   t0, chefe_estado
    li   t1, CH_ENTRADA
    sw   t1, 0(t0)
    la   t0, chefe_timer
    sw   zero, 0(t0)
    la   t0, perguntas_usadas          # perguntas novas para esta luta
    sw   zero, 0(t0)
    addi sp, sp, -4
    sw   ra, 0(sp)
    la   a0, SFX_CHEFE_ENTRA           # acorde ameaçador da entrada
    call tocar_som
    la   a0, musica_chefe              # troca para a música rápida do chefão
    call tocar_musica
    lw   ra, 0(sp)
    addi sp, sp, 4
ci_fim:
    ret


# --------------------------------------------------------------------------
# atualizar_chefe: um quadro do chefão (só o Stewart existe por enquanto)
# --------------------------------------------------------------------------
atualizar_chefe:
    la   t0, chefe_estado
    lw   t1, 0(t0)
    beqz t1, ac2_fim
    addi sp, sp, -4
    sw   ra, 0(sp)
    call stewart_atualizar
    lw   ra, 0(sp)
    addi sp, sp, 4
ac2_fim:
    ret


# --------------------------------------------------------------------------
# stewart_atualizar
# --------------------------------------------------------------------------
stewart_atualizar:
    addi sp, sp, -4
    sw   ra, 0(sp)
    la   t0, chefe_estado
    lw   t1, 0(t0)
    li   t2, CH_ENTRADA
    beq  t1, t2, st_entrada
    li   t2, CH_LUTA
    beq  t1, t2, st_luta
    li   t2, CH_ABRINDO
    beq  t1, t2, st_abrindo
    li   t2, CH_GOLPE
    beq  t1, t2, st_golpe
    li   t2, CH_MORRENDO
    beq  t1, t2, st_morrendo
    j    st_fim

    # ---- descendo do alto ----
st_entrada:
    la   t0, chefe_y
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    li   t2, STEWART_Y
    blt  t1, t2, st_fim
    la   t0, chefe_estado
    li   t1, CH_LUTA
    sw   t1, 0(t0)
    la   t0, chefe_ataque
    li   t1, 60
    sw   t1, 0(t0)
    la   t0, chefe_pergunta
    li   t1, STEWART_PRIMEIRA
    sw   t1, 0(t0)
    j    st_fim

    # ---- voando e atacando ----
st_luta:
    la   t0, chefe_x                   # anda de um lado para o outro
    lw   t1, 0(t0)
    la   t2, chefe_dir
    lw   t3, 0(t2)
    add  t1, t1, t3
    la   t4, arena_x0
    lw   t4, 0(t4)
    addi t5, t4, 16                    # limite da esquerda
    bgt  t1, t5, st_lim_dir
    li   t3, 1
    sw   t3, 0(t2)
st_lim_dir:
    addi t5, t4, 256                   # limite da direita: 320 - 16 - 48
    blt  t1, t5, st_x_ok
    li   t3, -1
    sw   t3, 0(t2)
st_x_ok:
    sw   t1, 0(t0)
    la   t0, tempo                     # balança para cima e para baixo
    lw   t1, 0(t0)
    srli t1, t1, 2
    andi t1, t1, 31
    la   t2, tabela_onda
    add  t2, t2, t1
    lb   t1, 0(t2)
    srai t1, t1, 1
    addi t1, t1, STEWART_Y
    la   t0, chefe_y
    sw   t1, 0(t0)

    la   t0, chefe_ataque              # hora de derrubar uma integral?
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, st_pergunta
    la   t2, chefe_vida                # quanto menos vida, mais rápido ataca
    lw   t2, 0(t2)
    li   t3, STEWART_VIDA
    sub  t3, t3, t2
    li   t4, 18
    mul  t3, t3, t4
    li   t1, STEWART_ATAQUE
    sub  t1, t1, t3
    sw   t1, 0(t0)
    la   t0, chefe_x
    lw   a0, 0(t0)
    addi a0, a0, 20
    la   t0, chefe_y
    lw   a1, 0(t0)
    addi a1, a1, 40
    call lancar_integral
    la   a0, SFX_CHEFE_TIRO            # assobio da integral caindo
    call tocar_som
st_pergunta:
    la   t0, chefe_pergunta            # hora da pergunta?
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, st_fim
    la   t0, chefe_estado
    li   t1, CH_ABRINDO
    sw   t1, 0(t0)
    la   t0, chefe_timer
    li   t1, 50
    sw   t1, 0(t0)
    la   a0, SFX_CHEFE_ABRE            # suspense: vem pergunta!
    call tocar_som
    call limpar_projeteis
    j    st_fim

    # ---- abrindo: treme e depois pergunta ----
st_abrindo:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, st_fim
    la   a0, perguntas_calculo
    call iniciar_pergunta
    j    st_fim

    # ---- levou um golpe: pisca ----
st_golpe:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, st_fim
    j    st_volta_luta

    # ---- derrotado: explode e cai ----
st_morrendo:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    li   t2, 160
    bge  t1, t2, st_venceu
    andi t2, t1, 7
    bnez t2, st_cai
    call aleatorio                     # uma explosão num ponto qualquer do livro
    andi a0, a0, 31
    la   t0, chefe_aux
    sw   a0, 0(t0)
    call aleatorio
    andi a1, a0, 31
    la   t0, chefe_x
    lw   a0, 0(t0)
    la   t0, chefe_aux
    lw   t0, 0(t0)
    add  a0, a0, t0
    addi a0, a0, 8
    la   t0, chefe_y
    lw   t1, 0(t0)
    add  a1, a1, t1
    addi a1, a1, 8
    li   a2, COR_AMARELO
    li   a3, 10
    call explodir
st_cai:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    li   t2, 60
    blt  t1, t2, st_fim
    la   t0, chefe_y
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    j    st_fim
st_venceu:
    la   t0, chefe_estado
    sw   zero, 0(t0)
    call concluir_fase
    j    st_fim

st_volta_luta:
    la   t0, chefe_estado
    li   t1, CH_LUTA
    sw   t1, 0(t0)
    la   t0, chefe_pergunta
    li   t1, STEWART_PERGUNTA
    sw   t1, 0(t0)
    la   t0, chefe_ataque
    li   t1, 60
    sw   t1, 0(t0)
st_fim:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# chefe_resposta: chamada pela tela de pergunta quando ela fecha
#   a0 = 1 se o estudante acertou, 0 se errou
# --------------------------------------------------------------------------
chefe_resposta:
    addi sp, sp, -4
    sw   ra, 0(sp)
    beqz a0, cr_errou
    la   t0, chefe_vida                # acertou: o livro perde uma página
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    la   t2, chefe_timer
    beqz t1, cr_derrotado
    li   t3, 60
    sw   t3, 0(t2)
    la   t0, chefe_estado
    li   t3, CH_GOLPE
    sw   t3, 0(t0)
    la   a0, SFX_BOSS_HIT              # som do golpe no livro
    call tocar_som
    j    cr_particulas
cr_derrotado:
    sw   zero, 0(t2)
    la   t0, chefe_estado
    li   t3, CH_MORRENDO
    sw   t3, 0(t0)
    call limpar_projeteis              # nenhuma integral acerta o estudante depois
    li   a0, CINEMA_VITORIA            # golpe final: passa o "filminho"
    call iniciar_cinema                #   (no fim dele o livro explode)
cr_particulas:
    la   t0, chefe_x
    lw   a0, 0(t0)
    addi a0, a0, 24
    la   t0, chefe_y
    lw   a1, 0(t0)
    addi a1, a1, 24
    li   a2, COR_BRANCO
    li   a3, 24
    call explodir
    j    cr_fim
cr_errou:
    li   a0, 0                         # errou: perde 1 vida (sem empurrão)
    call dano_jogador
    la   t0, chefe_estado
    li   t1, CH_LUTA
    sw   t1, 0(t0)
    la   t0, chefe_pergunta
    li   t1, STEWART_PERGUNTA
    sw   t1, 0(t0)
    la   t0, chefe_ataque
    li   t1, 60
    sw   t1, 0(t0)
cr_fim:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# desenhar_chefe: a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_chefe:
    la   t0, chefe_estado
    lw   t1, 0(t0)
    beqz t1, dc_fim
    addi sp, sp, -4
    sw   ra, 0(sp)
    mv   a4, a0
    li   t2, CH_GOLPE                  # golpeado: pisca
    bne  t1, t2, dc_imagem
    la   t3, tempo
    lw   t3, 0(t3)
    andi t3, t3, 4
    bnez t3, dc_sai
dc_imagem:
    la   a0, img_chefe_stewart_fechado
    li   t2, CH_ENTRADA
    beq  t1, t2, dc_pos
    li   t2, CH_LUTA
    beq  t1, t2, dc_pos
    la   a0, img_chefe_stewart_aberto
dc_pos:
    la   t0, chefe_x
    lw   a1, 0(t0)
    la   t0, camera_x
    lw   t2, 0(t0)
    sub  a1, a1, t2
    la   t0, chefe_y
    lw   a2, 0(t0)
    li   t2, CH_ABRINDO                # abrindo ou morrendo: treme
    beq  t1, t2, dc_treme
    li   t2, CH_MORRENDO
    bne  t1, t2, dc_desenha
dc_treme:
    la   t3, tempo
    lw   t3, 0(t3)
    andi t3, t3, 2
    add  a1, a1, t3
    addi a1, a1, -1
dc_desenha:
    li   a3, 0                         # (não espelha: a capa tem letras)
    call desenhar_imagem
dc_sai:
    lw   ra, 0(sp)
    addi sp, sp, 4
dc_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_hud_chefe: nome do chefão e páginas de vida (no alto da tela)
#   a0 = frame de destino.  Durante a entrada, escreve o nome grande no meio.
# --------------------------------------------------------------------------
desenhar_hud_chefe:
    la   t0, chefe_estado
    lw   t1, 0(t0)
    beqz t1, dhc_fim
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    mv   s1, a0
    li   t2, CH_ENTRADA
    bne  t1, t2, dhc_barra
    la   a0, txt_stewart_nome           # entrada: nome grande
    li   a1, CENTRO
    li   a2, 92
    li   a3, COR_VERMELHO_CLARO
    mv   a4, s1
    li   a5, 2
    call desenhar_texto_sombra
    la   a0, txt_stewart_sub
    li   a1, CENTRO
    li   a2, 122
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    j    dhc_sai
dhc_barra:
    la   a0, txt_stewart_nome           # nome pequeno no alto
    li   a1, CENTRO
    li   a2, 4
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    li   s2, 0                         # páginas de vida: um retângulo por vida
dhc_pag:
    li   t0, STEWART_VIDA
    bge  s2, t0, dhc_sai
    li   t0, 24
    mul  a0, s2, t0
    addi a0, a0, 126                   # 3 páginas de 20 + 4 de espaço: começa em 126
    li   a1, 18
    li   a2, 20
    li   a3, 12
    li   a4, COR_PAGINA_VAZIA
    la   t0, chefe_vida
    lw   t0, 0(t0)
    bge  s2, t0, dhc_cor
    li   a4, COR_PAGINA
dhc_cor:
    mv   a5, s1
    mv   a6, a4                        # borda da mesma cor: só o contorno preto aparece
    call desenhar_painel
    addi s2, s2, 1
    j    dhc_pag
dhc_sai:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
dhc_fim:
    ret


# --------------------------------------------------------------------------
# lancar_integral: cria um projétil ∫ caindo a partir de (a0, a1)
# --------------------------------------------------------------------------
lancar_integral:
    la   t0, projeteis
    li   t1, MAX_PROJ
li_procura:
    lw   t2, 16(t0)
    beqz t2, li_achou
    addi t0, t0, TAM_PROJ
    addi t1, t1, -1
    bnez t1, li_procura
    ret                                # nenhum livre: não lança
li_achou:
    sw   a0, 0(t0)
    sw   a1, 4(t0)
    li   t2, 8
    sw   t2, 8(t0)
    sw   zero, 12(t0)
    li   t2, 1
    sw   t2, 16(t0)
    ret


# --------------------------------------------------------------------------
# atualizar_projeteis: caem; somem no chão; machucam o estudante
# --------------------------------------------------------------------------
atualizar_projeteis:
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    la   s1, projeteis
    li   s2, MAX_PROJ
apj_loop:
    lw   t0, 16(s1)
    beqz t0, apj_prox
    lw   t1, 8(s1)                     # gravidade
    addi t1, t1, 3
    li   t2, 56
    ble  t1, t2, apj_vy
    mv   t1, t2
apj_vy:
    sw   t1, 8(s1)
    lw   t2, 12(s1)
    add  t2, t2, t1
    srai t3, t2, 4
    slli t4, t3, 4
    sub  t2, t2, t4
    sw   t2, 12(s1)
    lw   t2, 4(s1)
    add  t2, t2, t3
    sw   t2, 4(s1)
    lw   a0, 0(s1)                     # bateu no chão?
    addi a0, a0, 4
    lw   a1, 4(s1)
    addi a1, a1, 15
    call ponto_solido
    beqz a0, apj_jogador
    sw   zero, 16(s1)
    lw   a0, 0(s1)
    addi a0, a0, 4
    lw   a1, 4(s1)
    addi a1, a1, 12
    li   a2, COR_AMARELO
    li   a3, 5
    call explodir
    la   a0, SFX_INTEGRAL_CHAO         # baque no chão
    call tocar_som
    j    apj_prox
apj_jogador:
    lw   a0, 0(s1)
    addi a0, a0, 1
    lw   a1, 4(s1)
    addi a1, a1, 2
    addi a2, a0, 5
    addi a3, a1, 12
    call encosta_no_jogador
    beqz a0, apj_prox
    sw   zero, 16(s1)
    la   t0, jogador_x
    lw   t1, 0(t0)
    lw   t2, 0(s1)
    li   a0, 1
    bge  t1, t2, apj_dano
    li   a0, -1
apj_dano:
    call dano_jogador
apj_prox:
    addi s1, s1, TAM_PROJ
    addi s2, s2, -1
    bnez s2, apj_loop
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    addi sp, sp, 12
    ret


# --------------------------------------------------------------------------
# desenhar_projeteis: a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_projeteis:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    mv   s3, a0
    la   s1, projeteis
    li   s2, MAX_PROJ
dpj_loop:
    lw   t0, 16(s1)
    beqz t0, dpj_prox
    la   a0, img_proj_integral
    lw   a1, 0(s1)
    la   t0, camera_x
    lw   t0, 0(t0)
    sub  a1, a1, t0
    lw   a2, 4(s1)
    li   a3, 0
    mv   a4, s3
    call desenhar_imagem
dpj_prox:
    addi s1, s1, TAM_PROJ
    addi s2, s2, -1
    bnez s2, dpj_loop
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret
