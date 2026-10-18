# Swipe

**Escopo:** a tela `swipe` (View), o `swipeViewModelProvider` e o
`CategoryRepository` com a implementação `FakeCategoryRepository` (issues #11 e
#54). A tela mostra dois cards por nível; a pessoa toca ou arrasta um deles
até a sessão convergir para um tipo de comida.

As regras de produto vêm das seções §6 e §7 de `docs/contexto.md`. Este
documento explica o porquê das escolhas de implementação; não repete o contexto.

## O fluxo

| # | O que a pessoa vê / faz | Tela (View) | ViewModel / modelo |
|---|---|---|---|
| 1 | Abre o app: spinner enquanto as categorias carregam | `CircularProgressIndicator` | `build()` busca tudo no `CategoryRepository` e monta a `CategoryTree` |
| 2 | Vê "Bora decidir o Rango?" e dois cards (Salgado, Doce) com o adesivo "ou" | `PageHeader` com `state.title` e `state.subtitle`; `SwipeChoiceCards` anima a entrada (fade + deslize, 250 ms) | `SwipeState.options` traz as duas opções do nível |
| 3 | Toca num card ou o arrasta | Toque chama `choose(option)`; no arrasto o card acompanha o dedo (translação horizontal + inclinação extra) | `choose` empilha a opção em `history` e desce um nível |
| 4 | Solta o card antes do limite | O card volta para o lugar (200 ms; sem animação se o sistema pede menos movimento) | Nada muda |
| 5 | Solta o card além do limite | A View chama `choose(option)` | Igual ao toque |
| 6 | No nível seguinte aparece "Voltar" e os cards novos entram | Os cards têm `ValueKey(state.current.id)`; trocar de nível recria o par e refaz a entrada | `canUndo` passa a ser verdadeiro |
| 7 | Toca em "Voltar" | `undo()` | O ViewModel tira a última escolha de `history` e volta ao nível pai |
| 8 | Escolhe uma folha (ex.: Pizza) | Título "Agora é só escolher onde.", card grande com o tipo de comida, o caminho ("Salgado, massa, pizza"), o chip "3 escolhas", o adesivo "Deu match!" e o botão "Recomeçar" | `result` é a folha; `options` fica vazia |
| 9 | Toca em "Recomeçar" | `reset()` | Volta ao estado inicial |

O estado de convergência na tela é mínimo: a tela de resultado completa é uma
história posterior.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| Converge quando a opção escolhida é folha | `CategoryTree` (model) | Dart puro, teste unitário instantâneo; vale para o Fake e para o Firestore |
| Texto do título e do subtítulo por nível; `canUndo` | `SwipeState` | Derivados do estado; a View só os exibe |
| Desfazer a última escolha | `SwipeViewModel.undo` | É regra de sessão, testável sem widget |
| Limite do arrasto: mais de 35% da largura do card ou velocidade horizontal acima de 800 px/s | `DraggableFoodCard` (View) | É interpretação de gesto, não regra de negócio; o resultado só chama `choose` |
| Menos movimento (`MediaQuery.disableAnimationsOf`) | `SwipeChoiceCards` e `DraggableFoodCard` (View) | A preferência vem do sistema e só a View tem acesso ao contexto |
| Food Theme do card | `resolveFoodTheme` (View) | O model guarda o nome como `String` para continuar Dart puro; a View converte com fallback para `tomato` quando o nome é nulo ou desconhecido |
| Alternativa ao gesto | Toque no card, com `Semantics` de botão ("Escolher Salgado") | Arrastar não é acessível nem funciona bem no simulador |

O arrasto é só horizontal, para que a página continue rolando na vertical em
telas pequenas (375x667), onde o par de cards não cabe inteiro.

## Erros

| Situação | O que a tela mostra |
|---|---|
| Falha ao carregar as categorias | "Não deu para carregar as opções." e o botão "Tentar novamente", que invalida o `swipeViewModelProvider` |

## Testes

| Arquivo | O que cobre |
|---|---|
| `test/screens/swipe/swipe_view_model_test.dart` | Regras da sessão: escolher, convergir, desfazer, recomeçar, erro do repositório |
| `test/screens/swipe/swipe_screen_test.dart` | Raiz sem "Voltar"; toque avança; arrasto longo escolhe e arrasto curto volta; o card acompanha o dedo; "Voltar" desfaz; caminho completo até o resultado e "Recomeçar"; menos movimento sem animação em andamento; entrada animada; 375x667 sem overflow; erro com "Tentar novamente"; carregando |
| `test/screens/swipe/widgets/resolve_food_theme_test.dart` | Nome conhecido e fallback para `tomato` |

Não coberto por teste automatizado, validar à mão: **arrastar no simulador** (o
card acompanha o dedo, a inclinação e a volta suave ficam naturais, a rolagem
vertical continua funcionando fora dos cards) e a aparência dos cards e dos
adesivos contra as telas "01 Home", "02 Escolha nível 2" e "04" do Figma.

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Top Bar, logo, avatar e Tab Bar | Histórias de navegação e perfil |
| Tela de resultado completa (Figma 04) | História própria |
| Repositório real no Firestore | Sprint 2 |
