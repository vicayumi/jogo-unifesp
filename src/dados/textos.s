############################################################################
#  TEXTOS DO JOGO
#
#  Escreva normalmente, com acentos. "\n" pula de linha.
#  Cada letra tem 6 pixels: numa linha da tela cabem 53 letras, numa caixa de
#  texto (explicação, pergunta) cabem 46. A fonte tem: letras, números,
#  pontuação, á à â ã é ê í ó ô õ ú ç (e maiúsculas), ² ³ ° ∫ √ π ∞ → ≤ ≥ Ω Θ.
############################################################################

.data

# ---------------------------- tela inicial ----------------------------
txt_titulo_1:        .string "O ESTUDANTE"
txt_titulo_2:        .string "DA UNIFESP"
txt_subtitulo:       .string "Uma aventura em Assembly RISC-V"
txt_pressione_enter: .string "PRESSIONE ENTER"
txt_rodape_menu:     .string "Arquitetura e Organização de Computadores"

# ---------------------------- explicação ----------------------------
txt_historia_1:
.string "HISTÓRIA\n\nVocê é um calouro que acabou de entrar na\nUNIFESP. No primeiro dia de aula, algo\nestranho aconteceu: as matérias do curso\nganharam vida e encheram o campus de\nmonstros.\n\nCada matéria virou um mundo, guardado por um\nchefão. Só quem vencer todos eles chega à\nformatura.\n\nAntes de enfrentar as matérias, faça o\ntreino no campus."
txt_historia_2:
.string "COMO JOGAR\n\nA / D ou setas ................ andar\nW, seta para cima ou ESPAÇO ... pular\n(segure o pulo para ir mais alto)\n\nPule em cima dos monstros para vencê-los.\nEncostar neles de lado tira um coração.\nSem corações, a fase recomeça.\n\nNos chefões, responda as perguntas com\n1, 2, 3 ou 4.\n\nESC sai do jogo.   M liga ou desliga o som."
txt_enter_continuar: .string "ENTER para continuar"
txt_enter_comecar:   .string "ENTER para começar"

# ---------------------------- treino ----------------------------
txt_tutorial_nome:      .string "TREINO"
txt_tutorial_titulo:    .string "CAMPUS"
txt_tutorial_frase:     .string "Aprenda os comandos antes das matérias.\nEntre pela porta da UNIFESP!"
txt_tutorial_concluido: .string "TREINO CONCLUÍDO!\n\nVocê já sabe andar, pular e\nderrotar monstros.\n\nPróxima parada:\nFASE 1 - CÁLCULO 1"
txt_dica_andar:         .string "A/D ou setas: andar    W ou ESPAÇO: pular"
txt_dica_pulo:          .string "Segure o pulo para ir mais alto!"
txt_dica_pisar:         .string "Pule em cima dos monstros para vencê-los!"
txt_dica_dano:          .string "Encostar de lado tira um coração."
txt_dica_bandeira:      .string "Entre pela porta da UNIFESP!"
txt_unifesp:            .string "UNIFESP"

# ---------------------------- Fase 1: Cálculo 1 ----------------------------
txt_calculo_nome:      .string "FASE 1"
txt_calculo_titulo:    .string "CÁLCULO 1"
txt_calculo_frase:     .string "Cuidado com a cobra da integral, o fantasma\ndo limite e a derivada saltitante.\nNo fim da sala, o temido Livro do Stewart!"
txt_calculo_concluido: .string "FASE 1 CONCLUÍDA!\n\nVocê venceu o Livro do Stewart\ne passou em Cálculo 1.\n\nPróxima parada:\nFASE 2 - AED"
txt_stewart_nome:       .string "LIVRO DO STEWART"
txt_stewart_sub:        .string "Chefão de Cálculo 1"

# ---------------------------- Fase 2: AED ----------------------------
txt_aed_nome:          .string "FASE 2"
txt_aed_titulo:        .string "AED"
txt_aed_frase:         .string "Algoritmos e Estruturas de Dados: pilhas,\nponteiros e nós de grafo. Cuidado com os\nespinhos! No fim do laboratório: O GRAFO."
txt_aed_concluido:     .string "FASE 2 CONCLUÍDA!\n\nVocê derrotou O GRAFO\ne passou em AED.\n\nPróxima parada (a última!):\nFASE 3 - AOC"
txt_grafo_nome:        .string "O GRAFO"
txt_grafo_sub:         .string "Chefão de AED"
txt_grafo_pergunta:    .string "O GRAFO PERGUNTA:"
txt_grafo_certo:       .string "CERTO! O Grafo perdeu um vértice."
txt_cin_grafo_usa:     .string "O GRAFO usa:"
txt_cin_grafo_golpe:   .string "SEGMENTATION\nFAULT!"

