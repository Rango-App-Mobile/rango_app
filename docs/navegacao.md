# Navegação

**Escopo:** as abas Home e Histórico, a Top Bar, o Avatar Button e a Tab Bar
flutuante (issue #55), montados com `go_router` em `lib/app/router.dart` e
`lib/app/app_shell.dart`. O fluxo de escolhas está em `docs/swipe.md`.

## Rotas

| Rota | Tela | Onde abre | Top Bar | Tab Bar |
|---|---|---|---|---|
| `/home` | `SwipeScreen(mode: root)`: nível 1 das escolhas | Aba Home | Principal (logo + perfil) | Sim |
| `/history` | `HistoryScreen`: pilha de decisões (Figma 07d) ou vazio (Figma 10), ver `docs/historico.md` | Aba Histórico | Principal | Sim |
| `/history/<id>` | `HistoryDetailScreen`: detalhe da decisão (Figma 12), com transição em fade e o card crescendo (Hero) | Navigator raiz | Fluxo | Não |
| `/choose` | `SwipeScreen(mode: flow)`: níveis 2 em diante | Navigator raiz, por cima das abas | Fluxo (só "Voltar") | Não |
| `/result?path=<ids>` | `ResultScreen`: Deu match (Figma 04) | Navigator raiz | Fluxo | Não |
| `/restaurants?category=<id>` | `RestaurantsScreen`: placeholder até o mapa (#17) | Navigator raiz | Fluxo | Não |

O app abre em `/home`. As duas abas são um `StatefulShellRoute.indexedStack`:
cada aba guarda a própria pilha, e trocar de aba não perde o estado da outra.
Tudo fora das abas usa `parentNavigatorKey` do navigator raiz para cobrir o
shell inteiro; é assim que a Tab Bar some nas escolhas, no Deu match e em
restaurantes (decisão de 24/10 em `docs/contexto.md` §11).

## Voltar

| Onde | O que faz |
|---|---|
| Escolhas (`/choose`) | Zera a sessão e volta à Home (nível 1) |
| Deu match e restaurantes | `go('/home')`: volta à aba Home |

O botão da Top Bar, o gesto de borda do iOS e o voltar do Android fazem a mesma
coisa: cada tela de fluxo usa `PopScope(canPop: false)` e trata o gesto como o
botão.

## Componentes

| Componente | Arquivo | Figma |
|---|---|---|
| `TopBar.principal` / `TopBar.flow` | `lib/core/widgets/top_bar.dart` | Top Bar v1.1: 64 de altura, padding lateral `space/lg`; logo e voltar nunca juntos. O logo é decorativo para leitores de tela |
| `AvatarButton` | `lib/core/widgets/avatar_button.dart` | Avatar Button Guest: alvo 48×48, círculo 44 mostarda, rótulo "Abrir perfil" |
| `RangoTabBar` | `lib/core/widgets/rango_tab_bar.dart` | Tab Bar simplificada: pílula escura só com os ícones, aba ativa numa pílula creme, sem rótulo nem ponto vermelho, itens 64×48. O nome da aba vai para o leitor de tela ("Home, aba 1 de 2") e para o tooltip. Só a pílula creme anima (200 ms; nada com menos movimento) |
| `AppShell` | `lib/app/app_shell.dart` | Tab Bar centralizada a 20 px da base |

As telas das abas deixam `RangoTabBar.reservedHeight` (96) livre no fim da
rolagem para a Tab Bar não cobrir o conteúdo.

## Testes

| Arquivo | O que cobre |
|---|---|
| `test/core/widgets/top_bar_test.dart`, `avatar_button_test.dart` | Variantes, alvo de toque, semântica, callbacks |
| `test/core/widgets/rango_tab_bar_test.dart` | Itens, toque, tamanho, semântica de aba selecionada, tokens, menos movimento |
| `test/screens/history/history_screen_test.dart` | Conteúdo do vazio, "Decidir meu rango" vai à Home, 375x667 |
| `test/screens/restaurants/restaurants_screen_test.dart` | Placeholder, "Voltar" e "Voltar ao início" vão à Home |
| `test/app/app_test.dart` | Abre na Home com a Tab Bar; troca de abas; a Tab Bar some no fluxo e volta ao sair |

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Abrir o Profile Sheet pelo avatar (hoje sem ação) | #64 |
| Ícones do Figma (hoje Material Icons) | #52 |
| Histórico com dados | #60 |
