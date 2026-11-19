# Navegação

**Escopo:** as abas Home e Histórico, a Top Bar, o Avatar Button e a Tab Bar
flutuante (issue #55), montados com `go_router` em `lib/app/router.dart` e
`lib/app/app_shell.dart`. O fluxo de escolhas está em `docs/swipe.md`.

## Rotas

| Rota | Tela | Onde abre | Top Bar | Tab Bar |
|---|---|---|---|---|
| `/home` | `SwipeScreen(mode: root)`: nível 1 das escolhas | Aba Home | Principal (só o perfil) | Sim |
| `/history` | `HistoryScreen`: pilha de decisões (Figma 07d) ou vazio (Figma 10), ver `docs/historico.md` | Aba Histórico | Principal | Sim |
| `/history/<id>` | `HistoryDetailScreen`: detalhe da decisão (Figma 12), com transição em fade e o card crescendo (Hero) | Navigator raiz | Fluxo | Não |
| `/choose` | `SwipeScreen(mode: flow)`: níveis 2 em diante | Navigator raiz, por cima das abas | Fluxo (só "Voltar") | Não |
| `/result?path=<ids>` | `ResultScreen`: Deu match (Figma 04) | Navigator raiz | Fluxo | Não |
| `/restaurants?category=<id>` | `RestaurantsScreen`: restaurantes no mapa (Figma 05, 08 e 09; `docs/restaurantes.md`) | Navigator raiz | Fluxo | Não |
| `/restaurants/contact` (com `extra: RestaurantContactArgs`) | `RestaurantContactScreen`: opções de contato (Figma 06) | Navigator raiz, por cima do mapa | Fluxo | Não |
| `/login`, `/signup`, `/password-reset` | Entrar, Criar conta e Recuperar senha (Figma 13 a 15; `docs/login.md`) | Navigator raiz | Fluxo | Não |

O app abre em `/home`. As duas abas são um `StatefulShellRoute.indexedStack`:
cada aba guarda a própria pilha, e trocar de aba não perde o estado da outra.
Tudo fora das abas usa `parentNavigatorKey` do navigator raiz para cobrir o
shell inteiro; é assim que a Tab Bar some nas escolhas, no Deu match e em
restaurantes (decisão de 24/10 em `docs/contexto.md` §11).

## Voltar

| Onde | O que faz |
|---|---|
| Escolhas (`/choose`) | Zera a sessão e volta à Home (nível 1) |
| Deu match e mapa de restaurantes | `go('/home')`: volta à aba Home |
| Opções de contato | `pop()`: volta ao mapa com o mesmo restaurante selecionado; "Voltar ao início" faz `go('/home')` |

O botão da Top Bar, o gesto de borda do iOS e o voltar do Android fazem a mesma
coisa: cada tela de fluxo usa `PopScope(canPop: false)` e trata o gesto como o
botão.

## Componentes

| Componente | Arquivo | Figma |
|---|---|---|
| `TopBar.principal` / `TopBar.flow` | `lib/core/widgets/top_bar.dart` | Top Bar v1.2: 64 de altura, padding lateral `space/lg`. Principal só com o perfil à direita, Fluxo só com o voltar, nunca os dois juntos |
| `TopBarLayout` | `lib/core/widgets/top_bar_layout.dart` | Camada `Glass` da Top Bar: o corpo da tela vai até o topo e a barra flutua sobre um blur progressivo. Entrega ao corpo a altura coberta em `MediaQuery.padding.top` |
| `TopBarScrollView` | `lib/core/widgets/top_bar_scroll_view.dart` | Rolagem das telas com `TopBarLayout`: o conteúdo começa abaixo da barra e passa por trás dela |
| `GlassCircle` | `lib/core/widgets/glass_circle.dart` | Vidro dos botões redondos: blur do que está atrás e sombra `Elevation/Card` só por fora. Usado pelo Icon Button `Glass` e pelo Avatar Button |
| `AvatarButton` | `lib/core/widgets/avatar_button.dart` | Avatar Button Guest: alvo 48×48, círculo 44 de vidro mostarda (`color/glass/mustard`), rótulo "Abrir perfil". Abre o Profile Sheet (`docs/perfil.md`) |
| `RangoTabBar` | `lib/core/widgets/rango_tab_bar.dart` | Tab Bar simplificada: pílula escura só com os ícones, aba ativa numa pílula creme, sem rótulo nem ponto vermelho, itens 64×48. O nome da aba vai para o leitor de tela ("Home, aba 1 de 2") e para o tooltip. Só a pílula creme anima (200 ms; nada com menos movimento) |
| `AppShell` | `lib/app/app_shell.dart` | Tab Bar centralizada a 20 px da base, sobre um blur progressivo de 114 de altura (Figma 07d) |
| `ProgressiveBlur` | `lib/core/widgets/progressive_blur.dart` | Blur que cresce em direção a uma borda da tela, usado na Top Bar e em volta da Tab Bar. Não bloqueia toques |

As telas das abas deixam `RangoTabBar.reservedHeight` (96) livre no fim da
rolagem para a Tab Bar não cobrir o conteúdo.

## Top Bar e Tab Bar com blur

O conteúdo passa por trás da Top Bar e da Tab Bar em vez de ser cortado numa linha. O
`BackdropFilter` não aceita máscara em degradê, então o blur progressivo é feito
de doze faixas sobrepostas, cada uma mais curta que a anterior, sob um degradê de
`color/bg/canvas` que esconde os degraus e mantém a status bar legível. No topo,
ele começa na borda da tela e termina um pouco antes da borda de baixo da barra,
para o conteúdo parado logo abaixo dela continuar nítido, inclusive os acentos do
título. Na base, sobe 114 a partir da borda da tela, em volta da Tab Bar, e só
existe nas abas.

A tela do mapa não usa o `TopBarLayout`: o mapa vai limpo até o topo, sem blur e
sem degradê, e só o voltar é de vidro. O blur não é confiável sobre o mapa nativo
do Google, principalmente no Android.

## Testes

| Arquivo | O que cobre |
|---|---|
| `test/core/widgets/top_bar_test.dart`, `avatar_button_test.dart`, `glass_circle_test.dart` | Variantes, vidro, alvo de toque, semântica, callbacks |
| `test/core/widgets/top_bar_layout_test.dart`, `top_bar_scroll_view_test.dart`, `progressive_blur_test.dart` | Inset entregue ao corpo, faixas de blur nas duas bordas, toque atravessando o blur, conteúdo rolando por trás da barra |
| `test/core/widgets/rango_tab_bar_test.dart` | Itens, toque, tamanho, semântica de aba selecionada, tokens, menos movimento |
| `test/screens/history/history_screen_test.dart` | Conteúdo do vazio, "Decidir meu rango" vai à Home, 375x667 |
| `test/screens/restaurants/restaurants_screen_test.dart` | Mapa, estados e "Voltar" à Home (detalhes em `docs/restaurantes.md`) |
| `test/app/app_test.dart` | Abre na Home com a Tab Bar; troca de abas; a Tab Bar some no fluxo e volta ao sair |

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Abrir o Profile Sheet pelo avatar (hoje sem ação) | #64 |
| Ícones do Figma (hoje Material Icons) | #52 |
| Histórico com dados | #60 |
