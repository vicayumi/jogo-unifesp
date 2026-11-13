############################################################################
#  MONTAR OS DESENHOS (roda UMA vez, no começo do jogo)
#
#  Os gráficos do jogo são desenhados em texto dentro do próprio assembly
#  (dados/graficos.s e dados/fonte.s): uma letra por pixel. Esta rotina
#  transforma esse texto no formato que as rotinas de desenho usam:
#
#  1) IMAGENS (tabela_desenhos: imagem, paleta, imagem, paleta, ..., 0)
#     A paleta é uma lista de pares  letra, cor  terminada em 0:
#          pal_xxx: .byte '.',0xC7, 'K',0x00, 'R',0x07, 0
#     Com ela montamos uma tabela de tradução de 256 bytes (traducao[letra] = cor)
#     e trocamos, NO PRÓPRIO LUGAR, cada letra da imagem pela sua cor.
#     (1 letra = 1 byte = 1 pixel, então a imagem não muda de tamanho e o
#      .word largura, altura do começo continua valendo.)
#
#  2) MAPAS (tabela_mapas: mapa, mapa, ..., 0)
#     Cada letra vira o número do bloco:  '.' = 0,  '1'..'9' = 1..9,
#     'A'..'Z' = 10..35  (minúsculas valem o mesmo que maiúsculas).
#
#  3) FONTE (desenho_fonte: código, 12 linhas de 5 letras, ..., -1)
#     Cada linha de 5 letras ('#' = aceso) vira 1 byte: bit 4 = coluna da
#     esquerda ... bit 0 = coluna da direita. O resultado vai para 'fonte'
#     (256 letras x 12 bytes), que texto.s usa.
#
#  ATENÇÃO: como a troca é feita no próprio lugar, montar_desenhos só pode
#  rodar uma vez (se rodasse de novo, trataria as cores como se fossem letras).
############################################################################

.data
traducao:       .space 256              # letra -> cor (refeita para cada imagem)

.text

montar_desenhos:
    # ---------------- 1) imagens ----------------
    la   a0, tabela_desenhos
md_imagem:
    lw   a1, 0(a0)                     # a1 = imagem
    beqz a1, md_mapas                  # 0 = acabou a tabela
    lw   a2, 4(a0)                     # a2 = paleta

    # tradução: começa tudo transparente (uma letra que não está na paleta
    # não aparece) e depois aplica os pares da paleta
    la   t0, traducao
    li   t1, COR_TRANSPARENTE
    li   t2, 256
md_limpa:
    sb   t1, 0(t0)
    addi t0, t0, 1
    addi t2, t2, -1
    bnez t2, md_limpa
md_paleta:
    lbu  t1, 0(a2)                     # letra
    beqz t1, md_traduz                 # 0 = fim da paleta
    lbu  t2, 1(a2)                     # cor
    la   t0, traducao
    add  t0, t0, t1
    sb   t2, 0(t0)                     # traducao[letra] = cor
    addi a2, a2, 2
    j    md_paleta

md_traduz:
    lw   t1, 0(a1)                     # largura
    lw   t2, 4(a1)                     # altura
    mul  t2, t1, t2                    # t2 = número de pixels
    addi t1, a1, 8                     # t1 = primeiro pixel
    la   t3, traducao
md_pixel:
    beqz t2, md_prox_imagem
    lbu  t4, 0(t1)                     # a letra...
    add  t4, t4, t3
    lbu  t4, 0(t4)                     # ...vira a cor
    sb   t4, 0(t1)
    addi t1, t1, 1
    addi t2, t2, -1
    j    md_pixel
md_prox_imagem:
    addi a0, a0, 8
    j    md_imagem

    # ---------------- 2) mapas ----------------
md_mapas:
    la   a0, tabela_mapas
md_mapa:
    lw   a1, 0(a0)
    beqz a1, md_fonte
    lw   t1, 0(a1)                     # colunas
    lw   t2, 4(a1)                     # linhas
    mul  t2, t1, t2
    addi t1, a1, 8
md_bloco:
    beqz t2, md_prox_mapa
    lbu  t4, 0(t1)
    li   t5, 'a'                       # minúscula -> maiúscula
    blt  t4, t5, md_bl_maiuscula
    addi t4, t4, -32
md_bl_maiuscula:
    li   t5, 'A'
    bge  t4, t5, md_bl_letra
    li   t5, '1'
    blt  t4, t5, md_bl_vazio           # '.', '0' ou outra coisa: vazio
    li   t5, '9'
    bgt  t4, t5, md_bl_vazio
    addi t4, t4, -48                   # '1'..'9' -> 1..9
    j    md_bl_grava
md_bl_letra:
    addi t4, t4, -55                   # 'A'..'Z' -> 10..35
    j    md_bl_grava
md_bl_vazio:
    li   t4, 0
md_bl_grava:
    sb   t4, 0(t1)
    addi t1, t1, 1
    addi t2, t2, -1
    j    md_bloco
md_prox_mapa:
    addi a0, a0, 4
    j    md_mapa

    # ---------------- 3) fonte ----------------
md_fonte:
    la   a0, desenho_fonte
md_letra:
    lw   t0, 0(a0)                     # código da letra
    bltz t0, md_fim                    # -1 = acabou
    addi a0, a0, 4
    li   t1, ALT_LETRA
    mul  t0, t0, t1
    la   t1, fonte
    add  t1, t1, t0                    # t1 = os 12 bytes desta letra
    li   t2, ALT_LETRA                 # t2 = linhas que faltam
md_linha:
    li   t3, 0                         # t3 = byte da linha
    li   t4, 5                         # t4 = colunas que faltam
md_coluna:
    slli t3, t3, 1                     # abre espaço para a próxima coluna
    lbu  t5, 0(a0)
    li   t6, '#'
    bne  t5, t6, md_apagado
    ori  t3, t3, 1                     # '#' = pixel aceso
md_apagado:
    addi a0, a0, 1
    addi t4, t4, -1
    bnez t4, md_coluna
    sb   t3, 0(t1)
    addi t1, t1, 1
    addi t2, t2, -1
    bnez t2, md_linha
    j    md_letra                      # (12 x 5 = 60 letras: a próxima já começa alinhada)
md_fim:
    ret
