############################################################################
#  GRÁFICOS DO JOGO, DESENHADOS EM TEXTO (pixel art dentro do assembly)
#
#  Cada imagem é desenhada aqui mesmo, com UMA LETRA POR PIXEL:
#
#     pal_coracao_cheio:                       <- a PALETA: letra -> cor
#     .byte '.',0xC7, 'K',0x00, 'R',0x07, 0    (termina com 0)
#     .align 2
#     img_coracao_cheio:
#     .word 9, 8                               <- largura, altura
#     .ascii ".KK.KK..."                       <- uma linha da imagem
#     ...                                      (altura linhas de largura letras)
#
#  Quando o jogo abre, a rotina montar_desenhos (rotinas/desenhos.s) troca,
#  no próprio lugar, cada letra pela cor da paleta. Depois disso a imagem fica
#  no formato de sempre (.word largura, altura + 1 byte por pixel), e o resto
#  do jogo (desenhar_imagem, desenhar_mapa...) não precisa saber de nada.
#
#  CORES: 1 byte no formato BBGGGRRR (2 bits de azul, 3 de verde, 3 de
#  vermelho). 0xC7 = transparente (não é desenhado). As letras das paletas
#  foram escolhidas pelo tipo de cor:
#     .  transparente     K preto     W branco     S/s cinza claro/escuro
#     R/r vermelho        O laranja   N/n marrom   Y/y amarelo   G/g verde
#     C/c ciano           B/b azul    P/p roxo/rosa
#     (maiúscula = cor clara, minúscula = escura; quando duas cores caem na
#      mesma letra, a outra ganha um número ou símbolo: veja o comentário
#      ao lado de cada paleta)
#
#  PARA EDITAR UM DESENHO: troque as letras (use letras que existem na paleta
#  dele). Cada linha .ascii precisa ter exatamente "largura" letras.
#  PARA UMA COR NOVA: acrescente  'letra',cor  na paleta (antes do 0).
#  PARA UMA IMAGEM NOVA: escreva a paleta, o img_xxx com .word largura, altura
#  e as linhas, e acrescente "img_xxx, pal_xxx" na tabela_desenhos (no fim).
#
#  MAPAS (mapa_xxx): mesma ideia, uma letra por bloco de 16 x 16:
#     .  vazio      1..9  blocos 1 a 9      A..Z  blocos 10 a 35
#  (a lista de blocos é a tabela 'blocos', mais abaixo)
############################################################################

.data
.align 2

# ============================== SPRITES ==============================

# chefe_stewart_aberto (48x48)
pal_chefe_stewart_aberto:
.byte 'W',0xFF, '.',0xC7, 'R',0x05, 'K',0x00, 'S',0xAE, 'k',0x01, 'r',0x0E, '1',0x03   # W branco, . transparente, R vermelho, K preto, S cinza claro, k preto, r vermelho, 1 vermelho escuro
.byte 'B',0x89, 0   # B azul
.align 2
img_chefe_stewart_aberto:
.word 48, 48
.ascii "................................................"
.ascii "................................................"
.ascii ".......................kk......................."
.ascii "..kkkkkkkkkkkkkkkkkkkkk11kkkkkkkkkkkkkkkkkkkkk.."
.ascii ".kWWWWWWWBBWWWWWWWWWWWW11WWWWWWWWWWWRRRWWWWWWWk."
.ascii "kkWWWWWWBWWWWWWWWWWWWWW11WWWWWWWWWWRWWWRWWWWWWkk"
.ascii "RRWWWWWWBWWWWWWWWWWWWWW11WWWWWWWWWWWWWWRWWWWWWRR"
.ascii "RRWWWWWWBWWWWWWWWWWWWWW11WWWWWWWWWWWWWRWWWWWWWRR"
.ascii "RRWWWSSSBSSSSSSSSSSSWWW11WWWSSSSSSSSSRSWWWWWWWRR"
.ascii "RRWWWWWWBWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWBWWWWWWWWWWWWWW11WWWWWWWWWWWWRWWWWWWWWRR"
.ascii "RRWWWWWWBWWWWWKKWWWWWWW11WWWWWWWWKKWWWWWWWWWWWRR"
.ascii "RRWWWSBBSSSSSSKKKKWWWWW11WWWSSSKKKKSSSSSSSSWWWRR"
.ascii "RRWWWWWWWWWWWWWWKKKKWWW11WWWWKKKKWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWSSSSSSSSSWWWKKKWWW11WWWWWKKKWWSSSSSSWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWKKKWWW11WWWWWKKKWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWKKKWWW11WWWWWKKKWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWSSSSSSSSSSSWWWWWWW11WWWSSSSSSSSSSSWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWSSSSSSSSSSSSSSSWWW11WWWSSSSSSSSSSSSSSSWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWKWWKWWKWWKWWKWWKWWKWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWKWWKWWKWWKWWKWWKWWKWWWWWWWWWWWWWRR"
.ascii "RRWWWSSSSSSSSSKKKKKKKKKKKKKKKKKKKKKSSSSSSWWWWWRR"
.ascii "RRWWWWWWWWWWWWKKKKKKKKKKKKKKKKKKKKKWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWKKKKKKKKKKKKKKKKKKKKKWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWKKKKKKKKKKKKKKKKKKKKKWWWWWWWWWWWRR"
.ascii "RRWWWSSSSSSSSSKKKKKKKKKKKKKKKKKKKKKSSSSWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWKKKrrrrrrrrrrrrrrrKKKWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWKKKrrrrrrrrrrrrrrrKKKWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWKKKrrrrrrrrrrrrrrrKKKWWWWWWWWWWWRR"
.ascii "RRWWWSSSSSSSSSKKKrrrrrrrrrrrrrrrKKKSSSSSSSSWWWRR"
.ascii "RRWWWWWWWWWWWWKKKrrrrrrrrrrrrrrrKKKWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRWWWWWWWWWWWWWWWWWWWWW11WWWWWWWWWWWWWWWWWWWWWRR"
.ascii "RRRRRRRRRRRRRRRRRRRRRRR11RRRRRRRRRRRRRRRRRRRRRRR"
.ascii "RRRRRRRRRRRRRRRRRRRRRRR11RRRRRRRRRRRRRRRRRRRRRRR"
.ascii "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"
.ascii "................................................"
.ascii "................................................"
.ascii "................................................"
.ascii "................................................"

# chefe_stewart_fechado (48x48)
pal_chefe_stewart_fechado:
.byte 'R',0x05, 'W',0xFF, '.',0xC7, 'r',0x03, 'Y',0x37, 'K',0x01, 'S',0xAE, 'k',0x00   # R vermelho, W branco, . transparente, r vermelho escuro, Y amarelo, K preto, S cinza claro, k preto
.byte 'O',0x16, 0   # O laranja
.align 2
img_chefe_stewart_fechado:
.word 48, 48
.ascii "..KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK......"
.ascii ".KrrrrrOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOK....."
.ascii ".KrrrrrOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOK....."
.ascii ".KrrrrrRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRKKKK.."
.ascii ".KrrrrrRRYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRYYYRYYYRYRRRYYYRYRYRYRRRYYYRYRRWSWSK."
.ascii ".KrrrrrRRYRYRRRYRYRYRRRYRRRYRYRYRRRYRYRYRRWSWSK."
.ascii ".KrrrrrRRYRYRRRYYYRYRRRYRRRYRYRYRRRYRYRYRRWSWSK."
.ascii ".KrrrrrRRYRYRRRYRYRYRRRYRRRYRYRYRRRYRYRYRRWSWSK."
.ascii ".KrrrrrRRYRYYYRYRYRYYYRYYYRYYYRYYYRYYYRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRkkRRRRRRRRRRRRRRRRRkkRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRkkkkRRRRRRRRRRRRRkkkkRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRkkkkRRRRRRRRRkkkkRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRWWWRRRRRRRRRRRRRRRWWWRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRWWWWWWRRRRRRRRRWWWWWWRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRWWWkkkWRRRRRRRWWkkkWWRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRWWWkkkWRRRRRRRWWkkkWWRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRWWWkkkWRRRRRRRWWkkkWWRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRWWWWWWWRRRRRRRWWWWWWWRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRkWWkWWkWWkWWkWWkWWkRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRkWWkWWkWWkWWkWWkWWkRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRkkkkkkkkkkkkkkkkkkkRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRkkkkkkkkkkkkkkkkkkkRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRkkWWkWWkWWkWWkWWkWWRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRkkWWkWWkWWkWWkWWkWWRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYRRRRRRRRRRRRRRRRRRRRRRRRRRRRRYRRWSWSK."
.ascii ".KrrrrrRRYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYRRWSWSK."
.ascii ".KrrrrrRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRWSWSK."
.ascii ".KrrrrrRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRWSWSK."
.ascii ".KrrrrrRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRSSSSK."
.ascii "..KKKKWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWSWSK."
.ascii ".....KSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSK."
.ascii ".....KWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWSWSK."
.ascii "......KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK.."
.ascii "................................................"
.ascii "................................................"

# coracao_cheio (9x8)
pal_coracao_cheio:
.byte '.',0xC7, 'R',0x0E, 'r',0x03, '1',0xAF, 0   # . transparente, R vermelho, r vermelho escuro, 1 vermelho
.align 2
img_coracao_cheio:
.word 9, 8
.ascii "..rr.rr.."
.ascii ".rRRrRRr."
.ascii "rR1RRRRRr"
.ascii "rRRRRRRRr"
.ascii ".rRRRRRr."
.ascii "..rRRRr.."
.ascii "...rRr..."
.ascii "....r...."

# coracao_vazio (9x8)
pal_coracao_vazio:
.byte '.',0xC7, 'S',0xA4, 's',0x52, '1',0xAD, 0   # . transparente, S cinza claro, s cinza escuro, 1 cinza claro
.align 2
img_coracao_vazio:
.word 9, 8
.ascii "..ss.ss.."
.ascii ".sSSsSSs."
.ascii "sS1SSSSSs"
.ascii "sSSSSSSSs"
.ascii ".sSSSSSs."
.ascii "..sSSSs.."
.ascii "...sSs..."
.ascii "....s...."

# estudante_andando (16x24)
pal_estudante:                    # (todas as poses do estudante usam esta)
.byte '.',0xC7, 'p',0x41, 'n',0x0A, 'O',0x6F, 'R',0x5E, 'W',0xFF, 'o',0x1F, 'B',0x91   # . transparente, p roxo/rosa escuro, n marrom escuro, O laranja, R vermelho, W branco, o laranja, B azul
.byte '1',0x2F, 'S',0xAD, 'b',0x48, '2',0x15, 's',0x52, '3',0x49, 'N',0x14, 'G',0x72   # 1 laranja, S cinza claro, b azul escuro, 2 laranja, s cinza escuro, 3 cinza escuro, N marrom escuro, G verde
.byte '4',0xDA, 'g',0x61, 'c',0x50, '5',0x27, '6',0x60, 'r',0x0C, '7',0x0D, '8',0x0B   # 4 azul, g verde escuro, c ciano escuro, 5 laranja, 6 verde escuro, r vermelho escuro, 7 vermelho, 8 marrom escuro
.byte 'K',0x00, 0   # K preto
.align 2
img_estudante_andando:
.word 16, 24
.ascii "................"
.ascii ".....333333....."
.ascii "....3nnnnnn3...."
.ascii "...3nnnnnnnn3..."
.ascii "...3nnnnnOOO3..."
.ascii "...3nnnOOOKO3..."
.ascii "...3nnOOOOKO3..."
.ascii "....3nOOOOOO3..."
.ascii "....3OOOOO33...."
.ascii ".....33OO3......"
.ascii "..333gggggg3...."
.ascii ".3778ggggggg3..."
.ascii ".3778ggWWggO3..."
.ascii ".3778ggWWggO3..."
.ascii ".3778gggggg3...."
.ascii "..333gggggg3...."
.ascii ".....3BBBBB3...."
.ascii ".....3BBBBB3...."
.ascii "....3BB33BB3...."
.ascii "....3BB3.3BB3..."
.ascii "...3BB3...3BB3.."
.ascii "...3BB3...3BB3.."
.ascii "..3nnn3...3nnn3."
.ascii "..33333...33333."

# estudante_parado (16x24)
.align 2
img_estudante_parado:
.word 16, 24
.ascii "................"
.ascii ".....333333....."
.ascii "....3nnnnnn3...."
.ascii "...3nnnnnnnn3..."
.ascii "...3nnnnnOOO3..."
.ascii "...3nnnOOOKO3..."
.ascii "...3nnOOOOKO3..."
.ascii "....3nOOOOOO3..."
.ascii "....3OOOOO33...."
.ascii ".....33OO3......"
.ascii "..333gggggg3...."
.ascii ".3778ggggggg3..."
.ascii ".3778ggWWggO3..."
.ascii ".3778ggWWggO3..."
.ascii ".3778gggggg3...."
.ascii "..333gggggg3...."
.ascii ".....3BBBBB3...."
.ascii ".....3BBBBB3...."
.ascii ".....3BB3BB3...."
.ascii ".....3BB3BB3...."
.ascii ".....3BB3BB3...."
.ascii ".....3BB3BB3...."
.ascii "....3nnn3nnn3..."
.ascii "....333333333..."

# fundo_arbustos (336x22)
pal_fundo_arbustos:
.byte '.',0xC7, 's',0x49, 'S',0x4A, 'O',0x67, 'p',0x4B, 'R',0x55, 0   # . transparente, s cinza escuro, S cinza escuro, O laranja, p roxo/rosa escuro, R vermelho
.align 2
img_fundo_arbustos:
.word 336, 22
.ascii "...................................................................................................................................................................................................................................................OppRppRp....................................................................................."
.ascii "..................................................................................................................................................................................................................................................OSSSSSSSSp...................................................................................."
.ascii ".....OR..............................Op......................................................Op.......................................................................................................................Op.........................OSSSSSSSSSSR..................................................................................."
.ascii "....OSSp............................OSSR....................................................OSSp.....................................................................................................................OSSR........................OSSSSSSSSSSS..................................................................................."
.ascii "..ORSSSSpR........................OpSSSSpp................................................OpSSSSRp.................................................................................................................OpSSSSpp.....................OSSSSSSSSSSSSp.................................................................................."
.ascii "..OSSSSSSS........................OSSSSSSS................................................OSSSSSSS.................................................................................................................OSSSSSSS.....................OSSSSSSSSSSSSSp................................................................................."
.ascii ".OSSSSSSSSp......................OSSSSSSSSR..............................................OSSSSSSSSp...............................................................................................................OSSSSSSSSR..................OpSSSSSSSSSSSSSSSR................................................................................"
.ascii "OSSSSSSSSSSp....................OSSSSSSSSSSp............................................OSSSSSSSSSSR.............................................................................................................OSSSSSSSSSSp.................OSSSSSSSSSSSSSSSSSp..............................................................................."
.ascii "OSSSSSSSSSSS....................OSSSSSSSSSSS............................................OSSSSSSSSSSS.............................................................................................................OSSSSSSSSSSS................OSSSSSSSSSSSSSSSSSSS..............................................................................."
.ascii "OSSSSSSSSSSS....................OSSSSSSSSSSS............................................OSSSSSSSSSSS.............................................................................................................OSSSSSSSSSSS................OSSSSSSSSSSSSSSSSSS................................................................................"
.ascii "OSSSSSSSSSSS....................OSSSSSSSSSSS............................................OSSSSSSSSSSS.............................................................................................................OSSSSSSSSSSS.................OSSSSSSSSSSSSSSSSS................................................................................"
.ascii ".OSS.OS..........................OSS.OS..................................................OSS.OS...................................................................................................................OSS.OS......................OSSSSSSSSSSSSSSSS................................................................................."
.ascii ".....OS..............................OS......................................................OS...............................................................................OppRpp..................................OS........................OSSSS.OS...OS........................................ORppRp...........OpRppR...................."
.ascii ".....OS..............................OS......................................................OS.............................................................................OpSSSSSSRp................................OS..............................OS...........................................OpSSSSSSpR.......ORSSSSSSpp.................."
.ascii ".....OS..............................OS......................................................OS............................................OpRppR..........................OSSSSSSSSSSp...............................OS..............................OS..........................................OSSSSSSSSSSpp....OSSSSSSSSSSR................."
.ascii ".....Os..............................Os......................................................Os..........................................ORsssssspp.......................OssssssssssssR..............................Os..............................Os.........................................OsssssssssssssRp.Ossssssssssssp................"
.ascii ".....Os..............................Os.....................OppRppRppRpp.....................Os.........................................OssssssssssRppRp...........OpRppRpssssssssssssss..............OppR............Os..............................Os......................................OpRsssssssssssssssspssssssssssssss................"
.ascii ".....Os..............................Os...................OpssssssssssssRp...................Os.........................................OssssssssssssssspR.......ORsssssssssssssssssssss............Opsssspp..........Os..............................Os....................................ORssssssssssssssssssssssssssssssssss................"
.ascii ".....Os..............................Os...................OssssssssssssssspR.................Os...............................OppRppRp..Osssssssssssssssss.......Ossssssssssssssssssssss..........ORssssssss..........Os..............................Os....................................Osssssssssssssssssssssssssssssssssss................"
.ascii ".....Os..............................Os...................Osssssssssssssssssp................Os..............................Ossssssssp.Osssssssssssssssss.......Osssssssssssssssssssss..........Ossssssssss..........Os..............................Os....................................Osssssssssssssssssssss.Ossssssssssss................"
.ascii ".....Os..............................Os...................Ossssssssssssssssss................Os..............................Osssssssss..Ossssssssssssssss.......Ossssssssssssssssssss...........Ossssssssss..........Os..............................Os....................................Ossssssssssssssssssss...Osssssssssss................"
.ascii ".....Os..............................Os.....................Osssssssssssssss.................Os...............................Osssssss.....Ossssssssssss...........Ossssssssssssssss..............Osssssss............Os..............................Os......................................Ossssssssssssssss.......Ossssssss................."

# fundo_ceu (4x240)
pal_fundo_ceu:
.byte 'Y',0x77, 'R',0x5F, 'P',0x8B, 'p',0x95, '1',0x8C, 'O',0x67, 'o',0x6F, 'B',0x8A   # Y amarelo, R vermelho, P roxo/rosa, p roxo/rosa, 1 roxo/rosa, O laranja, o laranja, B azul
.byte '2',0x96, 'r',0x9F, 'b',0x89, 0   # 2 roxo/rosa, r vermelho, b azul
.align 2
img_fundo_ceu:
.word 4, 240
.ascii "bbbb"
.ascii "bbbb"
.ascii "bbBb"
.ascii "bbbb"
.ascii "BbBb"
.ascii "bbbb"
.ascii "BbBb"
.ascii "bbbb"
.ascii "BbBb"
.ascii "bBbB"
.ascii "BbBb"
.ascii "bBbB"
.ascii "BBBb"
.ascii "bBbB"
.ascii "BbBB"
.ascii "bBbB"
.ascii "BBBB"
.ascii "BBbB"
.ascii "BBBB"
.ascii "bBBB"
.ascii "BBBB"
.ascii "BBBB"
.ascii "BBBB"
.ascii "BBBB"
.ascii "PBPB"
.ascii "BBBB"
.ascii "PBPB"
.ascii "BBBB"
.ascii "PBPB"
.ascii "BPBP"
.ascii "PBPB"
.ascii "BPBP"
.ascii "PPPB"
.ascii "BPBP"
.ascii "PBPP"
.ascii "BPBP"
.ascii "PPPP"
.ascii "PPBP"
.ascii "PPPP"
.ascii "BPPP"
.ascii "PPPP"
.ascii "PPPP"
.ascii "PPPP"
.ascii "PPPP"
.ascii "1PPP"
.ascii "PPPP"
.ascii "1P1P"
.ascii "PPPP"
.ascii "1P1P"
.ascii "P1PP"
.ascii "1P1P"
.ascii "P1P1"
.ascii "111P"
.ascii "P1P1"
.ascii "1P11"
.ascii "P1P1"
.ascii "1111"
.ascii "P1P1"
.ascii "1111"
.ascii "P111"
.ascii "1111"
.ascii "1111"
.ascii "1111"
.ascii "1111"
.ascii "p111"
.ascii "1111"
.ascii "p1p1"
.ascii "1111"
.ascii "p1p1"
.ascii "1p11"
.ascii "p1p1"
.ascii "111p"
.ascii "p1p1"
.ascii "1p1p"
.ascii "p1pp"
.ascii "1p1p"
.ascii "pppp"
.ascii "1p1p"
.ascii "pppp"
.ascii "1ppp"
.ascii "pppp"
.ascii "pppp"
.ascii "pppp"
.ascii "pppp"
.ascii "2ppp"
.ascii "pppp"
.ascii "pp2p"
.ascii "pppp"
.ascii "2p2p"
.ascii "p2pp"
.ascii "2p2p"
.ascii "ppp2"
.ascii "2p2p"
.ascii "p2p2"
.ascii "2p2p"
.ascii "p2p2"
.ascii "2222"
.ascii "p2p2"
.ascii "2222"
.ascii "p2p2"
.ascii "2222"
.ascii "2222"
.ascii "2222"
.ascii "2222"
.ascii "r222"
.ascii "2222"
.ascii "22r2"
.ascii "2222"
.ascii "r2r2"
.ascii "2r22"
.ascii "r2r2"
.ascii "222r"
.ascii "r2r2"
.ascii "2r2r"
.ascii "r2r2"
.ascii "2r2r"
.ascii "rrrr"
.ascii "2r2r"
.ascii "rrrr"
.ascii "2r2r"
.ascii "rrrr"
.ascii "rr2r"
.ascii "rrrr"
.ascii "rrrr"
.ascii "Rrrr"
.ascii "rrrr"
.ascii "rrRr"
.ascii "rrrr"
.ascii "RrRr"
.ascii "rRrr"
.ascii "RrRr"
.ascii "rrrR"
.ascii "RrRr"
.ascii "rRrR"
.ascii "RrRr"
.ascii "rRrR"
.ascii "RRRr"
.ascii "rRrR"
.ascii "RRRR"
.ascii "rRrR"
.ascii "RRRR"
.ascii "RRrR"
.ascii "RRRR"
.ascii "RRRR"
.ascii "RRRR"
.ascii "RRRR"
.ascii "RROR"
.ascii "RRRR"
.ascii "OROR"
.ascii "RRRR"
.ascii "OROR"
.ascii "RRRO"
.ascii "OROR"
.ascii "RORO"
.ascii "OROR"
.ascii "RORO"
.ascii "OOOR"
.ascii "RORO"
.ascii "OROO"
.ascii "RORO"
.ascii "OOOO"
.ascii "OORO"
.ascii "OOOO"
.ascii "ROOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "OOoO"
.ascii "OOOO"
.ascii "oOoO"
.ascii "OOOO"
.ascii "oOoO"
.ascii "OOOO"
.ascii "oOoO"
.ascii "OoOo"
.ascii "oOoO"
.ascii "OoOo"
.ascii "oooO"
.ascii "OoOo"
.ascii "oOoo"
.ascii "OoOo"
.ascii "oooo"
.ascii "ooOo"
.ascii "oooo"
.ascii "Oooo"
.ascii "oooo"
.ascii "oooo"
.ascii "oooo"
.ascii "oooo"
.ascii "YoYo"
.ascii "oooo"
.ascii "YoYo"
.ascii "oooo"
.ascii "YoYo"
.ascii "oYoY"
.ascii "YoYo"
.ascii "oYoY"
.ascii "YYYo"
.ascii "oYoY"
.ascii "YoYY"
.ascii "oYoY"
.ascii "YYYY"
.ascii "YYoY"
.ascii "YYYY"
.ascii "oYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"

