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
| 3'''' | Sempre, com ou sem conta: "Termos e Privacidade" | Abre a mesma folha dos termos do cadastro (`showTermsSheet`, em `lib/core/widgets/terms_acceptance.dart`), com o texto de `docs/termos-e-privacidade.md`. As lojas pedem a política acessível dentro do app |
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

Direto, sem pedir login de novo:

| # | O que a pessoa vê | O que acontece |
|---|---|---|
| 1 | Toca em "Excluir conta" | Alerta nativo (`showAdaptiveDialog`): "Excluir sua conta?", "Seu histórico e seus dados serão apagados. Isso não pode ser desfeito.", "Cancelar" e "Excluir" (destrutivo). Só isso, sem campo de senha |
| 2 | Confirma | A animação de carregamento ("Excluindo sua conta…") cobre o app inteiro, por cima da folha, e nada pode ser tocado até terminar |
| 3 | Sucesso | O carregamento e a folha fecham e o app volta ao modo visitante, sem SnackBar (ele ficaria por baixo do blur da Tab Bar) |
| 3' | Erro | O carregamento fecha e um alerta "Não deu para excluir" explica: sem rede ("Sem conexão."), login antigo (abaixo) ou "Não foi possível excluir sua conta. Tente de novo." A conta continua |

**A ordem importa** (`ProfileViewModel.deleteAccount`), e qualquer `Failure`
interrompe a sequência:

1. `AuthRepository.refreshLoginSilently`: o Firebase só apaga uma conta com
   login de até uns 5 minutos atrás. Se o último login é desse tempo (com folga
   de 4 minutos), segue. Senão, uma conta com Google renova o login em silêncio
   (`attemptLightweightAuthentication`, sem tela). Nunca abre a folha da Apple,
   o seletor do Google nem pede senha. Se não der, nada é apagado e o alerta
   diz "Por segurança, saia e entre de novo na sua conta para excluí-la."
   (`RequiresRecentLoginFailure`).
2. `AccountRepository.deleteData(uid)`: apaga `users/{uid}/sessions` e
   `users/{uid}`. Vem antes porque `firestore.rules` só deixa a própria conta
   (não anônima) apagar os dados dela; sem a conta, os dados ficariam órfãos.
3. `AuthRepository.deleteAccount`: apaga o usuário no Firebase, sai do Google e
   cria um novo visitante anônimo.

**Limites conhecidos.** Apagar sempre, sem depender do login recente, e revogar
o token da Apple (a Apple pede isso na exclusão) só dá pelo servidor, com Cloud
Functions, que exige o plano Blaze com cartão (`docs/contexto.md` §11). Revogar
pelo app exigiria abrir a folha da Apple, e a exclusão não pede login. Se a
revisão da App Store cobrar a revogação, ela entra por uma função no servidor.

## Sobre o Rango

Visitante e conta têm a linha "Sobre o Rango" no Perfil. Ela abre uma folha
com uma descrição curta do app e a versão instalada, lida de
`PackageInfoAppInfoRepository` por `appVersionProvider`. Se os metadados do
aparelho não puderem ser lidos, a folha mostra uma mensagem e permite tentar de
novo. `package_info_plus` fornece os metadados em iOS e Android.

`test/screens/profile/about_rango_sheet_test.dart` cobre acesso nos dois modos,
a versão exibida e a recuperação após falha; `test/data/package_info_app_info_repository_test.dart`
cobre o valor retornado pelo repositório.

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
| `test/data/package_info_app_info_repository_test.dart`, `test/screens/profile/about_rango_sheet_test.dart` | Versão instalada; About acessível para visitante e conta; recuperação após falha |

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Foto da pessoa no próprio Avatar Button da Top Bar | Junto com o login por Google e Apple (`docs/login.md`) |
| Estatísticas com conta | E10-S2 |
| Preferências com conta | E10-S3 |
