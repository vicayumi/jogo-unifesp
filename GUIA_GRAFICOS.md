# Guia de gráficos do jogo

**Tudo é feito em assembly.** Os sprites, o cenário, os blocos, os mapas e até a fonte estão **desenhados em texto** dentro dos arquivos `.s`, com uma letra por pixel. Não existe conversor nem programa em Python: para mudar um desenho, vocês editam o `.s` e rodam o jogo.

```
editar o desenho em src/dados/graficos.s  →  rodar o jogo
```

Quando o jogo abre, a rotina `montar_desenhos` (`src/rotinas/desenhos.s`) transforma as letras em cores. A partir daí as imagens ficam no formato que as rotinas de desenho sempre usaram, então o resto do jogo não mudou nada.

---

## 1. Como uma imagem é desenhada

Exemplo real (o coração cheio do HUD), em `src/dados/graficos.s`:

```asm
pal_coracao_cheio:
.byte '.',0xC7, 'R',0x0E, 'r',0x03, '1',0xAF, 0   # . transparente, R vermelho, r vermelho escuro, 1 vermelho
.align 2
img_coracao_cheio:
.word 9, 8                  # largura, altura
.ascii "..rr.rr.."
.ascii ".rRRrRRr."
.ascii "rR1RRRRRr"
.ascii "rRRRRRRRr"
.ascii ".rRRRRRr."
.ascii "..rRRRr.."
.ascii "...rRr..."
.ascii "....r...."
```

São três partes:

1. **A paleta** (`pal_...`): pares `'letra', cor` e um `0` no fim. Diz qual cor cada letra representa.
2. **O tamanho** (`.word largura, altura`).
3. **O desenho**: `altura` linhas `.ascii`, cada uma com exatamente `largura` letras.

O `.align 2` antes da imagem é obrigatório, porque a imagem começa com `.word`, que precisa estar alinhado em 4 bytes.

### O que acontece por dentro

`.ascii "..rr.rr.."` guarda na memória os códigos das letras (`'.'` = 46, `'r'` = 114...), 1 byte por letra. A rotina `montar_desenhos` monta uma **tabela de tradução** de 256 bytes a partir da paleta (`traducao['r'] = 0x03`...). Depois ela troca, **no próprio lugar**, cada letra pela sua cor. Como 1 letra = 1 byte = 1 pixel, a imagem não muda de tamanho e fica exatamente no formato `.word largura, altura` + 1 byte por pixel, que `desenhar_imagem` usa.

### Fases 2 e 3

Os desenhos das Fases 2 (AED) e 3 (AOC) ficam num arquivo à parte, `src/dados/graficos_fases23.s`, no **mesmo formato**: monstros (ponteiro, pilha, nó, bit, bug, porta lógica), projéteis (seta, bits 0 e 1), os chefões (`img_chefe_grafo`, `img_chefe_professor` e as versões `_aberto`, usadas quando eles perguntam e no filminho), os blocos 19 a 29 (letras `J` a `T` nos mapas), os cenários do laboratório e do circuito e os mapas `mapa_aed` e `mapa_aoc`. Todas as imagens desse arquivo usam as letras de uma mesma "paleta mestre" (o comentário embaixo de cada paleta diz o nome de cada cor). Elas já estão na `tabela_desenhos`, os blocos na tabela `blocos` e os mapas na `tabela_mapas` (`graficos.s`). Em `previa/` há PNGs desses desenhos (`fases23_*.png`, `mapa_aed.png`, `mapa_aoc.png`).

## 2. Cores

Cada pixel é 1 byte no formato `BBGGGRRR`: 2 bits de azul, 3 de verde e 3 de vermelho (256 cores).

| Exemplo | Bits | Cor |
|---|---|---|
| `0x07` | 00 000 111 | vermelho puro |
| `0x38` | 00 111 000 | verde puro |
| `0xC0` | 11 000 000 | azul puro |
| `0x3F` | 00 111 111 | amarelo |
| `0xFF` | 11 111 111 | branco |
| `0x00` | 00 000 000 | preto |
| `0xC7` | 11 000 111 | **transparente** (o jogo não desenha esse pixel) |

As letras das paletas seguem o **tipo da cor** (maiúscula = clara, minúscula = escura):

| Letra | Cor | Letra | Cor |
|---|---|---|---|
| `.` | transparente | `G` / `g` | verde |
| `K` | preto | `C` / `c` | ciano |
| `W` | branco | `B` / `b` | azul |
| `S` / `s` | cinza claro / escuro | `P` / `p` | roxo / rosa |
| `R` / `r` | vermelho | `N` / `n` | marrom |
| `O` / `o` | laranja | `Y` / `y` | amarelo |

Quando uma imagem tem duas cores do mesmo tipo, a segunda ganha um número ou símbolo (`1`, `2`, `#`...). O comentário ao lado de cada paleta diz o que é cada letra.

Para ver as 256 cores possíveis e descobrir o número de uma cor, abram `ferramentas/paleta_fpgrars.png`.

## 3. Editar um desenho

