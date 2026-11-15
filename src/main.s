############################################################################
#  JOGO DO ESTUDANTE UNIFESP  -  Assembly RISC-V (simulador FPGRARS)
#
#  Tela inicial -> explicação (história e controles) -> treino no campus
#  -> FASE 1: CÁLCULO 1 (chefão: Livro do Stewart)
#  -> FASE 2: AED       (chefão: O Grafo)
#  -> FASE 3: AOC       (chefão final: o Professor) -> formatura.
#  Os chefões são vencidos respondendo perguntas da matéria.
#
#  Controles:  A / D ou setas = andar    W / seta p/ cima / ESPAÇO = pular
#              1, 2, 3, 4 = responder                     ENTER = confirmar
#              M = liga/desliga o som      ESC = sair
#
#  ATENÇÃO (ecall): no fpgrars.exe do Windows, cada ecall deixa um resto na pilha do
#  simulador e, depois de alguns milhares, o programa cai com "has overflowed its
#  stack". Por isso o jogo NÃO usa ecall: o relógio é lido com csrr, a espera é
#  ocupada e o texto é desenhado com a fonte própria (rotinas/texto.s).
#  As únicas ecalls são a de sair (ESC) e a de som (ecall 31, MIDI), que tem um
#  limite de notas por partida (veja rotinas/sfx.s).
#
#  Como a tela funciona no FPGRARS:
#    - 320 x 240 pixels, 1 byte por pixel (cor no formato BBGGGRRR)
#    - existem DOIS frames de vídeo: 0xFF000000 e 0xFF100000
#    - o byte em 0xFF200604 escolhe qual frame aparece na janela
#    Desenhamos sempre no frame que está ESCONDIDO e depois trocamos
#    (double buffering). Assim a tela não pisca.
#
#  Organização:
#    main.s               constantes, variáveis, laço principal, estados
#    rotinas/telas.s      menu, explicação, transição, jogo, morte, game over...
#    rotinas/cinema.s     "filminho" do golpe final contra o chefão
#    rotinas/sfx.s        efeitos sonoros (MIDI)
#    rotinas/jogador.s    movimento (com frações de pixel), pulo, dano, morte
#    rotinas/colisao.s    blocos sólidos, colisões
#    rotinas/monstros.s   monstros que andam, pulam e voam
#    rotinas/chefes.s     Livro do Stewart e os projéteis dele
#    rotinas/perguntas.s  tela de pergunta
#    rotinas/fases.s      carregar fase, câmera, arena, porta da UNIFESP, dicas
#    rotinas/texto.s      escrever na tela, painéis
#    rotinas/efeitos.s    partículas, números aleatórios
#    rotinas/video.s      desenhar imagem, mapa, copiar fundo
#    rotinas/cenario.s    cenários de fundo (campus, sala de aula, laboratório, circuito)
#    rotinas/debug.s      atalhos de teste (DEBUG_ATALHOS)
#    rotinas/teclado.s    leitura do teclado
#    dados/fases.s        a lista de fases
#    dados/monstros.s     onde ficam os monstros de cada fase
#    dados/textos.s       todos os textos do jogo
#    dados/perguntas.s    perguntas dos chefões
#    dados/fonte.s        a fonte, desenhada em texto ('#' = pixel aceso)
#    dados/graficos.s     sprites, cenário e mapas, desenhados em texto (uma letra por pixel)
#    dados/graficos_fases23.s  os desenhos e mapas das Fases 2 e 3 (mesmo formato)
#    rotinas/desenhos.s   monta esses desenhos quando o jogo abre (montar_desenhos)
############################################################################

# ------------------------------ teste -------------------------------------
# Para testar rápido, mude FASE_TESTE:
#   0 = jogo normal (tela inicial)    1 = começa no treino
#   2 = começa na Fase 1 (Cálculo)    3 = começa na arena do Livro do Stewart
#   4 = começa na Fase 2 (AED)        5 = começa na arena do Grafo
#   6 = começa na Fase 3 (AOC)        7 = começa na arena do Professor
.eqv FASE_TESTE       0
#
# Atalhos de teste no teclado (veja rotinas/debug.s): 1 = ligados, 0 = desligados.
#   5/6/7/8 vão para o treino / Fase 1 / Fase 2 / Fase 3;  9 = arena do chefão;
#   0 = vence a fase;  I = invencível;  V = corações;  K = mata os monstros;
#   J = pulo infinito;  G = posição;  N = morre;  B = golpe no chefão;
#   P = pergunta agora;  C = (na pergunta) responde a certa;  T = só 5 s no cronômetro.
# MUDE PARA 0 ANTES DE ENTREGAR O JOGO.
.eqv DEBUG_ATALHOS    1

