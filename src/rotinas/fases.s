############################################################################
#  FASES
#
#  Cada fase é um registro em dados/fases.s (veja os campos F_* no main.s).
#  carregar_fase lê o registro e deixa tudo pronto: mapa, monstros, estudante,
#  câmera, chefão. A variável fase_atual guarda o endereço do registro.
############################################################################

.text

# --------------------------------------------------------------------------
# carregar_fase: a0 = endereço do registro da fase
# --------------------------------------------------------------------------
carregar_fase:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    mv   s1, a0

    la   t0, fase_atual
    sw   s1, 0(t0)
    lw   t1, F_MAPA(s1)
    la   t0, mapa_atual
    sw   t1, 0(t0)

    # estudante
    lw   t1, F_INICIO_X(s1)
    la   t0, jogador_x
    sw   t1, 0(t0)
    lw   t1, F_INICIO_Y(s1)
    la   t0, jogador_y
    sw   t1, 0(t0)
    la   t0, jogador_vidas
    li   t1, VIDAS_INICIAIS
    sw   t1, 0(t0)
    la   t0, jogador_vy
    sw   zero, 0(t0)
    la   t0, jogador_frac_x
    sw   zero, 0(t0)
    la   t0, jogador_frac_y
    sw   zero, 0(t0)
    la   t0, jogador_no_chao
    sw   zero, 0(t0)
    la   t0, jogador_espelhar
    sw   zero, 0(t0)
    la   t0, jogador_anda
    sw   zero, 0(t0)
    la   t0, jogador_invuln
    sw   zero, 0(t0)
    la   t0, jogador_empurrao
    sw   zero, 0(t0)
    la   t0, chao_timer
    sw   zero, 0(t0)
    la   t0, pulo_buffer
    sw   zero, 0(t0)
    la   t0, item_energetico
    sw   zero, 0(t0)
    la   t0, jogador_oculto
    sw   zero, 0(t0)

    # mundo
    lw   a0, F_MONSTROS(s1)
    call iniciar_monstros
    la   t0, arena_ativa
    sw   zero, 0(t0)
    la   t0, camera_ultimo
    li   t1, 99999                     # força o cenário a ser redesenhado
    sw   t1, 0(t0)
    call limpar_particulas
    call parar_musica
    call chefe_reiniciar
    call atualizar_camera              # câmera já no lugar certo (senão os monstros
                                       # "aparecem" com a câmera que o menu deixou)

    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret


# --------------------------------------------------------------------------
# atualizar_camera: centraliza a câmera no estudante (sem sair do mapa).
#   Na arena do chefão a câmera fica parada no começo da arena.
#   Se a câmera mudou de lugar, redesenha o cenário no buffer 'fundo'.
# --------------------------------------------------------------------------
atualizar_camera:
    addi sp, sp, -4
    sw   ra, 0(sp)

    la   t0, arena_ativa
    lw   t0, 0(t0)
    beqz t0, ac_segue
    la   t0, arena_x0
    lw   t1, 0(t0)
    j    ac_guarda
ac_segue:
    la   t0, jogador_x
    lw   t1, 0(t0)
    addi t1, t1, -152                  # x - 160 + 8: estudante no centro

    la   t0, mapa_atual
    lw   t0, 0(t0)
    lw   t2, 0(t0)                     # largura do mapa em blocos
    slli t2, t2, 4                     # ... em pixels
    li   t3, LARGURA_TELA
    sub  t2, t2, t3                    # t2 = maior valor possível da câmera
    ble  t1, t2, ac_max_ok
    mv   t1, t2
ac_max_ok:
    bgez t1, ac_guarda
    li   t1, 0
ac_guarda:
    la   t0, camera_x
    sw   t1, 0(t0)

    la   t0, camera_ultimo
    lw   t2, 0(t0)
    la   t3, nuvem_x
    lw   t4, 0(t3)
    la   t5, nuvem_ultimo
    lw   t6, 0(t5)
    bne  t1, t2, ac_refaz              # a câmera mexeu: refaz o fundo
    beq  t4, t6, ac_fim                # nem câmera nem nuvens mexeram
