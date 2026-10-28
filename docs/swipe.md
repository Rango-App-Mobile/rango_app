# Swipe e Deu match

**Escopo:** a tela `swipe` (View), o `swipeViewModelProvider`, a tela `result`
("Deu match", Figma 04) com o `resultViewModelProvider`, o duelo "quem ganha
fica" (`DuelGame` e `DuelState`) e o `CategoryRepository` com a implementação
`LocalCategoryRepository` (issues #10, #11, #12 e #54). A pessoa escolhe
Salgado ou Doce e depois toca ou arrasta um de dois cards a cada duelo até uma
comida vencer três seguidas; o app então mostra o match. A navegação (abas, Top
Bar, Tab Bar) está em `docs/navegacao.md`.

As regras de produto vêm das seções §6 e §7 (R2) de `docs/contexto.md`. Este
documento explica o porquê das escolhas de implementação; não repete o contexto.

## O fluxo

| # | O que a pessoa vê / faz | Tela (View) | ViewModel / modelo |
| --- | --- | --- | --- |
| 1 | Abre o app: spinner enquanto as categorias carregam | `CircularProgressIndicator` | `build()` busca tudo no `CategoryRepository` e monta a `CategoryTree` |
| 2 | Na aba Home vê "Bora decidir o Rango?" e dois cards (Salgado, Doce) com o adesivo "ou", Top Bar com o logo e a Tab Bar | `SwipeScreen(mode: root)` em `/home`; `SwipeChoiceCards` anima a entrada (fade + deslize, 250 ms) | `SwipeState.options` traz as duas opções; `duel` é `null` |
| 3 | Toca num card ou o arrasta | Toque chama `choose(option)`; no arrasto o card acompanha o dedo (translação horizontal + inclinação extra) | `choose` empilha a opção em `history` |
| 4 | Solta o card antes do limite | O card volta para o lugar (200 ms; sem animação se o sistema pede menos movimento) | Nada muda |
| 5 | Solta o card além do limite | A View chama `choose(option)` | Igual ao toque |
| 6 | Escolhe Salgado ou Doce: o primeiro duelo abre em tela cheia ("Macarrão ou pizza?", "Salgado, anotado. Agora é duelo: quem ganha fica."), Top Bar só com "Voltar", sem Tab Bar | A Home faz `push('/choose')`, que abre `SwipeScreen(mode: flow)` | `_startDuel` cria o `DuelGame` com as 16 comidas do grupo e chama `start()`. As duas telas leem a mesma sessão |
| 7 | Escolhe um card do duelo: o vencedor fica, o outro dá lugar ao próximo desafiante; o subtítulo conta as vitórias seguidas | Os cards entram de novo a cada rodada (`ValueKey(history.length)`) | `DuelGame.choose` devolve o novo `DuelState` |
| 8 | Toca em "Voltar" (ou gesto de borda do iOS / voltar do Android) | `reset()` e `pop()`; o `PopScope` faz o mesmo para o gesto | A sessão volta ao Salgado vs. Doce e o duelo some |
| 9 | Uma comida vence três duelos seguidos (ex.: Macarrão) | A tela visível troca para `/result?path=savory,spaghetti,spaghetti,spaghetti` e chama `reset()` | `result` é o `winner` do duelo; os ids vêm de `history` |
| 10 | Vê o Deu match: card grande inclinado com a comida, o caminho ("Salgado, macarrão"), o chip "4 escolhas", o adesivo "Deu match!", "Agora é só escolher onde." e dois botões | `ResultScreen` | `ResultViewModel` resolve os ids da rota em `FoodCategory` |
| 11 | "Ver restaurantes perto" | `push('/restaurants?category=spaghetti')`: placeholder até o mapa (#17) | — |
| 12 | "Recomeçar" ou "Voltar" no Deu match | `go('/home')` | A sessão já foi zerada no passo 9 |

## O duelo

O `DuelGame` (`lib/models/duel_game.dart`) recebe as comidas do grupo e é uma
função pura: `choose(estado, escolhida)` devolve um `DuelState` novo, sem
mexer no anterior.

| Situação | O que acontece |
| --- | --- |
| `start()` | Embaralha a lista: as duas primeiras viram campeão e desafiante, o resto vira a fila. Pontos: 0 |
| Escolhe o campeão | O campeão soma 1 ponto e enfrenta o próximo da fila |
| Escolhe o desafiante | O desafiante vira campeão com 1 ponto; o derrubado perde os pontos e sai da fila |
| A fila acaba | A lista inteira é embaralhada de novo, sem o campeão atual; só aí um derrubado pode voltar |
| 3 pontos | `winner` recebe o campeão e o duelo termina; escolhas depois disso são ignoradas |
| Comida fora do duelo atual | Ignorada (devolve o mesmo estado) |

O `Random` do embaralhamento vem do `duelRandomProvider`. Em produção é um
`Random()` comum; os testes trocam por `InOrderRandom`
(`test/helpers/in_order_random.dart`), que mantém a ordem do seed, para que o
primeiro duelo seja sempre Macarrão vs. Pizza.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
| --- | --- | --- |
| Pontos, troca de campeão, fila e fim em 3 vitórias seguidas | `DuelGame` e `DuelState` (model) | Dart puro, teste unitário instantâneo; a VM só traduz o estado em dois cards |
| A raiz tem exatamente duas opções (Salgado e Doce) e cada grupo tem pelo menos duas comidas | `CategoryTree` e o construtor do `DuelGame` | Um seed quebrado falha no carregamento, não no meio da sessão |
| Texto do título e do subtítulo de cada rodada | `SwipeState` | Derivados do estado (`duel.streak`); a View só os exibe |
| Voltar sai do fluxo e zera a sessão (não desfaz a última escolha) | `SwipeScreen` (flow) chama `reset()`; decisão em `docs/contexto.md` §11 | Recomeçar é mais simples que desfazer passo a passo |
| Só a tela visível navega no match | `ref.listen` na `SwipeScreen` com `ModalRoute.isCurrent` | A Home (por baixo) e o fluxo (por cima) ouvem o mesmo provider; sem essa checagem as duas abririam o resultado |
| O resultado chega pela rota, não pelo ViewModel do swipe | `ResultScreen(pathIds)` + `ResultViewModel` próprio | Uma tela não importa o ViewModel de outra (`CLAUDE.md`); com os ids na URL o Deu match também abre por deep link |
| Caminho "Salgado, macarrão" (grupo e campeã) e "N escolhas" (todas as escolhas da sessão) | `ResultState.pathLabel` e `choiceCount` | Formatação testável sem widget |
| Limite do arrasto: mais de 35% da largura do card ou velocidade horizontal acima de 800 px/s | `DraggableFoodCard` (View) | É interpretação de gesto, não regra de negócio; o resultado só chama `choose` |
| O card arrastado volta ao lugar quando continua no duelo | `ValueKey(state.history.length)` na `SwipeScreen` | O campeão tem o mesmo id na rodada seguinte; uma chave por escolha recria o widget, como o `.id` do SwiftUI |
| Menos movimento (`MediaQuery.disableAnimationsOf`) | `SwipeChoiceCards` e `DraggableFoodCard` (View) | A preferência vem do sistema e só a View tem acesso ao contexto |
| Food Theme do card | `resolveFoodTheme` (swipe) e o helper privado de `match_card.dart` (result) | O model guarda o nome como `String` para continuar Dart puro; a View converte com fallback para `tomato` |
| Foto do card | `FoodCategory.photo` (nome do arquivo) + `foodPhoto` em `lib/core/widgets/food_photo.dart` | Mesmo motivo do Food Theme: o model guarda só o nome; a View monta o `AssetImage`. Sem nome, ou com um nome sem arquivo, o Food Card desenha o placeholder |
| Alternativa ao gesto | Toque no card, com `Semantics` de botão ("Escolher Salgado") | Arrastar não é acessível nem funciona bem no simulador |

O arrasto é só horizontal, para que a página continue rolando na vertical em
telas pequenas (375x667), onde o par de cards não cabe inteiro.

## O cardápio

O `LocalCategoryRepository` é a implementação real: o cardápio é dado local
versionado no app (`docs/contexto.md` §8). Cada comida tem label, exemplos,
Food Theme, foto e `placesKeyword`.

| Grupo | Comidas |
| --- | --- |
| Salgado (16) | Macarrão, Pizza, Hambúrguer, Xis, Lasanha, Sushi, Churrasco, Pastel, Salgadinhos, Cachorro-quente, Mexicana, Chinesa, Frango frito, Poke, Árabe, Parmegiana |
| Doce (16) | Sorvete, Bolo, Açaí, Brigadeiro, Donut, Churros, Crepe doce, Waffle, Milk-shake, Brownie, Cookie, Pudim, Paleta mexicana, Torta doce, Petit gâteau, Bombom |

No Figma, as 32 comidas estão como instâncias do Food Card nas seções
"Cardápio · Salgado" e "Cardápio · Doce" da página "Assets".

## Fotos

As fotos vêm do Unsplash e do Pexels (licença livre, sem crédito obrigatório)
e ficam em `assets/images/food/` (800 px de largura, JPEG). No Figma cada uma é
um frame `photo-<nome>` na página "Assets". O teste do seed garante que toda
comida tem foto e que todo `photo` tem arquivo.

O arquivo tem o nome do id da comida (`lasagna.jpg`, `ice_cream.jpg`), com
estas exceções, que já existiam antes do cardápio:

| Categoria | Arquivo |
| --- | --- |
| Salgado | `salgado.jpg` |
| Doce | `brigadeiro.jpg` (o mesmo do card Brigadeiro) |
| Macarrão | `macarrao.jpg` |
| Hambúrguer | `lanche.jpg` |
| Bolo | `bolo.jpg` |

## Erros

| Situação | O que a tela mostra |
| --- | --- |
| Falha ao carregar as categorias | "Não deu para carregar as opções." e o botão "Tentar novamente", que invalida o `swipeViewModelProvider` |
| `/result` com caminho vazio ou id desconhecido | "Não deu para mostrar o resultado." e "Recomeçar", com a Top Bar de voltar |

## Testes

| Arquivo | O que cobre |
| --- | --- |
| `test/models/duel_game_test.dart` | Início sem pontos, primeiro duelo vale 1, desafiante vencedor começa com 1, derrubado só volta na repetição, a lista se repete, 3 seguidas encerram, escolhas inválidas ignoradas, mínimo de 2 comidas |
| `test/models/category_tree_test.dart` | A raiz tem 2 opções, grupos com mais de 2 comidas, 16 por grupo |
| `test/models/food_category_test.dart` | O seed: 16 + 16 comidas, todas com `placesKeyword` e foto existente, ids únicos, temas diferentes para Salgado e Doce |
| `test/screens/swipe/swipe_view_model_test.dart` | Início do duelo, campeão contra o próximo desafiante, troca de campeão, 3 seguidas convergem, recomeçar limpa o duelo, textos de cada rodada, erro do repositório |
| `test/screens/swipe/swipe_screen_test.dart` | Home com logo e perfil, sem "Voltar"; toque abre o duelo em tela cheia; a rodada troca o perdedor; o campeão arrastado volta ao lugar; 3 seguidas abrem `/result` com todas as escolhas; "Voltar" e o voltar do Android zeram e voltam à Home; arrasto longo/curto; menos movimento; 375x667 sem overflow; erro; carregando |
| `test/screens/result/result_view_model_test.dart` | Resolve o caminho em ordem, `pathLabel` com grupo e campeã, `choiceCount` com todas as escolhas, id desconhecido e caminho vazio viram erro |
| `test/screens/result/result_screen_test.dart` | Comida, caminho, "4 escolhas" e "Deu match!"; os dois botões e o "Voltar" navegam; erro; 375x667 |
| `test/app/app_test.dart` | O app inteiro: abas, fluxo completo até restaurantes e volta, "Recomeçar" |
| `test/screens/swipe/widgets/resolve_food_theme_test.dart` | Nome conhecido e fallback para `tomato` |

Não coberto por teste automatizado, validar à mão: **arrastar no simulador** e a
aparência contra as telas "01 Home", "02 Escolha nível 2" e "04 Deu match" do
Figma.

## O que não está aqui

| Fora desta entrega | Onde vai |
| --- | --- |
| Mapa de restaurantes (hoje um placeholder) | #17 |
| Salvar a sessão e o match no histórico | #13 e #60 |
| Cardápio no Firestore, editável sem publicar o app | `docs/contexto.md` §12 |