# fundo_morros (320x32)
pal_fundo_morros:
.byte '.',0xC7, 'P',0x94, 'p',0x8B, '1',0x95, '2',0x8C, 0   # . transparente, P roxo/rosa, p roxo/rosa, 1 roxo/rosa, 2 roxo/rosa
.align 2
img_fundo_morros:
.word 320, 32
.ascii "................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................"
.ascii "...................................................................................................2ppp...................................................................................................................................................................2ppp.................................................."
.ascii "...............................................................................................pp.22pppp.................................................................................................................................................................22pppp................................................."
.ascii "..............................................................................................2ppp22pppp................................................................................................................................................................222ppp2ppp.............................................."
.ascii ".............................................................................................22pp222ppppp...............................................................................................................................................................222pp22pppp............................................."
.ascii ".......................................................................................11111122pp222ppppp...............................................................................................................................................................222pp22pppp............................................."
.ascii ".....................................................................................11PPPPPPPpppppppppp...............................................................................................................................................................p222p222ppppp..pp........................................"
.ascii "...................................................................................11PPPPPPPPPPppPpppppp1..........................................................................................................................1111111............................2ppppp222ppppp.2ppp......................................."
.ascii "........................................................2ppp......................1PPPPPPPPPPPPPPPPppppPP11111.......................2ppp.......................................................................................111PPPPPPP111........................22pppppppppppp122pppp.........11..........................."
.ascii ".......................................................22pp2ppp.................11PPPPPPPPPPPPPPPPPPPPPPPPPPPP1111111...............22pppp......................................................................2ppp..........11PPPPPPPPPPPPP111.....................22ppppppppppppP22pppp111111111PP111111....................."
.ascii "..............2ppp....................................222p22pppp...............1PPPPPPPPPPpPPPpPPPPPPPPPPPPPPPPPPPPPP11111.........222ppppp..2ppp..............................................................22pppp........1PPPPPPPPPPPPPPPPPP11.................111ppppppppppppPPPppppPPPPPPPPPPPPPPPPPP11..................."
.ascii ".............22pppp.................................pp222222ppppp............11PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP111.....p222ppppp.22pppp............................................................222ppppp.....11PPPPPPPPPPPPPPPPPPPPP111..........1111PPPPppPPPPPPPPPPPPPppPPPPPPPPPPPPPPPPPPPPP11................."
.ascii "......2ppp..222ppppp...............................2pp222222ppppp...........1PPPPPPPpPpPpPpPpPpPpPpPpPpPpPPPpPPPPPPPPPPPPPPPP111.2p222ppppp.22pppp.......111111111..........................................2p222ppppp...11PPPPPpPPPpPpPpPPPpPPPPPPPP1111111111PPPPPPPPPPPPPpPPPpPPPpPPPPPPPPPPPPPPPpPPPPPPPPPP11..............."
.ascii ".....22ppp2p222pppppp.............................22pp222222ppppp.........11PPPPPPPPPpPpPpPpPpPpPpPPPpPPPPPPPPPPPPPPPPPPPPPPPPPP22p222ppppp222ppppp...111PPPPPPPPP111......................................22p222ppppp..1PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP1.............."
.ascii "....222pp22p222ppp2ppp......................11111122ppppp222ppppp.......11PPPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPpPPPPPPPPPPPPP22ppppppppp222ppppp111PPPPPPPPPPPPPPP11...pp...............................22p222ppppp11PPPPPPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPPPPPpPPPpPpPpPpPpPpPpPPPpPPPpPPPpPpPpPPPpPPPPPPP11............"
.ascii "....222pp22p222pp22pppp...............111111PPPPPPPpppppppppppppp.....11PPPPPPPPPPPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPPPPPPPpppppppppp.pppppp1PPPPPPPPPPPPPPPPPPPP112ppp.............................222pppppppppPPPPPPPPPPPPPpPPPpPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP1..........."
.ascii "....222p222pppppp22pppp111111111111111PPPPPPPPPPPPPPppPpppppppppp11111PPPPPPpPpPpPpPpppppppppppppppPpppPpPpPpPpPpPpPpPpPpPpPpPPPPPpppppppp11ppppppPPPPPPPPPPpPPPpPPPPPPP22pppppp..........................222pppppppppPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPPPpPPPpPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPP1.........."
.ascii "....222p222pppppppppppPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPppppppppPPPPPPPPPPPPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPpPPPPPPPPPPPppppPPPPppppPPPPPPPPPPPPPPPPPPPPPPP22ppp2ppp..........................ppppppppppPPPPPPPPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPP11........"
.ascii "....pppppppppppppppppPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPppppPPPPPPPPPPPpPpPpPpPpppppppppppppppppppppppPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPPPPPpPPPpPpPpPpPpPPPPPPppp22pppp...................111111pppppppppPPPPPPpPpPpPpPpppPpppPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPPPPP11......"
.ascii "....ppppppppppppppPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpPpPpPpPpPpppPpppPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpp22pppp............1111111PPPPPPPppppPPPPPPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPpPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPP1....."
.ascii "11...pppppppppPPPPPPpPPPpPPPpPPPpPPPpPpPpPpPpPpPpPpPpPpPpPpPpPPPpPPPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppPpppPpPpPpPpPpPpPpPPPpPPPpPpPpPpPpPpPpPpPpPpPpPpPpPPPPpppp1111111111111PPPPPPPPPPPPPPPPPPPPPPpPpPpPpPpppppppppppppppppppppppPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppPpPpPpPpPpPPPPPP111.."
.ascii "PP111PppppPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpPPPpPPPpPPPPPPPPPPPPPPPPPPPpPpPpPpPpPpppppppppppppppppppppppPpppPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPpPpPpPpPpPpPpPpPpPPPPPPPPppPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpPpPpPpppPpppppppPpppPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppPpppPpppPpPpPpPpPpPpPpppPpPpPpPpPpPpPPPPPPPPPPPP11"
.ascii "PPPPPPPPPPPPPPpPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpPPPpPpPpPpPpppppppppppppppppppppppppppPpPpPpPpPpppPpppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPpPPPPPPPPP"
.ascii "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpPPPpPpPpPpPpPpPpPPPpPPPPPPPPPPPpPpPpPpPpPpppppppppppppppppppppppppppppppPpppPpPpPpPpPpPpPpPpPPPpPPPPPPPpPPPpPpPpPpPpPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpPpPpPpppppppppppppppppppPpPpPpPpPpPpPpPpPpPpPpppPpppppppppppppppPpppPpppPpppppppPpppPpPpPpPpPPPPPPPPPPPP"
.ascii "pPPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppPpppPpppPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPpPpPpPpPpppppppppppppppppppPpPpPpPpPpPPPpPPPpPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPpPPP"
.ascii "PPPPPPPPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppPpppPpPpPpPpPpPpPPPPPPPPPPPPPPPPPPPPPPPpPPPpPPPpPpPpPpPpPpPpPpppppppppppppppppppppppppppPpppPpppPpppppppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPPPPPP"
.ascii "pPpPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppPpppppppppppppppPpppPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppPpppPpPpPpppPpppppppppppppppppppppppPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPpP"
.ascii "PPPPPPPPPPPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPpPpPpPpPpPpPpppPpppppppppppPpPpPpPpPpPpPPPPPPPPPPPPPPPpPPPpPpPpPpPpPpPpPpPpPpPpPpppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppPpPpPpPpPPPPPP"

# fundo_nuvem_1 (72x20)
pal_fundo_nuvem_1:
.byte '.',0xC7, 'P',0x96, 'R',0x9F, 'Y',0x77, 'O',0x67, 0   # . transparente, P roxo/rosa, R vermelho, Y amarelo, O laranja
.align 2
img_fundo_nuvem_1:
.word 72, 20
.ascii "........................................................................"
.ascii "........................................................................"
.ascii ".......................PPPPPP.......PPPPPPPP............................"
.ascii "....................PPPPPPPPPPPP..PPPPPPPPPPPP.........................."
.ascii "...................PPPPPPPPPPPPPPPPPPPPPPPPPPPPP........................"
.ascii "..................PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP..PPPPPP..............."
.ascii ".................PPPPPPPPPRPPPPPPPPPPPRPPPRPPPPPPPPPPPPPPPP............."
.ascii "...........PPPPPPPPPPPPRPPPRPPPPPPPPPPPRPPPRPPPPPPPPPPPPPPPPP..........."
.ascii ".........PPPPPPPPPPPRRRRRRRRRRRPRPRPRRRRRRRRRRRPRPPPRPPPRPPPPP.........."
.ascii "........PPPPPPPPPPPRRRPRRRRRRRPRPRPRRRRRRRRRRRPRPPPRPRPRPPPPPPPPPPP....."
.ascii ".......PPPPPRPRPRPRRRRORORORORORRRORORORORORRRRRRPRRRRRRRPRPRPPPPPPP...."
.ascii ".......PPRPRPRPRPRRORORORORORORORRRORORORORORORORRRRRRRRRRRRPRPPPPPPP..."
.ascii ".......PRRRROROROROOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOROROOORORORORRRRRRPPP.."
.ascii ".......OROROROROROOOOOOOOYOOOOOOOOOOOYOOOYOOOOOOOOOOOOOOOOOORORRRORRPR.."
.ascii ".......OOOYOYOYOYOYYYOYYYYYYYOYYYOYYYYYYYYYYYOYYYOYOYOYOYOYOYOOOOOOOOO.."
.ascii ".......YOYYYOYYYOYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYOYOYOYOYOY.."
.ascii "........YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY..."
.ascii "........................................................................"
.ascii "........................................................................"
.ascii "........................................................................"

# fundo_nuvem_2 (56x16)
pal_fundo_nuvem_2:
.byte '.',0xC7, 'P',0x96, 'Y',0x77, 'R',0x9F, 'O',0x67, 0   # . transparente, P roxo/rosa, Y amarelo, R vermelho, O laranja
.align 2
img_fundo_nuvem_2:
.word 56, 16
.ascii "........................................................"
.ascii "...................PPPPPP..............................."
.ascii ".................PPPPPPPPPP.....PPPPPP.................."
.ascii "...............PPPPPPPPPPPPPP.PPPPPPPPPP................"
.ascii "..............PPPPPPPPPPPPPPPPPPPPPPPPPPPP.............."
.ascii "..............PPPPPPPRPPPPPPPPPPPPPPPPPPPPP............."
.ascii ".......PPPPPPPPPRPRRRPRRRPRPPPRPRPRPRPRPPPP.PPPPPP......"
.ascii "......PPPPPPPPPRPRPRRRRRRRPRPPPRPRPRPRPRPPPPPPPPPPP....."
.ascii ".....PPPRPPPRPRRORORORORORORRRRRORORORRRRRRPRPPPRPPP...."
.ascii "....PPPRPRPRPRRORORORORORORORRRORORORORORRRPPRPRPRPPP..."
.ascii "....RPRROROROROOYOOOOOYOOOOOOOOOOOOOOOOOOOORORORORRRR..."
.ascii "....RRROOOOOOOOYOYOYOYOYOYOYOOOYOYOYOYOYOOOOOOOOOOROR..."
.ascii "....YOYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYOYYYYYYYOY..."
.ascii ".....YYYYYYYYYY..YYYYYYYYYY.YYYYYYYYYYYYYYYYYYYYYYYY...."
.ascii "........................................................"
.ascii "........................................................"

# fundo_nuvem_3 (96x24)
pal_fundo_nuvem_3:
.byte '.',0xC7, 'P',0x96, 'R',0x9F, 'Y',0x77, 'O',0x67, 0   # . transparente, P roxo/rosa, R vermelho, Y amarelo, O laranja
.align 2
img_fundo_nuvem_3:
.word 96, 24
.ascii ".....................................PPPPPPPPPPPPPP............................................."
.ascii "...................................PPPPPPPPPPPPPPPPPP..........................................."
.ascii "..................................PPPPPPPPPPPPPPPPPPPP.........................................."
.ascii "........................PPPPPPPP.PPPPPPPPPPPPPPPPPPPPPP.PPPPPPPP................................"
.ascii "......................PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP............................."
.ascii "....................PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP............................"
.ascii "...................PPPPPPPPPPPPPPPPPPPRPPPRPPPRPPPRPPPPPPPPPPPPPPPPPP..........................."
.ascii "..................PPPPPPPPPPPPPPPPPRPRPRPPPRPPPRPPPPPPPPPPPPPPPPPPPPPP.........................."
.ascii "..................PPPPPPRPRPRPRPRPRPRRRRRRRPRRRPRRRPRPRPRPRPRPRPPPPPPPP..PPPPPP................."
.ascii ".................PPPPPPPPRPRPRPRPRPRRRPRRRPRRRPRRRPRPRPPPRPRPRPRPPPPPPPPPPPPPPPPPP.............."
.ascii "...........PPPPPPPPPRPRRRPRRRPRRRRRRRRORRRRRRRRRRRRRRRRPRPRRRPRRRPRPPPPPPPPPPPPPPPP............."
.ascii ".........PPPPPPPPPPRPRRRPRRRPRRRPRRORRRORRRRRRRRRRRRRRRRPRRRPRRRPRPRPPPPPPPPPPPPPPPP............"
.ascii ".......PPPPPPPPPPPRRRRRRORRRORRROROOOOORORORORORORORORRRORRRORRRRRRRRRRPRPRPRPRPRPPPP..........."
.ascii "......PPPPPPPPPPPRPRRRRORORRRORRROROOORORORORORORORORORRRORRRORRRORRRRPRPRPRPRPRPRPPPPPPPPP....."
.ascii "......PPPPRRRPRRRROROROOOROOOROOOOYOYOOOOOOOOOOOOOOOOOOROROOOROOORORORRRRRRRRRRRRRRPPPPPPPPP...."
.ascii ".....PPRPRPRRRRRRRROROOOROOOROOOOOOYOOOYOOOOOOOOOOOOOOOOROOOROOOROOORORRRRRORRRRRRRRPPPPPPPPP..."
.ascii ".....PRRRROROROROOOOYOYOYOYOYOYOYOYYYYYYYOYOYOYOYOYOYOYOYOYOYOYOYOYOOOOROOOOOOOROOORRRRRRRRPPP.."
.ascii ".....OROROROOOOOOOOOOYOYOYOYOYOYYYYYYYYYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOOOOOOOOOOOOOOOORORRRORRPR.."
.ascii ".....YOOOOYOYOYOYOYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYOYOYOYYYOYOYOYOOOOOOOOOOO.."
.ascii "......OYOYYYYYYYYYYYYYYYYYYYYYYYYY...YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYOYOYOYOYOY.."
.ascii "......YYYYYYYYYYYYYYYY..YYYYYYYY........YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY..."
.ascii "................................................................................................"
.ascii "................................................................................................"
.ascii "................................................................................................"