ac_refaz:
    sw   t1, 0(t0)
    sw   t4, 0(t5)
    call redesenhar_fundo

ac_fim:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

# redesenhar_fundo: cenário da fase + blocos do mapa, no buffer 'fundo'
redesenhar_fundo:
    addi sp, sp, -4
    sw   ra, 0(sp)
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t0, F_CENARIO(t0)             # cada fase tem a sua rotina de cenário
    jalr ra, t0, 0
    la   t0, camera_x
    lw   t1, 0(t0)
    la   t0, mapa_atual
    lw   a0, 0(t0)
    srli a1, t1, 4                     # coluna do mapa na borda esquerda
    andi a2, t1, 15                    # pixels da coluna que já saíram da tela
    call desenhar_mapa
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# verificar_arena: o estudante entrou na arena do chefão?
#   Fecha a arena (parede invisível à esquerda), trava a câmera e chama o chefão.
# --------------------------------------------------------------------------
verificar_arena:
    la   t0, arena_ativa
    lw   t0, 0(t0)
    bnez t0, va_fim
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t1, F_ARENA(t0)
    beqz t1, va_fim                    # fase sem chefão
    slli t1, t1, 4                     # t1 = x do começo da arena
    la   t2, jogador_x
    lw   t2, 0(t2)
    addi t3, t1, ENTRADA_ARENA
    blt  t2, t3, va_fim                # ainda não entrou
    la   t0, arena_x0
    sw   t1, 0(t0)
    la   t0, arena_ativa
    li   t1, 1
    sw   t1, 0(t0)
    tail chefe_iniciar
va_fim:
    ret


# --------------------------------------------------------------------------
# PORTA DA UNIFESP (fim do treino)
#   No lugar da bandeira, o treino termina num prediozinho da UNIFESP.
#   Quando o estudante encosta na porta (com os pés no chão), a porta abre,
#   ele anda até o meio dela e entra; a porta fecha e aparece "treino concluído"
#   (como nos jogos de plataforma em que o herói entra no castelo).
#
#   Registro da porta (campo F_META da fase):
#       .word x, y     x = canto esquerdo do prédio, y = chão (base do prédio), em pixels
#   O desenho é a tabela predio_unifesp (retângulos), mais a porta e o letreiro.
# --------------------------------------------------------------------------
.eqv PREDIO_LARG      64
.eqv PREDIO_ALT       72
.eqv PORTA_DX         22               # porta: posição dentro do prédio
.eqv PORTA_LARG       20
.eqv PORTA_ALT        34
.eqv PORTA_ESPERA     50               # quadros depois de fechar até "treino concluído"
.eqv MENOS_PORTA_ALT  -34              # (o assembler não aceita "-PORTA_ALT")
.eqv MENOS_PREDIO_ALT -72

.eqv COR_PREDIO       0xB7             # parede creme
.eqv COR_PREDIO_BASE  0x6D
.eqv COR_PREDIO_AZUL  0xD1             # telhado, ameias e molduras
.eqv COR_LETREIRO     0x60             # verde do letreiro
.eqv COR_JANELA       0xF5
.eqv COR_MADEIRA      0x0C
.eqv COR_MADEIRA_ESC  0x0A

.data
.align 2
porta_abertura:   .word 0              # 0 = fechada ... PORTA_LARG = toda aberta
porta_fase:       .word 0              # 0 abrindo, 1 andando, 2 fechando, 3 esperando
porta_timer:      .word 0