# ------------------------------ constantes --------------------------------
.eqv LARGURA_TELA     320
.eqv ALTURA_TELA      240
.eqv TAMANHO_TELA     76800          # 320 * 240
.eqv TAM_BLOCO        16
.eqv COLUNAS_TELA     20             # 320 / 16
.eqv LINHAS_TELA      15             # 240 / 16

.eqv VIDEO_FRAME0     0xFF000000
.eqv SELETOR_FRAME    0xFF200604

.eqv MS_POR_QUADRO    16             # ~60 quadros por segundo
.eqv NUVEM_VOLTA      480            # as nuvens dão a volta depois de andar isto (pixels)

# cores (formato BBGGGRRR: 3 bits de vermelho, 3 de verde, 2 de azul)
.eqv COR_TRANSPARENTE 0xC7           # pixels com esta cor não são desenhados
.eqv COR_PRETO        0x00
.eqv COR_BRANCO       0xFF
.eqv COR_AMARELO      0x3F
.eqv COR_CINZA        0xB6
.eqv COR_VERDE        0x38
.eqv COR_VERDE_ESCURO 0x10
.eqv COR_VERMELHO_CLARO 0x17
.eqv COR_VERMELHO_ESCURO 0x03
.eqv COR_PAINEL       0x49           # azul-marinho das caixas de texto
.eqv COR_FUNDO_TRANSICAO 0x40
.eqv COR_PAGINA       0xF7           # páginas de vida do Livro do Stewart
.eqv COR_PAGINA_VAZIA 0x52

# ---- teclado (veja rotinas/teclado.s) ----
.eqv MAPA_TECLAS   0xFF200520
.eqv KD_CONTROLE   0xFF200000      # teclado "buffer de caractere" (veja ler_teclado)

.eqv SC_ESC        1
.eqv SC_1          2
.eqv SC_2          3
.eqv SC_3          4
.eqv SC_4          5
.eqv SC_5          6       # 5 a 0 e as letras abaixo: atalhos de teste (debug.s)
.eqv SC_6          7
.eqv SC_7          8
.eqv SC_8          9
.eqv SC_9          10
.eqv SC_0          11
.eqv SC_T          20
.eqv SC_I          23
.eqv SC_P          25
.eqv SC_G          34
.eqv SC_J          36
.eqv SC_K          37
.eqv SC_V          47
.eqv SC_N          49
.eqv SC_W          17
.eqv SC_ENTER      28     # Enter (igual no Windows e no Linux)
.eqv SC_A          30
.eqv SC_D          32
.eqv SC_C          46
.eqv SC_B          48
.eqv SC_M          50      # M = liga/desliga o som
.eqv SC_ESPACO     57
.eqv SC_CIMA_WIN   72      # seta para cima (Windows)
.eqv SC_ESQ_WIN    75      # seta esquerda (Windows)
.eqv SC_DIR_WIN    77      # seta direita  (Windows)
.eqv SC_CIMA_LINUX 103     # seta para cima (Linux)
.eqv SC_ESQ_LINUX  105     # seta esquerda (Linux)
.eqv SC_DIR_LINUX  106     # seta direita  (Linux)

# bits das teclas do jogo (em teclas_agora / teclas_novas)
.eqv T_ESQ         1       # A ou seta esquerda
.eqv T_DIR         2       # D ou seta direita
.eqv T_PULO        4       # W, seta para cima ou ESPAÇO
.eqv T_ENTER       8
.eqv T_ESC         16
.eqv T_RESP_A      32      # tecla 1 (resposta A)
.eqv T_RESP_B      64      # tecla 2 (resposta B)
.eqv T_RESP_C      128     # tecla 3 (resposta C)
.eqv T_RESP_D      256     # tecla 4 (resposta D)
.eqv T_MUDO        512     # M (som)
# atalhos de teste (rotinas/debug.s; só funcionam com DEBUG_ATALHOS = 1)
.eqv T_DBG_TREINO   1024     # 5
.eqv T_DBG_FASE1    2048     # 6
.eqv T_DBG_FASE2    4096     # 7
.eqv T_DBG_FASE3    8192     # 8
.eqv T_DBG_CHEFE    16384    # 9
.eqv T_DBG_VENCER   32768    # 0
.eqv T_DBG_INVENC   65536    # I
.eqv T_DBG_VIDA     131072   # V
.eqv T_DBG_MATAR    262144   # K
.eqv T_DBG_GOLPE    524288   # B
.eqv T_DBG_PERGUNTA 1048576  # P
.eqv T_DBG_MORRER   2097152  # N
.eqv T_DBG_INFO     4194304  # G
.eqv T_DBG_PULO     8388608  # J
.eqv T_DBG_CERTA    16777216 # C
.eqv T_DBG_TEMPO    33554432 # T

