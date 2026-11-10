# Perfil (Profile Sheet)

**Escopo:** a folha de perfil aberta pelo Avatar Button, `showProfileSheet`,
`ProfileSheet`, `profileViewModelProvider` e `ProfileState` em
`lib/screens/profile/` (issue #64). Telas no Figma: 11 Perfil (visitante) e
11b Perfil (com conta).

As regras de produto vêm das seções §6 (passo 5), §7 (R1) e §11 de
`docs/contexto.md`. Este documento explica como a folha foi implementada e por
quê.

## O fluxo

| # | O que a pessoa vê | O que acontece |
|---|---|---|
| 1 | Toca no Avatar Button, na Home ou no Histórico | A Top Bar Principal chama `showProfileSheet` |
| 2 | A folha sobe da base em 350 ms sobre um véu escuro a 45%, cobrindo também a Tab Bar | `showModalBottomSheet` no navigator raiz. Com "reduzir movimento" ligado, abre sem animação |
| 3 | Visitante: "Visitante", "Entrar ou criar conta" e o aviso de que nada fica salvo | `ProfileViewModel` segue o usuário em `AuthRepository.watchUser()`, e `ProfileState.fromUser` decide o que mostrar. O botão fecha a folha e abre o login (`docs/login.md`) |
| 3' | Com conta: nome, e-mail e foto no cabeçalho | Sem foto, ou se ela falhar ao carregar, aparece o ícone de visitante. Sem nome, o e-mail ocupa o lugar dele |
| 3'' | Com conta: "Sair da conta" | `ProfileViewModel.signOut`; a folha vira a de visitante sozinha |
| 4 | Fecha pelo X, arrastando para baixo ou tocando no véu | O X dá `pop`; arrastar e tocar no véu são do próprio `showModalBottomSheet` |

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| Visitante não vê estatísticas nem preferências | `ProfileSheet`, pelo `ProfileState.isGuest` | Sem conta nada é salvo (R1), então não há o que mostrar |
| O que aparece como nome e subtítulo | `ProfileState.fromUser` | É regra, não desenho: testada sem montar widget |
| Nome, e-mail e foto vêm do provedor de login | `FirebaseAuthRepository._toAppUser` | É o único lugar que conhece o `User` do Firebase |
| A folha cobre a Tab Bar | `useRootNavigator: true` | O shell das abas tem navigator próprio, e a Tab Bar ficaria por cima do véu |
| O X sempre fica visível | O cabeçalho fica fora da rolagem; só o convite rola | Em tela pequena com texto grande, o conteúdo não pode empurrar a saída para fora |

A folha é aberta por uma função, e não por uma rota do `go_router`: ela não tem
endereço próprio e abre por cima de qualquer tela raiz, sem mudar a rota atual.

## Erros

A sessão já existe quando a folha abre, porque o app inteiro espera por ela
(`docs/auth.md`). Se a leitura falhar mesmo assim, ou se sair da conta falhar,
a folha mostra o modo visitante: é a resposta segura, já que visitante não
mostra dado nenhum.

## Testes

| Arquivo | Cobre |
|---|---|
| `test/screens/profile/profile_view_model_test.dart` | Visitante; conta com nome, e-mail e foto; os casos sem nome; erro sem novas tentativas; seguir o usuário; sair da conta |
| `test/screens/profile/profile_sheet_test.dart` | Véu, raio e posição; 350 ms e reduzir movimento; os três jeitos de fechar; os dois modos; tela pequena e nome longo |
| `test/data/firebase_auth_repository_test.dart` | Nome, e-mail e foto vindos do Firebase |
| `test/screens/history/history_screen_test.dart`, `test/screens/swipe/swipe_screen_test.dart` | O Avatar Button abre a folha nas duas abas |

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Foto da pessoa no próprio Avatar Button da Top Bar | Junto com o login por Google e Apple (`docs/login.md`) |
| Estatísticas com conta | E10-S2 |
| Preferências com conta | E10-S3 |
| "Sobre o Rango", Privacidade e "Apagar meus dados" | E10-S4 |