# fundo_predio (264x120)
pal_fundo_predio:
.byte '.',0xC7, 'O',0xB7, 'R',0xAF, 'P',0x9D, 'p',0x94, 'r',0xA6, 'B',0x9B, 'Y',0xBF   # . transparente, O laranja, R vermelho, P roxo/rosa, p roxo/rosa, r vermelho, B azul, Y amarelo
.byte 'g',0x10, 's',0x4A, 'c',0x50, '1',0x9E, 'o',0x67, 'S',0xA5, 'G',0x60, '2',0x53   # g verde escuro, s cinza escuro, c ciano escuro, 1 roxo/rosa, o laranja, S cinza claro, G verde escuro, 2 cinza escuro
.byte 'b',0x92, '3',0x18, '4',0x21, '5',0xAE, 'C',0x58, '6',0x48, '7',0x54, '8',0x51   # b azul, 3 verde escuro, 4 verde escuro, 5 cinza claro, C ciano escuro, 6 azul escuro, 7 vermelho escuro, 8 cinza escuro
.byte '9',0xEC, 'A',0x9C, 'D',0xA4, 'E',0xF5, 'F',0x59, 'W',0xFF, 'H',0x62, 'I',0x72   # 9 azul, A roxo/rosa, D cinza claro, E azul, F verde escuro, W branco, H verde escuro, I verde
.byte 'J',0x5E, 0   # J vermelho
.align 2
img_fundo_predio:
.word 264, 120
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "........................................................................................................................................................................................................................................................................"
.ascii "....................................................................................................................YYYYYrR............................................................................................................................................."
.ascii ".......................................................................................................YYYYYYYYYYYYYYYYYYr1RR..........................................................................................................................................."
.ascii "..........................................................................................YYYYYYYYYYYYYYYYYYYYYYYYYYrrrrrr111RR........................................................................................................................................."
.ascii ".............................................................................YYYYYYYYYYYYYYYOYYYOYYYOYYrrrrrrrrrrrrrrrrrrr11P11RR......................................................................................................................................."
.ascii "................................................................YYYYYYYYYYYYYYYYYYYYYYYYYYrrrrrrrrrrrrrrrrrrrrrrrrrrYYYYYr1111111R......................................................................................................................................"
.ascii "...................................................YYYYYYYYYYYYYYYOYYYOYYYOYYrrrrrrrrrrrrrrrrrrrrrrrrrrYYYOYYYOYYYOYYYOYYrP111P111RR...................................................................................................................................."
.ascii "......................................YYYYYYYYYYYYYYYYYYYYYYYYYYrrrrrrrrrrrrrrrrrrrrrrrrrrYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYr1111111111RR.................................................................................................................................."
.ascii "................................YOYYYYOYOYOYOYOYOYOrrrrrrrrrrrrrrrrrrrrrrrrrrYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOr11P111P111P1RR................................................................................................................................"
.ascii "................................YOYYYYrrrrrrrrrrrrrrrrrrrrrrrrrrYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYr11111111111111RR.............................................................................................................................."
.ascii "................................YOrrrrrrrrrrrrrrrrrYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOYOrP111P111P111P111RR............................................................................................................................"
.ascii "................................YOrrrrYYYYYYYYYYYYYYYYrYYYYYYYYYYYYYYYYYYYYYYrYYYYYYYYYYYYYYYYYYYYYYrYYYYYYYYYYYYYYYYYYYYr111111111111111111RR.........................................................................................................................."
.ascii "................................YOOYOYOYOYOYOYOYOYOYOYrYOYOYOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYOYrYOYOYOYOYOYOYOYOYOYOrP1P1Pp11P1P1P1P1P1P1R........................................................................................................................."
.ascii "................................YOYYCCCCCCCCCCCCYOYYsOrYsOsYYOsYsssssOsssssYsssssOYssssYssssYOYYYOYYrOYYYOYYYOYYYOYYYOYYYr11111pBB111111111111pRR......................................................................................................................."
.ascii "................................YOOYCGGGGGGGGGGCOYOYsYrYsYssOYsYOYsYOYsYOYOYsrOYOYsYOYOYsYOYsYOYOYOYrYOYOYOYOYOYOYOYOYOYOrP1P1PpBBBB11P1P1P1P1p1PRR....................................................................................................................."
.ascii "................................YOYOCGGGGGGGGGGCYYYOsYrOsYssYYsOYYsOYYsOYYYOsrYOYYsOYYYOsYYOsYYOYYYOrYYOYYYOYYYOYYYOYYYOYr11111pBBBBBo11111111p1111RR..................................................................................................................."
.ascii "................................YOOYCGWWWWWWWWGCOYOYsYrYsYsYsYsYOYsYOYssssOYssssOYOsssOYssssOYOYOYOYrYOYOYOYOYOYOYOYOYOYOrP1P1PpBBBBooPP11P1P1p1P1P1PRR................................................................................................................."
.ascii "................................YOYOCGGGGGGGGGGCYOYOsOrOsOsOsOsOYOsOYOsOYOYOsrYOYOYOYOsOsOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYr111P1pBBBooPPBB1111Pp11P111P1RR..............................................................................................................."
.ascii "................................YOOYCGWWWWWWWWGCOYOYsYrYsYsYOssYOYsYOYsYOYOYsrOYOYOYOYsYsYOYOYOYOYOYrYOYOYOYOYOYOYOYOYOYOrP1P1PpBBBooPPBBBB111p1P1P1P1P1PRR............................................................................................................."
.ascii "................................YOYOCGGGGGGGGGGCYOYOsOrOsOsOYssOYOsOYOsOYOYOsrYOYOYOYOsOsOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYr1P111pBBooPPBBBBBBB1pP111P111P111RR..........................................................................................................."
.ascii "............JJJJJJ..............YOOYCCCCCCCCCCCCOOOYOsssOOsYOOsYsssssOsYOOOYsssssOssssOYsOOYOOOYOOOYrOOYOOOYOOOYOOOYOOOYOrP1P1PpBooPPBBBBBBBoop1P1P1P1P1P1P1PR.........................................................................................................."
.ascii "..........JJ8c888cJJ............YOYOYOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYOYrYOYOYOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYr1P1P1pBooPPBBBBBBBoopP1P1P1P1P1P1P1PRR........................................................................................................"
.ascii ".........Jc8c8c8cFc8c...........YOOOOYOOOYOOOYOOOYOOOYrOOYOOOYOOOYOOOYOOOYOOOrOOOYOOOYOOOYOOOYOOOYOOrYOOOYOOOYOOOYOOOYOOOrP1P1PpooPPBBBBBBBooPp1P1P111P1P1P1P1P1RR......................................................................................................"
.ascii "........J88c888cF88c88..........YOYOYOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYOYrYOYOYOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYr1P111poPPBBBBBBBooPPpP111pB11P111P111P11RR...................................................................................................."
.ascii "........o8c8c8c8c8c8c8..........YOOOOOOOOOOOOOOOOOOO777777777777777777777777777777777777777OOOOOOOOOrOOOOOOOOOOOOOOOOOOOOrP1P1PpPPBBBBBBBooPPBp1P1Ppoo11P1P1P1P1P1p1RR.................................................................................................."
.ascii ".......J8c8c8c8c8c8cFc8.........YOYOYOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYOYrYOYOYOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYr1P1P1pPPBBBBBBBooPPBpP1P1pooPP111P1P1P1PpP1PRR................................................................................................"
.ascii ".......oc8c8c8H8c8c8c8c.........YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOrP1P1PpPBBBBBBBooPPBBp1P1PpoPPBBB11P1P1P1p1P1P1RR.............................................................................................."
.ascii ".......o8c8c8c8c8c8c8c8.........YOYOYOYOYOYOYOYOYOYO777777777777777777777777777777YOYOYOYOYOYOYOYOYOrOYOYOYOYOYOYOYOYOYOYr1P1P1pBBBBBBBooPPBBBpP1P1pPPBBBBBB111P1PpP1P1P1PR............................................................................................."
.ascii ".......ocHc8ccc8ccc8cFc.........YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOrP1PPPpBBBBBBBooPPBBBp1PPPpPPBBBBBBBo11PPp1PPP1PPPRR..........................................................................................."
.ascii "......Jc8c8c8c8c8F8F8c8c........YOYOOOYOOOYOOOYOOOYOOOrOOOYOOOYOOOYOOOYOOOYOOrYOOOYOOOYOOOYOOOYOOOYOrOYOOOYOOOYOOOYOOOYOOr1P1P1pBBBBBBooPPBBBBpP1P1pPBBBBBBBooPP11pP1P1P1P1P1RR........................................................................................."
.ascii ".....JccH8ccc8ccc8ccc8ccc.......YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOrPPP1PpBBBBBooPPBBBBBpPP1PpBBBBBBBooPPBBBpPP1PPP1PPP1PRR......................................................................................."
.ascii ".....o8c8c8H8c8c8c8c8c8c8.......YOOOYOOOYOOOYOOOYOOOYOrOYOOOYOOOYOOOYOOOYOOOYrOOYOOOYOOOYOOOYOOOYOOOrOOOYOOOYOOOYOOOYOOOYr1P1P1pBBBBBooPPBBBBBpP1P1pBBBBBBBooPPBBBpP1P1P1P1P1P1P1RR....................................................................................."
.ascii "....JccccccccccccFccccccccFcc...YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOrP1PPPpBBBBooPPBBBBBBp1PPPpBBBBBBooPPBBBBp1PPP1PPP1PPP1PPPRR..................................................................................."
.ascii "..JJ8c8cHc8c8c8FFc8c8c8c8c8c8F..YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOr1P1P1pBBBooPPBBBBBBBpP1P1pBBBBBooPPBBBBBpP1P111P1P1P1P1P1P1RR................................................................................."
.ascii ".JccccccccccHcccccccccccccccccF.YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOrPPP1PpBBooPPBBBBBBBopPP1PpBBBBooPPBBBBBBpPP1PpB11PP1PPP1PPP1pRR..............................................................................."
.ascii "JcHc8ccH8ccc8cHc8cccFccc8ccc8cc.YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOr1P1P1pBBooPPBBBBBBBopP1P1pBBBBooPPBBBBBBpP1P1pBBB11P1P1P1P1PpP1R.............................................................................."
.ascii "occHccccccccccccccccccccccccccccYOOOROOOROOOROOOROOOROrOROOOROOOROOOROOOROOORrOOROOOROOOROOOROOOROOOrOOOROOOROOOROOOROOORrPPPPPpBooPPBBBBBBBoopPPPPpBBBooPPBBBBBBBpPPPPpBBBBB11PPPPPPPpPPPRR............................................................................"
.ascii "oHccccccHcccccccccccFcccccccccccYOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOr1P1P1pooPPBBBBBBBooPpP1P1pBBooPPBBBBBBBopP1P1pBBBBooP11P1P1PpP1P1PRR.........................................................................."
.ascii "ocHcccccHcccccccccccccccccccccccYOROOOROOOROOOROOOROOOrOOOROOOROOOROOOROOOROOrROOOROOOROOOROOOROOOROrOROOOROOOROOOROOOROOrPPPPPpooPPBBBBBBBooPpPPPPpBBooPPBBBBBBBopPPPPpBBBBooPPB1PPPPpPPPPPPPRR........................................................................"
.ascii "occccccccccccccccccccccccccFccFcYOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOr1P1P1poPPBBBBBBBooPPpP1P1pBooPPBBBBBBBoopP1P1pBBBooPPBBB111PpP1P1P1P1PRR......................................................................"
.ascii "occc6cccHccc6ccc6ccF6ccc6ccc6cccYOROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORrPPPPPpPPBBBBBBBooPPBpPPPPpooPPBBBBBBBooPpPPPPpBBooPPBBBBBB11pPPPPPPPPPPPRR...................................................................."
.ascii "occcccccccccHccccFccccccccccccccYOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOr1PPP1pPPBBBBBBBooPPBpPPP1pooPPBBBBBBBooPpPPP1pBBooPPBBBBBBBopPPP1PPP1PPP1PRR.................................................................."
.ascii "oc6ccc6ccc6cccHccc6ccc6ccc6ccc6.YOROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORrPPPPPpPBBBBBBBooPPBBpPPPPpoPPBBBBBBBooPPpPPPPpBooPPBBBBBBBoopPPPPPPPPPPPPPPPR................................................................."
.ascii "occccccccccccccccFcccFccFcccccc.YOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOOOrOOOOOOOOOOOOOOOOOOOOrPP1PPpBBBBBBBooPPBBBpP1PPpPPBBBBBBBooPPBpP1PPpooPPBBBBBBBooPpP1PP11PPP1PPP1PPRR..............................................................."
.ascii "oc6cHc6c6c6c6c6c6c6c6c6c6c6c6c..YOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrrrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrOrrPPPPPpBBBBBBooPPBBBBpPPPPpPBBBBBBBooPPBBpPPPPpoPPBBBBBBBooPPpPPPPp11PPPPPPPPPPPRR............................................................."
.ascii ".occccccccccccccccccccccccccccc.YOOOOROOOROOOROOOROOORrOOROOOROOOROOOROOOROOOrOOOROOOROOOROOOROOOROOrROOOROOOROOOROOOROOOrPPPPPpBBBBBBooPPBBBBpPPPPpPBBBBBBBooPPBBpPPPPpoPPBBBBBBBooPPpPPPPpBo11PPPPPPPPPPpRR..........................................................."
.ascii ".o6c6c6c6c6c6c6c6F6c6c6c6c6c6c6.YOROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORrPPPPPpBBBBBooPPBBBBBpPPPPpBBBBBBBooPPBBBpPPPPpPPBBBBBBBooPPBpPPPPpooPP1PPPPPPPPPpPPR.........................................................."
.ascii "JHcccccccHccccccccFcccccccccccc.YOOROOOROOOROOOROOOROOrROOOROOOROOOROOOROOOROrOROOOROOOROOOROOOROOORrOOROOOROOOROOOROOOROrPP1PPpBBBBooPPBBBBBBpP1PPpBBBBBBooPPBBBBpP1PPpPBBBBBBBooPPBBpP1PPpoPPBB11P1PPP1PpP1P.........................................................."
.ascii "oc6c6c6H6c6c6c6c6cFcFcFc6c6c6cF.YOROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORrPPPPPpBBBBooPPBBBBBBpPPPPpBBBBBBooPPBBBBpPPPPpPBBBBBBBooPPBBpPPPPpoPPBBBB11PPPPPpPPP.........................................................."
.ascii "o6c6c6c6c6c6c6c6F6cFcFc6c6cFc6c.YOORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROrPPPPPpBBBooPPBBBBBBBpPPPPpBBBBBooPPBBBBBpPPPPpBBBBBBBooPPBBBpPPPPpPPBBBBBBB11PPPpPPP.........................................................."
.ascii "oH6c6c6c6c6c6H6c6c6c6c6cFcFc6c6.YOROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORrPPPPPpBBooPPBBBBBBBopPPPPpBBBBooPPBBBBBBpPPPPpBBBBBBooPPBBBBpPPPPpPBBBBBBBooP11PpPPP.........................................................."
.ascii "o6c6H6c6c6c6c6cFc6c6c6F6c6F6c6..YOORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROrPPPPPpBBooPPBBBBBBBopPPPPpBBBBooPPBBBBBBpPPPPpBBBBBBooPPBBBBpPPPPpPBBBBBBBooPPB1pPPP.........................................................."
.ascii "o6HcH66c666c666c666c66FF666c66..YORORRRORRRORRRORRRORRrORRRORRRORRRORRRORRRORrRORRRORRRORRRORRRORRROrRRORRRORRRORRRORRRORrPPpPPpBooPPBBBBBBBoopPpPPpBBBooPPBBBBBBBpPpPPpBBBBBooPPBBBBBpPpPPpBBBBBBBooPPBBBpPpPOYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY....."
.ascii ".oc6cHH6c6c6c6c6cFc6c6c6F6c6c6..YOORORORORORORORORORORrROROROROROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROrPPPPPpooPPBBBBBBBooPpPPPPpBBooPPBBBBBBBopPPPPpBBBBooPPBBBBBBpPPPPpBBBBBBooPPBBBBpPPPOYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY....."
.ascii ".o666c666c666H66Fc666cF66c666...YORRRORRRORRRORRRORRROrRRO99999RRORRRORRRORRRrRRRORRRORRRORRRORRRORRrORRRORRRORRRORRRORRRrpPPPppoPPBBBBBBBooPPpPPPppBooPPBBBBBBBoopPPPppBBBooPPBBBBBBBpPPPppBBBBBooPPBBBBBpPPPO1111111111111111111111111111111111111111111111111111..s.."
.ascii ".oc6c6c6c6c6c6H6c6c6cFc6F6cF....YOORORORORORORORORORORrROR9WEE9ROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROrPPPPPpoPPBBBBBBBooPPpPPPPpBooPPBBBBBBBoopPPPPpBBBooPPBBBBBBBpPPPPpBBBBBooPPBBBBBpPPPO1111111111111111111111111111111111111111111111111111..s.."
.ascii "..o66666666666sss..o6666666.....YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrPPpPPpPPBBBBBBBooPPBpPpPPpooPPBBBBBBBooPpPpPPpBBooPPBBBBBBBopPpPPpBBBBooPPBBBBBBpPpPORrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRr..s.."
.ascii "...oc6c6c6c6c7sss....oF6c.......YOORORORORORORORORORORrROR9WEE9ROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROrPPPPPpPBBBBBBBooPPBBpPPPPpoPPBBBBBBBooPPpPPPPpBooPPBBBBBBBoopPPPPpBBBooPPBBBBBBBpPPPORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR..s.."
.ascii "....o66666H6.7sss...ss..........YORRRRRRRRRRRRRRRRRRRRrRRR99999RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrpPPPppPBBBBBBBooPPBBpPPPppoPPBBBBBBBooPPpPPPppBooPPBBBBBBBoopPPPppBBBooPPBBBBBBBpPPPORrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRs..s.."
.ascii "......o6c6s..7sss..ss...........YOORORORORORORORORORORrROR9WEE9ROROROROROROROrORORORORORORORORORORORrROROROROROROROROROROrPPPPPpBBBBBBBooPPBBBpPPPPpPPBBBBBBBooPPBpPPPPpooPPBBBBBBBooPpPPPPpBBooPPBBBBBBBopPPPORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRs..s.."
.ascii ".........ss..7sss.sss...........YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrpPpPppBBBBBBooPPBBBBpPpPppPBBBBBBBooPPBBpPpPppoPPBBBBBBBooPPpPpPppBooPPBBBBBBBoopPpPORrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRs..sss"
.ascii "..........ss.7sss.ss............YOORRRORRRORRRORRRORRRrRRR9WEE9RRRORRRORRRORRrORRRORRRORRRORRRORRRORrRORRRORRRORRRORRRORRrPPPPPpBBBBBBooPPBBBBpPPPPpPBBBBBBBooPPBBpPPPPpoPPBBBBBBBooPPpPPPPpBooPPBBBBBBBoopPPPOrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRs.ss."
.ascii "..........sss7ssssss............YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrpPpPppBBBBBooPPBBBBBpPpPppBBBBBBBooPPBBBpPpPppPPBBBBBBBooPPBpPpPppooPPBBBBBBBooPpPpPORrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrs.ss."
.ascii "...........ssssssss.............YORRORRRORRRORRRORRRORrROR9WEE9RORRRORRRORRROrRRORRRORRRORRRORRRORRRrRRRORRRORRRORRRORRROrPPPPPpBBBBooPPBBBBBBpPPPPpBBBBBBooPPBBBBpPPPPpPBBBBBBBooPPBBpPPPPpoPPBBBBBBBooPPpPPPOrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrR.sss."
.ascii "...........sssssss..............YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrpPpPppBBBooPPBBBBBBBpPpPppBBBBBooPPBBBBBpPpPppBBBBBBBooPPBBBpPpPppPPBBBBBBBooPPBpPpPORrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrr.s.s."
.ascii "............ssssss..............YORRRRRRRRRRRRRRRRRRRRrRRR99999RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrPPPpPpBBBooPPBBBBBBBpPPpPpBBBBBooPPBBBBBpPPpPpBBBBBBBooPPBBBpPPpPpPPBBBBBBBooPPBpPPpOrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrR.s.s."
.ascii "............s7sss...............YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrpPpPppBBooPPBBBBBBBopPpPppBBBBooPPBBBBBBpPpPppBBBBBBooPPBBBBpPpPppPBBBBBBBooPPBBpPpPOPPRPPrPPrPPrPPRPPrPPrPPrPPRPPrPPrPPrPPRPPrPPrPPrPPRPs.ss."
.ascii ".............7sss...............YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrPpPPPpbooPPbbbbbbbooppPPPpbbbooPPbbbbbbbppPPPpbbbbbooPPbbbbbppPPPpbbbbbbbooPPbbbppPPOPPrPPRPPrPPRPPrPPRPPrPPRPPrPPRPPrPPRPPrPPRPPrPPRPPrPs.ss."
.ascii ".............7sss...............YORRrRRRrRRRrRRRrRRRrRrRrR9WEE9RrRRRrRRRrRRRrrRRrRRRrRRRrRRRrRRRrRRRrRRRrRRRrRRRrRRRrRRRrrpPpPppbooPPbbbbbbboopPpPppbbbooPPbbbbbbbpPpPppbbbbbooPPbbbbbpPpPppbbbbbbbooPPbbbpPpPOPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPPrPs..s."
.ascii ".............7sss...............YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrPpPpPpooPPbbbbbbbooPppPpPpbbooPPbbbbbbboppPpPpbbbbooPPbbbbbbppPpPpbbbbbbooPPbbbbppPpOpPrpPRpPrpPRpPrpPRpPrpPRpPrpPRpPrpPRpPrpPRpPrpPRpPrp.s.s."
.ascii ".............7sss...............YOrRRRrRRRrRRRrRRRrRRRrRRR9WEE9RRRrRRRrRRRrRRrrRRRrRRRrRRRrRRRrRRRrRrRrRRRrRRRrRRRrRRRrRRrpPpPppoPPbbbbbbbooPPpPpPppbooPPbbbbbbboopPpPppbbbooPPbbbbbbbpPpPppbbbbbooPPbbbbbpPpPOpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrp.s.s."
.ascii ".............7sss...............YORRRRRRRRRRRRRRRRRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrPpPPPpoPPbbbbbbbooPPppPPPpbooPPbbbbbbbooppPPPpbbbooPPbbbbbbbppPPPpbbbbbooPPbbbbbppPPOpPrpPRpPrpPrpPrpPRpPrpPrpPrpPRpPrpPrpPrpPRpPrpPrpPrp.s.s."
.ascii ".............7sss...............YOrRrRrRrRrRrRrRrRrRrRrRrR99999RrRrRrRrRrRrRrrrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrrpPpPppPPbbbbbbbooPPbpPpPppooPPbbbbbbbooPpPpPppbbooPPbbbbbbbopPpPppbbbbooPPbbbbbbpPpPOpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrssrp..ss."
.ascii ".............7sss...............YORRRDRRRDRRRDRRRDRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrPpPpPpPbbbbbbbooPPbbppPpPpoPPbbbbbbbooPPppPpPpbooPPbbbbbbbooppPpPpbbbooPPbbbbbbbppPpOpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPsp..ss."
.ascii ".............7sss...............YOrRrDrRrDrRrDrRrDrRrRrRrR9WEE9RrRrRrRrRrRrRrrrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrrpPpPppPbbbbbbbooPPbbpPpPppoPPbbbbbbbooPPpPpPppbooPPbbbbbbboopPpPppbbbooPPbbbbbbbpPpPOpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrs...s."
.ascii ".............7sss...............YORRRDRRRDRRRDRRRDRRRRrRRR9WEE9RRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRRRrRRRRRRRRRRRRRRRRRRRRrPpPpPpbbbbbbbooPPbbbppPpPpPPbbbbbbbooPPbppPpPpooPPbbbbbbbooPppPpPpbbooPPbbbbbbboppPpOpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrps..s."
.ascii ".............7sss...............YOrRrDrRrDrRrDrRrDrRrRrRrR9WEE9RrRrRrRrRrRrRrrrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrrpPpppppppppppppppppppPpppppppppppppppppppPpppppppppppppppppppPpppppppppppppppppppPppOpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrp.s.s."
.ascii ".............7sss...............YORRRDRRRDRRRDRRRDRRRrrRRr9WEE9RRrRRRrRRRrRRRrRRRrRRRrRRRrRRRrRRRrRRrrRRRrRRRrRRRrRRRrRRRrPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpPpOpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrp..ss."
.ascii ".............7sss...............YOrRrDrRrDrRrDrRrDrRrRrRrR9WEE9RrRrRrRrRrRrRrrrRrRrRrRrRrRrRrRrRrRYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYPpppPpppPpppPpppPpppPpppPpppPOpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrp...s."
.ascii ".............7sss...............YORrRDRrRDRrRDRrRDRrRRrrRR99999rRRRrRRRrRRRrRrRrRRRrRRRrRRRrRRRrRROOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOpPpPpPpPpPpPpPpPpPpPpPpPpPpPpOpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrpPrp...s."
.ascii ".............7sss...............YOrRrDrRrDrRrDrRrDrRrRrRrR9WEE9RrRrRrRrRrRrRrrrRrRrRrRrRrRrRrRrRrROOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOppPpppPpppPpppPpppPpppPpppPppOpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrp...s."
.ascii ".............7sss...............YORrRDRrRDRrRDRrRDRrRrrrRr9WEE9rRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOpPpPpPpPpPpPpPpPpPpPpPpPpPpPpOpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPp...s."
.ascii ".............7sss...............YOrRrDrRrDrRrDrRrDrRrRrRrR9WEE9RrRrRrRrRrRrRrrrRrRrRrRrRrRrRrRrRrROOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPpppPpppPpppPpppPpppPpppPpppPOpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrp...s."
.ascii ".............7sss...............YORrRDRrRDRrRDRrRDRrRrrrRr9WEE9rRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOpPpPpPpPpPpPpPpPpPpPpPpPpPpPpOpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrpPrpPPpPrpPrp...s."
.ascii ".............7sss...............YOrRrDrRrDrRrDrRrDrRrrrRrr9WEE9RrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrrRrrPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPpppppppppppppppppppppppppppppOpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrp...s."
.ascii ".............7sss...............YORrRDRrRDRrRDRrRDRrRrrrRr9WEE9rRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrRrIGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIGPpPpPpPpPpPpPpPpPpPpPpPpPpPpOpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPp...s."
.ascii ".............7sss...............GGrrrDrrrDrrrDrrrDrrrRrrGG99999rrRrrrRrrrRrrrrrrGGrrrRrrrRrrrRrrrGGGCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCIGCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCIGppppppppppppppppppppppppppppOpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrp...s."
.ascii ".............7sss...............GGRrRDRrRDRrRDRrRDRrRrrrGG9WEE9rRrRrRrRrRrRrRrRrGGRrRrRrRrRrRrRrRGGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2sIGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2IGPpPpPpPpPpPpPpPpPpPpPpPpPpPpOpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPp...s."
.ascii ".............7sss...............AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2IGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGsIGppppppppppppppppppppppppppppOpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPp...s."
.ascii ".............7sss...............GGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5GGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2sIGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2IGPpppPpppPpppPpppPpppPpppPpppOpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPp...s."
.ascii ".............7sss...............GGS5SS5SS5SS5SS5SS5SS5SSGGS5SS5SS5SS5SS5SS5SS5SSGGS5SS5SS5SS5SS5SGGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2IGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGsIGppppppppppppppppppppppppppppOpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrp...s."
.ascii ".............7sss...............GG5SS5SS5SS5SS5SS5SS5SS5GG5SS5SS5SS5SS5SS5SS5SS5GG5SS5SS5SS5SS5SSGGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2sIGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2IGppPpppPpppPpppPpppPpppPpppPpOpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPpPrpPPp...s."
.ascii ".............7sss...............GGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5GGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2IGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGsIGppppppppppppppppppppppppppppOpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPp...s."
.ascii ".............7sss...............GGS5SS5SS5SS5SS5SS5SS5SSGGS5SS5SS5SS5SS5SS5SS5SSGGS5SS5SS5SS5SS5SGGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2sIGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2IGppppppppppppppppppppppppppppOpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPp...s."
.ascii ".............7sss...............GG5SS5SS5SS5SS5SS5SS5SS5GG5SS5SS5SS5SS5SS5SS5SS5GG5SS5SS5SS5SS5SSGGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2IGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGsIGppppppppppppppppppppppppppppOpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPp...s."
.ascii ".............7sss...............GGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5GGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2sIGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2IGppPpppPpppPpppPpppPpppPpppPpOpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPpPrpPPpPPpPPp...s."
.ascii ".............7sss...............GGS5SS5SS5SS5SS5SS5SS5SSGGS5SS5SS5SS5SS5SS5SS5SSGGS5SS5SS5SS5SS5SGGGCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCIGCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCIGppppppppppppppppppppppppppppOpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPp...s."
.ascii ".............7sss...............GG5SS5SS5SS5SS5SS5SS5SS5GG5SS5SS5SS5SS5SS5SS5SS5GG5SS5SS5SS5SS5SSGGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2sIGGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2IGppppppppppppppppppppppppppppOpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPp...s."
.ascii ".............7sss...............GGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5SS5SS5SGGSS5SS5SS5SS5SS5GGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGs2IGG2s2sGs2s2G2s2sGs2s2G2s2sGs2s2G2s2sGsIG............................OpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPpPPp....."
.ascii "444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444"
.ascii "333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333"
.ascii "gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"
.ascii "gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"
.ascii "gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"

