# Entrar e criar conta

**Escopo:** as telas Entrar, Criar conta e Recuperar senha
(`lib/screens/login/`, `sign_up/` e `password_reset/`), o login por e-mail no
`AuthRepository` e os componentes de formulário em `lib/core/widgets/` (issue
#46). Telas no Figma: fluxo 06 (13, 14 e 15, com seus estados).

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
| 7 | No Profile Sheet, "Sair da conta" | `ProfileViewModel.signOut`: sai da conta e cria uma sessão de visitante nova |

O voltar de Entrar e de Criar conta sai do fluxo e a pessoa segue como
visitante. Como uma tela substitui a outra, o voltar nunca passa pelas duas.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| A conta nasce do visitante, com o mesmo `uid` | `FirebaseAuthRepository.signUp` (`linkWithCredential`) | O que for salvo depois fica no mesmo usuário; só o repositório conhece o Firebase |
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
até fechar o app.

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
| `test/data/firebase_auth_repository_test.dart` | Criar conta ligando o visitante; entrar; os códigos de erro; recuperar senha; sair; `watchUser` |
| `test/data/fake_auth_repository_test.dart` | Criar, sair e entrar de novo; senha errada e e-mail repetido |
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

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Entrar com Google e com Apple: os botões aparecem desligados e sem o ícone da marca | Issue nova (precisa de `google_sign_in` e `sign_in_with_apple`) |
| Foto da pessoa no Avatar Button da Top Bar | Junto com Google e Apple: conta por e-mail não tem foto |
| Estado de carregando no Button: enquanto envia, o botão só fica desligado | Componente ainda não desenhado no Figma |
| Termos de Uso e Política de Privacidade (a frase da tela 14 não entrou) | Os documentos ainda não existem |
| Salvar os rangos de quem tem conta | E2-S4 |

## Pendências

- Quem entra numa conta que já existe deixa para trás o usuário anônimo daquele
  aparelho no Firebase. Não há dado nele (R1), mas eles se acumulam no console.