# ---- movimento do estudante (em 1/16 de pixel; veja jogador.s) ----
.eqv VEL_ANDAR        22             # 1,375 pixel por quadro
.eqv VEL_ANDAR_RAPIDO 32             # com energético (próximas fases)
.eqv VEL_EMPURRAO     28             # empurrão do dano
.eqv GRAVIDADE        9              # quanto a velocidade de queda cresce por quadro
.eqv GRAVIDADE_SOLTO  9              # gravidade extra subindo sem segurar o pulo
.eqv VEL_QUEDA_MAX    112            # 7 pixels por quadro, no máximo
.eqv FORCA_PULO       124            # sobe ~56 pixels (3 blocos e meio)
.eqv FORCA_PULO_RAPIDO 138
.eqv PULO_BUFFER      6              # quadros que um pulo apertado cedo fica guardado
.eqv PULO_COYOTE      5              # quadros para ainda pular depois de sair da beirada
.eqv QUIQUE_PISAO     96             # impulso para cima ao pisar num monstro
.eqv QUIQUE_DANO      64             # pulinho ao levar dano
.eqv MORTE_SALTO      104            # salto da animação de morte
.eqv MORTE_QUADROS    120            # duração da animação de morte (2 s)

# ---- monstros ----
.eqv MAX_MONSTROS     24
.eqv TAM_MONSTRO      48
.eqv COMP_ANDA        0
.eqv COMP_PULA        1
.eqv COMP_VOA         2
.eqv MONSTRO_VEL_ANDA 12             # 0,75 pixel por quadro
.eqv MONSTRO_VEL_PULA 10
.eqv MONSTRO_VEL_VOA  10
.eqv MONSTRO_GRAVIDADE 8
.eqv MONSTRO_PULO_FORCA 88           # pulo de ~30 pixels
.eqv MONSTRO_PULO_INTERVALO 70
# tipos (posição em imagens_monstros, dados/monstros.s)
.eqv TIPO_CALCULO     0
.eqv TIPO_AOC         1
.eqv TIPO_INTEGRAL    2
.eqv TIPO_LIM         3
.eqv TIPO_DERIVADA    4
.eqv TIPO_PONTEIRO    5              # Fase 2 (AED): voa
.eqv TIPO_PILHA       6              #               anda
.eqv TIPO_NO          7              #               pula (nó de grafo)
.eqv TIPO_BIT         8              # Fase 3 (AOC): pula
.eqv TIPO_BUG         9              #               voa
.eqv TIPO_PORTA       10             #               anda (porta lógica)

# ---- vidas e dano ----
.eqv VIDAS_INICIAIS   3
.eqv INVULN_QUADROS   90             # invencibilidade depois do dano (1,5 s)
.eqv EMPURRAO_QUADROS 10

# ---- estados do jogo (tabela_estados) ----
.eqv ESTADO_MENU      0
.eqv ESTADO_HISTORIA  1
.eqv ESTADO_TRANSICAO 2
.eqv ESTADO_JOGANDO   3
.eqv ESTADO_PERGUNTA  4
.eqv ESTADO_MORTE     5
.eqv ESTADO_GAME_OVER 6
.eqv ESTADO_CONCLUIDA 7
.eqv ESTADO_PORTA    8          # entrando pela porta da UNIFESP (fim do treino)
.eqv ESTADO_CINEMA   9          # "filminho" do golpe final contra o chefão
.eqv CINEMA_DERROTA  0          # tipos de filminho (rotinas/cinema.s)
.eqv CINEMA_VITORIA  1
.eqv CINEMA_MONSTRO  2          # um monstrinho derrotou o estudante
.eqv CINEMA_PERIGO   3          # espinhos / curto-circuito derrotaram o estudante
.eqv CINEMA_TEMPO    4          # o cronômetro zerou: "REPROVOU POR FALTA!"

# ---- do que o estudante morreu (morte_causa) ----
.eqv CAUSA_NENHUMA   0
.eqv CAUSA_MONSTRO   1          # morte_info = tipo do monstro
.eqv CAUSA_PERIGO    2          # morte_info = número do bloco
.eqv CAUSA_TEMPO     3