# fundo_sala_carteiras (192x32)
pal_fundo_sala_carteiras:
.byte '.',0xC7, 'y',0x1C, 'n',0x0A, 'N',0x13, 0   # . transparente, y amarelo escuro, n marrom escuro, N marrom escuro
.align 2
img_fundo_sala_carteiras:
.word 192, 32
.ascii "................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................"
.ascii "............................................................NNNNNNN.........................................................................................NNNNNNN............................."
.ascii "............................................................NNNNNNN.........................................................................................NNNNNNN............................."
.ascii "............................................................NNNNNNN.........................................................................................NNNNNNN............................."
.ascii "............................................................NNNNNNN.........................................................................................NNNNNNN............................."
.ascii "............................................................NNNNNNN.........................................................................................NNNNNNN............................."
.ascii "............................................................NNNNNNN.........................................................................................NNNNNNN............................."
.ascii "............yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy.......NNNNNNN.........................................yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy.......NNNNNNN............................."
.ascii "............yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy.......NNNNNNN.........................................yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy.......NNNNNNN............................."
.ascii "............yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy.......NNNNNNN.........................................yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy.......NNNNNNN............................."
.ascii "............yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy...........nnn.........................................yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy...........nnn............................."
.ascii "............NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...........nnn.........................................NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...........nnn............................."
.ascii "............NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...........nnn.........................................NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...........nnn............................."
.ascii "..............nn.................................nn.............nnn...........................................nn.................................nn.............nnn............................."
.ascii "..............nn.................................nn.............nnn...........................................nn.................................nn.............nnn............................."
.ascii "..............nn.................................nn.......yyyyyyyyyyyyyyyyyyyyy...............................nn.................................nn.......yyyyyyyyyyyyyyyyyyyyy................."
.ascii "..............nn.................................nn.......yyyyyyyyyyyyyyyyyyyyy...............................nn.................................nn.......yyyyyyyyyyyyyyyyyyyyy................."
.ascii "..............nn.................................nn.......yyyyyyyyyyyyyyyyyyyyy...............................nn.................................nn.......yyyyyyyyyyyyyyyyyyyyy................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."
.ascii "..............nn.................................nn.......nn....nnn.........nn................................nn.................................nn.......nn....nnn.........nn.................."

# fundo_sala_parede (4x240)
pal_fundo_sala_parede:
.byte 'S',0xB6, 'g',0x63, 's',0x5A, 'G',0x59, 'y',0x64, 'O',0x6E, 'Y',0x6D, '1',0x51   # S cinza claro, g verde escuro, s cinza escuro, G verde escuro, y amarelo escuro, O laranja, Y amarelo, 1 cinza escuro
.byte 'n',0x13, '2',0x1C, 0   # n marrom escuro, 2 amarelo escuro
.align 2
img_fundo_sala_parede:
.word 4, 240
.ascii "1111"
.ascii "1111"
.ascii "1111"
.ascii "1111"
.ascii "G111"
.ascii "1111"
.ascii "11G1"
.ascii "1111"
.ascii "G1G1"
.ascii "1G11"
.ascii "G1G1"
.ascii "111G"
.ascii "G1G1"
.ascii "1G1G"
.ascii "G1G1"
.ascii "1G1G"
.ascii "GGG1"
.ascii "1G1G"
.ascii "G1GG"
.ascii "1G1G"
.ascii "GGGG"
.ascii "1G1G"
.ascii "GGGG"
.ascii "1G1G"
.ascii "GGGG"
.ascii "GG1G"
.ascii "GGGG"
.ascii "1GGG"
.ascii "GGGG"
.ascii "GGGG"
.ascii "GGGG"
.ascii "GGGG"
.ascii "sGGG"
.ascii "GGGG"
.ascii "GGsG"
.ascii "GGGG"
.ascii "sGsG"
.ascii "GsGG"
.ascii "sGsG"
.ascii "GGGs"
.ascii "sGsG"
.ascii "GsGs"
.ascii "sGsG"
.ascii "GsGs"
.ascii "sssG"
.ascii "GsGs"
.ascii "sGss"
.ascii "GsGs"
.ascii "ssss"
.ascii "GsGs"
.ascii "ssss"
.ascii "GsGs"
.ascii "ssss"
.ascii "ssGs"
.ascii "ssss"
.ascii "Gsss"
.ascii "ssss"
.ascii "ssss"
.ascii "ssss"
.ascii "ssss"
.ascii "gsss"
.ascii "ssss"
.ascii "ssgs"
.ascii "ssss"
.ascii "gsgs"
.ascii "ssss"
.ascii "gsgs"
.ascii "sssg"
.ascii "gsgs"
.ascii "sgsg"
.ascii "gsgs"
.ascii "sgsg"
.ascii "gsgs"
.ascii "sgsg"
.ascii "gsgs"
.ascii "sgsg"
.ascii "gggg"
.ascii "sgsg"
.ascii "gggg"
.ascii "sgsg"
.ascii "gggg"
.ascii "ggsg"
.ascii "gggg"
.ascii "sggg"
.ascii "gggg"
.ascii "gggg"
.ascii "gggg"
.ascii "gggg"
.ascii "yggg"
.ascii "gggg"
.ascii "ggyg"
.ascii "gggg"
.ascii "ygyg"
.ascii "gggg"
.ascii "ygyg"
.ascii "gggg"
.ascii "ygyg"
.ascii "gygg"
.ascii "ygyg"
.ascii "gggy"
.ascii "ygyg"
.ascii "gygy"
.ascii "ygyg"
.ascii "gygy"
.ascii "yyyg"
.ascii "gygy"
.ascii "ygyy"
.ascii "gygy"
.ascii "yyyy"
.ascii "yygy"
.ascii "yyyy"
.ascii "gyyy"
.ascii "yyyy"
.ascii "yyyy"
.ascii "yyyy"
.ascii "yyyy"
.ascii "Yyyy"
.ascii "yyyy"
.ascii "yyYy"
.ascii "yyyy"
.ascii "YyYy"
.ascii "yyyy"
.ascii "YyYy"
.ascii "yyyy"
.ascii "YyYy"
.ascii "yYyy"
.ascii "YyYy"
.ascii "yyyY"
.ascii "YyYy"
.ascii "yYyY"
.ascii "YyYy"
.ascii "yYyY"
.ascii "YYYy"
.ascii "yYyY"
.ascii "YyYY"
.ascii "yYyY"
.ascii "YYYY"
.ascii "YYyY"
.ascii "YYYY"
.ascii "yYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "YYYY"
.ascii "OYYY"
.ascii "YYYY"
.ascii "YYOY"
.ascii "YYYY"
.ascii "OYOY"
.ascii "YYYY"
.ascii "nnnn"
.ascii "2222"
.ascii "2222"
.ascii "nnnn"
.ascii "OYOY"
.ascii "YYYO"
.ascii "OYOY"
.ascii "YOYO"
.ascii "OYOY"
.ascii "YOYO"
.ascii "OOOY"
.ascii "YOYO"
.ascii "OYOO"
.ascii "YOYO"
.ascii "OOOO"
.ascii "YOYO"
.ascii "OOOO"
.ascii "YOOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "OOOO"
.ascii "SOSO"
.ascii "OOOO"
.ascii "SOSO"
.ascii "OOOO"
.ascii "SOSO"
.ascii "OSOO"
.ascii "SOSO"
.ascii "OOOS"
.ascii "SOSO"
.ascii "OSOS"
.ascii "SOSO"
.ascii "OSOS"
.ascii "SSSO"
.ascii "OSOS"
.ascii "SOSS"
.ascii "OSOS"
.ascii "SSSS"
.ascii "OSOS"
.ascii "SSSS"
.ascii "OSOS"
.ascii "SSSS"
.ascii "SSOS"
.ascii "SSSS"
.ascii "OSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"
.ascii "SSSS"

# fundo_sala_quadro (256x96)
pal_fundo_sala_quadro:
.byte 'g',0x11, '.',0xC7, 'n',0x14, 'N',0x0A, 'W',0xFF, 'w',0xF6, 'S',0xB6, 'Y',0x7F   # g verde escuro, . transparente, n marrom escuro, N marrom escuro, W branco, w branco, S cinza claro, Y amarelo
.byte 's',0x49, '1',0x5A, 'B',0x89, 'r',0x03, 'K',0x00, 0   # s cinza escuro, 1 cinza escuro, B azul, r vermelho escuro, K preto
.align 2
img_fundo_sala_quadro:
.word 256, 96
.ascii "......NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN......................................................"
.ascii "......NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN......................................................"
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN......................................................"
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN......................................................"
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN......................................................"
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN......................................................"
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnngg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggnnnnNN.........................sssssss......................"
.ascii "......NNnnnngggggggggwwggggggggggggggwwgggggggggggggwggggggggggggggggggggggggggggggggwwwggggggwgwwwwgggggggggggggg11gggggwwwggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................ssssssWssssss..................."
.ascii "......NNnnnnggggggggwggggggggggggggggggwggggggggggggwgggggggggggggggggggggggggggggggggwwggggggwgggggwgggggggggwgggggggggwgggw11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.....................sssWWWWWWWWWsss.................."
.ascii "......NNnnnnggggggggwgggggggggwgggwgggwggggggggggwwwwgwgggwgggggggwwwwwgggggggwgggwggg1wgggggwggggggwgggggggggwgggggggggwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN...................sssWWWWWWsWWWWWWsss................"
.ascii "......NNnnnnggggggggwggggggggggwgwgggwwwggggggg1wgggwggwgwgggggggggggggggggggggwgwgggwwwggggwggggwwwggggggggwwwwwgggggggwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN..................sssWWsWWWWWWWWWsWWsss..............."
.ascii "......NNnnnnggggggggwgggggggggggwgggggggggggggggwgggwgggwg11ggggggwwwwwgggggggggwggggggggggwggggggggwgggggggggwgggggggggwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN..................ssWWWWWWWWWWWWWWWWWss..............."
.ascii "......NNnnnnggggggg1wggggggggggwgwggggggggggggggwgggwggwgwgggggggggggggggggggggwgwggggggggwgggggggggwgggggggggwgggggggggwgggwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.................ssWWWWWWWWWWWWWWWWWWWss.............."
.ascii "......NNnnnnggggggggwgggggggggwgggwggggggggggggggwwwwgwgggwgggggggggggggggggggwgggwgggggggwgggggwwwwgggggggggggggggggggggwwwgggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggnnnnNN................ssWWWWWWWWWWKWWWWWWWWWWss............."
.ascii "......NNnnnnggggggggwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggnnnnNN................ssWsWWWWWWWWKWWWWWWWWsWss............."
.ascii "......NNnnnnggggggwwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN................sWWWWWWWWWWWKWWWWWWWWWWWs............."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN...............ssWWWWWWWWWWWKWWWWWWWWWWWss............"
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN...............ssWWWWWWWWWWWKWWWWWWWWWWWss............"
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN...............ssWWWWWWWWWWWKWWWWWWWWWWWss............"
.ascii "......NNnnnngggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN...............sWWsWWWWWWWWWKKKKKWWWWWsWWs............"
.ascii "......NNnnnnggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN...............ssWWWWWWWWWWWWWWWWWWWWWWWss............"
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggnnnnNN...............ssWWWWWWWWWWWWWWWWWWWWWWWss............"
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN...............ssWWWWWWWWWWWWWWWWWWWWWWWss............"
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN................sWWWWWWWWWWWWWWWWWWWWWWWs............."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN................ssWsWWWWWWWWWWWWWWWWWsWss............."
.ascii "......NNnnnngggggggYYgggggYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggYgggggggggggggggggggggggggggggggggYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN................ssWWWWWWWWWWWWWWWWWWWWWss............."
.ascii "......NNnnnnggggggggYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggYggggggggggggggggggggggggggggggggYYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.................ssWWWWWWWWWWWWWWWWWWWss.............."
.ascii "......NNnnnnggggggggYggggYYgggYYgYgggggg11gggggggYYYYggYYYggYYYYggggggggYgggYggggggggggYggggggggYgggYgggggggYYYYYgggggggggYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN..................ssWWWWWWWWWWWWWWWWWss..............."
.ascii "......NNnnnnggggggggYgggggYgggYgYgYgggggggggggggYgg11gYgggYgYgggYggggggggYgYggggggggggYggggggggggYgYggggggggggggggggggggggYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN..................sssWWsWWWWWWWWWsWWsss..............."
.ascii "......NNnnnnggggggggYgggggYgggYgYgYggggggggggggggYYYggYYYYYgYgggYgggggggggYggggggggggYggggggggggggYgggggggggYYYYYgggggggggYggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggnnnnNN...................sssWWWWWWsWWWWWWsss................"
.ascii "......NNnnnnggggggggYgggggYgggYgYgYgggggggggggggggggYgYgggggYgggYggggggggYgYggggggggYggggggggggggYgYggggggggggggggggggggggYgggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggnnnnNN.....................sssWWWWWWWWWsss.................."
.ascii "......NNnnnngggggggYYYgggYYYggYgYgYgggggggggggggYYYYgggYYYggYgggYgggggggYgggYgggggggYgggggggggggYgggYggggggggggggggggggggYYYgggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggnnnnNN......................ssssssWssssss..................."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.........................sssssss......................"
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnngggggggggggggggggggggggggYYYgggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnnggggg11gggggggggggggYgggYgggYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnnggggggggggggYgggY1gggYggYggYYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnngggggggggggggYgYggYYYYYgYgYgYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnnggggggggggggggYggggggYggYYggYggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnngggggggggggggYgYggggYgggYgggYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN......................................................"
.ascii "......NNnnnnggggggggggggYgggYggggggggYYYgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS.........."
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggwwggggwggggggwgggggggggwgggggggggggggggggggggggwwwgggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggwgggggggggggwgggggwgggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggwggggggwgggggwgggggggggggwgggg11gggggggggggggggwgggwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggwgggggggggggwgggggwgggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggwwwwgggggggggwggggwgggwggggwggggggggwwwwwgggggggggggwgwgggwggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggwwwwgwgggwggggwgggwwwwgwgggwggggggggggggggggggg11ggggggnnnnNN.............SSWWWWWWWBBBBBBBBBBWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggwg11ggggggggwgggggwgwgggggwgggggggggggggggggggggggwgggwgwggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggwgggwgwgggwgggwgggwgggwggwgwggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWBBBBBBBBBBWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggwgggggggggggwggggggwggggggwggggggggwwwwwgggggggggwgggggwgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggwgggwgwgggwggwggggwg11wgggwgggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWBBWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggwggggggggggggwggggwgwggggwggggggggggggggggggggggwgggggwgwggggggggwgggwgggwgggwgggwgggwgggwgggwgggwgggw11gwgggwgggwgggwgggwgggwggwwwwgwgggggwgggwggwgwggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWBBWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggwgggggggggggggwggwgggwggwggggggggggggggggggggggwwwwwgwgggwgggggggggwgggwgggwgggwgggwgggwgggwgggwgggwgggwgggwgggwg11wgggwggwwwwgggggwgwggggggwwwwgwgggwgggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWBBWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggwwwggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWBBWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWBBWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWBBWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWWWBBWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWBBWWWWBBWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWWWWWWWWWWWWWWWWWWWWWWWSS.........."
.ascii "......NNnnnngggggggggggggggggggggggggggggg11ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWrrrrWWWWWWWWWWrWWWWWWrWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg11gggggggggggggnnnnNN.............SSWWWWWrWWWWWWWWrrWWWWWrrWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWrWWWWWWWWWrWWWWrWrWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWrrrWWWWWWWWWWrWWWrWWrWWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWrWWWWWWWWWrWWWrrrrrWWWSS.........."
.ascii "......NNnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggnnnnNN.............SSWWWWWrWWWrWWWWWrWWWWWWrWWWWSS.........."
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN.............SSWrrrrWWWWrWWWWrrrWWWWWrWWWWSS.........."
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN.............SSSSSSSSSSrSSSSSSSSSSSSSSSSSSSS.........."
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN.............SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS.........."
.ascii "......NNnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnNN......................................................"
.ascii "......NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNwwwwwwNNNNNNNNNNNNNNYYYYNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN......................................................"
.ascii "......NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNwwwwwwNNNNNNNNNNNNNNYYYYNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN......................................................"
.ascii "....NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...................................................."
.ascii "....NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...................................................."
.ascii "....NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...................................................."
.ascii "....NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN...................................................."
.ascii "................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................"