- **Mudar pixels:** troquem letras nas linhas `.ascii`, usando letras que existem na paleta daquela imagem.
- **Cor nova:** acrescentem `'letra',cor` na paleta, **antes do 0** (ex.: `'Y',0x3F,`).
- **Cuidado:** cada linha precisa ter **exatamente** `largura` letras e precisa haver **exatamente** `altura` linhas. Se faltar ou sobrar uma letra, a imagem toda "escorrega".
- Letra que não está na paleta vira transparente.
- Usem uma fonte de largura fixa no editor (o VS Code já usa), assim as linhas ficam alinhadas e dá para enxergar o desenho.

## 4. Criar uma imagem nova

1. Em `src/dados/graficos.s`, escrevam a paleta, o `.align 2`, o rótulo `img_nome:`, o `.word largura, altura` e as linhas.
2. No fim do arquivo, acrescentem uma linha na `tabela_desenhos` (antes do `.word 0`):
   ```asm
   .word img_nome, pal_nome
   ```
   Sem isso, a imagem não é montada e aparece com cores erradas.
3. Desenhem no código:
   ```asm
   la   a0, img_nome            # qual imagem
   li   a1, 100                 # x
   li   a2, 184                 # y
   li   a3, 0                   # 0 = normal, 1 = espelhado
   mv   a4, s1                  # onde desenhar (o frame escondido)
   call desenhar_imagem
   ```

Várias imagens podem usar a mesma paleta. Todas as poses do estudante, por exemplo, usam `pal_estudante`.

## 5. Tamanhos

| O quê | Tamanho | Observação |
|---|---|---|
| Tela | 320 × 240 | cabem 20 × 15 blocos |
| Bloco do cenário | **16 × 16 (obrigatório)** | chão, tijolo, plataforma... |
| Estudante | 32 × 32 (animações) | o desenho é centralizado na hitbox |
| Monstros | 16 × 16 | |
| Chefe | 48 × 48 | |

## 6. Blocos e mapas

**Blocos** são imagens 16 × 16 (`img_bloco_1`, `img_bloco_2`...). A tabela `blocos` (em `graficos.s`) diz qual imagem é cada número. Quais blocos são sólidos é decidido pela tabela `bloco_solido` em `src/rotinas/colisao.s` (1 = sólido). Hoje são sólidos de 1 a 4 (campus) e de 11 a 15 (sala de aula).

**Mapas** também são desenhados em texto, **uma letra por bloco**:

```asm
mapa_fase1:
.word 60, 15                 # colunas, linhas (15 linhas = altura da tela)
.ascii "....................."
...
.ascii "..........333.........3333.....44444....3333..8..333....4444"
.ascii "..5...7..6.........A.6.....5..4444444.6A......9.5....6..4444"
.ascii "111111111111111111111111111111111111111111111111111111111111"
.ascii "222222222222222222222222222222222222222222222222222222222222"
```

| Letra | Bloco |
|---|---|
| `.` | vazio (céu) |
| `1` a `9` | blocos 1 a 9 |
| `A` a `Z` | blocos 10 a 35 (A = 10, B = 11, ...) |

`montar_desenhos` troca cada letra pelo número do bloco. Um mapa novo precisa entrar na `tabela_mapas` (no fim de `graficos.s`).

Com o pulo atual (~3,5 blocos), deixem cada plataforma no máximo 2 blocos acima de onde o estudante pula. Com 20 colunas cabe exatamente uma tela; fases maiores usam 40, 60, 80... colunas.

## 7. A fonte (letras do texto)

Fica em `src/dados/fonte.s`, também desenhada em texto: `#` = pixel aceso, `.` = apagado, 12 linhas de 5 colunas por letra:

```asm
# 'A'
.word 65                     # código da letra (Latin-1)
.ascii "....."
.ascii "....."
.ascii ".###."
.ascii "#...#"
.ascii "#...#"
.ascii "#####"
.ascii "#...#"
.ascii "#...#"
.ascii "#...#"
.ascii "....."
.ascii "....."
.ascii "....."
```

`montar_desenhos` transforma cada linha em 1 byte (bit 4 = coluna da esquerda) e guarda na tabela `fonte`. Os símbolos de matemática (∫ Ω Θ √ π ∞ → ≤ ≥) usam os códigos 0x80 a 0x88 (veja `proximo_caractere` em `texto.s`).

## 8. Dicas de pixel art para o jogo

- **Desenhem os personagens olhando para a direita.** O jogo espelha sozinho quando eles andam para a esquerda (veja `espelhar_monstros` em `dados/monstros.s`).
- **Contorno escuro** (azul-marinho ou marrom-escuro fica melhor que preto puro) destaca o personagem do fundo.
- **Poucas cores** por sprite (3 a 6) deixam com cara de fliperama e o desenho em texto fica mais fácil de ler.
- Para os monstros das matérias, pensem em **uma característica marcante** que se leia em 16 × 16.

## 9. E as pastas `graficos/` e `previa/`?

Elas têm os PNGs antigos, de quando havia um conversor em Python. **O jogo não usa mais esses arquivos:** o que vale é o que está desenhado em `src/dados/graficos.s`. Eles ficaram só como referência visual e podem ser apagados.