# ---------------------------- Fase 3: AOC (final) ----------------------------
# (o chefão final foi desenhado parecido com o nosso professor de AOC;
#  para trocar o nome dele é só mudar os textos txt_professor_* e txt_cin_professor_*)
txt_aoc_nome:          .string "FASE 3"
txt_aoc_titulo:        .string "AOC"
txt_aoc_frase:         .string "Arquitetura e Organização de Computadores:\nbits, bugs e portas lógicas. Cuidado com os\ncurtos-circuitos! Chefão final: o PROFESSOR."
txt_aoc_concluido:     .string "PARABÉNS! VOCÊ SE FORMOU!\n\nVocê venceu o Professor de AOC\ne todas as matérias do curso.\n\nObrigado por jogar\nO ESTUDANTE DA UNIFESP!"
txt_professor_nome:    .string "PROFESSOR CAPPA"
txt_professor_sub:     .string "Chefão final de AOC"
txt_professor_pergunta: .string "O PROFESSOR CAPPA PERGUNTA:"
txt_professor_certo:   .string "CERTO! O professor ficou orgulhoso."
txt_cin_professor_usa: .string "O PROFESSOR CAPPA usa:"
txt_cin_professor_golpe: .string "PROVA DE\nASSEMBLY!"

# ---------------------------- atalhos de teste (rotinas/debug.s) ----------------------------
txt_dbg_invencivel:    .string "INVENCÍVEL"
txt_dbg_pulo:          .string "PULO INFINITO"
txt_dbg_pos:           .string "X       Y       COL     LIN"

# ---------------------------- perguntas ----------------------------
txt_pergunta_titulo:   .string "O LIVRO DO STEWART PERGUNTA:"
txt_pergunta_ajuda:    .string "Responda com 1, 2, 3 ou 4"
txt_pergunta_certo:    .string "CERTO! O livro perdeu uma página."
txt_pergunta_errado:   .string "ERROU! Você perdeu um coração."
txt_alt_1:             .string "1)"
txt_alt_2:             .string "2)"
txt_alt_3:             .string "3)"
txt_alt_4:             .string "4)"

# ---------------------------- fim de jogo ----------------------------
txt_game_over_dica:    .string "A fase recomeça com 3 corações."

# ---------------------------- cinema (golpe final, rotinas/cinema.s) ----------------------------
txt_cin_stewart_usa:    .string "O LIVRO DO STEWART usa:"
txt_cin_prova:         .string "PROVA\nSURPRESA!"
txt_cin_reprovado:     .string "REPROVADO!"
txt_cin_aluno_usa:     .string "O ESTUDANTE usa:"
txt_cin_resposta:      .string "RESPOSTA\nCERTA!"
txt_cin_aprovado:      .string "APROVADO!"

# derrota para os monstrinhos, blocos que machucam e o cronômetro
# ("Fulano usa:" cabe em 30 letras; o golpe em 2 linhas de 15)
txt_cin_m_calculo:     .string "O MONSTRO DE CÁLCULO usa:"
txt_cin_g_calculo:     .string "CONTA\nERRADA!"
txt_cin_m_aoc:         .string "O CHIP MALUCO usa:"
txt_cin_g_aoc:         .string "SUPER-\nAQUECIMENTO!"
txt_cin_m_integral:    .string "A COBRA DA INTEGRAL usa:"
txt_cin_g_integral:    .string "BOTE\nINTEGRAL!"
txt_cin_m_lim:         .string "O FANTASMA DO LIMITE usa:"
txt_cin_g_lim:         .string "TENDE AO\nINFINITO!"
txt_cin_m_derivada:    .string "A DERIVADA usa:"
txt_cin_g_derivada:    .string "PULO DA\nTANGENTE!"
txt_cin_m_ponteiro:    .string "O PONTEIRO usa:"
txt_cin_g_ponteiro:    .string "PONTEIRO\nNULO!"
txt_cin_m_pilha:       .string "A PILHA usa:"
txt_cin_g_pilha:       .string "STACK\nOVERFLOW!"
txt_cin_m_no:          .string "O NÓ DO GRAFO usa:"
txt_cin_g_no:          .string "LOOP\nINFINITO!"
txt_cin_m_bit:         .string "O BIT usa:"
txt_cin_g_bit:         .string "BIT\nINVERTIDO!"
txt_cin_m_bug:         .string "O BUG usa:"
txt_cin_g_bug:         .string "TELA\nAZUL!"
txt_cin_m_porta:       .string "A PORTA LÓGICA usa:"
txt_cin_g_porta:       .string "NAND\nFATAL!"
txt_cin_m_espinhos:    .string "OS ESPINHOS usam:"
txt_cin_g_espinhos:    .string "ESPETADA\nDOLORIDA!"
txt_cin_m_curto:       .string "O CURTO-CIRCUITO usa:"
txt_cin_g_curto:       .string "CHOQUE DE\n220 VOLTS!"
txt_cin_relogio_usa:   .string "O RELÓGIO usa:"
txt_cin_relogio_golpe: .string "FIM DO\nTEMPO!"
txt_cin_reprovou_falta: .string "REPROVOU POR FALTA!"