# fundo_serra (336x64)
pal_fundo_serra:
.byte '.',0xC7, 'P',0x9D, 'p',0x94, '1',0x9E, 'R',0xA6, 'r',0xAF, '2',0x8B, 0   # . transparente, P roxo/rosa, p roxo/rosa, 1 roxo/rosa, R vermelho, r vermelho, 2 roxo/rosa
.align 2
img_fundo_serra:
.word 336, 64
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "................................................................................................................................................................................................................................................................................................................................................"
.ascii "..........................................................................................................................................................................................................................................................................................................................r....................."
.ascii ".........................................................................................................................................................................................................................................................................................................................rRr1..................."
.ascii "........................................................................................................................................................................................................................................................................................................................rRRRP1.................."
.ascii "........................................................................................................................................................................................................................................................................................................................RRRRPP.................."
.ascii ".......................................................................................................................................................................................................................................................................................................................rRRRRPP.................."
.ascii ".......................................................................................................................................................................................................r...............................................................................................................RRRPRpP1................."
.ascii ".......................................................................................................................................................................................................Rr.............................................................................................................rRRPPPppP1................"
.ascii "............................................................................rr1...rr..................................................................................................................rRR............................................................................................................rRRPPPPppPP................"
.ascii "..........................................................................rrRRP11rRR1...r.............................................................................................................RRR1..........................................................................................................rRRRPPPPppPP1..............."
.ascii ".......................................................................rrrRRRRPPPRRRP111R1...rr.......................................................................................................RRRP...................r.................................................................................rr1rrRRRPPPPPpppPP1.............."
.ascii "......................................................................rRRRRRRRPPPRRRPPPPRP111RR1.....................................................................................................rRPRP1.................rRr...............................................................................rRRPRRRRRPPPPPppppPP11............"
.ascii "......................................................................RRRRRRRRpPPRRRPPPPRPPPPRRP.............................................................................rr......................RRPPPP.................RRR1..............................................................................RRRPRRRRPPPPPPppppPPPP111........."
.ascii "......................................................................RRRRRRPPpppRPPpPPPRPPPPRRP1............................................................................RR1....................rRPPPpP1...............rRRRP..............................................................................RRRPRRRPPPPPPPpppppPPPPPP1........"
.ascii ".....................................................................rRRRRPPPPpppPPPppppPpPPPRRPP...........................................................................rRRP....................RRPPPpPP1.............rRRRRP1............................................................................rRRRpRRPPPPPPPPppppppPPPPPP........"
.ascii ".....................................................................RRPPPPPPPpppPPPppppPppppPPpP...........................................................................RRRP1..................rRRPPPppPP1....r.......RRRPRPP............................................................................RRPPpPPPPPPPPPPppppppppPPPP1......."
.ascii ".....................................................................RPPPPPPPPpppPPPppppPppppPPpP1..........................................................................RRRPP..................RRPPPPppPPP111rR1.....rRRPPPpP1...........................................................................RPPPpPPPPPPPPPPpppppppppppPP......."
.ascii "....................................................................rRPPPPPPPPpppPPPppppPppppPPppP.........................................................................rRPPpP1................rRRPPPPpppPPPPPRRP11.rrRRRPPPpPP..........................................................................rRPPPpPPPPPPPpPPppppppppppppP1......"
.ascii "....................................................................RRPPPPPPPPpppPPPppppPppppPPppP1........................................................................RRPPpPP................RRPPPPPppppPPPPRRPPP1RRRRPPPPppP1.........................................................................RRPPPpPPPPPPPPPPppppppppppppPP......"
.ascii "....................................................................RPPPPPPPPPpppPPPppppPppppPPppPP........................................................................RPPPppP1..............rRRPPPPPpppppPPPRRPPPPRRRPPPPPppPP.........................................................................RPPPPpPPPPPPPPpPpppppppppppppP......"
.ascii "...................................................................rRPPPPPPPPPpppPPPppppPppppPPpppP1.....................rr11.............................................rRPPPppPP1............rRRPPPPPPppppppppRPpPPPRRRPPPPPpppP........................................................................rRPPPPpPPPPPPPPPPpppppppppppppP1....."
.ascii "...................................................................RRPPPPPPPPPpppPPPppppPppppPPpppPP...................rrRRPP1............................................RRPPPpppPP1.....rrr11rRRRPPPPPPppppppppPPpppPRRPPPPPPpppP1.......................................................................RRPPPPpPPPPPPPPPpppppppppppppppP....."
.ascii "...................................................................RPPPPPPPPPPpppPPPppppPppppPPppppP1.................rRRRRPPP...........................................rRPPPPpppPPP1...rRRRPPRRRPPPPPPPppppppppPPppppPPPPPPPPppppP......................................................................rRPPPPPpPPPPPPPPPPppppppppppppppP....."
.ascii "..................................................................rRPPPPPPPPPPpppPpPppppPppppPPppppPP1...............rRRRRRPPP1..........................................RRPPPPppppPPP11rRRRRPPRRRPPPPPpPppppppppPPppppPPPPPPPPppppP......................................................................RRPPPPPpPPPPPPPPPP2pppppppppppppP1...."
.ascii "..................................................................RRPPPPPPPPpPpppPPPppppPppppPPpppppPP...............RRRRRRppPP..........................................RRPPPPpppppPPPPRRRRRPPRRPPPPPPPPppppppppPPppppPPPPPPPPppppP1....................................................................rRRPPPPPpPPPPpPPPPPpppppppppppppppP...."
.ascii ".................................................................rRPPPPPPPPPPPpppPPpppppPppppPPpppppPP11............rRRRRPPpppP1........................................rRPPPPPppppppPPPRRRRRppRPPPPPPPPpppppppppPPppppPPPPPPPPpppppP.......................................rr......rr1..................RRPPPPPppPPPPPPPPPPp2pppppppppppppP1..."
.ascii ".................................................................RRPPPPPPPPPPppppPPPppppPp2ppPPppppppPPP111........rRRRPPPPpppPP1.......................................RRPPPPPpppppppPPRRPPPppPPPPPPPPPPppppppppPPppppPPPPPpPPpppppP1......................................RR1111rrRRP1................rRRPPPPPPpPPPPPpPPPPpppppppppppppppPP..."
.ascii "................................................................rRRPPPPpPPPPPPpppPPP2pppPppppPPpppppppPPPPP........RRRPPPPPppppPP1.....................................rRPPPPPPpppppppppRPPPPppPPPPPPPPPP2pppppppPPppppPPPPPPPPpppppPP.....................................rRRPPPPRRRRPP1..............rRRPPPPPPP2PPPPPPPPPPpp2pppppppppppppP1.."
.ascii ".........................r......................................RRPPPPPPPPPPPP2ppPPPppppPpp2pPPpppppppPPPPP1......rRRPPPPPPppppPPP....................................rRRPPPPPPpppppppppPPPPPppPPPPPPPPPPppppppppPPppppPPPPPPpPppppppP1....................................RRRPPPPRRRRPPP.............rRRRPPPPPPPpPPPPPPpPPPppppppppp2ppppppPP1."
.ascii "........................rR111..................................rRRPPPPPPpPPPPPpppPPPp2ppPppppPPpppppppppPPPP1....rRRRPPPPPPpppppPP...................................rRRRPPPPPPpppppppppPPPPPppPPPPPPPPPPp2ppppppPPppppPPPPPPPPppppppPP1...................................RRRPPPPRRRRpPP1..........rrRRRPPPPPPPPppPPPPPPPPPppp2pppppppppppppPP."
.ascii "..................rr..rrRRPPP1.................................RRPPPPPPPPPPPPPp2pPPPppppPppp2PPppppppppppppPP111rRRRPPPPPPPppppppP1.................................rRRRPPPPPPPpppppppppPPPPPppPPPPPpPPPPppppppppPPppppPPPPPPPppppppppPP1.................................rRPPppppRRPPppPP.........rRRRRRPPPPPPPPpPPPPPPPpPPpppppppppp2ppppppPP1"
.ascii "11...............rRR11RRRRPPPP1...............................rRRPPPPPPPPpPPPPpppPPPpp2pPppppPPppppppppppppPPPPPRRRPPPPPPPPpppppppP.................................RRRRPPPPPPPpppppppppPPPPPppPPPPPPPPPPpp2pppppPPppppPPPPPPPPpppppppPPP1................................RRPPppppPPPPpppP1.......rRRRRRPPPPPPPPPpPpPPPPPPPPpppp2pppppppppppppPP"
.ascii "PP.............rrRRRPPRRRRPPPPP1............................rrRRPPPPPPPPPPPPPPpp2PPPppppPpppppPpppppppppppppPPPPRRRPPPPPPPPpppppppP................................rRRRPPPPpPPPpppppppppPPPPPppPPPPPPpPPPppppppppPpppppPPPPPPPP2pppppppPPP...............................rRPPPppppPPPPpppPP1.....rRRRRRPPPPPPpPPPpPPPPPPPPpPppppppppppp2pppppppP"
.ascii "PP1..........rrRRRRRPPRRRPpppPPP1..rr......................rRRRRPPPPPPPPPPpPPPpppPPPppp2PppppPPppppppppppppppPPPRRPPPPPPPPPpppppppP1...............................RRRPPPPPPPPPpppppppppPPPPPppPPPPPPPPPPppp2ppppPPppppPPpPPPPPpppppppppPP...............................RRPPPppppPPPPppppPP1...rRRRRRPPPPPPPPPPPpPPpPPPPPPPppppp2pppppppppppppP"
.ascii "PPP1.........RRRRRRRPPRRPPppppPPP11RR11....rr1.............RRRRPPPPPpPPPPPPPPPppppPPppppPppppPppppppppppppppppppRPPPPPPPPPPppppppppP...............................RRPPPPPPPpPPpppppppppPPPPPppPPPPPPPpPPppppppppPP2pppPPPPPPPPp2ppppppppP1.............................rRRPPPppppPPPPppppPPP111RRRRPPPPPPPPPPpPPpPPPPPPPPPppppppppppppp2ppppppp"
.ascii "ppPP........rRRRRRPPppPPPPpppppPPPPRRPP111rRRP111.........rRRRRPPPPPPPPPPPPpPPpppPPPpppppppppPPpppppppppppppppppPPPPPPPPPPPppppppppP1.............................rRPPPPPPPPPPPpppp2ppppPPPPPppPpPPPPPPPPpppp2pppPPppppPPPpPPPPpppppppppppP............................rRRPPPPppppPPPPpppppPPPPPRRRPPPPPPPPPPPPPPpPPPpPPPPPPpppppp2ppppppppppppp"
.ascii "ppPP1......rRRRRRPPPppPPPPppppppPPPRRPPPPPRRRPPPP.........RRRRPPPPPPPpPPPPPPPPpppPpPppppPppppPP2ppppppppppppppppPPPPPPPPPpPppppppppPP.............................RRPPPPPPPPPpPpppppppppPPpPPppPPPPPPPPpPppppppppPPp2ppPPPPPPPPpp2ppppppppP1....................rr....rRRRPPPPppppPPPPppppppPPPPRRPPPPPPPPPPPPPpPpPPPPPPPPPP2pppppppppppp2pppppp"
.ascii "pppPP1....rRRRRPPPPPppPPPPpppppppPPRRPPPPPRRRPPPP1.......rRRPPPPPPPPPPPPPPPPpPpppPPPppppP2pppPPpppppppppppppppppPPPPPPPPPPPpppppppppP1...........................rRPPPPPPPPPPPPppppp2pppPPPPPppPPpPPPPPPPppppp2ppPPppppPPPPpPPPpppppppppppPP..............rrr1rrRR111rRRRPPPPPppppPPPPpppppppPPPRPPPPPPPPPPPPPPPPpPPPPpPPPPPppppppp2pppppppppppp"
.ascii "ppppPP111rRRRPPPPPPPppPPPPpppppppppPPppPPPRRRpPPPP1.....rRRPPPPPPPPPPPpPPPPPPPpppPPpppppPppppPPp2pppppppppppppppPPPPPPPPPPppppppppppPP1............rr...r.......rRRPPPPPPPPPPPppppppppppPPPpPppPPPPPPPPPpppppppppPPpp2pPPPPPPPPppp2ppppppppP1............rRRRPRRRRPPPRRRRPPPPPppppPPPPppppppppppPPPPPPPPPPPPPPPPppPPPPPPPPPPp2pppppppppppp2ppppp"
.ascii "pp1pPP1PPR1RRP1PPP1Ppp1PPP1ppp1ppp1PPp1ppp1PPp1ppP11...rRR1PPP1PPP1PPP1PPP1PPp1ppP1Ppp1pPp1ppP1ppp1ppp1ppp1ppp1pPP1PPP1PPP1ppp1ppp1ppP11....rr1...rRR11rR1......RR1PPP1PPP1PPP1ppp1pp21pPP1PPp1PPP1PPP1PPp1ppp12pP1ppp1PPP1PpP1ppp1ppp1ppp1PP1.......rr1rR1RRP1RRR1PPR1RPP1PPP1ppp1PPP1ppp1ppp1pPP1PPP1PPP1PPP1PPp1PPP1pPP1Ppp1ppp1p2p1ppp1ppp1p"
.ascii "pppppPPPPRRRPPPPPPPPppPPPPpppppppppPPpppppPPPppppPPP111RRRPPPPPPPPPPPPPpPPPPPPpppPPP2pppPppppPPpp2ppppppppppppppPPPPPPPPPPP2pppppppppPPP111rRRP11rRRRPPRRP1....rRRPPPPPPPPPPPPP2ppppppppPPPPpppPPPPPPPPPP2pppppppPPppp2PPPPPPPPpppp2ppppppppPP......rRRPRRRRRPRRRRPPPRRPPPPPPPppppPPPPppppppppppPPPPPPPPPPPPPPPPP2PPPPPPPPPPpp2pppppppppppp2pppp"
.ascii "1p1p1p1P1R1P1P1P1P1P1p1P1P1p1p1p1p1P1p1p1p1P1p1p1p1P1P1R1R1P1P1P1p1P1P1P1P1P1P1p1P1P1p1p1p121P1p1p1p1p1p1p1p1p1p1P1P1p1P1P1p1p1p1p1p1p1P1P1R1R1P1R1R1P1R1P1111rR1R1P1P1P1p1P1P1p1p1p1p1p1P1P1p1P1P1p1P1P1p1p1p1p1P1p1p1P1P1P1p1p1p1p1p1p1p1p1P11..rr1R1P1R1R1p1R1P1p1R1P1P1P1P1p121P1P1p1p1p1p1p1P1P1P1P1P1p1P1P1p1P1P1P1P1P1p1p1p1p121p1p1p1p1p"
.ascii "p1ppp1ppp1PPP1PPP1PPp1PPP1ppp1ppp1pPP1ppp1PPP1ppp1pPP1PRR1PPP1PPP1PPP1PPp1PPP1ppp1PPp1ppP1ppp1Ppp12pp1ppp1ppp1ppP1PPP1PPP1Pp21ppp1ppp1pPP1PRR1PPP1RRR1PRR1PPP1RRR1PPP1PPP1PPP1Pp21ppp1ppP1PPP1pPP1PPP1PPP12pp1ppp1Ppp1ppP1PPP1Ppp1pp21ppp1ppp1PP11RRR1RPR1PPP1PPP1ppp1PPP1PpP1ppp1PPP1pp21ppp1ppP1PPP1PPP1PPP1PPP1pPP1PPP1PPp1p2p1ppp1ppp1pp21pp"
.ascii "1p1p1p1p1P1P1P1P1P1P1p1P1P1p1p1p1p1P1p1p1p1P1p1p1p1p1P1R1P1P1P1P1P1P1P1P1P1P1P121P1P1p1p1p1p1P1p1p1p1p1p121p1p1p1P1P1P1P1P1p1p1p1p1p1p1p1P1R1R1P1R1P1p1R1p1P1P1R1P1P1P1P1P1P1P1p1p1p1p121P1P1p1P1P1P1P1P1p1p1p1p1p1p1p1P1P1P1P1p1p1p1p1p1p1p1p1P1P1R1R1p1P1P1p1P1P1p1P1P1P1P1P1p1p1P1P1p1p1p1p1p1P1P1P1P1P1P1P1P1p1P1P1P1p1P1p1p1p1p1p1p1p1p1p1p"
.ascii "ppp1ppp1pPP1PPP1PPP1ppP1PPp1ppp1ppp1Ppp1ppP1Ppp1ppp1ppp1PPP1PPP1PPP1PPP1PpP1PPp1pPP1pp21Ppp1pPP1ppp1ppp1ppp1ppp1PPP1PPP1PPP1p2p1ppp1ppp1ppp1PPp1pRP1Ppp1Ppp1PPR1PPP1PPP1PPP1PPP1p2p1ppp1PPP1Pp21PPP1PPP1Ppp1ppp1pPP1ppp1pPP1PPP1ppp1p2p1ppp1ppP1PPR1RPP1PPP1PpP1PPp1pPP1PPP1pPp1ppP1PPp1p2p1ppp1PPP1PPp1PPP1PPP1PpP1PPP1PPP1ppp12pp1ppp1ppp1p2p1"
.ascii "1p1p1p1p1P1P1P1P1P1P1p1P1P1p1p1p1p1P1p1p1p1P1p1p1p1p1p1P1P1P1P1P1P1p1P1P1P1P1P1p1P1P1p1p1p1p1p1p1p1p1p1p1p1p1p1p1P1P1P1p1P1p1p1p1p1p1p1p1p1P1P1p1P1P1p1P1p1p1p1P1P1P1P1P1P1p1P1p1p1p1p1p1P1P1p1P1P1P1p1P1p1p1p1p1P1p1p1P1P1P1P121p1p1p1p1p1p1p1p1P1R1P1p1P1P1p1P1P1p1P1P1P1P1P1p1p1p1P1p1p1p1p1p1P1P1P1P1P1P1p1P1p1P1P1P1P1P1p1p1p1p1p121p1p1p1p"
.ascii "p1p1p1p1p1P1P1P1P1P1p1p1P1p1p1p1p1p1P1p1p1P1P1p1p1p1p1p1P1P1P1P1P1P1P1P1P1p1P1p1p1P1p1p1P1p1p1P1p1p121p1p1p1p1p1P1P1P1P1P1P1p121p1p1p1p1p1p1P1p1p1P1P1p1P1p1p1P1P1P1P1P1P1P1P1P1p121p1p1P1P1P1p1P1P1P1P1P1p121p1p1P1p1p1P1P1P1P1p1p1p121p1p1p1p1p1P1P1P1P1P1P1P1P1p1p1P1P1P1P1p1p1P1P1p1p121p1p1P1P1P1P1P1P1P1P1P1P1p1P1P1P1p1p1p1p1p1p1p1p1p121"
.ascii "1p111p111P111P111P111p111P1112111p111p111p111p111p111p111P111P111P111P111P111P111p111p111p111P111p111p111p111p111P111P111P111p111p111p111p111P111P111p111p111p111P111P111P111P111p111p111p111p111P111P111p111p111P111p111P111P111p111p111p111p111p111P111P111p111P111P111P111P111p111P111p111p111p111P111P111P111p111P111P111p111p111p111p111p11"
.ascii "p1p1p1p1p1P1P1P1P1P1p1P1P1p1p1p1p1p1p1p1p1P1P1p1p1p1p1p1P1P1P1p1P1P1P1P1P1P1P1p1p1P1p1p1p1p1p1P1p1p1p1p1p1p1p1p1P1p1P1P1P1P1p1p1p1p1p1p1p1p1P1p1p1P1P1p1P1p1p1P1P1P1P1p1P1P1P1P1p1p1p1p1P1P1P1p1p1P1P1P1P1p1p1p1p1P1p1p1P1p1P1P1p1p1p1p1p1p1p1p1p1P1P1P1P1P1P1P1P1p1p1P1P1P1P121p1P1P1p1p1p1p1p1P1P1P1P1p1P1P1P1P1P1P1P1P1P1p1p1p121p1p1p1p1p1p1"
.ascii "111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"
.ascii "11p111p111P111P111P111P111p111p111p111p111P111p111p111p111P111P111P111P111P111p111P111p111p111P111p1112111p111p111P111P111P111p111p111p111p111p111P111p111p111P111P111P111P111P111p111p111P111p111P111P111p1112111P111p111P111P111p111p111p111p111P111P111P111P111p111P111P111p111P111p111p111p111P111P111P111P111P111p111P111p111p111p111p111p1"
.ascii "111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"
.ascii "p111p111p111p111P111p111P111p111p111P111p111P111p111p111P111P111p111P111P111P111p111p111P111p111p111p111p111p111P111p111P111p111p111p111p111P111p111P111P111p111P111P111p111P111p111p111P111P111P111P111P111p111p111p111P111p111p111p111p111p111p111P111P111P111P111p111P111P1112111P111p111p111P111P111P111P111P111P111P111p111p1112111p111p111"

# fundo_sol (48x48)
pal_fundo_sol:
.byte '.',0xC7, 'Y',0x77, 'y',0x7F, '1',0xBF, 'O',0x6F, 0   # . transparente, Y amarelo, y amarelo, 1 amarelo, O laranja
.align 2
img_fundo_sol:
.word 48, 48
.ascii "....................O.O.O.O.O..................."
.ascii ".................O.O.O.O.O.O.O.O................"
.ascii "..............O.O.O.O.O.O.O.O.O.O.O............."
.ascii ".............O.O.O.YYYYYYYYYYO.O.O.O............"
.ascii "..........O.O.O.YYYYYYYYYYYYYYYYO.O.O..........."
.ascii ".........O.O.OYYYYYYYYYYYYYYYYYYYY.O.O.........."
.ascii "........O.O.YYYYYYYYYYYYYYYYYYYYYYYYO.O........."
.ascii ".......O.O.YYYYYYYYYyyyyyyyyYYYYYYYYYO.O........"
.ascii "......O.O.YYYYYYYyyyyyyyyyyyyyyYYYYYYYO.O......."
.ascii ".....O.O.YYYYYYyyyyyyyyyyyyyyyyyyYYYYYYO.O......"
.ascii "....O.O.YYYYYYyyyyyyyyyyyyyyyyyyyyYYYYYYO.O....."
.ascii ".....O.YYYYYyyyyyyyyyyyyyyyyyyyyyyyyYYYYYO.O...."
.ascii "....O.YYYYYyyyyyyyyyy111111yyyyyyyyyyYYYYYO.O..."
.ascii "...O.OYYYYYyyyyyyy111111111111yyyyyyyYYYYY.O.O.."
.ascii "..O.OYYYYYyyyyyyy11111111111111yyyyyyyYYYYY.O..."
.ascii "...O.YYYYyyyyyyy1111111111111111yyyyyyyYYYYO.O.."
.ascii "..O.YYYYYyyyyyy111111111111111111yyyyyyYYYYYO.O."
.ascii ".O.OYYYYyyyyyy11111111111111111111yyyyyyYYYY.O.."
.ascii "..O.YYYYyyyyy1111111111111111111111yyyyyYYYYO.O."
.ascii ".O.YYYYYyyyyy1111111111111111111111yyyyyYYYYYO.O"
.ascii "O.OYYYYyyyyyy1111111111111111111111yyyyyyYYYY.O."
.ascii ".O.YYYYyyyyy111111111111111111111111yyyyyYYYYO.O"
.ascii "O.OYYYYyyyyy111111111111111111111111yyyyyYYYY.O."
.ascii ".O.YYYYyyyyy111111111111111111111111yyyyyYYYYO.O"
.ascii "O.OYYYYyyyyy111111111111111111111111yyyyyYYYY.O."
.ascii ".O.YYYYyyyyy111111111111111111111111yyyyyYYYYO.O"
.ascii "O.OYYYYyyyyy111111111111111111111111yyyyyYYYY.O."
.ascii ".O.YYYYyyyyyy1111111111111111111111yyyyyyYYYYO.O"
.ascii "O.OYYYYYyyyyy1111111111111111111111yyyyyYYYYY.O."
.ascii ".O.OYYYYyyyyy1111111111111111111111yyyyyYYYY.O.."
.ascii "..O.YYYYyyyyyy11111111111111111111yyyyyyYYYYO.O."
.ascii ".O.OYYYYYyyyyyy111111111111111111yyyyyyYYYYY.O.."
.ascii "..O.OYYYYyyyyyyy1111111111111111yyyyyyyYYYY.O..."
.ascii "...O.YYYYYyyyyyyy11111111111111yyyyyyyYYYYYO.O.."
.ascii "..O.O.YYYYYyyyyyyy111111111111yyyyyyyYYYYYO.O..."
.ascii "...O.OYYYYYyyyyyyyyyy111111yyyyyyyyyyYYYYY.O...."
.ascii "....O.OYYYYYyyyyyyyyyyyyyyyyyyyyyyyyYYYYY.O....."
.ascii ".....O.OYYYYYYyyyyyyyyyyyyyyyyyyyyYYYYYY.O.O...."
.ascii "......O.OYYYYYYyyyyyyyyyyyyyyyyyyYYYYYY.O.O....."
.ascii ".......O.OYYYYYYYyyyyyyyyyyyyyyYYYYYYY.O.O......"
.ascii "........O.OYYYYYYYYYyyyyyyyyYYYYYYYYY.O.O......."
.ascii ".........O.OYYYYYYYYYYYYYYYYYYYYYYYY.O.O........"
.ascii "..........O.O.YYYYYYYYYYYYYYYYYYYYO.O.O........."
.ascii "...........O.O.OYYYYYYYYYYYYYYYY.O.O.O.........."
.ascii "............O.O.O.OYYYYYYYYYY.O.O.O............."
.ascii ".............O.O.O.O.O.O.O.O.O.O.O.............."
.ascii "................O.O.O.O.O.O.O.O................."
.ascii "...................O.O.O.O.O...................."

# monstro_aoc (16x16)
pal_monstro_aoc:
.byte '.',0xC7, 's',0x52, 'S',0x49, 'Y',0x37, 'B',0x9B, 'K',0x00, 'R',0x0E, 'W',0xFF, 0   # . transparente, s cinza escuro, S cinza escuro, Y amarelo, B azul, K preto, R vermelho, W branco
.align 2
img_monstro_aoc:
.word 16, 16
.ascii "................"
.ascii "................"
.ascii "................"
.ascii "...SSSSssSSSS..."
.ascii "...SBBBSSBBBS..."
.ascii ".YYSssssssssSYY."
.ascii "...SsWKssWKsS..."
.ascii ".YYSsWKssWKsSYY."
.ascii "...SssssssssS..."
.ascii ".YYSssssssssSYY."
.ascii "...SssRRRRssS..."
.ascii ".YYSssssssssSYY."
.ascii "...SSSSSSSSSS..."
.ascii "....Y.Y..Y.Y...."
.ascii "....Y.Y..Y.Y...."
.ascii "....Y.Y..Y.Y...."

# monstro_calculo (16x16)
pal_monstro_calculo:
.byte 'P',0x95, '.',0xC7, 'p',0x41, '1',0xE6, 'W',0xFF, 'K',0x00, 0   # P roxo/rosa, . transparente, p roxo/rosa escuro, 1 roxo/rosa, W branco, K preto
.align 2
img_monstro_calculo:
.word 16, 16
.ascii "................"
.ascii "...pppppppppp..."
.ascii "..p111p11p111p.."
.ascii ".p11pp1111pp11p."
.ascii ".p11WKPPPKWPPPp."
.ascii ".p11WKPPPKWPPPp."
.ascii ".p11PPPPPPPPPPp."
.ascii ".p11PPKKKKPPPPp."
.ascii ".p11PPPPWWPPPPp."
.ascii ".p11PPPWPPPPPPp."
.ascii ".p11PPPWPPPPPPp."
.ascii ".p11PPPWPPPPPPp."
.ascii ".p11PPWPPPPPPPp."
.ascii ".p11PWWPPPPPPPp."
.ascii "..pppppppppppp.."
.ascii "...ppp....ppp..."

