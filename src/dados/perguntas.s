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

# ======================== FASE 2: AED (O GRAFO) ========================
perguntas_aed:
.word 13
.word pa1, pa1a, pa1b, pa1c, pa1d, 1
.word pa2, pa2a, pa2b, pa2c, pa2d, 2
.word pa3, pa3a, pa3b, pa3c, pa3d, 3
.word pa4, pa4a, pa4b, pa4c, pa4d, 2
.word pa5, pa5a, pa5b, pa5c, pa5d, 0
.word pa6, pa6a, pa6b, pa6c, pa6d, 1
.word pa7, pa7a, pa7b, pa7c, pa7d, 1
.word pa8, pa8a, pa8b, pa8c, pa8d, 1
.word pa9, pa9a, pa9b, pa9c, pa9d, 2
.word pa10, pa10a, pa10b, pa10c, pa10d, 3
.word pa11, pa11a, pa11b, pa11c, pa11d, 0
.word pa12, pa12a, pa12b, pa12c, pa12d, 0
.word pa13, pa13a, pa13b, pa13c, pa13d, 3

pa1:   .string "Qual estrutura segue a regra LIFO (o último\na entrar é o primeiro a sair)?"
pa1a:  .string "Fila"
pa1b:  .string "Pilha"
pa1c:  .string "Lista ligada"
pa1d:  .string "Árvore binária"

pa2:   .string "Qual estrutura segue a regra FIFO (o primeiro\na entrar é o primeiro a sair)?"
pa2a:  .string "Pilha"
pa2b:  .string "Árvore"
pa2c:  .string "Fila"
pa2d:  .string "Grafo"

pa3:   .string "Qual é a complexidade da busca binária num\nvetor ORDENADO de n elementos?"
pa3a:  .string "O(n)"
pa3b:  .string "O(n²)"
pa3c:  .string "O(1)"
pa3d:  .string "O(log n)"

pa4:   .string "Qual destes algoritmos de ordenação é\nO(n log n) até no PIOR caso?"
pa4a:  .string "Bubble sort"
pa4b:  .string "Insertion sort"
pa4c:  .string "Merge sort"
pa4d:  .string "Selection sort"

pa5:   .string "Numa árvore binária de busca, onde ficam os\nvalores MENORES que a raiz?"
pa5a:  .string "na subárvore esquerda"
pa5b:  .string "na subárvore direita"
pa5c:  .string "só nas folhas"
pa5d:  .string "em qualquer lugar"

pa6:   .string "Qual percurso visita os nós de uma árvore\nbinária de busca em ordem CRESCENTE?"
pa6a:  .string "pré-ordem"
pa6b:  .string "em ordem (in-order)"
pa6c:  .string "pós-ordem"
pa6d:  .string "em largura"

pa7:   .string "A busca em LARGURA (BFS) num grafo usa qual\nestrutura auxiliar?"
pa7a:  .string "pilha"
pa7b:  .string "fila"
pa7c:  .string "árvore AVL"
pa7d:  .string "tabela hash"

pa8:   .string "Em C, se p é um ponteiro para int, o que\nfaz a expressão  *p ?"
pa8a:  .string "devolve o endereço de p"
pa8b:  .string "acessa o valor apontado por p"
pa8c:  .string "multiplica p por alguma coisa"
pa8d:  .string "libera a memória de p"

pa9:   .string "Qual é a complexidade do Quicksort no PIOR\ncaso?"
pa9a:  .string "O(n log n)"
pa9b:  .string "O(n)"
pa9c:  .string "O(n²)"
pa9d:  .string "O(log n)"

pa10:  .string "Um grafo simples com n vértices e uma aresta\nentre CADA par de vértices tem quantas\narestas?"
pa10a: .string "n"
pa10b: .string "n²"
pa10c: .string "2n"
pa10d: .string "n(n-1)/2"

pa11:  .string "Quanto custa inserir um elemento no INÍCIO\nde uma lista ligada?"
pa11a: .string "O(1)"
pa11b: .string "O(n)"
pa11c: .string "O(log n)"
pa11d: .string "O(n²)"

pa12:  .string "Qual estrutura implementa uma fila de\nprioridade de forma eficiente?"
pa12a: .string "heap (monte)"
pa12b: .string "pilha"
pa12c: .string "fila simples"
pa12d: .string "vetor não ordenado"

pa13:  .string "Quantos nós tem, no máximo, uma árvore\nbinária de altura h (a raiz tem altura 0)?"
pa13a: .string "2h"
pa13b: .string "h²"
pa13c: .string "2^h"
pa13d: .string "2^(h+1) - 1"

