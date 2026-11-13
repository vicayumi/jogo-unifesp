############################################################################
#  PERGUNTAS DOS CHEFÕES
#
#  Cada pergunta é uma linha:
#     .word enunciado, alternativa_1, alternativa_2, alternativa_3, alternativa_4, certa
#  com certa = 0 (alternativa 1), 1, 2 ou 3.  Depois aumente a quantidade.
#  Máximo: 32 perguntas por matéria.
#
#  O enunciado pode ter até 3 linhas de 46 letras ("\n" pula de linha).
#  Cada alternativa cabe em 1 linha de até 42 letras.
############################################################################

.data
.align 2

perguntas_calculo:
.word 10
.word pc1, pc1a, pc1b, pc1c, pc1d, 1
.word pc2, pc2a, pc2b, pc2c, pc2d, 0
.word pc3, pc3a, pc3b, pc3c, pc3d, 2
.word pc4, pc4a, pc4b, pc4c, pc4d, 3
.word pc5, pc5a, pc5b, pc5c, pc5d, 1
.word pc6, pc6a, pc6b, pc6c, pc6d, 3
.word pc7, pc7a, pc7b, pc7c, pc7d, 1
.word pc8, pc8a, pc8b, pc8c, pc8d, 2
.word pc9, pc9a, pc9b, pc9c, pc9d, 1
.word pc10, pc10a, pc10b, pc10c, pc10d, 2

pc1:   .string "Qual é a derivada de f(x) = x² ?"
pc1a:  .string "x"
pc1b:  .string "2x"
pc1c:  .string "x²/2"
pc1d:  .string "2"

pc2:   .string "Quanto vale  ∫ 2x dx ?"
pc2a:  .string "x² + C"
pc2b:  .string "2x² + C"
pc2c:  .string "2 + C"
pc2d:  .string "x + C"

pc3:   .string "Quanto vale o limite de sen(x)/x\nquando x → 0 ?"
pc3a:  .string "0"
pc3b:  .string "∞"
pc3c:  .string "1"
pc3d:  .string "O limite não existe"

pc4:   .string "Qual é a derivada de f(x) = sen(x) ?"
pc4a:  .string "-sen(x)"
pc4b:  .string "tg(x)"
pc4c:  .string "-cos(x)"
pc4d:  .string "cos(x)"

pc5:   .string "Qual é a derivada de f(x) = e^x ?"
pc5a:  .string "x · e^(x-1)"
pc5b:  .string "e^x"
pc5c:  .string "ln(x)"
pc5d:  .string "1/x"

pc6:   .string "Qual é a derivada de f(x) = ln(x), x > 0 ?"
pc6a:  .string "x"
pc6b:  .string "e^x"
pc6c:  .string "ln(x)/x"
pc6d:  .string "1/x"

pc7:   .string "Se f'(a) = 0 e f''(a) > 0, então no ponto\nx = a a função f tem um:"
pc7a:  .string "máximo local"
pc7b:  .string "mínimo local"
pc7c:  .string "ponto de descontinuidade"
pc7d:  .string "assíntota vertical"

pc8:   .string "Quanto vale a integral de x dx\nde 0 até 1 ?"
pc8a:  .string "1"
pc8b:  .string "2"
pc8c:  .string "1/2"
pc8d:  .string "0"

pc9:   .string "A regra da cadeia serve para derivar:"
pc9a:  .string "somas de funções"
pc9b:  .string "funções compostas, como sen(x²)"
pc9c:  .string "funções constantes"
pc9d:  .string "integrais definidas"

pc10:  .string "Quanto vale o limite de 1/x quando x → ∞ ?"
pc10a: .string "1"
pc10b: .string "∞"
pc10c: .string "0"
pc10d: .string "-1"
