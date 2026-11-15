############################################################################
#  CHEFÕES E PROJÉTEIS DOS INIMIGOS
#
#  O chefão da fase vem do campo F_CHEFE do registro da fase (CHEFE_STEWART,
#  CHEFE_GRAFO ou CHEFE_PROFESSOR). Ele só aparece quando o estudante entra na
#  arena (verificar_arena, em fases.s).
#
#  Os três chefões usam o MESMO código; o que muda entre eles está num
#  registro de dados (chefe_stewart, chefe_grafo, chefe_professor, no fim
#  deste arquivo): desenhos, vida, de quanto em quanto tempo pergunta, quantos
#  projéteis joga, velocidade, perguntas, textos e música. Para deixar um
#  chefão mais fácil ou mais difícil é só mexer nos números do registro dele.
#
#  Estados de um chefão (chefe_estado):
#     CH_INATIVO   ainda não apareceu
#     CH_ENTRADA   descendo do alto da tela, com o nome dele escrito
#     CH_LUTA      andando e atacando
#     CH_ABRINDO   abre (desenho "aberto") e treme antes de fazer uma pergunta
#     CH_GOLPE     levou dano (pisca)
#     CH_MORRENDO  explodindo; no fim a fase é concluída
#
#  Como se vence: a cada "intervalo" ele faz uma pergunta da matéria.
#  Acerto = o chefão perde 1 vida; erro = o estudante perde 1 coração.
#  Quanto menos vida o chefão tem, mais rápido ele ataca ("raiva").
#
#     chefão              fase   vida  pergunta a cada  projéteis por ataque
#     Livro do Stewart     1      3        8,0 s          1 integral (reta)
#     O Grafo              2      4        7,0 s          2 setas (em leque)
#     Professor de AOC     3      5        6,5 s          3 bits 0/1 (em leque)
#
#  Projétil (TAM_PROJ bytes):  +0 x  +4 y  (pixels, no mundo)
#      +8 vy (1/16 px por quadro)  +12 resto de y  +16 ativo
#      +20 vx (1/16 px por quadro) +24 resto de x  +28 imagem (8 x 16)
############################################################################

.eqv CH_INATIVO        0
.eqv CH_ENTRADA        1
.eqv CH_LUTA           2
.eqv CH_ABRINDO        3
.eqv CH_GOLPE          4
.eqv CH_MORRENDO       5

.eqv CHEFE_NENHUM      0
.eqv CHEFE_STEWART     1
.eqv CHEFE_GRAFO       2
.eqv CHEFE_PROFESSOR   3

.eqv CHEFE_LARG        48              # todos os chefões têm 48 x 48
.eqv CHEFE_Y           36              # altura onde ele voa
.eqv CHEFE_ATAQUE_MIN  24              # nunca ataca mais rápido que isto (quadros)

# campos do registro de um chefão
.eqv CB_IMG            0               # desenho normal (48 x 48)
.eqv CB_IMG_ABERTO     4               # desenho perguntando / atacando forte
.eqv CB_VIDA           8               # acertos para vencer
.eqv CB_PRIMEIRA       12              # quadros até a primeira pergunta
.eqv CB_INTERVALO      16              # quadros entre as perguntas seguintes
.eqv CB_ATAQUE         20              # quadros entre ataques (com vida cheia)
.eqv CB_RAIVA          24              # quantos quadros o ataque acelera por vida perdida
.eqv CB_TIROS          28              # projéteis por ataque (1, 2 ou 3)
.eqv CB_ABERTURA       32              # velocidade de lado dos projéteis do leque (1/16 px)
.eqv CB_VEL            36              # pixels por quadro andando de um lado para o outro
.eqv CB_PROJ           40              # desenho do projétil
.eqv CB_PROJ2          44              # desenho alternativo (alterna com o outro)
.eqv CB_PERGUNTAS      48              # tabela de perguntas (dados/perguntas.s)
.eqv CB_NOME           52              # nome grande da entrada e do alto da tela
.eqv CB_SUB            56              # "Chefão de ..."
.eqv CB_PERG_TITULO    60              # título da tela de pergunta
.eqv CB_CERTO          64              # texto de quando o estudante acerta
.eqv CB_CIN_USA        68              # filminho da derrota: "Fulano usa:"
.eqv CB_CIN_GOLPE      72              # filminho da derrota: nome do golpe
.eqv CB_MUSICA         76              # música da luta (rotinas/musica.s)
.eqv CB_COR_NOME       80              # cor do nome grande na entrada