# ---- campos do registro de uma fase (dados/fases.s) ----
.eqv F_MAPA           0
.eqv F_MONSTROS       4
.eqv F_META           8              # porta de chegada (0 = sem porta)
.eqv F_INICIO_X       12
.eqv F_INICIO_Y       16
.eqv F_ARENA          20             # coluna onde começa a arena (0 = sem chefão)
.eqv F_CHEFE          24
.eqv F_TIRO           28             # tiro liberado (próximas fases)
.eqv F_CENARIO        32             # rotina que desenha o fundo
.eqv F_NOME           36             # "FASE 1"
.eqv F_TITULO         40             # "CÁLCULO 1"
.eqv F_FRASE          44             # frase da tela de transição
.eqv F_DICAS          48             # dicas na tela (0 = nenhuma)
.eqv F_PROXIMA        52             # próxima fase (0 = volta ao menu)
.eqv F_CONCLUIDA      56             # texto da tela de fase concluída
.eqv F_MUSICA         60             # música de fundo (rotinas/musica.s; 0 = nenhuma)
.eqv F_VEL_MONSTROS   64             # velocidade a mais dos monstros (1/16 px por quadro)
.eqv F_TEMPO          68             # tempo da fase, em segundos (0 = sem cronômetro)
.eqv ENTRADA_ARENA    40             # pixels dentro da arena para ela fechar

# Hitbox do estudante (a caixa usada nas colisões), relativa ao ponto (jogador_x, jogador_y).
# x vai de 2 a 13 (12 de largura), y de 0 a 27 (28 de altura). O DESENHO (32 x 32)
# fica centralizado na hitbox, com os pés na base dela.
.eqv HIT_X0           2
.eqv HIT_X1           13
.eqv HIT_Y0           0
.eqv HIT_Y1           27
.eqv HIT_MEIO         13
.eqv SPR_OFF_X        8
.eqv SPR_OFF_Y        4

# ------------------------------ variáveis ---------------------------------
.data
.align 2
fundo:            .space TAMANHO_TELA   # cenário já desenhado (cópia rápida a cada quadro)

estado_jogo:      .word ESTADO_MENU
estado_timer:     .word 0              # quadros desde que o estado começou
tempo:            .word 0              # quadros desde o começo do jogo
quadro_inicio:    .word 0              # relógio no começo deste quadro (ms)
frame_visivel:    .word 0              # qual frame está aparecendo agora (0 ou 1)

jogador_x:        .word 0              # posição NO MUNDO (pixels)
jogador_y:        .word 0
jogador_vy:       .word 0              # velocidade vertical (1/16 px; negativo = subindo)
jogador_frac_x:   .word 0              # restos de pixel (veja jogador.s)
jogador_frac_y:   .word 0
jogador_no_chao:  .word 0
chao_timer:       .word 0              # quadros desde que saiu do chão
pulo_buffer:      .word 0
jogador_espelhar: .word 0              # 0 = olhando p/ direita, 1 = p/ esquerda
jogador_anda:     .word 0              # contador para a animação de andar
jogador_vidas:    .word VIDAS_INICIAIS
jogador_invuln:   .word 0
jogador_empurrao: .word 0
jogador_empurrao_dir: .word 0
item_energetico:  .word 0              # quadros de energético (próximas fases)
jogador_oculto:   .word 0              # 1 = não desenha (entrou pela porta)

monstros_total:   .word 0
monstros:         .space 1152          # MAX_MONSTROS * TAM_MONSTRO
monstros_vel_extra: .word 0            # da fase atual (F_VEL_MONSTROS)
fase_tempo:       .word 0              # cronômetro: quadros que faltam (60 por segundo)
morte_causa:      .word 0              # do que o estudante morreu (CAUSA_*)
morte_info:       .word 0              # tipo do monstro ou número do bloco

fase_atual:       .word 0              # endereço do registro da fase
mapa_atual:       .word 0
camera_x:         .word 0              # pixel do mundo na borda esquerda da tela
camera_ultimo:    .word 99999          # câmera do último desenho do 'fundo'
nuvem_x:          .word 0              # deriva das nuvens (andam sozinhas)
nuvem_ultimo:     .word 0
arena_ativa:      .word 0              # 1 = arena do chefão fechada
arena_x0:         .word 0              # x do começo da arena

# ordem dos desenhos do "parado" (cada item dura 8 quadros): 0 = normal, 1 = respirando, 2 = piscando
idle_sequencia:   .byte 0,0,0,0,1,1,1,1,0,0,0,2,0,0,0,0
.align 2

tabela_estados:
.word estado_menu, estado_historia, estado_transicao, estado_jogando
.word estado_pergunta, estado_morte, estado_game_over, estado_concluida
.word estado_porta, estado_cinema

