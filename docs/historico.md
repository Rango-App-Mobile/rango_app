# Histórico

**Escopo:** a aba Histórico (`HistoryScreen`), o `historyViewModelProvider`, o
modelo `HistoryEntry` e o `HistoryRepository` com o `FakeHistoryRepository`.
Mostra as decisões da pessoa como uma pilha de cards, como uma carteira: o mais
recente embaixo, inteiro e na frente; os antigos acima, cada um mostrando só a
faixa do título, menos o último de cada mês, que aparece inteiro. Tocar num card abre o detalhe da decisão (`HistoryDetailScreen`, em
`/history/<id>`). Figma: "07d Histórico", "10 Histórico vazio" e "12 Detalhe
do histórico".

Ainda não há dado real: salvar a sessão é a E2-S4 (#13, #60). Até lá o
`FakeHistoryRepository` é o padrão do provider e traz 9 decisões de exemplo
(setembro a novembro de 2026), para dar para ver a pilha funcionando.

## O que a pessoa vê

| Situação | Tela |
| --- | --- |
| Carregando | `CircularProgressIndicator` |
| Com decisões | "Seu histórico" e a pilha, separada por mês. A lista abre embaixo, no mais recente |
| Sem decisões | O estado vazio: Empty Card "Seu primeiro rango", o texto e "Decidir meu rango" (vai para a Home) |
| Erro | "Não deu para carregar seu histórico." e "Tentar novamente", que invalida o provider |

Cada card é um Food Card Hero com a comida, o restaurante e o chip da data
("21 set"), no Food Theme e com a foto da comida. O título fica numa linha só
(`titleMaxLines: 1`): uma segunda linha empurraria o restaurante e a data para
baixo do card seguinte. Um nome longo, como "Cachorro-quente", diminui a fonte
até caber (`FittedBox`), em vez de quebrar ou ser cortado com reticências.

## A pilha

O `HistoryStack` (`lib/screens/history/widgets/history_stack.dart`) é uma
rolagem invertida (abre no fim da lista) sobre um `Stack` de cards posicionados
a cada quadro, a partir do quanto a lista já rolou.

| Constante | Valor | Para quê |
| --- | --- | --- |
| `stripHeight` | 84 | Parte visível de um card embaixo do seguinte |
| `pileTop` | 56 | Onde a pilha descansa, a partir do topo da lista: abaixo do rótulo do mês e das bordas da pilha |
| `pileStep` | 6 | Borda de cada card que aparece acima do seguinte na pilha |
| `pileDepth` | 3 | Cards da pilha com borda visível; os de trás não são desenhados |
| `scaleStep` | 0,04 | Quanto cada card mais ao fundo da pilha encolhe |

- Rolando para cima, os cards antigos descem e voltam inteiros (só a faixa).
- Dentro de um mês, um card que chega ao topo para em `pileTop`, encolhe e sobe
  `pileStep` por "card de distância", até `pileDepth`. Assim a pilha mostra
  algumas bordas finas, como cartões numa carteira.
- O último card do mês não para: chega ao topo e sai inteiro por baixo do topo da
  lista, levando a pilha do mês junto.
- Os mais novos ficam sempre na frente: os cards são desenhados do mais antigo
  para o mais novo.
- O tamanho da rolagem vem de um `Column` invisível: as faixas, os cards inteiros
  e os rótulos dos meses antigos e o card mais novo inteiro, medido de verdade (`Visibility` sem
  desenhar).

## Os meses

Um `MonthHeader` (Figma "Month Header") separa os meses: o nome do mês e um chip
com a contagem ("4 rangos"). O mesmo mês de outro ano é outro grupo.

- O último card de cada mês aparece sempre inteiro, sem mudar de tamanho durante
  a rolagem, e depois vem a pausa com o rótulo do mês seguinte no fundo creme. A
  altura do card é medida no `Column` invisível (`_cardHeight`).
- O rótulo do mês no topo fica fixo até o do mês seguinte chegar e empurrá-lo para
  fora, como um cabeçalho de seção.
- Os cards saem por baixo de um véu no topo da lista, creme atrás do rótulo e com
  blur progressivo abaixo dele, em vez de serem cortados numa linha reta.

## O detalhe

Tocar em qualquer card da pilha (no mais novo inteiro ou na faixa de um antigo)
faz `push('/history/<id>')`. A rota abre por cima das abas, sem Tab Bar e com a
Top Bar de "Voltar".

| O que mostra | De onde vem |
| --- | --- |
| Food Card Expanded: comida, chip "1 nov, 12:30", foto | `HistoryDetailState.food` e `dateLabel` |
| "O caminho até aqui": grupo → comida ("Salgado → Macarrão") | `HistoryDetailState.path`, montado pelo `parentId` da comida |
| "Onde você pediu": restaurante e "Italiana · Moinhos de Vento" | `HistoryEntry.restaurantName` e `cuisine` |
| "Pedir de novo" e "Ver no mapa" | Os dois vão para `/restaurants?category=<comida>` até existir a tela "Opções de contato" (06) |
| Id desconhecido | "Não encontramos esse rango." com o "Voltar" |

**A animação:** o card da pilha e o do detalhe estão no mesmo `Hero`
(`HistoryCardHero`, tag `history-card-<id>`), com uma trajetória própria
(`PullOutRectTween`): é como puxar um cartão da carteira.

1. Primeiro o card sobe 96 px, reto, para fora da pilha, no tamanho que tinha.
   Isso ocupa 55% do progresso do Hero, que já vem acelerado pela curva
   `fastOutSlowIn`, então a puxada dura cerca de um terço do voo.
2. Depois viaja e cresce até o lugar dele no detalhe.
3. No caminho ele inclina até 3° e ganha a sombra `Elevation/Floating`, que
   somem ao chegar.
4. Na volta faz o inverso: chega ao ponto acima da pilha e desliza para dentro
   dela no fim.

Durante o voo os dois layouts (Hero e Expanded) trocam por fade, cada um na
própria altura e recortado pela caixa que cresce, para nenhum ser espremido. A
página dura 650 ms na ida e 500 ms na volta. Dela, só o fundo creme entra
rápido (primeiros 30%); o "Voltar" e os botões só aparecem no fim (últimos 30%,
`_LateFade`). Assim, enquanto o card voa, só ele se mexe.

**Por que o detalhe é síncrono:** o Hero só voa se o card de destino já
existir no primeiro quadro da tela nova. Por isso a lista de decisões e o
cardápio ficam em providers guardados em `lib/data/` (`historyEntriesProvider`
e `categoriesProvider`), que o Histórico já carregou. O
`HistoryDetailViewModel` é um `Notifier` síncrono que os lê. Se o detalhe
for aberto direto, sem passar pelo Histórico (deep link), ele passa pelo
"carregando" como qualquer tela, só que sem o voo.

## Onde cada regra mora

| Regra | Onde | Por quê ali |
| --- | --- | --- |
| Ordem do mais antigo para o mais novo; decisões de comida fora do cardápio são ignoradas | `HistoryViewModel` | A View recebe a lista pronta |
| Agrupar por mês, "4 rangos" (singular com 1) e o chip "21 set" | `HistoryState.months` e `HistoryItem.dateLabel` | Formatação testável sem widget |
| Posição, escala e o que entra na pilha | `HistoryStack` (View) | É geometria de rolagem, não regra de negócio |
| Achar a decisão pelo id, a comida e o grupo, já no primeiro quadro; data com hora | `HistoryDetailViewModel` (síncrono, sobre `historyEntriesProvider` e `categoriesProvider`) e `HistoryDetailState` | A tela de detalhe não importa o estado do Histórico (`CLAUDE.md`): recebe só o id pela rota |
| A tag do Hero, igual nas duas telas | `HistoryCardHero` em `lib/core/widgets/` | As duas telas precisam dela e uma tela não importa a outra |

## Testes

| Arquivo | O que cobre |
| --- | --- |
| `test/screens/history/history_view_model_test.dart` | Ordem, comida fora do cardápio, vazio, meses (plural, singular e outro ano), data curta, o histórico de exemplo, erro |
| `test/screens/history_detail/history_detail_view_model_test.dart` | Pronto na hora quando o Histórico já carregou; decisão, comida e grupo; data com hora e minutos com dois dígitos; aberto direto carrega e depois mostra; id desconhecido; histórico com erro |
| `test/screens/history_detail/history_detail_screen_test.dart` | Comida, data, caminho e restaurante, sem adesivo; botões levam aos restaurantes; "Voltar"; id desconhecido; 375x667 |
| `test/core/widgets/history_card_hero_test.dart` | A trajetória: começa e termina nos cards, primeiro sobe reto para fora da pilha, só depois cresce; na volta passa pelo ponto acima da pilha |
| `test/app/app_test.dart` | Tocar no card abre o detalhe e o "Voltar" volta, sem erro de layout no meio do voo |
| `test/screens/history/history_screen_test.dart` | Tocar no mais novo e na faixa de um antigo abre o detalhe certo; o mais novo inteiro e na frente; distância de uma faixa entre os cards; nenhum card sai pelo topo, antes e depois de rolar; a pilha encolhe para o fundo; título em uma linha, com nome longo encolhendo a fonte; estado vazio e "Decidir meu rango"; erro; 375x667 |

Não coberto por teste automatizado, validar à mão: a rolagem e o voo do card no
simulador, e a aparência contra as telas "07d" e "12" do Figma.

## O que não está aqui

| Fora desta entrega | Onde vai |
| --- | --- |
| Salvar as decisões de verdade | E2-S4 (#13, #60) |
| Separar por mês ("Setembro", "12 min") como no Figma | Junto com a E2-S4, quando houver dado real |
| "Pedir de novo" abrindo as opções de contato (06) | E3 |
| Foto do restaurante e as métricas (distância, tempo) do bloco "Onde você pediu" | Junto com os dados reais dos restaurantes (E3-S7) |
