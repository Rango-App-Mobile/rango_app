# Sessão anônima (modo visitante)

**Escopo:** abertura do app, `StartupScreen`, `startupViewModelProvider`,
`AuthRepository` e suas implementações (issue #8). Não toca o Firestore.

As regras de produto vêm das seções §6 (passo 1) e §7 (R1) de
`docs/contexto.md`. Este documento explica como a sessão anônima foi
implementada e por quê.

## O fluxo

| # | O que a pessoa vê | O que acontece |
|---|---|---|
| 1 | Abre o app: um indicador de carregando | `RangoApp` observa `startupViewModelProvider`; enquanto não há usuário, o `builder` do `MaterialApp.router` mostra a `StartupScreen` no lugar das rotas |
| 2 | — | `StartupViewModel.build()` chama `AuthRepository.ensureSignedIn()` |
| 3 | — | `FirebaseAuthRepository` reaproveita `FirebaseAuth.currentUser` se existir; senão chama `signInAnonymously()` |
| 4 | A Home (swipe) aparece | Com o `AppUser` pronto, o `builder` passa a mostrar o router |
| 4' | Sem rede: mensagem "Sem conexão." e o botão "Tentar novamente" | O repositório lança `NetworkFailure`; o botão chama `retry()`, que invalida o ViewModel e refaz o passo 2 |

O app inteiro espera a sessão: nada atrás do portão roda sem um usuário do
Firebase. É o modo visitante: o usuário é anônimo (`AppUser.isAnonymous`) e nada
dele é gravado.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| Reabrir o app mantém o mesmo usuário | `FirebaseAuthRepository.ensureSignedIn` (usa `currentUser` antes de entrar) | O Firebase Auth já persiste o usuário no aparelho; entrar de novo criaria outro `uid` a cada abertura |
| A sessão nasce sem interação | `StartupViewModel.build()`, disparado pelo `RangoApp` | Não existe tela de login para o visitante |
| Nenhuma tela roda sem usuário | `builder` do `MaterialApp.router` em `lib/app/app.dart` | Um ponto só, sem precisar de redirect no `go_router` enquanto não há rotas protegidas |
| O erro aparece na hora, sem novas tentativas escondidas | `retry: (_, _) => null` no `startupViewModelProvider` | O Riverpod 3 refaz sozinho providers que falham; isso escondia o erro e deixava o "Tentar novamente" sem efeito visível |
| Visitante não grava nada | Não existe acesso ao Firestore nesta feature | A persistência chega com E2-S4, que só salva para quem tem conta; as regras do Firestore (E4-S2) garantem no servidor |

O provider padrão do `AuthRepository` é o Firebase. O `FakeAuthRepository`
(sempre o mesmo usuário anônimo, `fake-uid`) e mocks são usados só nos testes,
que sempre sobrescrevem `authRepositoryProvider`.

## Erros

| Situação | `Failure` | O que a tela mostra |
|---|---|---|
| Sem rede (`network-request-failed`) | `NetworkFailure` | "Sem conexão." e "Tentar novamente" |
| Login anônimo desligado no console (`operation-not-allowed`) ou outro erro do Firebase Auth | `UnexpectedFailure` | "Algo deu errado." e "Tentar novamente" |
| Firebase devolve login sem usuário | `UnexpectedFailure` | "Algo deu errado." e "Tentar novamente" |

## Testes

| Arquivo | Cobre |
|---|---|
| `test/data/firebase_auth_repository_test.dart` | Cria anônimo sem usuário; reaproveita sem novo login; mapeamento de erros |
| `test/data/fake_auth_repository_test.dart` | O fake devolve sempre o mesmo `uid` |
| `test/screens/startup/startup_view_model_test.dart` | Pronto com anônimo; erro com `NetworkFailure`; `retry` recupera |
| `test/screens/startup/startup_screen_test.dart` | Erro com botão; tocar tenta de novo |
| `test/app/app_test.dart` | O router só aparece depois do usuário pronto |

Validação manual (não coberta por teste automatizado):

1. No console do Firebase (`rango-f0485`), Authentication > Método de login >
   Anônimo precisa estar ativado.
2. Instalar e abrir o app: em Authentication > Usuários aparece um usuário anônimo.
3. Fechar e abrir de novo: continua um único usuário, com o mesmo `uid`.
4. Instalação nova com modo avião: aparece "Sem conexão."; desligar o modo
   avião e tocar em "Tentar novamente" abre a Home.
