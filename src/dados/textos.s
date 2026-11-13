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
txt_calculo_concluido: .string "FASE 1 CONCLUÍDA!\n\nVocê venceu o Livro do Stewart\ne passou em Cálculo 1.\n\nPróxima: FASE 2 - AED\n(em construção)"
txt_stewart_nome:       .string "LIVRO DO STEWART"
txt_stewart_sub:        .string "Chefão de Cálculo 1"

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