# retângulos do prédio:  .word dx, dy, largura, altura, cor
# (dx, dy a partir do canto de cima do prédio; termina com largura 0)
predio_unifesp:
.word  0, -8, 10,  8, COR_PREDIO_AZUL  # ameias (como um castelinho)
.word 18, -8, 10,  8, COR_PREDIO_AZUL
.word 36, -8, 10,  8, COR_PREDIO_AZUL
.word 54, -8, 10,  8, COR_PREDIO_AZUL
.word -2,  0, 68,  6, COR_PREDIO_AZUL  # telhado
.word  0,  6, 64, 66, COR_PREDIO       # parede
.word  0, 66, 64,  6, COR_PREDIO_BASE  # rodapé
.word  5, 10, 54, 16, COR_PRETO        # letreiro
.word  6, 11, 52, 14, COR_LETREIRO
.word  5, 32, 12, 12, COR_PREDIO_AZUL  # janela da esquerda
.word  7, 34,  8,  8, COR_JANELA
.word  7, 37,  8,  2, COR_PREDIO_AZUL
.word 47, 32, 12, 12, COR_PREDIO_AZUL  # janela da direita
.word 49, 34,  8,  8, COR_JANELA
.word 49, 37,  8,  2, COR_PREDIO_AZUL
.word 19, 34, 26, 38, COR_PREDIO_AZUL  # moldura da porta
.word 22, 38, 20, 34, COR_PRETO        # lado de dentro (escuro)
.word  0,  0,  0,  0, 0

.text

# --------------------------------------------------------------------------
# verificar_meta: o estudante encostou na porta (de pé no chão)? -> entra
# --------------------------------------------------------------------------
verificar_meta:
    la   t0, estado_jogo               # (morreu neste quadro: não entra)
    lw   t0, 0(t0)
    li   t1, ESTADO_JOGANDO
    bne  t0, t1, vm_fim
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t0, F_META(t0)
    beqz t0, vm_fim                    # fase sem porta
    la   t1, jogador_no_chao
    lw   t1, 0(t1)
    beqz t1, vm_fim                    # só entra andando, não no meio do pulo
    addi sp, sp, -4
    sw   ra, 0(sp)
    lw   a0, 0(t0)
    addi a0, a0, PORTA_DX              # esquerda da porta
    addi a2, a0, PORTA_LARG
    addi a2, a2, -1                    # direita
    lw   a3, 4(t0)
    addi a3, a3, -1                    # base
    addi a1, a3, MENOS_PORTA_ALT            # topo
    addi a1, a1, 1
    call encosta_no_jogador
    beqz a0, vm_sai
    call iniciar_porta
vm_sai:
    lw   ra, 0(sp)
    addi sp, sp, 4
vm_fim:
    ret

# iniciar_porta: começa a entrada pela porta
iniciar_porta:
    addi sp, sp, -4
    sw   ra, 0(sp)
    li   a0, ESTADO_PORTA
    call mudar_estado
    la   t0, porta_abertura
    sw   zero, 0(t0)
    la   t0, porta_fase
    sw   zero, 0(t0)
    la   t0, porta_timer
    sw   zero, 0(t0)
    la   t0, jogador_vy
    sw   zero, 0(t0)
    la   t0, jogador_invuln            # para de piscar
    sw   zero, 0(t0)
    la   t0, jogador_empurrao
    sw   zero, 0(t0)
    la   t0, jogador_anda
    sw   zero, 0(t0)
    la   a0, SFX_FLAG                  # arpejo + acorde
    call tocar_som
    call parar_musica
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret


# --------------------------------------------------------------------------
# estado_porta: a porta abre, o estudante entra, a porta fecha
# --------------------------------------------------------------------------
estado_porta:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    la   t0, porta_fase
    lw   t1, 0(t0)
    li   t2, 1
    beq  t1, t2, epo_anda
    li   t2, 2
    beq  t1, t2, epo_fecha
    li   t2, 3
    beq  t1, t2, epo_espera

    # ---- 0) abrindo ----
    la   t3, porta_abertura
    lw   t4, 0(t3)
    addi t4, t4, 1
    sw   t4, 0(t3)
    li   t5, PORTA_LARG
    blt  t4, t5, epo_desenha
    li   t1, 1
    sw   t1, 0(t0)
    j    epo_desenha

    # ---- 1) andando até o meio da porta ----