# monstro_derivada (16x16)
pal_monstro_derivada:
.byte 'O',0x27, '.',0xC7, 'n',0x0B, 'Y',0x77, 'K',0x00, 'W',0xFF, 0   # O laranja, . transparente, n marrom escuro, Y amarelo, K preto, W branco
.align 2
img_monstro_derivada:
.word 16, 16
.ascii "................"
.ascii "................"
.ascii "....nnnnnnnn...."
.ascii "...nOOOOOOOOn..."
.ascii "..nOYYOOOnOOOn.."
.ascii ".nOOYOOOOWKOWKn."
.ascii "nOOYOOOOOOOOOOOn"
.ascii "nOOOOOOOOOOOOOOn"
.ascii "nOOOOOnOOOOOOOOn"
.ascii "nOOOOOnOnOnOOOOn"
.ascii "nOOOnnnOOnOOOOOn"
.ascii ".nOOnOnOnOnOOOn."
.ascii "..nOnnnOnOnOOn.."
.ascii "...nOOOOOOOOn..."
.ascii "..nnnnnnnnnnnn.."
.ascii "...nnn....nnn..."

# monstro_integral (16x16)
pal_monstro_integral:
.byte '.',0xC7, 'G',0x2A, 'g',0x10, '1',0x75, 'R',0x0F, 'K',0x00, 'W',0xFF, 0   # . transparente, G verde, g verde escuro, 1 verde, R vermelho, K preto, W branco
.align 2
img_monstro_integral:
.word 16, 16
.ascii "..........gg...."
.ascii ".........gGGggg."
.ascii "........gGGGGGGg"
.ascii ".......gGGGGWKGg"
.ascii "......g1GGgGGGGG"
.ascii "......g1GGgGGGGg"
.ascii "......g1GGggggRR"
.ascii "......g1GGg....."
.ascii "......g1GGg....."
.ascii "...g..g1GGg....."
.ascii "..gGggg1GGg....."
.ascii ".gGGGG1GGg......"
.ascii "..gGGGGGg......."
.ascii "..ggGGGg........"
.ascii "....ggg........."
.ascii "................"

# monstro_lim (16x16)
pal_monstro_lim:
.byte 'W',0xF6, 'B',0x8A, '.',0xC7, 'b',0xED, 'K',0x00, 'w',0xFF, 0   # W branco, B azul, . transparente, b azul, K preto, w branco
.align 2
img_monstro_lim:
.word 16, 16
.ascii "......BBBB......"
.ascii "....BBWWWWBB...."
.ascii "...BWWWWWWWWB..."
.ascii "..BWWWWWwWWWbB.."
.ascii ".BWWWWWWKWWKbbB."
.ascii ".BWWWWWWWWWWbbB."
.ascii ".BWWWWWWWWWWbbB."
.ascii ".BWBWBWWWWWWbbB."
.ascii "BWWBWWWBBBBWbbbB"
.ascii "BWWBWBWBWBWBbbbB"
.ascii "BWWBWBWBWBWBbbbB"
.ascii "BWWBWBWBWBWBbbbB"
.ascii "BWWWWWWWWWWWbbbB"
.ascii "BWBBWWBBWWBBbbB."
.ascii ".BBWWBBWWBBWbB.."
.ascii "...BB..BB..BB..."

# proj_integral (8x16)
pal_proj_integral:
.byte '.',0xC7, 'r',0x0C, 'Y',0x37, 0   # . transparente, r vermelho escuro, Y amarelo
.align 2
img_proj_integral:
.word 8, 16
.ascii ".....rr."
.ascii "...rrYYr"
.ascii "..rYYYYr"
.ascii "..rYYrr."
.ascii "..rYYr.."
.ascii "..rYYr.."
.ascii "..rYYr.."
.ascii "..rYYr.."
.ascii "..rYYr.."
.ascii "..rYYr.."
.ascii "..rYYr.."
.ascii ".rrYYr.."
.ascii "rYYYr..."
.ascii "rYYr...."
.ascii "YYr....."
.ascii "rr......"

# tela_game_over (208x64)
pal_tela_game_over:
.byte 'K',0x00, 'R',0x0E, 'W',0xFF, 's',0x52, 0   # K preto, R vermelho, W branco, s cinza escuro
.align 2
img_tela_game_over:
.word 208, 64
.ascii "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
.ascii "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
.ascii "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
.ascii "RRRKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKRRR"
.ascii "RRRKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKRRR"
.ascii "RRRKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKRRR"
.ascii "RRRKKKssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKRRRRRRRRKKKKKKKKKKKRRRRRRKKKKKKKKRRRRRKKKKKKKKKRRRRRKKKKKRRRRRRRRRRRRKKKKKKKKKKKKKKKKKKRRRRRRRKKKKKKRRRRKKKKKKKKKKRRRRKKRRRRRRRRRRRRKKKKKRRRRRRRRRRRKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKRRRRRRRRRRRRKKKKKKKKKRRRRRRKKKKKKKKRRRRRRKKKKKKKRRRRRRKKKKKRRRRRRRRRRRRKKKKKKKKKKKKKKKRRRRRRRRRRRRKKKKKRRRRKKKKKKKKRRRRKKKRRRRRRRRRRRRKKKKKRRRRRRRRRRRRRKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKRRRRRRRRRRRRRRKKKKKKKKRRRRRRRRKKKKKKKRRRRRRKKKKKKKRRRRRRKKKKKRRRRRRRRRRRRKKKKKKKKKKKKKKRRRRRRRRRRRRRRKKKKRRRRKKKKKKKKRRRRKKKRRRRRRRRRRRRKKKKKRRRRRRRRRRRRRKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKRRRRRKKKKKKRRRKKKKKKKKRRRRRRRRKKKKKKKRRRRRRRKKKKKRRRRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKKRRRRRRKKKKRRRRRRKKKRRRRKKKKKKKKRRRRKKKRRRRKKKKKKKKKKKKKRRRRKKKKKRRRRRKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKRRRRRKKKKKKKKKRKKKKKKKKRRRRRRRRKKKKKKKRRRRRRRKKKKKRRRRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKRRRRKKKKRRRRKKKKKKRRRRKKKKRRRRKKKKKKKKKKKKKRRRRKKKKKKRRRRKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKKKKKKKKKKKRRRRRRRRRRKKKKKKRRRRRRRKKKKKRRRRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKRRRRRKKKKKKKKRRRRKKKKRRRRKKKKKKRRRRKKKKRRRRKKKKKKKKKKKKKRRRRKKKKKKRRRRKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKKKKKKKKKKKKRRRRKKRRRRKKKKKKRRRRKRRRKKKRRRKRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKKKRRRRKKKRRRRRKKKKRRRRRKKKKRRRRKKKKKKKKKKKKKRRRRKKKKKKRRRRKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKKKKKKKKKKKKRRRRKKRRRRKKKKKKRRRRKRRRKKKRRRKRRRRKKKKKRRRRRRRRRRRKKKKKKKKKKKKKRRRRKKKKKKKKKKRRRRKKKKRRRRKKKKRRRRKKKKKRRRRRRRRRRRKKKKKKRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKRRRRKKKKKKRRRRRRRKKKKKRRRRRKKRRRRRKKKKKRRRRKRRRRKRRRRKRRRRKKKKKRRRRRRRRRRRKKKKKKKKKKKKKRRRRKKKKKKKKKKRRRRKKKKRRRRKKKKRRRRKKKKKRRRRRRRRRRRKKKKKKRRRRRRRRRRRRRKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKRRRRKKKKKKRRRRRRRKKKKKRRRRKKKKRRRRKKKKKRRRRKKRRRKRRRKKRRRRKKKKKRRRRRRRRRRRKKKKKKKKKKKKKRRRRKKKKKKKKKKRRRRKKKKRRRRRKKRRRRRKKKKKRRRRRRRRRRRKKKKKKRRRRRRRRRRRKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKRRRRKKKKKKRRRRRRRKKKKKRRRRKKKKRRRRKKKKKRRRRKKRRRKRRRKKRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKKKRRRRKKKKKRRRRKKRRRRKKKKKKRRRRKKKKKKKKKKKKKRRRRRRRRRRRRRKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKKRRRRKKKKRRRRRKKKKRRRRRKKKKRRRRKKKRRRRRKKKRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKKKRRRRKKKKKRRRRKKRRRRKKKKKKRRRRKKKKKKKKKKKKKRRRRKKKKRRRRRKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKRRRRKKKKRRRRRRRRRRRRRRKKKKRRRRKKKRRRRRKKKRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKRRRRRKKKKKKKKRRRRKKKKKKRRRRRRRRRRKKKKKKRRRRKKKKKKKKKKKKKRRRRKKKKKRRRRRKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKRRRRRKKKKKKKRRRRKKKKRRRRRRRRRRRRRRKKKKRRRRKKKRRRRRKKKRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKKRRRRKKKKKKKKRRRRKKKKKKKRRRRRRRRKKKKKKKRRRRKKKKKKKKKKKKKRRRRKKKKKKRRRRKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKRRRRRKKKKKKRRRRKKKRRRRRRRRRRRRRRRRKKKRRRRKKKKRRRKKKKRRRRKKKKKRRRRKKKKKKKKKKKKKKKKKKKKKRRRRRRKKKKRRRRRKKKKKKKKRRRRRRRRKKKKKKKRRRRKKKKKKKKKKKKKRRRRKKKKKKRRRRRKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKRRRRRRRRRRRRRRRKKKRRRRKKKKKKKKRRRRKKKRRRRKKKKKKKKKKKRRRRKKKKKRRRRRRRRRRRRKKKKKKKKKKKKKKRRRRRRRRRRRRRRKKKKKKKKRRRRRRRRKKKKKKKRRRRRRRRRRRRKKKKKRRRRKKKKKKKRRRRKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKRRRRRRRRRRRRRKKKRRRRKKKKKKKKRRRRKKKRRRRKKKKKKKKKKKRRRRKKKKKRRRRRRRRRRRRKKKKKKKKKKKKKKKRRRRRRRRRRRKKKKKKKKKKKRRRRRRKKKKKKKKRRRRRRRRRRRRKKKKKRRRRKKKKKKKRRRRKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKRRRRRRRRKKKKKRRRRKKKKKKKKKKRRRRKKRRRRKKKKKKKKKKKRRRRKKKKKRRRRRRRRRRRRKKKKKKKKKKKKKKKKKRRRRRRRKKKKKKKKKKKKKRRRRRRKKKKKKKKRRRRRRRRRRRRKKKKKRRRRKKKKKKKRRRRRKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWWWWWKKWWWKKWWKWWWWWWWWWWWWWWKKWWWWWKKKKKKKKKKKKKKKKKKKWWWWWWWWKWWWWWWKWWWKKWWKWWWWWWWWKKWWKKKKWWWWWKKKKKKKKWWWWWKKKKWWWWWWKKKKKWWWKKWWKKKKWWWWKKWWKKKKWWKKKKWWWWKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWKKKKKKWWWKKWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKKKKKKKKKKKKKKKKWWKKKKWWKKKKKWWWKKWWKKKKWWKKKKWWWWKKKWWKKWWKKKKKKKWWKKWWKKKWWKKKKKKKKKWWWKKWWKKKWWKKWWKKWWKKWWKKKKWWKKWWKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWKKKKKKWWWKKWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKKKKKKKKKKKKKKKKWWKKKKWWKKKKKWWWKKWWKKKKWWKKKKWWWWKKKWWKKWWKKKKKKKWWKKKWWKKWWKKKKKKKKKWWWKKWWKKWWKKKKWWKWWKKWWKKKWWKKKKWWKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWWWWWKKWWKWKWWKKKKWWKKKWWWWWWKKWWKKWWKKKKKKWWWWWWWKKKKKKKKWWKKKKWWWWWWKWWKWKWWKKKKWWKKKKWKKWKKKWWKKWWKKKKKKKWWKKKWWKKWWWWWWKKKKKWWKWKWWKKWWKKKKWWKWWKKWWKKKWWKKKKWWKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWKKKKKKWWKWKWWKKKKWWKKKWWKKKKKKWWWWWKKKKKKKKKKKKKKKKKKKKKKWWKKKKWWKKKKKWWKWKWWKKKKWWKKKWWKKWWKKWWWWWKKKKKKKKWWKKKWWKKWWKKKKKKKKKWWKWKWWKKWWKKKKWWKKWKKWKKKKWWKKKKWWKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWKKKKKKWWKKWWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKWWWWWWWKKKKKKKKWWKKKKWWKKKKKWWKKWWWKKKKWWKKKWWWWWWKKWWKKWWKKKKKKKWWKKKWWKKWWKKKKKKKKKWWKKWWWKKWWKKKKWWKKWWWWKKKKWWKKKKWWKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWKKKKKKWWKKWWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKKKKKKKKKKKKKKKKWWKKKKWWKKKKKWWKKWWWKKKKWWKKKWWKKWWKKWWKKWWKKKKKKKWWKKWWKKKWWKKKKKKKKKWWKKWWWKKKWWKKWWKKKWWWWKKKKKWWKKWWKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKWWWWWWKKWWKKWWWKKKKWWKKKWWWWWWKKWWKKKWWKKKKKKKKKKKKKKKKKKKKWWKKKKWWWWWWKWWKKWWWKKKKWWKKWWKKKKWWKWWKKKWWKKKKKKWWWWWKKKKWWWWWWKKKKKWWKKWWWKKKKWWWWKKKKKWWKKKKKKKWWWWKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKRRR"
.ascii "RRRKKKssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssKKKRRR"
.ascii "RRRKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKRRR"
.ascii "RRRKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKRRR"
.ascii "RRRKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKRRR"
.ascii "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
.ascii "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
.ascii "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"

# tela_vitoria (208x64)
pal_tela_vitoria:
.byte 'K',0x00, 'Y',0x37, 'W',0xFF, 's',0x52, 0   # K preto, Y amarelo, W branco, s cinza escuro
.align 2
img_tela_vitoria:
.word 208, 64
.ascii "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
.ascii "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
.ascii "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
.ascii "YYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYY"
.ascii "YYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYY"
.ascii "YYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYY"
.ascii "YYYKKKssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYYYYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYKKKKYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKYYYYKKKKKKKKYYYYKKKKKKYYYYYYKKKKKKKKKKKKYYYYYYYKKKKYYYYYYYYYYYKKKKKKKKKYYYYKKKKKKKKYYYYKKYYYYYYYYYYYKKKYYYYYKKKKKYYYYKKKKKKKKYYYYYYYKKKKYYYYYYYYYYYKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKYYYYKKKKKKYYYYKKKKKYYYYYYYYYYKKKKKKKKYYYYYYYYYYKKKYYYYYYYYYYYKKKKKKKKKKYYYYKKKKKKYYYYKKKYYYYYYYYYYYKKKYYYYYKKKKKYYYYKKKKKKYYYYYYYYYYKKKYYYYYYYYYYYKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKYYYYKKKKKKYYYYKKKKYYYYKKKKYYYYKKKKKKYYYYKKKKKKYKKKYYYYKKKKKKKKKKKKKKKKKYYYYKKKKKKYYYYKKKYYYYKKKKKKKKKKYYYYYYKKKKYYYYKKKKKYYYYKKKKKKYKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKYYYYYKKKKYYYYYKKKYYYYKKKKKKYYYYKKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKYYYYYKKKKYYYYYKKKYYYYKKKKKKKKKKYYYYYYYKKKYYYYKKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKYYYYKKKKYYYYKKKYYYYKKKKKKKKYYYYKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKKYYYYKKKKYYYYKKKKYYYYKKKKKKKKKKYYYYYYYKKKYYYYKKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKYYYYKKKKYYYYKKKYYYYKKKKKKKKYYYYKKYYYYKKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKKYYYYKKKKYYYYKKKKYYYYKKKKKKKKKKYYYYYYYYKKYYYYKKKYYYYKKKKKKKKKKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKYYYYYKKYYYYYKKKYYYYKKKKKKKKYYYYKKYYYYKKKKKKKKKKKKYYYYYYYYYYKKKKKKKKKKKKYYYYYKKYYYYYKKKKYYYYYYYYYYKKKKYYYYKYYYKKYYYYKKKYYYYKKKKKKKKKKKKYYYYYYYYYYKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKYYYYKKYYYYKKKKYYYYKKKKKKKKYYYYKKYYYYKKKKKKKKKKKKYYYYYYYYYYKKKKKKKKKKKKKYYYYKKYYYYKKKKKYYYYYYYYYYKKKKYYYYKYYYYKYYYYKKKYYYYKKKKKKKKKKKKYYYYYYYYYYKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKYYYYKKYYYYKKKKYYYYKKKKKKKKYYYYKKYYYYKKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKKKYYYYKKYYYYKKKKKYYYYKKKKKKKKKKYYYYKKYYYKYYYYKKKYYYYKKKKKKKKKKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKYYYYYYYYKKKKKYYYYKKKKKKKKYYYYKKYYYYKKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKKKKYYYYYYYYKKKKKKYYYYKKKKKKKKKKYYYYKKYYYYYYYYKKKYYYYKKKKKKKKKKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKYYYYYYYYKKKKKYYYYKKKKKKKKYYYYKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKKKKYYYYYYYYKKKKKKYYYYKKKKKKKKKKYYYYKKKYYYYYYYKKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKYYYYYYYYKKKKKKYYYYKKKKKKYYYYKKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKKKKKKKKKKYYYYYYYYKKKKKKYYYYKKKKKKKKKKYYYYKKKYYYYYYYKKKKYYYYKKKKKKKKKKKYYYYKKKKKKKKKKKYYYYKKKKKYYYYKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKYYYYYYKKKKKKKKYYYYKKKKYYYYKKKKKKYYYYKKKKKKYKKKYYYYKKKKKKKKKKKKKKKKKKKKKYYYYYYKKKKKKKYYYYKKKKKKKKKKYYYYKKKKYYYYYYKKKKKYYYYKKKKKKYKKKYYYYKKKKKKKKKKKKYYYYKKKYYYYKKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKYYYYYYKKKKKKKKKYYYYYYYYYYKKKKKKKKYYYYYYYYYYKKKYYYYYYYYYYYKKKKKKKKKKKKKKYYYYYYKKKKKKKYYYYYYYYYYYKKKYYYYKKKKKYYYYYKKKKKKYYYYYYYYYYKKKYYYYYYYYYYYKKKKKYYYYYYYYYYYKKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKYYYYYYKKKKKKKKKKKYYYYYYKKKKKKKKKKKKYYYYYYYKKKKYYYYYYYYYYYKKKKKKKKKKKKKKYYYYYYKKKKKKKYYYYYYYYYYYKKKYYYYKKKKKYYYYYKKKKKKKKYYYYYYYKKKKYYYYYYYYYYYKKKKKKKYYYYYYYKKKKKKKKYYYYKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWWWWWKKWWWKKWWKWWWWWWWWWWWWWWKKWWWWWKKKKKKKKKKKKKKKKKKKKWWKKKKWWWWKKKKKKWWWWWKKKKWWKKKKWWWWWKKKKKKKWWWWWKKKKWWWWWWKKKKKKWWWKKWWKKKKWWWWKKWWKKKKWWKKKWWWWKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWKKKKKKWWWKKWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKKKKKKKKKKKKKKWWKKKWWKKWWKKKKWWKKKWKKKWWWWKKKWWKKWWKKKKKKWWKKWWKKKWWKKKKKKKKKKWWWKKWWKKKWWKKWWKKWWKKWWKKKWWKKWWKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWKKKKKKWWWKKWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKKKKKKKKKKKKKKWWKKWWKKKKWWKKWWKKKKKKKKWWWWKKKWWKKWWKKKKKKWWKKKWWKKWWKKKKKKKKKKWWWKKWWKKWWKKKKWWKWWKKWWKKWWKKKKWWKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWWWWWKKWWKWKWWKKKKWWKKKWWWWWWKKWWKKWWKKKKKKWWWWWWWKKKKKKWWKKWWKKKKWWKKWWKKKKKKKKWKKWKKKWWKKWWKKKKKKWWKKKWWKKWWWWWWKKKKKKWWKWKWWKKWWKKKKWWKWWKKWWKKWWKKKKWWKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWKKKKKKWWKWKWWKKKKWWKKKWWKKKKKKWWWWWKKKKKKKKKKKKKKKKKKKKWWKKWWKKKKWWKKWWKKWWWKKWWKKWWKKWWWWWKKKKKKKWWKKKWWKKWWKKKKKKKKKKWWKWKWWKKWWKKKKWWKKWKKWKKKWWKKKKWWKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWKKKKKKWWKKWWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKWWWWWWWKKKKKKWWKKWWKKKKWWKKWWKKKWWKKWWWWWWKKWWKKWWKKKKKKWWKKKWWKKWWKKKKKKKKKKWWKKWWWKKWWKKKKWWKKWWWWKKKWWKKKKWWKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWKKKKKKWWKKWWWKKKKWWKKKWWKKKKKKWWKKWWKKKKKKKKKKKKKKKKKKKWWKKKWWKKWWKKKKWWKKWWKKWWKKWWKKWWKKWWKKKKKKWWKKWWKKKWWKKKKKKKKKKWWKKWWWKKKWWKKWWKKKWWWWKKKKWWKKWWKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKWWWWWWKKWWKKWWWKKKKWWKKKWWWWWWKKWWKKKWWKKKKKKKKKKKKKKKKKKWWKKKKWWWWKKKKKKWWWWWKWWKKKKWWKWWKKKWWKKKKKWWWWWKKKKWWWWWWKKKKKKWWKKWWWKKKKWWWWKKKKKWWKKKKKKWWWWKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKWWKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKsKKKYYY"
.ascii "YYYKKKsssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssWWWssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssKKKYYY"
.ascii "YYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYY"
.ascii "YYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYY"
.ascii "YYYKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKYYY"
.ascii "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
.ascii "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
.ascii "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"

