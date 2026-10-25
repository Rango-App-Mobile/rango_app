# Swipe e Deu match

**Escopo:** a tela `swipe` (View), o `swipeViewModelProvider`, a tela `result`
("Deu match", Figma 04) com o `resultViewModelProvider`, e o
`CategoryRepository` com a implementação `LocalCategoryRepository` (issues #11,
#12 e #54). A pessoa toca ou arrasta um de dois cards por nível até a sessão
convergir para um tipo de comida; o app então mostra o match. A navegação
(abas, Top Bar, Tab Bar) está em `docs/navegacao.md`.

As regras de produto vêm das seções §6 e §7 de `docs/contexto.md`. Este
documento explica o porquê das escolhas de implementação; não repete o contexto.

## O fluxo

| #   | O que a pessoa vê / faz                                                                                                                                                                    | Tela (View)                                                                                                 | ViewModel / modelo                                                    |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| 1   | Abre o app: spinner enquanto as categorias carregam                                                                                                                                        | `CircularProgressIndicator`                                                                                 | `build()` busca tudo no `CategoryRepository` e monta a `CategoryTree` |
| 2   | Na aba Home vê "Bora decidir o Rango?" e dois cards (Salgado, Doce) com o adesivo "ou", Top Bar com o logo e a Tab Bar                                                                     | `SwipeScreen(mode: root)` em `/home`; `SwipeChoiceCards` anima a entrada (fade + deslize, 250 ms)           | `SwipeState.options` traz as duas opções do nível                     |
| 3   | Toca num card ou o arrasta                                                                                                                                                                 | Toque chama `choose(option)`; no arrasto o card acompanha o dedo (translação horizontal + inclinação extra) | `choose` empilha a opção em `history` e desce um nível                |
| 4   | Solta o card antes do limite                                                                                                                                                               | O card volta para o lugar (200 ms; sem animação se o sistema pede menos movimento)                          | Nada muda                                                             |
| 5   | Solta o card além do limite                                                                                                                                                                | A View chama `choose(option)`                                                                               | Igual ao toque                                                        |
| 6   | Depois da primeira escolha, o nível 2 abre em tela cheia: Top Bar só com "Voltar", sem Tab Bar                                                                                             | A Home faz `push('/choose')`, que abre `SwipeScreen(mode: flow)`                                            | O mesmo `swipeViewModelProvider`: as duas telas leem a mesma sessão   |
| 7   | Toca em "Voltar" (ou gesto de borda do iOS / voltar do Android)                                                                                                                            | `reset()` e `pop()`; o `PopScope` faz o mesmo para o gesto                                                  | A sessão volta ao nível 1                                             |
| 8   | Escolhe uma folha (ex.: Macarrão)                                                                                                                                                          | A tela visível troca para `/result?path=savory,pasta,spaghetti` e chama `reset()`                           | `result` é a folha; os ids vêm de `history`                           |
| 9   | Vê o Deu match: card grande inclinado com o tipo de comida, o caminho ("Salgado, massa, macarrão"), o chip "3 escolhas", o adesivo "Deu match!", "Agora é só escolher onde." e dois botões | `ResultScreen`                                                                                              | `ResultViewModel` resolve os ids da rota em `FoodCategory`            |
| 10  | "Ver restaurantes perto"                                                                                                                                                                   | `push('/restaurants?category=spaghetti')`: placeholder até o mapa (#17)                                     | —                                                                     |
| 11  | "Recomeçar" ou "Voltar" no Deu match                                                                                                                                                       | `go('/home')`                                                                                               | A sessão já foi zerada no passo 8                                     |

## Onde cada regra mora

| Regra                                                                                        | Onde é garantida                                                                           | Por quê ali                                                                                                                                                |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Converge quando a opção escolhida é folha                                                    | `CategoryTree` (model)                                                                     | Dart puro, teste unitário instantâneo; vale para o Fake e para o Firestore                                                                                 |
| Texto do título e do subtítulo por nível                                                     | `SwipeState`                                                                               | Derivados do estado; a View só os exibe                                                                                                                    |
| Voltar sai do fluxo e zera a sessão (não desfaz a última escolha)                            | `SwipeScreen` (flow) chama `reset()`; decisão em `docs/contexto.md` §11                    | O fluxo tem só três escolhas; recomeçar é mais simples que desfazer passo a passo                                                                          |
| Só a tela visível navega no match                                                            | `ref.listen` na `SwipeScreen` com `ModalRoute.isCurrent`                                   | A Home (por baixo) e o nível 2+ (por cima) ouvem o mesmo provider; sem essa checagem as duas abririam o resultado                                          |
| O resultado chega pela rota, não pelo ViewModel do swipe                                     | `ResultScreen(pathIds)` + `ResultViewModel` próprio                                        | Uma tela não importa o ViewModel de outra (`CLAUDE.md`); com os ids na URL o Deu match também abre por deep link                                           |
| Caminho "Salgado, massa, macarrão" e "N escolhas"                                            | `ResultState.pathLabel` e `choiceCount`                                                    | Formatação testável sem widget                                                                                                                             |
| Limite do arrasto: mais de 35% da largura do card ou velocidade horizontal acima de 800 px/s | `DraggableFoodCard` (View)                                                                 | É interpretação de gesto, não regra de negócio; o resultado só chama `choose`                                                                              |
| Menos movimento (`MediaQuery.disableAnimationsOf`)                                           | `SwipeChoiceCards` e `DraggableFoodCard` (View)                                            | A preferência vem do sistema e só a View tem acesso ao contexto                                                                                            |
| Food Theme do card                                                                           | `resolveFoodTheme` (swipe) e o helper privado de `match_card.dart` (result)                | O model guarda o nome como `String` para continuar Dart puro; a View converte com fallback para `tomato`                                                   |
| Foto do card                                                                                 | `FoodCategory.photo` (nome do arquivo) + `foodPhoto` em `lib/core/widgets/food_photo.dart` | Mesmo motivo do Food Theme: o model guarda só o nome; a View monta o `AssetImage`. Sem nome, ou com um nome sem arquivo, o Food Card desenha o placeholder |
| Alternativa ao gesto                                                                         | Toque no card, com `Semantics` de botão ("Escolher Salgado")                               | Arrastar não é acessível nem funciona bem no simulador                                                                                                     |

O arrasto é só horizontal, para que a página continue rolando na vertical em
telas pequenas (375x667), onde o par de cards não cabe inteiro.

## Fotos

As fotos vêm da página "Assets" do Figma e ficam em `assets/images/food/`
(800 px de largura, JPEG). O teste do seed garante que todo `photo` do
`LocalCategoryRepository` tem arquivo.

| Categoria  | Arquivo          | Frame no Figma                                       |
| ---------- | ---------------- | ---------------------------------------------------- |
| Salgado    | `salgado.jpg`    | `photo-salgado`                                      |
| Doce       | `brigadeiro.jpg` | `photo-brigadeiro` (o mesmo do card Doce na tela 01) |
| Massa      | `massa.jpg`      | `photo-massa`                                        |
| Lanche     | `lanche.jpg`     | `photo-lanche`                                       |
| Macarrão   | `macarrao.jpg`   | `photo-macarrao` (o garfo da tela 04)                |
| Pizza      | `pizza.jpg`      | `photo-pizza`                                        |
| Hambúrguer | `lanche.jpg`     | Não tem foto própria; a de Lanche é um hambúrguer    |
| Xis        | `xis.jpg`        | `photo-xis`                                          |
| Bolo       | `bolo.jpg`       | `photo-doce` (uma fatia de bolo)                     |
| Sorvete    | —                | Não tem; placeholder                                 |

## Erros

| Situação                                       | O que a tela mostra                                                                                      |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| Falha ao carregar as categorias                | "Não deu para carregar as opções." e o botão "Tentar novamente", que invalida o `swipeViewModelProvider` |
| `/result` com caminho vazio ou id desconhecido | "Não deu para mostrar o resultado." e "Recomeçar", com a Top Bar de voltar                               |

## Testes

| Arquivo                                                   | O que cobre                                                                                                                                                                                                                                   |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `test/screens/swipe/swipe_view_model_test.dart`           | Regras da sessão: escolher, convergir, recomeçar, erro do repositório                                                                                                                                                                         |
| `test/screens/swipe/swipe_screen_test.dart`               | Home com logo e perfil, sem "Voltar"; toque abre o nível 2 em tela cheia; "Voltar" e o voltar do Android zeram e voltam à Home; folha abre `/result` com os ids; arrasto longo/curto; menos movimento; 375x667 sem overflow; erro; carregando |
| `test/screens/result/result_view_model_test.dart`         | Resolve o caminho em ordem, `pathLabel`, `choiceCount`, id desconhecido e caminho vazio viram erro                                                                                                                                            |
| `test/screens/result/result_screen_test.dart`             | Tipo, caminho, "3 escolhas" e "Deu match!"; os dois botões e o "Voltar" navegam; erro; 375x667                                                                                                                                                |
| `test/app/app_test.dart`                                  | O app inteiro: abas, fluxo completo até restaurantes e volta, "Recomeçar"                                                                                                                                                                     |
| `test/screens/swipe/widgets/resolve_food_theme_test.dart` | Nome conhecido e fallback para `tomato`                                                                                                                                                                                                       |

Não coberto por teste automatizado, validar à mão: **arrastar no simulador** e a
aparência contra as telas "01 Home", "02 Escolha nível 2" e "04 Deu match" do
Figma.

## O que não está aqui

| Fora desta entrega                                                                                              | Onde vai  |
| --------------------------------------------------------------------------------------------------------------- | --------- |
| Foto do Sorvete (o Figma não tem uma; o card mostra o placeholder) e licença das fotos (`docs/contexto.md` §12) | #57       |
| Mapa de restaurantes (hoje um placeholder)                                                                      | #17       |
| Salvar a sessão e o match no histórico                                                                          | #13 e #60 |
| Repositório real no Firestore                                                                                   | Sprint 2  |