epo_anda:
    la   t3, fase_atual
    lw   t3, 0(t3)
    lw   t3, F_META(t3)
    lw   t3, 0(t3)
    addi t3, t3, PORTA_DX              # alvo: meio do estudante no meio da porta
    addi t3, t3, 2                     # (22 + 10 - 8)
    la   t4, jogador_x
    lw   t5, 0(t4)
    la   t6, jogador_anda
    lw   s1, 0(t6)
    addi s1, s1, 1                     # anima a corrida
    sw   s1, 0(t6)
    beq  t5, t3, epo_entrou
    la   t6, jogador_espelhar
    blt  t5, t3, epo_dir
    addi t5, t5, -1
    li   s1, 1
    sw   s1, 0(t6)
    j    epo_x
epo_dir:
    addi t5, t5, 1
    sw   zero, 0(t6)
epo_x:
    sw   t5, 0(t4)
    j    epo_desenha
epo_entrou:
    li   t1, 2
    sw   t1, 0(t0)
    la   t0, jogador_oculto            # sumiu lá dentro
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, jogador_anda
    sw   zero, 0(t0)
    la   t0, fase_atual                # confete na porta
    lw   t0, 0(t0)
    lw   t0, F_META(t0)
    lw   a0, 0(t0)
    addi a0, a0, 32
    lw   a1, 4(t0)
    addi a1, a1, -40
    li   a2, COR_AMARELO
    li   a3, 16
    call explodir
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t0, F_META(t0)
    lw   a0, 0(t0)
    addi a0, a0, 32
    lw   a1, 4(t0)
    addi a1, a1, -40
    li   a2, COR_VERDE
    li   a3, 16
    call explodir
    j    epo_desenha

    # ---- 2) fechando ----
epo_fecha:
    la   t3, porta_abertura
    lw   t4, 0(t3)
    addi t4, t4, -1
    sw   t4, 0(t3)
    bgtz t4, epo_desenha
    li   t1, 3
    sw   t1, 0(t0)
    j    epo_desenha

    # ---- 3) um tempinho com a porta fechada; depois "treino concluído" ----
epo_espera:
    la   t3, porta_timer
    lw   t4, 0(t3)
    addi t4, t4, 1
    sw   t4, 0(t3)
    li   t5, PORTA_ESPERA
    blt  t4, t5, epo_desenha
    call concluir_fase

epo_desenha:
    call atualizar_particulas
    call atualizar_camera
    call frame_escondido
    call desenhar_cena
    call mostrar_frame
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret

# concluir_fase: mostra a tela de fase concluída
concluir_fase:
    la   t0, estado_jogo
    li   t1, ESTADO_CONCLUIDA
    sw   t1, 0(t0)
    la   t0, estado_timer
    sw   zero, 0(t0)
    ret


# --------------------------------------------------------------------------
# desenhar_porta: o prédio da UNIFESP com a porta.  a0 = frame de destino
# --------------------------------------------------------------------------
desenhar_porta:
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t6, F_META(t0)
    beqz t6, dpo_fim
    lw   t1, 0(t6)                     # x no mundo
    la   t0, camera_x
    lw   t2, 0(t0)
    sub  t1, t1, t2                    # x na tela
    addi t2, t1, PREDIO_LARG
    addi t2, t2, 2
    blez t2, dpo_fim                   # saiu pela esquerda
    li   t2, LARGURA_TELA
    bge  t1, t2, dpo_fim               # ainda não chegou na tela
    addi sp, sp, -20
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    mv   s1, a0                        # s1 = destino
    mv   s2, t1                        # s2 = x do prédio na tela
    lw   s3, 4(t6)
    addi s3, s3, MENOS_PREDIO_ALT           # s3 = y do topo do prédio

    la   s4, predio_unifesp            # os retângulos da tabela