# ============================== ANIMAÇÕES ==============================
# estudante_corrida_32x32: 9 quadro(s) de 32x32
.align 2
img_estudante_corrida_0:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "..............ppppp............."
.ascii ".............pnnnnnp............"
.ascii "............pNNNNnnnp..........."
.ascii "...........pNNnnpppnnp.........."
.ascii "..........pnnnnpOnnnnRp........."
.ascii "..........pnnnpOOOWWORp........."
.ascii "..........pnnpROOOWpORp........."
.ascii "..........pnnpROOOWpORO........."
.ascii "..........pnnpOOOOOORRR........."
.ascii "..........pppOOOOOOrrp.........."
.ascii ".......ppp55pRpppRRRp..........."
.ascii "......pGGGp22p111ppp............"
.ascii "......pG6p1ppp1o2pp............."
.ascii "......pG6p1op1122pp............."
.ascii "......pG6p1op1o2p2p............."
.ascii "......pccp1op1oop2pp............"
.ascii "......pccp1op1oopppRp..........."
.ascii ".......ppp22p1opORppp..........."
.ascii "..........ppppppORpB4p.........."
.ascii "...........pp4BpRRpBBp.........."
.ascii "...........pbppbppBBbbp........."
.ascii "............pbbppppppp.........."
.ascii "............pbbpWWWWWp.........."
.ascii "..........pppppWWWWWWSp........."
.ascii ".........pSSSSSpWWSSssp........."
.ascii ".........pSSSSSpsssppp.........."
.ascii ".........pssssssppp............."
.align 2
img_estudante_corrida_1:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "..........ppnnpOOOOOORRR........"
.ascii ".......ppp55ppppOOOOrrp........."
.ascii "......pGGGp22p11pORRRp.........."
.ascii "......pG6p1pp11o2pRppp.........."
.ascii "......pG6pp111o22pppp..........."
.ascii "......pc6pp1o222p2pp............"
.ascii "......pccpp1ooppo2pp............"
.ascii "......pGcpp1opppp2p............."
.ascii ".......ppp2ppOOp4p.............."
.ascii "..........pppORRpBp............."
.ascii "..........pbppRpBBBp............"
.ascii "..........pbbppBBBBbp..........."
.ascii "..........pbbbpbBBBbp..........."
.ascii "........ppbbbbpppBBBp..........."
.ascii "......pppppbbbp.pppppp.........."
.ascii ".....pSSSSSpbbp.pWWWWWp........."
.ascii ".....pSSSSSSpp..pWWWWWWp........"
.ascii ".....pssssssp...pssssssSp......."
.align 2
img_estudante_corrida_2:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "...........pnnpOOOOOORRR........"
.ascii "..........p5ppOOOOOOrrp........."
.ascii ".......ppp555pppOORRRp.........."
.ascii "......pGGGp22p11pRRpp..........."
.ascii "......pG6p1ppp1o2ppRRp.........."
.ascii "......pG6p1op1122ppRRp.........."
.ascii "......pc6p1p1122p2pRRp.........."
.ascii "......pccpp11oopo2ppp..........."
.ascii "......pGcpp1ooopp2p............."
.ascii ".......ppp2ppopORp.............."
.ascii "..........pp4pOORp.............."
.ascii "...........ppBpRRpp............."
.ascii ".........pppbpBppBbp............"
.ascii ".......ppSSSpp4BBBBp............"
.ascii "......pSSSSSSppBBBbbp..........."
.ascii ".......pSSSSSsppBBbp............"
.ascii ".......pSsssspbpppppp..........."
.ascii "........ppppppppWWWWWp.........."
.ascii "...............pWWWWWSp........."
.ascii "...............pssssssp........."
.align 2
img_estudante_corrida_3:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "...........pnnpOOOOOORRR........"
.ascii "..........p5ppOOOOOOrrp........."
.ascii ".......ppp555pppOORRRp.........."
.ascii "......pGGGp22p11pRRpp..........."
.ascii "......pG6p1ppp1o2pp............."
.ascii "......pG6p1oop1o2pp............."
.ascii "......pc6p1oop1oopp............."
.ascii "......pccp1oop1oooppp..........."
.ascii "......pGcp1opp1oopORRp.........."
.ascii ".......ppp2p4p122pRRp..........."
.ascii "..........pp4Bpppppp............"
.ascii "...........p4BBbpbbp............"
.ascii "...........p4BBbpbbbp..........."
.ascii "...........p4BBBppbp............"
.ascii "..........pSpBBBbpp............."
.ascii "..........pSp4Bbbpp............."
.ascii "...........pp4Bbpp.............."
.ascii "...........pppppp..............."
.ascii "...........pWWWWWp.............."
.ascii "...........pWWWWWSp............."
.ascii "...........pssssssp............."
.align 2
img_estudante_corrida_4:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "...........pnnpOOOOOORRR........"
.ascii "..........p5ppOOOOOOrrp........."
.ascii ".......ppp555pppOORRRp.........."
.ascii "......pGGGp22p11pRRppp.........."
.ascii "......pG6p1ppp1oopppORp........."
.ascii "......pG6p1oop1oooppORp........."
.ascii "......pc6p1ooopoooopRRp........."
.ascii "......pccp1oopppoo22pp.........."
.ascii "......pGcp1op44p122pp..........."
.ascii ".......ppp2p44Bbpppp............"
.ascii "..........pp4BBbppbbp..........."
.ascii "...........p4Bbbpbbbp..........."
.ascii "..........p44Bbpbpppp..........."
.ascii "..........p4BBbppSSSp..........."
.ascii ".........p44BbbpSSSSSp.........."
.ascii ".........p4BBbpSSSSSSsp........."
.ascii "........pppppbppsssssp.........."
.ascii ".......pWWWWWp..ppppp..........."
.ascii ".......pWWWWWSp................."
.ascii ".......pssSSSSp................."
.align 2
img_estudante_corrida_5:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "..........ppnnpOOOOOORRR........"
.ascii ".......ppp55ppppOOOOppp........."
.ascii "......pGGGp22p11ppRpORp........."
.ascii "......pG6p1ppp1oo1ppRRp........."
.ascii "......pG6p1oop1oooo1ppp........."
.ascii "......pc6p1ooop2ooo22p.........."
.ascii "......pccp1ooppppo22p..........."
.ascii "......pGcp1op44p2p2p............"
.ascii ".......ppp2p44Bbppp............."
.ascii "..........pp4BBbpp.............."
.ascii "..........p44Bbbpp.............."
.ascii ".........p44Bbbpbbp............."
.ascii ".........p4BBbpbbbbp............"
.ascii "........p44Bbbpbbbbp............"
.ascii "......pppppbbp.pbppppp.........."
.ascii ".....pWWWWWpp...pSSSSSp........."
.ascii ".....pWWWWWSp...pSSSSSSp........"
.ascii ".....pssssssp...pssssssSp......."
.align 2
img_estudante_corrida_6:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "...........pnnpOOOOOORRR........"
.ascii "..........p5ppOOOOOOrrp........."
.ascii ".......ppp555pppOORRRp.........."
.ascii "......pGGGp22p11pRRppp.........."
.ascii "......pG6p1ppp1oopppORp........."
.ascii "......pG6p1oop1oooppORp........."
.ascii "......pc6p1ooopoooopRRp........."
.ascii "......pccp1oopppoo22pp.........."
.ascii "......pGcp1op44p122pp..........."
.ascii ".......ppp2p44Bbppp............."
.ascii "..........pp4BBbpp.............."
.ascii "...........p4BBBp..............."
.ascii ".........ppppBBBbp.............."
.ascii ".......ppWWWp4BBbpp............."
.ascii "......pWWWWWWpBBbpp............."
.ascii ".......pWWWWSspBbpp............."
.ascii ".......pSsssspbbbpppp..........."
.ascii "........pppppppppSSSSp.........."
.ascii "...............pSSSSSSp........."
.ascii "...............pssssssp........."
.align 2
img_estudante_corrida_7:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "...........pnnpOOOOOORRR........"
.ascii "..........p5ppOOOOOOrrp........."
.ascii ".......ppp555pppOORRRp.........."
.ascii "......pGGGp22p11pRRpp..........."
.ascii "......pG6p1ppp1o2pp............."
.ascii "......pG6p1oop1o2pp............."
.ascii "......pc6p1oop1oopp............."
.ascii "......pccp1oop1oooppp..........."
.ascii "......pGcp1opp1oopORRp.........."
.ascii ".......ppp2p4p122pRRp..........."
.ascii "..........pp4Bpppppp............"
.ascii "..........pbpBBBBBBp............"
.ascii "...........ppppppBBbp..........."
.ascii "...........pWWWWWpBbp..........."
.ascii "..........pWWWWWWSpbp..........."
.ascii "..........pWWWSssspp............"
.ascii "...........pssspppp............."
.ascii "...........pppppp..............."
.ascii "...........pSSSSSp.............."
.ascii "...........pSSSSSSp............."
.ascii "...........pssssssp............."
.align 2
img_estudante_corrida_8:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "...............ppppp............"
.ascii "..............pnnnnnp..........."
.ascii ".............pNNNNnnnp.........."
.ascii "............pNNnnpppnnp........."
.ascii "...........pnnnnpOnnnnRp........"
.ascii "...........pnnnpOOOWWORp........"
.ascii "...........pnnpROOOWpORp........"
.ascii "...........pnnpROOOWpORO........"
.ascii "...........pnnpOOOOOORRR........"
.ascii "..........p5ppOOOOOOrrp........."
.ascii ".......ppp555pppOORRRp.........."
.ascii "......pGGGp22p11pRRpp..........."
.ascii "......pG6p1ppp1o2ppRRp.........."
.ascii "......pG6p1op1122ppRRp.........."
.ascii "......pc6p1p1122p2pRRp.........."
.ascii "......pccpp11oopo2ppp..........."
.ascii "......pGcpp1oooppppp............"
.ascii ".......ppp2ppopORp44p..........."
.ascii "..........pp4pOORpBBbp.........."
.ascii "..........pbpbpRRpBBbp.........."
.ascii "..........pbbpppppppbp.........."
.ascii "..........pbbbbppWWWp..........."
.ascii "..........pbbbpWWWWWWp.........."
.ascii ".........pbbbbpWWWWWSsp........."
.ascii "........pppppbppsssssp.........."
.ascii ".......pSSSSSp..ppppp..........."
.ascii ".......pSSSSSSp................."
.ascii ".......pssSSSSp................."
anim_estudante_corrida:
.word 9, img_estudante_corrida_0, img_estudante_corrida_1, img_estudante_corrida_2, img_estudante_corrida_3, img_estudante_corrida_4, img_estudante_corrida_5, img_estudante_corrida_6, img_estudante_corrida_7, img_estudante_corrida_8

# estudante_dano_32x32: 1 quadro(s) de 32x32
.align 2
img_estudante_dano_0:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "............ppppp..............."
.ascii "...........pnnnnnp.............."
.ascii "..........pNNNNnnnp............."
.ascii ".........pNNnnpppnnp............"
.ascii "........pnnnnpOnnnnRp..........."
.ascii "........pnnnpOOOpOORp..........."
.ascii "........pnnpROOOOpORp..........."
.ascii "........pnnpROOOpOORO..........."
.ascii "........pnnpOOOOOORRR..........."
.ascii ".........ppOOOOOWWWp............"
.ascii "........p5pRpppprrr............."
.ascii ".......pp2pp1111pppppp.........."
.ascii "......pGGp111o22pp2pRRp........."
.ascii ".....pGpp11o222po2pRRRp........."
.ascii ".....pppp1222ppoo2ppRp.........."
.ascii ".....pOORp2ppoppp2ppp..........."
.ascii ".....pORRppoop444pp............."
.ascii "......pRpcpop44BBBp............."
.ascii "......ppppp2p4BBBBBp............"
.ascii ".......p...pppBBBBBBp..........."
.ascii "...........pbbpBBBBBbp.........."
.ascii "...........pbbbpBBBBbp.........."
.ascii "..........ppbbpppppbbp.........."
.ascii "........ppppppWWWWWpp..........."
.ascii ".......pSSSSSpWWWWWSp..........."
.ascii ".......pSSSSSpssWWWSp..........."
.ascii ".......psssssspppsssp..........."
anim_estudante_dano:
.word 1, img_estudante_dano_0

# estudante_idle_32x32: 3 quadro(s) de 32x32
.align 2
img_estudante_idle_0:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii ".............ppppp.............."
.ascii "............pnnnnnp............."
.ascii "...........pNNNNnnnp............"
.ascii "..........pNNnnpppnnp..........."
.ascii ".........pnnnnpOnnnnRp.........."
.ascii ".........pnnnpOOOWWORp.........."
.ascii ".........pnnpROOOWpORp.........."
.ascii ".........pnnpROOOWpORO.........."
.ascii ".........pnnpOOOOOORRR.........."
.ascii "..........ppOOOOOOrrp..........."
.ascii ".........p5pROpORRRp............"
.ascii ".......ppp55pp1pRpp............."
.ascii "......pGGpp2p112p2p............."
.ascii "......pG6p1pp1oop2p............."
.ascii "......pG6p1op1oo2pp............."
.ascii "......pG6p1op1oo2pp............."
.ascii "......pccp1oopoo2pp............."
.ascii "......pccp1opp1o2pp............."
.ascii ".......ppp22pp1opp.............."
.ascii "..........ppp4ppOpp............."
.ascii "...........pbppORRpp............"
.ascii "............pbpRRpBbp..........."
.ascii "............pbpppBBbp..........."
.ascii "............pbbpBBbbp..........."
.ascii "..........pppppppppp............"
.ascii ".........pSSSpWWWWWp............"
.ascii ".........pSSSpWWWWWWp..........."
.ascii ".........pssspssssssSp.........."
.align 2
img_estudante_idle_1:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii ".............ppppp.............."
.ascii "............pnnnnnp............."
.ascii "...........pNNNNnnnp............"
.ascii "..........pNNnnpppnnp..........."
.ascii ".........pnnnnpOnnnnRp.........."
.ascii ".........pnnnpOOOWWORp.........."
.ascii ".........pnnpROOOWpORp.........."
.ascii ".........pnnpROOOWpORO.........."
.ascii ".........pnnpOOOOOORRR.........."
.ascii ".........pppOOppOOrrp..........."
.ascii ".......ppp5pRp11pRRp............"
.ascii "......pGGpp2p112ppp............."
.ascii "......pG6p1pp1oop2p............."
.ascii "......pG6p1op1oo2pp............."
.ascii "......pG6p1op1oo2pp............."
.ascii "......pccp1oopoo2pp............."
.ascii "......pGcp1opp1o2pp............."
.ascii ".......ppp22pp1pppp............."
.ascii "..........ppp4pOOppp............"
.ascii "...........pbppORRpBp..........."
.ascii "............pbpRRpBBbp.........."
.ascii "............ppbppBBbbp.........."
.ascii "..........pppppppppbp..........."
.ascii ".........pSSSpWWWWWp............"
.ascii ".........pSSSpWWWWWWp..........."
.ascii ".........pssspssssssSp.........."
.align 2
img_estudante_idle_2:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii ".............ppppp.............."
.ascii "............pnnnnnp............."
.ascii "...........pNNNNnnnp............"
.ascii "..........pNNnnpppnnp..........."
.ascii ".........pnnnnpOnnnnRp.........."
.ascii ".........pnnnpOOOOOORp.........."
.ascii ".........pnnpROOOOOORp.........."
.ascii ".........pnnpROOOppORO.........."
.ascii ".........pnnpOOOOOORRR.........."
.ascii "..........ppOOOOOOrrp..........."
.ascii ".........p5pROpORRRp............"
.ascii ".......ppp55pp1pRpp............."
.ascii "......pGGpp2p112p2p............."
.ascii "......pG6p1pp1oop2p............."
.ascii "......pG6p1op1oo2pp............."
.ascii "......pG6p1op1oo2pp............."
.ascii "......pccp1oopoo2pp............."
.ascii "......pccp1opp1o2pp............."
.ascii ".......ppp22pp1opp.............."
.ascii "..........ppp4ppOpp............."
.ascii "...........pbppORRpp............"
.ascii "............pbpRRpBbp..........."
.ascii "............pbpppBBbp..........."
.ascii "............pbbpBBbbp..........."
.ascii "..........pppppppppp............"
.ascii ".........pSSSpWWWWWp............"
.ascii ".........pSSSpWWWWWWp..........."
.ascii ".........pssspssssssSp.........."
anim_estudante_idle:
.word 3, img_estudante_idle_0, img_estudante_idle_1, img_estudante_idle_2

# estudante_pulo_32x32: 3 quadro(s) de 32x32
.align 2
img_estudante_pulo_0:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "..............ppppp............."
.ascii ".............pnnnnnp............"
.ascii "............pNNNNnnnp..........."
.ascii "...........pNNnnpppnnp.........."
.ascii "..........pnnnnpOnnnnRp........."
.ascii "..........pnnnpOOOWWORp........."
.ascii "..........pnnpROOOWpORp........."
.ascii "..........pnnpROOOWpORO........."
.ascii "..........pnnpOOOOOORpp........."
.ascii "...........ppOOOOOOppORp........"
.ascii "..........p5pROOppp1pRRp........"
.ascii ".......ppp555ppp11112ppp........"
.ascii "......pGGpp22p111oo22pp........."
.ascii "......pG6p1ppp1o2222p..........."
.ascii "......pG6p1oop122ppp............"
.ascii ".....ppG6p1oooppp2ppp..........."
.ascii ".....ppccp1ooppppp444p.........."
.ascii "......pGcp1op444444BBbp........."
.ascii ".......ppp22p4BBBBBBBbp........."
.ascii "..........ppp4Bpppppbbp........."
.ascii "...........pbppWWWWWpp.........."
.ascii "...........pbbpWWWWWWp.........."
.ascii ".........ppppbpWWWWSssp........."
.ascii "........pSSppppssssspp.........."
.ascii "........pSSSSSpppppp............"
.ascii "........pSSSSSpbp..............."
.ascii "........pssSSSSp................"
.ascii ".........pppsssp................"
.ascii "............ppp................."
.align 2
img_estudante_pulo_1:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii "..............ppppp............."
.ascii ".............pnnnnnp............"
.ascii "............pNNNNnnnp..........."
.ascii "...........pNNnnpppnnp.........."
.ascii "..........pnnnnpOnnnnRp........."
.ascii "..........pnnnpOOOWWORp........."
.ascii "..........pnnpROOOWpORp........."
.ascii "..........pnnpROOOWpORO........."
.ascii "..........pnnpOOOOOORRR........."
.ascii "..........pppOOOOOOrrp.........."
.ascii ".......ppp55pRpppRRRp..........."
.ascii "......pGGp222p111ppppppp........"
.ascii "......pG6pppp11ooo11pOORp......."
.ascii "......pG6p1oop2ooooopRRRp......."
.ascii "......pG6p1ooopp2o222ppp........"
.ascii "......pccp1ooopppp2ppp.........."
.ascii "......pccp1oop444pppp..........."
.ascii "......pGpp1op44BBB444p.........."
.ascii "......ppRp22p4BBBBBBBbp........."
.ascii ".......pppppp4bBpppBbbp........."
.ascii "..........ppppppWWWpbp.........."
.ascii ".........pSSSSpWWWWWp..........."
.ascii ".........pSSSSpWWWWWSp.........."
.ascii ".........pSSSSpssssssp.........."
.ascii ".........pssssspppppp..........."
.ascii "..........pppppp................"
.ascii "................................"
.ascii "................................"
.align 2
img_estudante_pulo_2:
.word 32, 32
.ascii "................................"
.ascii "................................"
.ascii "................................"
.ascii ".............ppppp.............."
.ascii "............pnnnnnp............."
.ascii "...........pNNNNnnnp............"
.ascii "..........pNNnnpppnnp..........."
.ascii ".........pnnnnpOnnnnRp.........."
.ascii ".........pnnnpOOOWWORp.........."
.ascii ".........pnnpROOOWpORp.........."
.ascii ".........pnnpROOOWpORO.........."
.ascii ".........pnnpOOOOOORRpp........."
.ascii "..........ppOOOOOppppOOp........"
.ascii ".....ppppp5pROppp111pORRp......."
.ascii "....pRRppp25pp1111o2pRRp........"
.ascii "....pRpGGpppp11oo222ppp........."
.ascii ".....ppG6p1op12222pp............"
.ascii "......pG6p1oopppppp............."
.ascii "......pccp1oooppo2p............."
.ascii "......pccp1oop44p2p............."
.ascii "......pGcp1op44Bbpp............."
.ascii ".......ppp22p4BBBp.............."
.ascii "..........ppp4BBBbp............."
.ascii "...........pbpBBBBp............."
.ascii "............pp4BBBbp............"
.ascii "............pbpBBBbp............"
.ascii "..........ppppp4Bbbp............"
.ascii ".........pSSSSppppp............."
.ascii ".........pSSSpWWWWpp............"
.ascii ".........pSSSpWWWWWSp..........."
.ascii ".........pssspWWWWWSp..........."
.ascii "..........ppppssssssp..........."
anim_estudante_pulo:
.word 3, img_estudante_pulo_0, img_estudante_pulo_1, img_estudante_pulo_2

# ============================== BLOCOS ==============================
# 10_capim_alto -> bloco 10 (no mapa: 'A')
pal_bloco_10:
.byte '.',0xC7, 'g',0x19, 'G',0x22, 'Y',0x36, 'O',0x67, 0   # . transparente, g verde escuro, G verde escuro, Y amarelo, O laranja
.align 2
img_bloco_10:
.word 16, 16
.ascii "................"
.ascii "................"
.ascii "................"
.ascii "................"
.ascii "................"
.ascii "................"
.ascii "................"
.ascii "..........Y....."
.ascii "..O.....Y.G.Y..."
.ascii "..G.O...GG..G.Y."
.ascii ".GG.G.YG.G..G.G."
.ascii ".GG.G.GGYG..GGG."
.ascii "Ogg.GGGgGgYGgGGY"
.ascii "GggGggggGgGggggG"
.ascii "gggggggggggggggg"
.ascii "gggggggggggggggg"

# 11_piso -> bloco 11 (no mapa: 'B')
pal_bloco_11:
.byte 'O',0x1D, 'n',0x14, 'o',0x6E, 'N',0x13, 0   # O laranja, n marrom escuro, o laranja, N marrom escuro
.align 2
img_bloco_11:
.word 16, 16
.ascii "oooooooooooooooo"
.ascii "oooooooooooooooo"
.ascii "NNNNNNNNNNNNNNNN"
.ascii "OOOOONOOOOOOOOOO"
.ascii "OOOOONOOOOOOOOOO"
.ascii "OOOOONOOOOOOOOOO"
.ascii "OOOOONOOOOOOOOOO"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "OOOOOOOOOOOONOOO"
.ascii "OOOOOOOOOOOONOOO"
.ascii "OOOOOOOOOOOONOOO"
.ascii "OOOOOOOOOOOONOOO"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "OONOOOOOOOOOOOOO"
.ascii "OONOOOOOOOOOOOOO"
.ascii "OONOOOOOOOOOOOOO"

