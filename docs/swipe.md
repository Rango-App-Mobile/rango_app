# Swipe e Deu match

**Escopo:** a tela `swipe` (View), o `swipeViewModelProvider`, a tela `result`
("Deu match", Figma 04) com o `resultViewModelProvider`, o card único
(`LikeGame` e `LikeState`) e o `CategoryRepository` com a implementação
`LocalCategoryRepository` (issues #10, #11, #12 e #54). A pessoa escolhe
Salgado ou Doce e depois vê uma comida por vez, num card no centro da tela, como
no Tinder: direita curte, esquerda passa. A primeira comida a somar três
curtidas é o match. A navegação (abas, Top Bar, Tab Bar) está em
`docs/navegacao.md`.

As regras de produto vêm das seções §6 e §7 (R2) de `docs/contexto.md`. Este
documento explica o porquê das escolhas de implementação; não repete o contexto.

No Figma, as telas estão na seção "02 V2 · Card único (curtir ou passar)" da
página "📱 Telas" (parado, curtindo, passando). Os componentes novos, `Like
Meter` e `Swipe Button`, estão na página "Components".

## O fluxo

| # | O que a pessoa vê / faz | Tela (View) | ViewModel / modelo |
| --- | --- | --- | --- |
| 1 | Abre o app: spinner enquanto as categorias carregam | `CircularProgressIndicator` | `build()` busca tudo no `CategoryRepository` e monta a `CategoryTree` |
| 2 | Na aba Home vê "Bora decidir o Rango?" e dois cards (Salgado, Doce) com o adesivo "ou", Top Bar com o logo e a Tab Bar | `SwipeScreen(mode: root)` em `/home`; `SwipeChoiceCards` anima a entrada (fade + deslize, 250 ms) | `SwipeState.options` traz as duas opções; `game` é `null` |
| 3 | Toca num card ou o arrasta | Toque ou arrasto além do limite chamam `choose(option)` (`DraggableFoodCard`); antes do limite o card volta | `choose` empilha o grupo em `history` e cria o `LikeGame` com as 16 comidas do grupo |
| 4 | Abre o card único em tela cheia, só com o essencial: o Like Meter (corações) centralizado, o card da comida (nome e foto, sem legenda) com a borda do próximo aparecendo embaixo e os botões X e coração. Top Bar só com "Voltar", sem Tab Bar e sem título | A Home faz `push('/choose')`, que abre `SwipeScreen(mode: flow)` com o `FoodCardDeck` | As duas telas leem a mesma sessão; `game.current` é o card de cima e `game.next` o de trás |
| 5 | Arrasta o card: ele segue o dedo e inclina; aparece o carimbo "Curti!" (direita, lima) ou "Passo!" (esquerda, rosa) | `SwipeableFoodCard` | Nada muda até soltar |
| 6 | Solta antes do limite | O card volta ao centro (200 ms; sem animação se o sistema pede menos movimento) | Nada muda |
| 7 | Solta além do limite, ou toca no coração / no X | O card sai voando para o lado (200 ms) e o de trás sobe para o lugar | `like()` ou `pass()`; a comida entra em `history` |
| 8 | Toca em "Voltar" (ou gesto de borda do iOS / voltar do Android) | `reset()` e `pop()`; o `PopScope` faz o mesmo para o gesto | A sessão volta ao Salgado vs. Doce e o jogo some |
| 9 | Uma comida chega a três curtidas (ex.: Macarrão) | A tela visível troca para `/result?path=savory,spaghetti,pizza,…,spaghetti` e chama `reset()` | `result` é o `winner` do jogo; os ids vêm de `history` |
| 10 | Vê o Deu match: card grande inclinado com a comida, o caminho ("Salgado, macarrão"), o chip "N escolhas", o adesivo "Deu match!", "Agora é só escolher onde." e dois botões | `ResultScreen` | `ResultViewModel` resolve os ids da rota em `FoodCategory` |
| 11 | "Ver restaurantes perto" | `push('/restaurants?category=spaghetti')`: placeholder até o mapa (#17) | — |
| 12 | "Recomeçar" ou "Voltar" no Deu match | `go('/home')` | A sessão já foi zerada no passo 9 |

## O card único

O `LikeGame` (`lib/models/like_game.dart`) recebe as comidas do grupo e é uma
função pura: `like(estado)` e `pass(estado)` devolvem um `LikeState` novo, sem
mexer no anterior.

| Situação | O que acontece |
| --- | --- |
| `start()` | Embaralha a lista: a primeira vira o card de cima, o resto vira a fila. Nenhuma curtida |
| Curtir | A comida de cima soma 1 curtida (as curtidas nunca zeram) e a próxima sobe |
| Passar | A comida entra em `passedIds` e sai da sessão; a próxima sobe |
| A rodada acaba | As comidas que não foram passadas são embaralhadas de novo. A que acabou de aparecer não abre a nova rodada, para o mesmo card não vir duas vezes seguidas |
| Todas foram passadas | `passedIds` zera e as 16 voltam |
| 3 curtidas na mesma comida | `winner` recebe a comida e o jogo termina; swipes depois disso são ignorados |

A nova rodada é dada assim que o último card da rodada sobe, e não quando ele
sai. Assim sempre existe um `next` para desenhar atrás do card de cima.

O `Random` do embaralhamento vem do `deckRandomProvider`. Em produção é um
`Random()` comum; os testes trocam por `InOrderRandom`
(`test/helpers/in_order_random.dart`), que mantém a ordem do seed, para que o
primeiro card seja sempre Macarrão e o de trás, Pizza.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
| --- | --- | --- |
| Curtidas que somam, passar tira da sessão, novas rodadas e fim em 3 curtidas | `LikeGame` e `LikeState` (model) | Dart puro, teste unitário instantâneo; a VM só repassa o swipe |
| A raiz tem exatamente duas opções (Salgado e Doce) e cada grupo tem pelo menos duas comidas | `CategoryTree` e o construtor do `LikeGame` | Um seed quebrado falha no carregamento, não no meio da sessão |
| Título e subtítulo só na raiz; no card único, `null` (sem cabeçalho) | `SwipeState` | Derivados do estado; a View só os exibe |
| Card da comida só com nome e foto; Salgado e Doce mantêm os exemplos | `FoodCardDeck` (sem `subtitle`) e `SwipeChoiceCards` | Segue o cardápio do Figma (página Assets) |
| Total de curtidas do Like Meter | `LikeState.likesToMatch` | A View desenha os corações sem repetir o número 3 |
| Voltar sai do fluxo e zera a sessão (não desfaz o último swipe) | `SwipeScreen` (flow) chama `reset()`; decisão em `docs/contexto.md` §11 | Recomeçar é mais simples que desfazer passo a passo |
| Só a tela visível navega no match | `ref.listen` na `SwipeScreen` com `ModalRoute.isCurrent` | A Home (por baixo) e o fluxo (por cima) ouvem o mesmo provider; sem essa checagem as duas abririam o resultado |
| O resultado chega pela rota, não pelo ViewModel do swipe | `ResultScreen(pathIds)` + `ResultViewModel` próprio | Uma tela não importa o ViewModel de outra (`CLAUDE.md`); com os ids na URL o Deu match também abre por deep link |
| Caminho "Salgado, macarrão" (grupo e vencedora) e "N escolhas" (todos os swipes + o grupo) | `ResultState.pathLabel` e `choiceCount` | Formatação testável sem widget |
| Limite do arrasto do card único: mais de 30% da largura ou velocidade horizontal acima de 800 px/s | `SwipeableFoodCard` (View) | É interpretação de gesto, não regra de negócio; o resultado só chama `like` ou `pass` |
| Limite do arrasto na raiz: mais de 35% da largura ou 800 px/s | `DraggableFoodCard` (View) | Mesmo motivo |
| Cada card novo é um widget novo | `ValueKey(history.length)` no `SwipeableFoodCard` | A mesma comida pode voltar ao topo (quando só ela sobrou); a chave por swipe recria o widget, como o `.id` do SwiftUI |
| O deck cabe entre o título e os botões | `FittedBox` no `FoodCardDeck` | O card é desenhado na largura do Figma (354) e encolhe em telas pequenas, sem rolagem |
| Menos movimento (`MediaQuery.disableAnimationsOf`) | `SwipeChoiceCards`, `DraggableFoodCard` e `SwipeableFoodCard` (View) | A preferência vem do sistema e só a View tem acesso ao contexto |
| Cores dos botões: X em tomate, coração em lima, com a tinta do Food Theme | `SwipeButton` (View) | Mesmas cores dos carimbos; o par do Food Theme passa no contraste AA |
| Food Theme do card | `resolveFoodTheme` (swipe) e o helper privado de `match_card.dart` (result) | O model guarda o nome como `String` para continuar Dart puro; a View converte com fallback para `tomato` |
| Foto do card | `FoodCategory.photo` (nome do arquivo) + `foodPhoto` em `lib/core/widgets/food_photo.dart` | Mesmo motivo do Food Theme: o model guarda só o nome; a View monta o `AssetImage`. Sem nome, ou com um nome sem arquivo, o Food Card desenha o placeholder |
| Alternativa ao gesto | Na raiz, toque no card ("Escolher Salgado"); no card único, os botões "Passar Macarrão" e "Curtir Macarrão" | Arrastar não é acessível nem funciona bem no simulador |

O arrasto é só horizontal: na raiz, a página continua rolando na vertical em
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
| `test/models/like_game_test.dart` | Início sem curtidas e com um card atrás, curtir e passar, curtidas que somam entre rodadas, 3 curtidas encerram, comida passada não volta, rodada só com as que sobraram, passar todas traz as 16 de volta, sempre há um próximo card, swipes depois do fim ignorados, mínimo de 2 comidas |
| `test/models/category_tree_test.dart` | A raiz tem 2 opções, grupos com mais de 2 comidas, 16 por grupo |
| `test/models/food_category_test.dart` | O seed: 16 + 16 comidas, todas com `placesKeyword` e foto existente, ids únicos, temas diferentes para Salgado e Doce |
| `test/screens/swipe/swipe_view_model_test.dart` | O grupo dá as cartas, curtir, passar, todo swipe no histórico, 3 curtidas convergem, swipes ignorados na raiz e depois do match, recomeçar limpa o jogo, título e subtítulo só na raiz, erro do repositório |
| `test/screens/swipe/swipe_screen_test.dart` | Home com logo e perfil, sem "Voltar"; toque abre o card único em tela cheia, sem título nem legenda no card; Like Meter centralizado acima do deck; o próximo card aparece embaixo; botões coração e X; arrastar para a direita curte e para a esquerda passa; arrasto curto volta; carimbos "Curti!" e "Passo!"; Like Meter; 3 curtidas abrem `/result` com todos os swipes; "Voltar" e o voltar do Android zeram e voltam à Home; menos movimento; 375x667 sem overflow; erro; carregando |
| `test/screens/result/result_view_model_test.dart` | Resolve o caminho em ordem, `pathLabel` com grupo e vencedora, `choiceCount` com todas as escolhas, id desconhecido e caminho vazio viram erro |
| `test/screens/result/result_screen_test.dart` | Comida, caminho, "N escolhas" e "Deu match!"; os dois botões e o "Voltar" navegam; erro; 375x667 |
| `test/app/app_test.dart` | O app inteiro: abas, fluxo completo até restaurantes e volta, "Recomeçar" |
| `test/screens/swipe/widgets/resolve_food_theme_test.dart` | Nome conhecido e fallback para `tomato` |

Não coberto por teste automatizado, validar à mão: **arrastar no simulador** e a
aparência contra as telas "01 Início", "02 Card único" e "04 Deu match" do
Figma.

## O que não está aqui

| Fora desta entrega | Onde vai |
| --- | --- |
| Mapa de restaurantes (hoje um placeholder) | #17 |
| Salvar a sessão e o match no histórico | #13 e #60 |
| Cardápio no Firestore, editável sem publicar o app | `docs/contexto.md` §12 |