.eqv MAX_PROJ          12
.eqv TAM_PROJ          32

.data
.align 2
chefe_estado:     .word 0
chefe_dados:      .word 0              # registro do chefão desta fase (chefe_stewart...)
chefe_x:          .word 0              # canto superior esquerdo, no mundo
chefe_y:          .word 0
chefe_dir:        .word 1
chefe_vida:       .word 0
chefe_timer:      .word 0              # uso geral de cada estado
chefe_ataque:     .word 0              # quadros até o próximo ataque
chefe_pergunta:   .word 0              # quadros até a próxima pergunta
chefe_aux:        .word 0              # rascunho
chefe_ataques:    .word 0              # quantos ataques já fez (alterna os desenhos dos projéteis)
projeteis:        .space 384           # MAX_PROJ * TAM_PROJ

# registro de cada chefão, na ordem dos números CHEFE_* (0 = nenhum)
tabela_chefes:    .word 0, chefe_stewart, chefe_grafo, chefe_professor

# ---------------- Livro do Stewart (Fase 1: Cálculo 1) ----------------
chefe_stewart:
.word img_chefe_stewart_fechado, img_chefe_stewart_aberto
.word 3                                # vida
.word 300, 480                         # 1ª pergunta em 5 s; depois a cada 8 s
.word 80, 18                           # ataque a cada 80 quadros, 18 mais rápido por acerto
.word 1, 0                             # 1 integral, caindo reta
.word 1                                # anda 1 pixel por quadro
.word img_proj_integral, img_proj_integral
.word perguntas_calculo
.word txt_stewart_nome, txt_stewart_sub, txt_pergunta_titulo, txt_pergunta_certo
.word txt_cin_stewart_usa, txt_cin_prova
.word musica_chefe
.word COR_VERMELHO_CLARO

# ---------------- O Grafo (Fase 2: AED) ----------------
chefe_grafo:
.word img_chefe_grafo, img_chefe_grafo_aberto
.word 4                                # vida
.word 300, 420                         # 1ª pergunta em 5 s; depois a cada 7 s
.word 72, 10                           # ataque a cada 72 quadros, 10 mais rápido por acerto
.word 2, 7                             # 2 setas, abrindo em leque
.word 1
.word img_proj_seta, img_proj_seta
.word perguntas_aed
.word txt_grafo_nome, txt_grafo_sub, txt_grafo_pergunta, txt_grafo_certo
.word txt_cin_grafo_usa, txt_cin_grafo_golpe
.word musica_chefe
.word 0xD6                             # rosa

# ---------------- Professor de AOC (Fase 3: AOC, chefão final) ----------------
chefe_professor:
.word img_chefe_professor, img_chefe_professor_aberto
.word 5                                # vida
.word 300, 390                         # 1ª pergunta em 5 s; depois a cada 6,5 s
.word 64, 8                            # ataque a cada 64 quadros, 8 mais rápido por acerto
.word 3, 6                             # 3 bits (0 e 1), em leque
.word 2                                # anda 2 pixels por quadro
.word img_proj_bit1, img_proj_bit0
.word perguntas_aoc
.word txt_professor_nome, txt_professor_sub, txt_professor_pergunta, txt_professor_certo
.word txt_cin_professor_usa, txt_cin_professor_golpe
.word musica_chefe_final
.word COR_AMARELO

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

# chefe_campo: a0 = campo (CB_*)  ->  a0 = valor desse campo do chefão atual
chefe_campo:
    la   t0, chefe_dados
    lw   t0, 0(t0)
    add  t0, t0, a0
    lw   a0, 0(t0)
    ret