# ------------------------------ programa ----------------------------------
.text
main:
    call montar_desenhos               # transforma os desenhos em texto em imagens (rotinas/desenhos.s)
    call misturar_semente
    la   a0, fase_tutorial
    call carregar_fase                 # o campus aparece por trás do menu

    li   t0, FASE_TESTE                # começar direto numa fase (teste)
    beqz t0, loop_jogo
    addi t0, t0, -1
    slli t0, t0, 3
    la   t1, fases_teste               # tabela em rotinas/debug.s
    add  t1, t1, t0
    lw   a0, 0(t1)                     # a fase
    lw   a1, 4(t1)                     # 1 = já na porta da arena do chefão
    call debug_ir_fase

loop_jogo:
    csrr t0, time                      # início deste quadro (relógio em ms; sem ecall)
    la   t1, quadro_inicio
    sw   t0, 0(t1)

    call ler_teclado
    li   a0, T_ESC                     # ESC sai de qualquer tela
    call tecla_segurada
    beqz a0, lj_contadores
    li   a7, 10
    ecall

lj_contadores:
    li   t0, DEBUG_ATALHOS             # atalhos de teste (rotinas/debug.s)
    beqz t0, lj_tempo
    call atalhos_debug
lj_tempo:
    la   t0, tempo
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    andi t2, t1, 7                     # as nuvens andam sozinhas: 1 pixel a cada 8 quadros
    bnez t2, lj_estado
    la   t0, nuvem_x
    lw   t3, 0(t0)
    addi t3, t3, 1
    li   t4, NUVEM_VOLTA
    blt  t3, t4, lj_nuvem
    li   t3, 0
lj_nuvem:
    sw   t3, 0(t0)

lj_estado:
    la   t0, estado_timer
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    la   t0, estado_jogo               # chama a rotina do estado atual
    lw   t1, 0(t0)
    slli t1, t1, 2
    la   t0, tabela_estados
    add  t0, t0, t1
    lw   t0, 0(t0)
    jalr ra, t0, 0
    call atualizar_som                 # efeitos sonoros (rotinas/sfx.s)

    # Espera o resto do tempo do quadro (espera "ocupada", sem ecall de dormir).
lj_espera:
    csrr t0, time
    la   t1, quadro_inicio
    lw   t1, 0(t1)
    sub  t0, t0, t1
    li   t1, MS_POR_QUADRO
    blt  t0, t1, lj_espera
    j    loop_jogo


# --------------------------------------------------------------------------
# frame_escondido: a0 = endereço do frame de vídeo que NÃO está aparecendo
# --------------------------------------------------------------------------
frame_escondido:
    la   t0, frame_visivel
    lw   t1, 0(t0)
    xori t1, t1, 1
    slli t1, t1, 20
    li   a0, VIDEO_FRAME0
    add  a0, a0, t1
    ret

# mostrar_frame: troca os frames (o que acabamos de desenhar passa a aparecer)
mostrar_frame:
    la   t0, frame_visivel
    lw   t1, 0(t0)
    xori t1, t1, 1
    sw   t1, 0(t0)
    li   t0, SELETOR_FRAME
    sb   t1, 0(t0)
    ret

# --------------------------------------------------------------------------
# preencher_frame: pinta um frame inteiro com uma cor
#   a0 = endereço do frame     a1 = cor (1 byte)
# --------------------------------------------------------------------------
preencher_frame:
    andi a1, a1, 255
    slli t0, a1, 8
    or   a1, a1, t0
    slli t0, a1, 16
    or   a1, a1, t0
    li   t1, TAMANHO_TELA
    add  t1, a0, t1
pf_loop:
    sw   a1, 0(a0)
    addi a0, a0, 4
    blt  a0, t1, pf_loop
    ret


# ------------------------------ outros arquivos ---------------------------
.include "rotinas/teclado.s"
.include "rotinas/video.s"
.include "rotinas/texto.s"
.include "rotinas/desenhos.s"
.include "rotinas/efeitos.s"
.include "rotinas/colisao.s"
.include "rotinas/jogador.s"
.include "rotinas/monstros.s"
.include "rotinas/chefes.s"
.include "rotinas/perguntas.s"
.include "rotinas/fases.s"
.include "rotinas/telas.s"
.include "rotinas/cinema.s"
.include "rotinas/sfx.s"
.include "rotinas/musica.s"
.include "rotinas/cenario.s"
.include "rotinas/debug.s"
.include "dados/fases.s"
.include "dados/monstros.s"
.include "dados/textos.s"
.include "dados/perguntas.s"
.include "dados/fonte.s"
.include "dados/graficos.s"
.include "dados/graficos_fases23.s"