dpo_ret:
    lw   a2, 8(s4)
    beqz a2, dpo_letreiro
    lw   a0, 0(s4)
    add  a0, a0, s2
    lw   a1, 4(s4)
    add  a1, a1, s3
    lw   a3, 12(s4)
    lw   a4, 16(s4)
    mv   a5, s1
    call preencher_retangulo
    addi s4, s4, 20
    j    dpo_ret

dpo_letreiro:
    addi a1, s2, 11                    # "UNIFESP" (7 letras x 6 = 42 pixels)
    bltz a1, dpo_folha                 # (só escreve se couber inteiro na tela)
    li   t0, 278
    bgt  a1, t0, dpo_folha
    la   a0, txt_unifesp
    addi a2, s3, 12
    li   a3, COR_BRANCO
    mv   a4, s1
    li   a5, 1
    call desenhar_texto

    # a folha da porta: vai sumindo da direita para a esquerda (dobradiça na esquerda)
dpo_folha:
    la   t0, porta_abertura
    lw   t0, 0(t0)
    li   s4, PORTA_LARG
    sub  s4, s4, t0                    # s4 = largura da folha que ainda aparece
    blez s4, dpo_sai
    addi a0, s2, PORTA_DX
    addi a1, s3, PREDIO_ALT
    addi a1, a1, MENOS_PORTA_ALT
    mv   a2, s4
    li   a3, PORTA_ALT
    li   a4, COR_MADEIRA
    mv   a5, s1
    call preencher_retangulo
    li   t0, 8
    blt  s4, t0, dpo_sai               # folha fininha: sem detalhes
    addi a0, s2, PORTA_DX              # almofadas da porta
    addi a0, a0, 3
    addi a1, s3, PREDIO_ALT
    addi a1, a1, MENOS_PORTA_ALT
    addi a1, a1, 4
    addi a2, s4, -6
    li   a3, 11
    li   a4, COR_MADEIRA_ESC
    mv   a5, s1
    call preencher_retangulo
    addi a0, s2, PORTA_DX
    addi a0, a0, 3
    addi a1, s3, PREDIO_ALT
    addi a1, a1, -15
    addi a2, s4, -6
    li   a3, 11
    li   a4, COR_MADEIRA_ESC
    mv   a5, s1
    call preencher_retangulo
    addi a0, s2, PORTA_DX              # maçaneta
    add  a0, a0, s4
    addi a0, a0, -4
    addi a1, s3, PREDIO_ALT
    addi a1, a1, -18
    li   a2, 2
    li   a3, 3
    li   a4, COR_AMARELO
    mv   a5, s1
    call preencher_retangulo
dpo_sai:
    lw   ra, 0(sp)
    lw   s1, 4(sp)
    lw   s2, 8(sp)
    lw   s3, 12(sp)
    lw   s4, 16(sp)
    addi sp, sp, 20
dpo_fim:
    ret


# --------------------------------------------------------------------------
# desenhar_dica: no treino, mostra no alto da tela a dica do trecho onde
#   o estudante está.  a0 = frame de destino
#   Tabela da fase (F_DICAS):  .word x_inicio, x_fim, texto   ...   0, 0, 0
# --------------------------------------------------------------------------
desenhar_dica:
    la   t0, fase_atual
    lw   t0, 0(t0)
    lw   t1, F_DICAS(t0)
    beqz t1, dd_fim
    la   t2, jogador_x
    lw   t2, 0(t2)
dd_loop:
    lw   t3, 8(t1)
    beqz t3, dd_fim                    # acabou a tabela
    lw   t4, 0(t1)
    blt  t2, t4, dd_prox
    lw   t4, 4(t1)
    bge  t2, t4, dd_prox
    addi sp, sp, -4                    # achou: escreve
    sw   ra, 0(sp)
    mv   a4, a0
    mv   a0, t3
    li   a1, CENTRO
    li   a2, 26
    li   a3, COR_AMARELO
    li   a5, 1
    call desenhar_texto_sombra
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret
dd_prox:
    addi t1, t1, 12
    j    dd_loop
dd_fim:
    ret