# --------------------------------------------------------------------------
# chefe_iniciar: o estudante entrou na arena; o chefão da fase aparece
# --------------------------------------------------------------------------
chefe_iniciar:
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t0, F_CHEFE(t0)
    beqz t0, ci_fim                    # fase sem chefão
    slli t0, t0, 2
    la   t1, tabela_chefes
    add  t1, t1, t0
    lw   t1, 0(t1)
    la   t0, chefe_dados
    sw   t1, 0(t0)
    lw   t2, CB_VIDA(t1)
    la   t0, chefe_vida
    sw   t2, 0(t0)
    la   t0, arena_x0
    lw   t1, 0(t0)
    addi t1, t1, 136                   # aparece no meio da arena
    la   t0, chefe_x
    sw   t1, 0(t0)
    la   t0, chefe_y
    li   t1, -48                       # começa acima da tela
    sw   t1, 0(t0)
    la   t0, chefe_dir
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, chefe_estado
    li   t1, CH_ENTRADA
    sw   t1, 0(t0)
    la   t0, chefe_timer
    sw   zero, 0(t0)
    la   t0, chefe_ataques
    sw   zero, 0(t0)
    la   t0, perguntas_usadas          # perguntas novas para esta luta
    sw   zero, 0(t0)
    addi sp, sp, -4
    sw   ra, 0(sp)
    la   a0, SFX_CHEFE_ENTRA           # acorde ameaçador da entrada
    call tocar_som
    li   a0, CB_MUSICA                 # troca para a música da luta
    call chefe_campo
    call tocar_musica
    lw   ra, 0(sp)
    addi sp, sp, 4
ci_fim:
    ret


# --------------------------------------------------------------------------
# atualizar_chefe: um quadro do chefão
# --------------------------------------------------------------------------
atualizar_chefe:
    la   t0, chefe_estado
    lw   t1, 0(t0)
    beqz t1, ac2_fim
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    la   t0, chefe_dados
    lw   s1, 0(t0)                     # s1 = registro do chefão
    li   t2, CH_ENTRADA
    beq  t1, t2, ch_entrada
    li   t2, CH_LUTA
    beq  t1, t2, ch_luta
    li   t2, CH_ABRINDO
    beq  t1, t2, ch_abrindo
    li   t2, CH_GOLPE
    beq  t1, t2, ch_golpe
    li   t2, CH_MORRENDO
    beq  t1, t2, ch_morrendo
    j    ch_fim

    # ---- descendo do alto ----
ch_entrada:
    la   t0, chefe_y
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    li   t2, CHEFE_Y
    blt  t1, t2, ch_fim
    la   t0, chefe_estado
    li   t1, CH_LUTA
    sw   t1, 0(t0)
    la   t0, chefe_ataque
    li   t1, 60
    sw   t1, 0(t0)
    la   t0, chefe_pergunta
    lw   t1, CB_PRIMEIRA(s1)
    sw   t1, 0(t0)
    j    ch_fim

    # ---- voando e atacando ----
ch_luta:
    la   t0, chefe_x                   # anda de um lado para o outro
    lw   t1, 0(t0)
    la   t2, chefe_dir
    lw   t3, 0(t2)
    lw   t6, CB_VEL(s1)
    mul  t6, t6, t3
    add  t1, t1, t6
    la   t4, arena_x0
    lw   t4, 0(t4)
    addi t5, t4, 16                    # limite da esquerda
    bgt  t1, t5, ch_lim_dir
    mv   t1, t5
    li   t3, 1
    sw   t3, 0(t2)
ch_lim_dir:
    addi t5, t4, 256                   # limite da direita: 320 - 16 - 48
    blt  t1, t5, ch_x_ok
    mv   t1, t5
    li   t3, -1
    sw   t3, 0(t2)
ch_x_ok:
    sw   t1, 0(t0)
    la   t0, tempo                     # balança para cima e para baixo
    lw   t1, 0(t0)
    srli t1, t1, 2
    andi t1, t1, 31
    la   t2, tabela_onda
    add  t2, t2, t1
    lb   t1, 0(t2)
    srai t1, t1, 1
    addi t1, t1, CHEFE_Y
    la   t0, chefe_y
    sw   t1, 0(t0)

    la   t0, chefe_ataque              # hora de atacar?
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, ch_pergunta
    lw   t2, CB_VIDA(s1)               # quanto menos vida, mais rápido ataca
    la   t3, chefe_vida
    lw   t3, 0(t3)
    sub  t2, t2, t3                    # t2 = vidas perdidas
    lw   t3, CB_RAIVA(s1)
    mul  t2, t2, t3
    lw   t1, CB_ATAQUE(s1)
    sub  t1, t1, t2
    li   t2, CHEFE_ATAQUE_MIN
    bge  t1, t2, ch_ataque_ok
    mv   t1, t2
ch_ataque_ok:
    sw   t1, 0(t0)
    call chefe_atacar
    la   a0, SFX_CHEFE_TIRO            # assobio do projétil caindo
    call tocar_som
