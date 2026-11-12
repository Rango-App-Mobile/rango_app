# Entrar e criar conta

**Escopo:** as telas Entrar, Criar conta e Recuperar senha
(`lib/screens/login/`, `sign_up/` e `password_reset/`), o login por e-mail no
`AuthRepository` e os componentes de formulário em `lib/core/widgets/` (issue
#46), mais o login com Google e Apple (E1-S4). Telas no Figma: fluxo 06 (13, 14
e 15, com seus estados).

As regras de produto vêm das seções §6 (passo 5), §7 (R1) e §11 de
`docs/contexto.md`. A sessão de visitante está em `docs/auth.md` e a folha de
perfil em `docs/perfil.md`.

## O fluxo

| # | O que a pessoa vê | O que acontece |
|---|---|---|
| 1 | No Profile Sheet, toca em "Entrar ou criar conta" | A folha fecha e abre `/login` por cima das abas |
| 2 | Entrar: e-mail, senha e "Entrar" | `LoginViewModel.submit` chama `AuthRepository.signIn` |
| 2' | "Ainda não tem conta? Criar conta" | `/signup` **substitui** o login na pilha. O mesmo vale no caminho de volta |
| 3 | Criar conta: nome, e-mail e senha | `SignUpViewModel.submit` valida e chama `AuthRepository.signUp` |
| 4 | Deu certo: volta para a tela de onde saiu, já com a conta | A tela dá `pop` quando o estado vira `done`. O Profile Sheet passa a mostrar a pessoa sozinho, porque segue `AuthRepository.watchUser()` |
| 5 | "Esqueci minha senha" → Recuperar senha, com o e-mail já digitado | `/password-reset` recebe o e-mail pelo `extra` da rota |
| 6 | "Enviar link" → "Confira seu e-mail" | `AuthRepository.sendPasswordReset`. A senha nova é criada na página do Firebase, fora do app |
| 2'' | Em Entrar ou Criar conta, "Continuar com o Google" ou "Continuar com a Apple" | `continueWithGoogle` / `continueWithApple` do ViewModel chamam `AuthRepository.signInWithGoogle` / `signInWithApple`. Abre a folha do Google ou da Apple; deu certo, segue o passo 4 |
| 7 | No Profile Sheet, "Sair da conta" | `ProfileViewModel.signOut`: sai da conta (e do Google) e cria uma sessão de visitante nova |

O voltar de Entrar e de Criar conta sai do fluxo e a pessoa segue como
visitante. Como uma tela substitui a outra, o voltar nunca passa pelas duas.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| A conta nasce do visitante, com o mesmo `uid` | `FirebaseAuthRepository.signUp` (`linkWithCredential`) | O que for salvo depois fica no mesmo usuário; só o repositório conhece o Firebase |
| Google e Apple: liga ao visitante ou entra na conta que já existe | `FirebaseAuthRepository._linkOrSignIn` | Detalhes na seção "Google e Apple" |
| O botão da Apple aparece só no iOS | `offersApple` de cada ViewModel | Decisão de 2026-11-12 (§11); fora da tela, dá para testar com `debugDefaultTargetPlatformOverride` |
| Enquanto um login está em andamento, os botões ficam desligados e um segundo toque não faz nada | `submitting` no `AuthFormState` | O mesmo cuidado do "Entrar" |
| Nome obrigatório, e-mail com cara de e-mail, senha com 8 caracteres ou mais | `SignUpViewModel` e `AuthFormState` | Valida antes de gastar uma chamada, e é testável sem tela |
| Cada erro aparece junto do que o causou | `AuthFormState.failed` | Um lugar só para as três telas: credencial e senha fraca no campo Senha, e-mail em uso ou inválido no campo E-mail, rede e inesperado no aviso do topo |
| "E-mail ou senha incorretos" serve para os dois casos | `FirebaseAuthRepository._toFailure` | O Firebase não diz qual dos dois errou, e dizer ajudaria a descobrir quem tem conta |
| Recuperar senha confirma o envio mesmo sem conta naquele e-mail | `FirebaseAuthRepository.sendPasswordReset` | Mesma razão: a tela não revela quem está cadastrado |
| Editar um campo limpa os erros | `edited()` de cada ViewModel | O erro é da tentativa anterior |
| O que foi digitado continua depois de um erro | Os `TextEditingController` ficam na tela, fora do estado | O estado guarda só erros e andamento |