# 12_piso_baixo -> bloco 12 (no mapa: 'C')
pal_bloco_12:
.byte 'n',0x13, 'N',0x0A, 0   # n marrom escuro, N marrom escuro
.align 2
img_bloco_12:
.word 16, 16
.ascii "NnnnnnnnnnnNnnnn"
.ascii "nnnnnnnnnNnnnnnn"
.ascii "nnnnnnnNnnnnnnnn"
.ascii "nnnnnNnnnnnnnnnn"
.ascii "nnnNnnnnnnnnnnNn"
.ascii "nNnnnnnnnnnnNnnn"
.ascii "nnnnnnnnnnNnnnnn"
.ascii "nnnnnnnnNnnnnnnn"
.ascii "nnnnnnNnnnnnnnnn"
.ascii "nnnnNnnnnnnnnnnN"
.ascii "nnNnnnnnnnnnnNnn"
.ascii "NnnnnnnnnnnNnnnn"
.ascii "nnnnnnnnnNnnnnnn"
.ascii "nnnnnnnNnnnnnnnn"
.ascii "nnnnnNnnnnnnnnnn"
.ascii "nnnNnnnnnnnnnnNn"

# 13_livros -> bloco 13 (no mapa: 'D')
pal_bloco_13:
.byte 'R',0x0D, 'W',0xFF, 'B',0x91, 'K',0x00, 'g',0x61, 'b',0xE3, 'Y',0x37, '.',0xC7, 0   # R vermelho, W branco, B azul, K preto, g verde escuro, b azul, Y amarelo, . transparente
.align 2
img_bloco_13:
.word 16, 16
.ascii ".KKKKKKKKKKKKKK."
.ascii "KbbbbbbbbbbbbbbK"
.ascii "KBBBBBBBBBBBWWWK"
.ascii "KBBYYYYYBBBBWWWK"
.ascii "KBBBBBBBBBBBWWWK"
.ascii "KBBBBBBBBBBBBBBK"
.ascii "WWWWWWWWWWWWWWWW"
.ascii "RRRRRRRRRRRRRWWW"
.ascii "RRYYYYYRRRRRRWWW"
.ascii "RRRRRRRRRRRRRWWW"
.ascii "RRRRRRRRRRRRRRRR"
.ascii "KKbbbbbbbbbbbbKK"
.ascii ".KgggggggggWWWK."
.ascii ".KggYYYYYggWWWK."
.ascii ".KgggggggggWWWK."
.ascii ".KggggggggggggK."

# 14_mesa -> bloco 14 (no mapa: 'E')
pal_bloco_14:
.byte 'n',0x14, 'y',0x1C, 'O',0x66, 'N',0x13, '1',0x0A, 'Y',0x37, 0   # n marrom escuro, y amarelo escuro, O laranja, N marrom escuro, 1 marrom escuro, Y amarelo
.align 2
img_bloco_14:
.word 16, 16
.ascii "OOOOOOOOOOOOOOOO"
.ascii "OOOOOOOOOOOOOOOO"
.ascii "OOOOOOOOOOOOOOOO"
.ascii "1111111111111111"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "nnNNNNNNNNNNNNnn"
.ascii "nnNyyyyyyyyyyNnn"
.ascii "nnNyyyyyyyyyyNnn"
.ascii "nnNyyyyYYyyyyNnn"
.ascii "nnNyyyyyyyyyyNnn"
.ascii "nnNyyyyyyyyyyNnn"
.ascii "nnNNNNNNNNNNNNnn"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "nnnnnnnnnnnnnnnn"

# 15_armario -> bloco 15 (no mapa: 'F')
pal_bloco_15:
.byte 'S',0xA4, 'B',0x9B, 's',0x52, 'W',0xF6, '1',0x49, 0   # S cinza claro, B azul, s cinza escuro, W branco, 1 cinza escuro
.align 2
img_bloco_15:
.word 16, 16
.ascii "WWWWWWWWWWWWWWWW"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSS1SBBS1SSSSS"
.ascii "SSSSS1SBBS1SSSSS"
.ascii "SSSSS1SBBS1SSSSS"
.ascii "SSSSS1SBBS1SSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "SSSSSSSBBSSSSSSS"
.ascii "ssssssssssssssss"

# 16_cadeira -> bloco 16 (no mapa: 'G')
pal_bloco_16:
.byte '.',0xC7, 'O',0x1D, 'n',0x0A, 0   # . transparente, O laranja, n marrom escuro
.align 2
img_bloco_16:
.word 16, 16
.ascii "................"
.ascii "...OOOOOOOOO...."
.ascii "...OOOOOOOOO...."
.ascii "...OOOOOOOOO...."
.ascii "...OOOOOOOOO...."
.ascii "...OOOOOOOOO...."
.ascii "...OOOOOOOOO...."
.ascii "...nnn.........."
.ascii "...nnn.........."
.ascii "...OOOOOOOOOOO.."
.ascii "...OOOOOOOOOOO.."
.ascii "...nnn......nn.."
.ascii "...nnn......nn.."
.ascii "...nnn......nn.."
.ascii "...nnn......nn.."
.ascii "...nnn......nn.."

# 17_lixeira -> bloco 17 (no mapa: 'H')
pal_bloco_17:
.byte '.',0xC7, 'B',0x9A, 'K',0x00, 's',0x51, 'b',0xE3, 'W',0xFF, 0   # . transparente, B azul, K preto, s cinza escuro, b azul, W branco
.align 2
img_bloco_17:
.word 16, 16
.ascii "......KKKK......"
.ascii ".....KWWWWK....."
.ascii ".....KWWWWK....."
.ascii "..KKKKWWWWKKKK.."
.ascii ".KbbbbbbbbbbbbK."
.ascii ".KbbbbbbbbbbbbK."
.ascii "..KBBBBBBBBBBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBsBBsBBsBK.."
.ascii "..KBBBBBBBBBBK.."

# 18_globo -> bloco 18 (no mapa: 'I')
pal_bloco_18:
.byte '.',0xC7, 'B',0xD9, 'K',0x00, 'G',0x2A, 'n',0x0A, 'N',0x13, 0   # . transparente, B azul, K preto, G verde, n marrom escuro, N marrom escuro
.align 2
img_bloco_18:
.word 16, 16
.ascii "................"
.ascii ".....KKKKK......"
.ascii "....KGBBBBK....."
.ascii "...KBBBBGGGK...."
.ascii "..KBBBGGGBBBK..."
.ascii "..KBGGGBBBBGK..."
.ascii "..KGGBBBBGGGK..."
.ascii "..KBBBBGGGBBK..."
.ascii "..KBBGGGBBBBK..."
.ascii "...KGGBBBBGK...."
.ascii "....KBBBGGK....."
.ascii ".....KKKKK......"
.ascii ".....KNNNK......"
.ascii "....KKNNNKK....."
.ascii "...KnnnnnnnK...."
.ascii "...KnnnnnnnK...."

# 1_grama -> bloco 1 (no mapa: '1')
pal_bloco_1:
.byte 'n',0x14, 'Y',0x35, 'p',0x4B, 'g',0x22, 'y',0x37, 0   # n marrom escuro, Y amarelo, p roxo/rosa escuro, g verde escuro, y amarelo
.align 2
img_bloco_1:
.word 16, 16
.ascii "yggyggyggyggyggy"
.ascii "YgYgYYgYgYggYYgg"
.ascii "YYYYYgYYggYYgYYY"
.ascii "YgpgnYYnYnYYnYnY"
.ascii "nnnpnnnnpnnnnnnn"
.ascii "nnnnnnpnnnnnnnpn"
.ascii "nppnnnnnpnnnnnnn"
.ascii "nnnnnnnnnnpnnnnn"
.ascii "nnnpnnnnnnpnppnn"
.ascii "nppnpnpnnnnnnnnn"
.ascii "nnppnnnnpnnnnpnn"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "nnnppnnnnnnnnnnn"
.ascii "nnnnnnnnpnnnnnnn"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "nnnpnnnnnnnnnnnn"

# 2_terra -> bloco 2 (no mapa: '2')
pal_bloco_2:
.byte 'n',0x14, 'p',0x4B, 0   # n marrom escuro, p roxo/rosa escuro
.align 2
img_bloco_2:
.word 16, 16
.ascii "nnnnnnnnnnnnnpnn"
.ascii "pnnnnnnnnnpnnnnn"
.ascii "nnnnnnnnnnnnnnnn"
.ascii "nnnnnnpnpnnnnnnn"
.ascii "nnnnnnnnnnnnnnnp"
.ascii "nnpnnnpnnnpnpnnn"
.ascii "nnnnnnnnppnnpnnn"
.ascii "pnpnnnnnnnnnpnpn"
.ascii "nnnnnnnpnpnnnnnp"
.ascii "nnnnnnnnnnnnnnpn"
.ascii "pnnnpnnnnnnnnnnn"
.ascii "nnnnnnpnnnnnpnpn"
.ascii "ppnnnnnnnnnnnnnn"
.ascii "pnnnnnnnnnnnnnnn"
.ascii "npnnpnnnnnnpnnnn"
.ascii "npnnpnnnnnnnnnnn"

# 3_tijolo -> bloco 3 (no mapa: '3')
pal_bloco_3:
.byte 'O',0x16, 'S',0xAE, 'p',0x4C, 0   # O laranja, S cinza claro, p roxo/rosa escuro
.align 2
img_bloco_3:
.word 16, 16
.ascii "OOOOOOOSOOOOOOOS"
.ascii "OOOOOOOSOOOOOOOS"
.ascii "pppppppSpppppppS"
.ascii "SSSSSSSSSSSSSSSS"
.ascii "OOOSOOOOOOOSOOOO"
.ascii "OOOSOOOOOOOSOOOO"
.ascii "pppSpppppppSpppp"
.ascii "SSSSSSSSSSSSSSSS"
.ascii "OOOOOOOSOOOOOOOS"
.ascii "OOOOOOOSOOOOOOOS"
.ascii "pppppppSpppppppS"
.ascii "SSSSSSSSSSSSSSSS"
.ascii "OOOSOOOOOOOSOOOO"
.ascii "OOOSOOOOOOOSOOOO"
.ascii "pppSpppppppSpppp"
.ascii "SSSSSSSSSSSSSSSS"

# 4_pedra -> bloco 4 (no mapa: '4')
pal_bloco_4:
.byte 'P',0x9C, 's',0x4A, 'W',0xF7, 0   # P roxo/rosa, s cinza escuro, W branco
.align 2
img_bloco_4:
.word 16, 16
.ascii "WWWWWWWWWWWWWWWW"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPsPPPPPPPPsPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPsPPPPPPPPsPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "WPPPPPPPPPPPPPPs"
.ascii "Wsssssssssssssss"

# 5_arbusto -> bloco 5 (no mapa: '5')
pal_bloco_5:
.byte '.',0xC7, 'c',0x58, 'G',0x6A, 'C',0x50, 'g',0x74, '1',0x61, 'O',0x67, 0   # . transparente, c ciano escuro, G verde, C ciano escuro, g verde, 1 verde escuro, O laranja
.align 2
img_bloco_5:
.word 16, 16
.ascii "................"
.ascii "................"
.ascii "................"
.ascii "................"
.ascii ".......Og......."
.ascii ".....OGgGGGgG..."
.ascii "....OGgGGGGGGG.."
.ascii "..OgGGGGc1cGcGc."
.ascii ".OgGgGGcGcGGGGGc"
.ascii "GgGGG1cccGcGcGcc"
.ascii "gGgGGcGcGcGccccc"
.ascii "GGGGccccccc1ccCc"
.ascii "GGG1Gcc1GccccccC"
.ascii ".GccccCcccCcCcC."
.ascii "..cccCcCCCcCcC.."
.ascii "....CCC...CC...."

# 6_flores -> bloco 6 (no mapa: '6')
pal_bloco_6:
.byte '.',0xC7, 'g',0x19, 'Y',0x36, 'y',0x37, 'R',0x9F, 'W',0xFF, 'O',0x27, '1',0x77, 0   # . transparente, g verde escuro, Y amarelo, y amarelo, R vermelho, W branco, O laranja, 1 amarelo
.align 2
img_bloco_6:
.word 16, 16
.ascii "................"
.ascii "................"
.ascii "........y......."
.ascii ".......yOy......"
.ascii "....R...y......."
.ascii "...RyR..g...W..."
.ascii "....R...g..W1W.."
.ascii "....g...g...W..."
.ascii "....g...g...g..."
.ascii "....g...g...g..."
.ascii "....g...g.Y.g..."
.ascii "....g...gg..g..."
.ascii "...gg..Ygg..gY.."
.ascii "..Ygg.g.gg..g..Y"
.ascii ".g.gg.g.gg..g.g."
.ascii ".g.gg.g.gg..g.g."

# 7_placa -> bloco 7 (no mapa: '7')
pal_bloco_7:
.byte '.',0xC7, 'R',0x5D, 's',0x4A, 'r',0x54, 'O',0x66, 'W',0xFF, 'p',0x4B, 0   # . transparente, R vermelho, s cinza escuro, r vermelho escuro, O laranja, W branco, p roxo/rosa escuro
.align 2
img_bloco_7:
.word 16, 16
.ascii "................"
.ascii ".ssssssssssssss."
.ascii ".sOOOOOOOOOOOOs."
.ascii ".sRRRRRRRRWRRRs."
.ascii ".sRRRRRRRWRRRRs."
.ascii ".sRRWWWWWWWWRRs."
.ascii ".sRRRRRRRWRRRRs."
.ascii ".sRRRRRRRRWRRRs."
.ascii ".srrrrrrrrrrrrs."
.ascii ".ssssssssssssss."
.ascii ".......rp......."
.ascii ".......rp......."
.ascii ".......rp......."
.ascii ".......rp......."
.ascii ".......rp......."
.ascii ".......rp......."

# 8_poste_topo -> bloco 8 (no mapa: '8')
pal_bloco_8:
.byte '.',0xC7, 'O',0x6F, 'Y',0x77, 's',0x52, 'S',0xA4, 'y',0xBF, 0   # . transparente, O laranja, Y amarelo, s cinza escuro, S cinza claro, y amarelo
.align 2
img_bloco_8:
.word 16, 16
.ascii "....O.O.O.O....."
.ascii "...O.O.O.O.O...."
.ascii "..O.Ossssss.O..."
.ascii ".O.OsSSsssss.O.."
.ascii "..O.ssYYYYssO.O."
.ascii ".O.OYYyyyyYOYO.."
.ascii "..OYOYyyyyYYO.O."
.ascii ".O.OYYYyyYYOYO.."
.ascii "..OYOYOSsYOYO.O."
.ascii ".O.OYOYSsOYO.O.."
.ascii "..O.OYOSsYOYO.O."
.ascii "...O.OYSsO.O.O.."
.ascii "....O.OSs.O.O..."
.ascii ".....O.SsO.O...."
.ascii ".......Ss......."
.ascii ".......Ss......."

# 9_poste_base -> bloco 9 (no mapa: '9')
pal_bloco_9:
.byte '.',0xC7, 's',0x52, 'S',0xA4, '1',0x49, 0   # . transparente, s cinza escuro, S cinza claro, 1 cinza escuro
.align 2
img_bloco_9:
.word 16, 16
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".......Ss......."
.ascii ".....SSssss....."
.ascii ".....SSssss....."
.ascii ".....SSssss....."
.ascii ".....111111....."

# Tabela de blocos: blocos[n] = endereço da imagem do bloco n (0 = vazio)
blocos:
.word 0, img_bloco_1, img_bloco_2, img_bloco_3, img_bloco_4, img_bloco_5, img_bloco_6, img_bloco_7, img_bloco_8, img_bloco_9, img_bloco_10, img_bloco_11, img_bloco_12, img_bloco_13, img_bloco_14, img_bloco_15, img_bloco_16, img_bloco_17, img_bloco_18
# blocos das fases 2 e 3 (desenhados em dados/graficos_fases23.s)
#      19 J piso lab    20 K piso lab   21 L bancada   22 M caixa     23 N placa     24 O placa
#      25 P chip        26 Q servidor   27 R capacitor 28 S espinhos  29 T curto-circuito
.word img_bloco_19, img_bloco_20, img_bloco_21, img_bloco_22, img_bloco_23, img_bloco_24, img_bloco_25, img_bloco_26, img_bloco_27, img_bloco_28, img_bloco_29

# ============================== MAPAS ===============================
# calculo: 80 colunas x 15 linhas (4 tela(s))
.align 2
mapa_calculo:
.word 80, 15
.ascii "................................................................................"
.ascii "................................................................................"
.ascii "................................................................................"
.ascii "................................................................................"
.ascii "................................................................................"
.ascii "................................................................................"
.ascii "................................................................................"
.ascii "................................................................................"
.ascii ".................EEE............................................................"
.ascii ".................................EEE............................................"
.ascii "...............D......................................DEEE......................"
.ascii "........EEE...DD..............FF.....DDD.............DD........EE..........EE..."
.ascii "..I.G........DDD.....H.G......FF.........G...I......DDD...H..G................I."
.ascii "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
.ascii "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"

# fase1: 60 colunas x 15 linhas (3 tela(s))
.align 2
mapa_fase1:
.word 60, 15
.ascii "............................................................"
.ascii "............................................................"
.ascii "............................................................"
.ascii "............................................................"
.ascii "............................................................"
.ascii "............................................................"
.ascii "............................................................"
.ascii "............................................................"
.ascii "............................................................"
.ascii "..............333................4.........................."
.ascii "................................444........................."
.ascii "..........333.........3333.....44444....3333..8..333....4444"
.ascii "..5...7..6.........A.6.....5..4444444.6A......9.5....6..4444"
.ascii "111111111111111111111111111111111111111111111111111111111111"
.ascii "222222222222222222222222222222222222222222222222222222222222"


# ============================== TABELAS PARA montar_desenhos ==============================
# cada imagem com a sua paleta (termina com 0)
.align 2
tabela_desenhos:
.word img_chefe_stewart_aberto, pal_chefe_stewart_aberto
.word img_chefe_stewart_fechado, pal_chefe_stewart_fechado
.word img_coracao_cheio, pal_coracao_cheio
.word img_coracao_vazio, pal_coracao_vazio
.word img_estudante_andando, pal_estudante
.word img_estudante_parado, pal_estudante
.word img_fundo_arbustos, pal_fundo_arbustos
.word img_fundo_ceu, pal_fundo_ceu
.word img_fundo_morros, pal_fundo_morros
.word img_fundo_nuvem_1, pal_fundo_nuvem_1
.word img_fundo_nuvem_2, pal_fundo_nuvem_2
.word img_fundo_nuvem_3, pal_fundo_nuvem_3
.word img_fundo_predio, pal_fundo_predio
.word img_fundo_sala_carteiras, pal_fundo_sala_carteiras
.word img_fundo_sala_parede, pal_fundo_sala_parede
.word img_fundo_sala_quadro, pal_fundo_sala_quadro
.word img_fundo_serra, pal_fundo_serra
.word img_fundo_sol, pal_fundo_sol
.word img_monstro_aoc, pal_monstro_aoc
.word img_monstro_calculo, pal_monstro_calculo
.word img_monstro_derivada, pal_monstro_derivada
.word img_monstro_integral, pal_monstro_integral
.word img_monstro_lim, pal_monstro_lim
.word img_proj_integral, pal_proj_integral
.word img_tela_game_over, pal_tela_game_over
.word img_tela_vitoria, pal_tela_vitoria
.word img_estudante_corrida_0, pal_estudante
.word img_estudante_corrida_1, pal_estudante
.word img_estudante_corrida_2, pal_estudante
.word img_estudante_corrida_3, pal_estudante
.word img_estudante_corrida_4, pal_estudante
.word img_estudante_corrida_5, pal_estudante
.word img_estudante_corrida_6, pal_estudante
.word img_estudante_corrida_7, pal_estudante
.word img_estudante_corrida_8, pal_estudante
.word img_estudante_dano_0, pal_estudante
.word img_estudante_idle_0, pal_estudante
.word img_estudante_idle_1, pal_estudante
.word img_estudante_idle_2, pal_estudante
.word img_estudante_pulo_0, pal_estudante
.word img_estudante_pulo_1, pal_estudante
.word img_estudante_pulo_2, pal_estudante
.word img_bloco_10, pal_bloco_10
.word img_bloco_11, pal_bloco_11
.word img_bloco_12, pal_bloco_12
.word img_bloco_13, pal_bloco_13
.word img_bloco_14, pal_bloco_14
.word img_bloco_15, pal_bloco_15
.word img_bloco_16, pal_bloco_16
.word img_bloco_17, pal_bloco_17
.word img_bloco_18, pal_bloco_18
.word img_bloco_1, pal_bloco_1
.word img_bloco_2, pal_bloco_2
.word img_bloco_3, pal_bloco_3
.word img_bloco_4, pal_bloco_4
.word img_bloco_5, pal_bloco_5
.word img_bloco_6, pal_bloco_6
.word img_bloco_7, pal_bloco_7
.word img_bloco_8, pal_bloco_8
.word img_bloco_9, pal_bloco_9
# fases 2 e 3 (dados/graficos_fases23.s)
.word img_relogio, pal_relogio
.word img_relogio_mini, pal_relogio_mini
.word img_monstro_ponteiro, pal_monstro_ponteiro
.word img_monstro_pilha, pal_monstro_pilha
.word img_monstro_no, pal_monstro_no
.word img_monstro_bit, pal_monstro_bit
.word img_monstro_bug, pal_monstro_bug
.word img_monstro_porta, pal_monstro_porta
.word img_proj_seta, pal_proj_seta
.word img_proj_bit1, pal_proj_bit1
.word img_proj_bit0, pal_proj_bit0
.word img_chefe_grafo, pal_chefe_grafo
.word img_chefe_grafo_aberto, pal_chefe_grafo_aberto
.word img_chefe_professor, pal_chefe_professor
.word img_chefe_professor_aberto, pal_chefe_professor_aberto
.word img_bloco_19, pal_bloco_19
.word img_bloco_20, pal_bloco_20
.word img_bloco_21, pal_bloco_21
.word img_bloco_22, pal_bloco_22
.word img_bloco_23, pal_bloco_23
.word img_bloco_24, pal_bloco_24
.word img_bloco_25, pal_bloco_25
.word img_bloco_26, pal_bloco_26
.word img_bloco_27, pal_bloco_27
.word img_bloco_28, pal_bloco_28
.word img_bloco_29, pal_bloco_29
.word img_fundo_lab_parede, pal_fundo_lab_parede
.word img_fundo_circuito_parede, pal_fundo_circuito_parede
.word img_fundo_lab_quadro, pal_fundo_lab_quadro
.word img_fundo_lab_mesas, pal_fundo_lab_mesas
.word img_fundo_circuito_trilhas, pal_fundo_circuito_trilhas
.word img_fundo_circuito_servidores, pal_fundo_circuito_servidores
.word 0

# mapas (termina com 0)
tabela_mapas:
.word mapa_calculo, mapa_fase1, mapa_aed, mapa_aoc, 0
