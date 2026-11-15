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
| 3''' | Conta de e-mail e senha com o e-mail ainda não confirmado: aviso "Confirme seu e-mail" e "Reenviar" | `ProfileState.needsVerification` (`usesPassword && !emailVerified`). "Reenviar" chama `ProfileViewModel.resendVerification`, que chama `AuthRepository.resendVerification`; o sucesso mostra o SnackBar "Link reenviado." |
| 4 | Fecha pelo X, arrastando para baixo ou tocando no véu | O X dá `pop`; arrastar e tocar no véu são do próprio `showModalBottomSheet` |

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| Visitante não vê estatísticas nem preferências | `ProfileSheet`, pelo `ProfileState.isGuest` | Sem conta nada é salvo (R1), então não há o que mostrar |
| O que aparece como nome e subtítulo | `ProfileState.fromUser` | É regra, não desenho: testada sem montar widget |
| Nome, e-mail e foto vêm do provedor de login | `FirebaseAuthRepository._toAppUser` | É o único lugar que conhece o `User` do Firebase. O nome é o `displayName` do usuário; se estiver vazio, o primeiro `displayName` não vazio de `providerData` (a Apple e o Google às vezes só o guardam no provedor). Se ainda assim faltar, a tela "Quase lá" (`docs/login.md`) pede o nome logo após o login |
| A folha cobre a Tab Bar | `useRootNavigator: true` | O shell das abas tem navigator próprio, e a Tab Bar ficaria por cima do véu |
| O X sempre fica visível | O cabeçalho fica fora da rolagem; só o convite rola | Em tela pequena com texto grande, o conteúdo não pode empurrar a saída para fora |

O Firebase não avisa quando o e-mail é confirmado no app de e-mail
(`userChanges()` não emite). Por isso o `ProfileViewModel` chama
`AuthRepository.reload()` assim que a folha abre; o aviso some se a conta já
estiver confirmada. Contas Google e Apple chegam confirmadas e não mostram o
aviso.

A folha é aberta por uma função, e não por uma rota do `go_router`: ela não tem
endereço próprio e abre por cima de qualquer tela raiz, sem mudar a rota atual.

## Excluir conta

Exigida pela App Store (diretriz 5.1.1(v)): quem cria conta no app precisa
poder apagá-la dentro dele. A linha "Excluir conta" (em vermelho, `textDanger`)
aparece só no modo com conta, abaixo de "Sair da conta".

| # | O que a pessoa vê | O que acontece |
|---|---|---|
| 1 | Toca em "Excluir conta" | `showAdaptiveDialog` (visual nativo no iOS): "Excluir sua conta?", "Seu histórico e seus dados serão apagados. Isso não pode ser desfeito.", "Cancelar" e "Excluir" (destrutivo). Conta de e-mail e senha vê também o campo "Senha" |
| 2 | Confirma | `ProfileViewModel.deleteAccount({password})`. A folha vira a tela de carregamento "Excluindo sua conta…" e não fecha até terminar |
| 3 | Sucesso | A folha fecha e aparece o SnackBar "Sua conta foi excluída."; o app volta ao modo visitante |
| 3' | Erro | A conta continua. A folha mostra o aviso: senha errada ("E-mail ou senha incorretos."), sem rede ("Sem conexão.") ou "Não foi possível excluir sua conta. Tente de novo." |
| 3'' | Fecha a janela do Google ou da Apple | Nada é apagado e nada é mostrado |

**A ordem importa** (`ProfileViewModel.deleteAccount`), e qualquer `Failure`
interrompe a sequência:

1. `AuthRepository.reauthenticate`: o Firebase só apaga uma conta com login
   recente. Conta de e-mail usa a senha digitada; Google reabre o seletor da
   conta; Apple reabre a folha da Apple. `false` se a pessoa fechar a janela.
   O provedor é o da sessão atual (`sign_in_provider` do token), porque uma
   conta pode ter mais de um ligado (o mesmo e-mail no Google e na Apple). Sem
   essa informação, a ordem é Apple, Google, senha.
2. `AccountRepository.deleteData(uid)`: apaga `users/{uid}/sessions` e
   `users/{uid}`. Vem antes porque `firestore.rules` só deixa a própria conta
   (não anônima) apagar os dados dela; sem a conta, os dados ficariam órfãos.
3. `AuthRepository.deleteAccount`: revoga o token da Apple (se for conta Apple),
   apaga o usuário no Firebase, sai do Google e cria um novo visitante anônimo.

**Revogação da Apple.** O reautenticar com a Apple devolve
`additionalUserInfo.authorizationCode`; o `FirebaseAuthRepository` guarda esse
código e o entrega a `FirebaseAuth.revokeTokenWithAuthorizationCode` antes de
apagar o usuário. Se a revogação falhar, a exclusão segue mesmo assim: a conta
some do app, e a pessoa ainda pode remover o app nos ajustes da Apple.

Se o Firebase ainda pedir login recente, o erro vira
`RequiresRecentLoginFailure` ("Entre de novo para excluir sua conta.").

## Erros

A sessão já existe quando a folha abre, porque o app inteiro espera por ela
(`docs/auth.md`). Se a leitura falhar mesmo assim, ou se sair da conta falhar,
a folha mostra o modo visitante: é a resposta segura, já que visitante não
mostra dado nenhum.

## Testes

| Arquivo | Cobre |
|---|---|
| `test/screens/profile/profile_view_model_test.dart` | Visitante; conta com nome, e-mail e foto; os casos sem nome; erro sem novas tentativas; seguir o usuário; sair da conta |
| `test/screens/profile/profile_view_model_delete_test.dart` | Ordem da exclusão (reautenticar, dados, conta), cancelamento e falhas |
| `test/screens/profile/profile_sheet_delete_test.dart` | A linha só com conta, o diálogo (campo de senha só para senha), SnackBar de sucesso e erros |
| `test/data/firebase_auth_repository_delete_test.dart`, `test/data/fake_auth_repository_delete_test.dart` | Reautenticação por provedor, cancelamento, revogação da Apple, exclusão e mapeamento de erros |
| `test/screens/profile/profile_sheet_test.dart` | Véu, raio e posição; 350 ms e reduzir movimento; os três jeitos de fechar; os dois modos; tela pequena e nome longo |
| `test/data/firebase_auth_repository_test.dart` | Nome, e-mail e foto vindos do Firebase |
| `test/screens/history/history_screen_test.dart`, `test/screens/swipe/swipe_screen_test.dart` | O Avatar Button abre a folha nas duas abas |

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Foto da pessoa no próprio Avatar Button da Top Bar | Junto com o login por Google e Apple (`docs/login.md`) |
| Estatísticas com conta | E10-S2 |
| Preferências com conta | E10-S3 |
| "Sobre o Rango" e Privacidade | E10-S4 |