# ======================== FASE 3: AOC (O PROFESSOR, chefão final) ========================
perguntas_aoc:
.word 14
.word po1, po1a, po1b, po1c, po1d, 1
.word po2, po2a, po2b, po2c, po2d, 1
.word po3, po3a, po3b, po3c, po3d, 2
.word po4, po4a, po4b, po4c, po4d, 2
.word po5, po5a, po5b, po5c, po5d, 2
.word po6, po6a, po6b, po6c, po6d, 1
.word po7, po7a, po7b, po7c, po7d, 0
.word po8, po8a, po8b, po8c, po8d, 0
.word po9, po9a, po9b, po9c, po9d, 1
.word po10, po10a, po10b, po10c, po10d, 2
.word po11, po11a, po11b, po11c, po11d, 0
.word po12, po12a, po12b, po12c, po12d, 2
.word po13, po13a, po13b, po13c, po13d, 1
.word po14, po14a, po14b, po14c, po14d, 3

po1:   .string "Em RISC-V, qual instrução CARREGA uma\npalavra (32 bits) da memória num registrador?"
po1a:  .string "sw"
po1b:  .string "lw"
po1c:  .string "lb"
po1d:  .string "add"

po2:   .string "Quanto vale o número binário 1011 em\ndecimal?"
po2a:  .string "9"
po2b:  .string "11"
po2c:  .string "13"
po2d:  .string "15"

po3:   .string "Qual registrador do RISC-V vale SEMPRE\nzero?"
po3a:  .string "x1 (ra)"
po3b:  .string "x2 (sp)"
po3c:  .string "x0 (zero)"
po3d:  .string "x10 (a0)"

po4:   .string "Em complemento de 2 com 8 bits, como fica\no número -1?"
po4a:  .string "10000001"
po4b:  .string "11111110"
po4c:  .string "11111111"
po4d:  .string "00000001"

po5:   .string "Quanto vale 0x1F em decimal?"
po5a:  .string "15"
po5b:  .string "16"
po5c:  .string "31"
po5d:  .string "255"

po6:   .string "Para que serve o PC (program counter)?"
po6a:  .string "guarda o resultado da ULA"
po6b:  .string "guarda o endereço da instrução"
po6c:  .string "guarda o topo da pilha"
po6d:  .string "conta quantos programas rodaram"

po7:   .string "Num pipeline clássico de 5 estágios, qual\né a ordem certa?"
po7a:  .string "IF, ID, EX, MEM, WB"
po7b:  .string "ID, IF, EX, WB, MEM"
po7c:  .string "IF, EX, ID, MEM, WB"
po7d:  .string "EX, IF, ID, WB, MEM"

po8:   .string "Uma instrução precisa de um dado que a\nanterior ainda não escreveu no registrador.\nIsso é um:"
po8a:  .string "hazard de dados"
po8b:  .string "hazard estrutural"
po8c:  .string "cache miss"
po8d:  .string "overflow"

po9:   .string "A memória cache serve para:"
po9a:  .string "aumentar o tamanho do disco"
po9b:  .string "diminuir o tempo de acesso à memória"
po9c:  .string "guardar o sistema operacional"
po9d:  .string "substituir os registradores"

po10:  .string "Em RISC-V, o que faz  addi t0, t0, -1 ?"
po10a: .string "soma 1 a t0"
po10b: .string "zera t0"
po10c: .string "subtrai 1 de t0"
po10d: .string "copia t0 para t1"

po11:  .string "Qual instrução RISC-V desvia (pula) quando\ndois registradores são IGUAIS?"
po11a: .string "beq"
po11b: .string "bne"
po11c: .string "jal"
po11d: .string "blt"

po12:  .string "A porta lógica que só dá 1 quando as DUAS\nentradas são 1 é a:"
po12a: .string "OR"
po12b: .string "XOR"
po12c: .string "AND"
po12d: .string "NOT"

po13:  .string "Em little-endian, a palavra 0x12345678 fica\nna memória (do menor endereço para o maior)\ncomo:"
po13a: .string "12 34 56 78"
po13b: .string "78 56 34 12"
po13c: .string "87 65 43 21"
po13d: .string "56 78 12 34"

po14:  .string "Numa chamada de função em RISC-V, para que\nserve a pilha (registrador sp)?"
po14a: .string "guardar o código do programa"
po14b: .string "acelerar as contas da ULA"
po14c: .string "guardar o PC da instrução atual"
po14d: .string "salvar ra e os registradores s"