As três telas usam o mesmo estado, `AuthFormState`, em `lib/models/`: os
campos são os mesmos e a regra de onde cada erro aparece é uma só.

Sem as chaves do Firebase no `env.json`, o app usa o `FakeAuthRepository`, que
guarda as contas na memória: dá para criar uma conta, sair e entrar de novo
até fechar o app. Google e Apple entram sempre na mesma conta de exemplo
(Ana Souza).

## Google e Apple

| Passo | Google (Android e iOS) | Apple (só iOS) |
|---|---|---|
| Abrir a folha | `google_sign_in`: `GoogleSignIn.instance.initialize` (uma vez) e `authenticate()`; o app pega o `idToken` da conta escolhida | O próprio `firebase_auth` abre a folha da Apple (`AppleAuthProvider`, escopos `email` e `name`) |
| Visitante | `linkWithCredential(GoogleAuthProvider.credential(idToken))`: a conta nasce com o `uid` do visitante | `linkWithProvider(AppleAuthProvider)`: idem |
| A conta já existe (`credential-already-in-use`, `email-already-in-use` ou `account-exists-with-different-credential`) | Entra nela com `signInWithCredential`. O visitante fica para trás: ele não tem nada salvo (R1) | Entra com a credencial que o Firebase devolve no erro; sem ela, abre a folha de novo (`signInWithProvider`) |
| Fechou a folha | O repositório devolve `null` e o formulário volta como estava, sem mensagem | Idem (códigos `canceled` e `web-context-canceled`) |

O `FirebaseAuthRepository` recebe pelo construtor a função que abre o Google
(`googleIdToken`) e a que sai dele (`googleSignOut`). O padrão usa o
`google_sign_in`; os testes passam as suas, sem o plugin. "Sair da conta" sai
também do Google, para o próximo toque mostrar a escolha de conta.

### Configuração (uma vez, fora do código)

Os ids de cliente OAuth são públicos, como o `appId`, e ficam no git:

| O que preencher | Onde | De onde vem |
|---|---|---|
| `DefaultFirebaseOptions.googleWebClientId` | `lib/firebase_options.dart` | Console do Firebase > Authentication > Método de login > Google > Configuração do SDK da Web > ID do cliente da Web. O Android precisa dele para o token ser aceito pelo Firebase |
| `DefaultFirebaseOptions.googleIosClientId` | `lib/firebase_options.dart` | `CLIENT_ID` do `GoogleService-Info.plist` do app iOS (baixar só para copiar o valor, não fica no projeto) |
| `CFBundleURLSchemes` | `ios/Runner/Info.plist` | `REVERSED_CLIENT_ID` do mesmo arquivo. É por esse endereço que o Google volta para o app |

Como o id do iOS vai no `initialize`, o `Info.plist` não precisa da chave
`GIDClientID`. Os ids do iOS já estão preenchidos. O id da Web ainda é um
marcador com `TODO(antonio)`: até ele ser trocado, o Google funciona só no
iOS e, no Android, tocar no Google mostra "Algo deu errado".

No console e nas contas:

1. Firebase > Authentication > Método de login: ativar **Google** e **Apple**.
2. Android: cadastrar no app Android do Firebase o SHA-1 do certificado de
   cada pessoa que roda o app (`./gradlew signingReport`), senão o Google
   recusa o login.
3. Apple Developer > Identifiers > `br.senac.rangoApp`: ligar a capacidade
   **Sign in with Apple**. O `ios/Runner/Runner.entitlements` já pede essa
   capacidade, e o target Runner aponta para ele (`CODE_SIGN_ENTITLEMENTS`).

## Componentes