ch_pergunta:
    la   t0, chefe_pergunta            # hora da pergunta?
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, ch_fim
    la   t0, chefe_estado
    li   t1, CH_ABRINDO
    sw   t1, 0(t0)
    la   t0, chefe_timer
    li   t1, 50
    sw   t1, 0(t0)
    la   a0, SFX_CHEFE_ABRE            # suspense: vem pergunta!
    call tocar_som
    call limpar_projeteis
    j    ch_fim

    # ---- abrindo: treme e depois pergunta ----
ch_abrindo:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, ch_fim
    lw   a0, CB_PERGUNTAS(s1)
    call iniciar_pergunta
    j    ch_fim

    # ---- levou um golpe: pisca ----
ch_golpe:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    bgtz t1, ch_fim
    j    ch_volta_luta

    # ---- derrotado: explode e cai ----
ch_morrendo:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    li   t2, 160
    bge  t1, t2, ch_venceu
    andi t2, t1, 7
    bnez t2, ch_cai
    call aleatorio                     # uma explosão num ponto qualquer do chefão
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
ch_cai:
    la   t0, chefe_timer
    lw   t1, 0(t0)
    li   t2, 60
    blt  t1, t2, ch_fim
    la   t0, chefe_y
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    j    ch_fim
ch_venceu:
    la   t0, chefe_estado
    sw   zero, 0(t0)
    call concluir_fase
    j    ch_fim

ch_volta_luta:
    la   t0, chefe_estado
    li   t1, CH_LUTA
    sw   t1, 0(t0)
    la   t0, chefe_pergunta
    lw   t1, CB_INTERVALO(s1)
    sw   t1, 0(t0)
    la   t0, chefe_ataque
    li   t1, 60
    sw   t1, 0(t0)
ch_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
ac2_fim:
    ret


# --------------------------------------------------------------------------
# chefe_atacar: lança os projéteis de um ataque (CB_TIROS deles, em leque)
#   Com n projéteis, o i-ésimo (i = 0 .. n-1) sai com velocidade de lado
#       vx = (2i - (n - 1)) x CB_ABERTURA
#   ou seja: 1 = reto; 2 = um para cada lado; 3 = esquerda, reto e direita.
#   Os desenhos alternam entre CB_PROJ e CB_PROJ2 (os bits 0 e 1 do Professor).
# --------------------------------------------------------------------------
chefe_atacar:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    la   t0, chefe_dados
    lw   s1, 0(t0)
    lw   s3, CB_TIROS(s1)              # s3 = n
    li   s2, 0                         # s2 = i
    la   t0, chefe_ataques
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
cat_loop:
    bge  s2, s3, cat_fim
    slli a2, s2, 1                     # vx = (2i - (n-1)) * abertura
    sub  a2, a2, s3
    addi a2, a2, 1
    lw   t0, CB_ABERTURA(s1)
    mul  a2, a2, t0
    lw   a3, CB_PROJ(s1)               # desenho: alterna entre os dois
    la   t0, chefe_ataques
    lw   t0, 0(t0)
    add  t0, t0, s2
    andi t0, t0, 1
    beqz t0, cat_img
    lw   a3, CB_PROJ2(s1)
cat_img:
    la   t0, chefe_x
    lw   a0, 0(t0)
    addi a0, a0, 20                    # sai do meio de baixo do chefão
    la   t0, chefe_y
    lw   a1, 0(t0)
    addi a1, a1, 40
    call lancar_projetil
    addi s2, s2, 1
    j    cat_loop
cat_fim:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    addi sp, sp, 16
    ret


# --------------------------------------------------------------------------
# chefe_resposta: chamada pela tela de pergunta quando ela fecha
#   a0 = 1 se o estudante acertou, 0 se errou
# --------------------------------------------------------------------------
chefe_resposta:
    addi sp, sp, -4
    sw   ra, 0(sp)
    beqz a0, cr_errou
    la   t0, chefe_vida                # acertou: o chefão perde uma vida
    lw   t1, 0(t0)
    addi t1, t1, -1
    sw   t1, 0(t0)
    la   t2, chefe_timer
    blez t1, cr_derrotado
    li   t3, 60
    sw   t3, 0(t2)
    la   t0, chefe_estado
    li   t3, CH_GOLPE
    sw   t3, 0(t0)
    la   a0, SFX_BOSS_HIT              # som do golpe no chefão
    call tocar_som
    j    cr_particulas