| Componente | Arquivo | Figma |
|---|---|---|
| `RangoTextField` | `lib/core/widgets/rango_text_field.dart` | Text Field: rótulo fora do campo, 56 de altura, mensagem de apoio ou de erro embaixo. Senha ganha o olho para mostrar e esconder |
| `RangoDivider` | `lib/core/widgets/rango_divider.dart` | Divider: linha com "ou" no meio |
| `InlineAlert` | `lib/core/widgets/inline_alert.dart` | Inline Alert: erro do formulário inteiro, acima dos campos |
| `ListRow` | `lib/core/widgets/list_row.dart` | List Row, só a variante `Trailing=Chevron` sem valor. Usada em "Sair da conta" |

## Erros

| Situação | `Failure` | O que a tela mostra |
|---|---|---|
| E-mail ou senha errados, conta inexistente ou desativada | `InvalidCredentialsFailure` | "E-mail ou senha incorretos." no campo Senha |
| E-mail já tem conta | `EmailInUseFailure` | "Esse e-mail já tem conta. Entre nele ou use outro." no campo E-mail |
| E-mail recusado pelo Firebase | `InvalidEmailFailure` | "Confira o e-mail." no campo E-mail |
| Senha recusada pelo Firebase | `WeakPasswordFailure` | "Pelo menos 8 caracteres." no campo Senha |
| Sem rede | `NetworkFailure` | Aviso "Sem conexão. Confira sua internet e tente de novo." |
| Qualquer outro, inclusive e-mail e senha desligado no console | `UnexpectedFailure` | Aviso "Algo deu errado. Tente de novo." |
| Sair da conta sem rede | `NetworkFailure` | O Profile Sheet mostra o visitante: a conta já saiu, e a sessão nova é criada na próxima abertura |

## Testes

| Arquivo | Cobre |
|---|---|
| `test/data/firebase_auth_repository_test.dart` | Criar conta ligando o visitante; entrar; os códigos de erro; recuperar senha; sair (e sair do Google); `watchUser`; Google e Apple: ligar, conta que já existe, folha fechada, erros |
| `test/data/fake_auth_repository_test.dart` | Criar, sair e entrar de novo; senha errada e e-mail repetido; Google e Apple |
| `test/screens/login/login_view_model_test.dart` | Google e Apple: sucesso, folha fechada, rede, erro sempre no aviso, toque duplo; Apple só no iOS |
| `test/models/auth_form_state_test.dart` | Onde cada erro aparece; formato de e-mail |
| `test/screens/login/`, `sign_up/`, `password_reset/` | Cada tela: sucesso, validação, erros, links e o voltar |
| `test/screens/profile/` | O convite abre o login; "Sair da conta"; a folha segue o usuário |
| `test/core/widgets/form_widgets_test.dart` | Os quatro componentes |

Validação manual, não coberta por teste automatizado:

1. No console do Firebase, Authentication > Método de login > E-mail/senha
   precisa estar ativado.
2. Criar uma conta: em Authentication > Usuários, o usuário anônimo vira uma
   conta com o mesmo `uid`.
3. Pedir a recuperação de senha e conferir a chegada do e-mail.
4. Entrar com Google no Android e no iOS, e com Apple no iOS: o visitante vira
   conta com o mesmo `uid`. Sair e entrar de novo na mesma conta: entra sem
   erro, com o `uid` da conta.
5. Fechar a folha do Google e a da Apple: o formulário volta sem mensagem.

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Ícone da marca nos botões do Google e da Apple | Componente ainda não desenhado no Figma |
| Entrar com a Apple no Android | Fora do MVP (§11, 2026-11-12) |
| Quando a Apple ou o Google usam um e-mail que já tem conta por senha, o Firebase pode recusar (`account-exists-with-different-credential` ao entrar) e a tela mostra "Algo deu errado" | Issue nova, se aparecer na prática |
| Estado de carregando no Button: enquanto envia, o botão só fica desligado | Componente ainda não desenhado no Figma |
| Termos de Uso e Política de Privacidade (a frase da tela 14 não entrou) | Os documentos ainda não existem |
| Salvar os rangos de quem tem conta | E2-S4 |

## Pendências

- Quem entra numa conta que já existe (por e-mail, Google ou Apple) deixa para
  trás o usuário anônimo daquele aparelho no Firebase. Não há dado nele (R1), mas eles se acumulam no console.