cr_derrotado:
    sw   zero, 0(t0)                   # (vida não fica negativa)
    sw   zero, 0(t2)
    la   t0, chefe_estado
    li   t3, CH_MORRENDO
    sw   t3, 0(t0)
    call limpar_projeteis              # nenhum projétil acerta o estudante depois
    li   a0, CINEMA_VITORIA            # golpe final: passa o "filminho"
    call iniciar_cinema                #   (no fim dele o chefão explode)
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
    li   a0, CB_INTERVALO
    call chefe_campo
    la   t0, chefe_pergunta
    sw   a0, 0(t0)
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
    la   t0, chefe_dados
    lw   t0, 0(t0)
    lw   a0, CB_IMG(t0)
    li   t2, CH_ENTRADA
    beq  t1, t2, dc_pos
    li   t2, CH_LUTA
    beq  t1, t2, dc_pos
    lw   a0, CB_IMG_ABERTO(t0)
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
    li   a3, 0                         # (não espelha: os desenhos têm letras)
    call desenhar_imagem
dc_sai:
    lw   ra, 0(sp)
    addi sp, sp, 4
dc_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_hud_chefe: nome do chefão e páginas de vida (no alto da tela)
#   a0 = frame de destino.  Durante a entrada, escreve o nome grande no meio.
#   As "páginas" de vida ficam centralizadas: uma por vida (20 de largura + 4).
# --------------------------------------------------------------------------
desenhar_hud_chefe:
    la   t0, chefe_estado
    lw   t1, 0(t0)
    beqz t1, dhc_fim
    addi sp, sp, -20
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    mv   s1, a0
    la   t0, chefe_dados
    lw   s3, 0(t0)                     # s3 = registro do chefão
    li   t2, CH_ENTRADA
    bne  t1, t2, dhc_barra
    lw   a0, CB_NOME(s3)               # entrada: nome grande
    li   a1, CENTRO
    li   a2, 92
    lw   a3, CB_COR_NOME(s3)
    mv   a4, s1
    li   a5, 2
    call desenhar_texto_sombra
    lw   a0, CB_SUB(s3)
    li   a1, CENTRO
    li   a2, 122
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    j    dhc_sai
dhc_barra:
    lw   a0, CB_NOME(s3)               # nome pequeno no alto
    li   a1, CENTRO
    li   a2, 4
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto_sombra
    lw   t0, CB_VIDA(s3)               # s4 = x da primeira página: 162 - 12 x vida
    li   t1, 12
    mul  t0, t0, t1
    li   s4, 162
    sub  s4, s4, t0
    li   s2, 0                         # páginas de vida: um retângulo por vida
dhc_pag:
    lw   t0, CB_VIDA(s3)
    bge  s2, t0, dhc_sai
    li   t0, 24
    mul  a0, s2, t0
    add  a0, a0, s4
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
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    addi sp, sp, 20
dhc_fim:
    ret


# --------------------------------------------------------------------------
# lancar_projetil: cria um projétil caindo a partir de (a0, a1)
#   a2 = velocidade de lado (1/16 px por quadro; 0 = cai reto)   a3 = desenho
# --------------------------------------------------------------------------
lancar_projetil:
    la   t0, projeteis
    li   t1, MAX_PROJ
lp2_procura:
    lw   t2, 16(t0)
    beqz t2, lp2_achou
    addi t0, t0, TAM_PROJ
    addi t1, t1, -1
    bnez t1, lp2_procura
    ret                                # nenhum livre: não lança
lp2_achou:
    sw   a0, 0(t0)
    sw   a1, 4(t0)
    li   t2, 8
    sw   t2, 8(t0)
    sw   zero, 12(t0)
    li   t2, 1
    sw   t2, 16(t0)
    sw   a2, 20(t0)
    sw   zero, 24(t0)
    sw   a3, 28(t0)
    ret


# --------------------------------------------------------------------------
# atualizar_projeteis: caem (e andam de lado); somem no chão ou na parede;
#   machucam o estudante
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
    lw   t1, 20(s1)                    # de lado: resto += vx; anda a parte inteira
    lw   t2, 24(s1)
    add  t2, t2, t1
    srai t3, t2, 4
    slli t4, t3, 4
    sub  t2, t2, t4
    sw   t2, 24(s1)
    lw   t2, 0(s1)
    add  t2, t2, t3
    sw   t2, 0(s1)
    lw   a0, 0(s1)                     # bateu no chão (ou na parede)?
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
    lw   a0, 28(s1)
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
