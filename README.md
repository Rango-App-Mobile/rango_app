# Rango

App mobile (Flutter) que resolve o "não sei o que comer": uma sessão curta de escolhas binárias por
swipe converge até um tipo de comida e, no mesmo fluxo, recomenda restaurantes reais e próximos
via Google Places.

Projeto da disciplina Projeto de Desenvolvimento I (Senac), 2º semestre de 2026.

## Estado atual

| Área | Situação |
|---|---|
| Gestão (backlog, board, CI, templates) | ✅ pronto |
| Projeto Flutter + arquitetura MVVM | ⏳ Sprint 2: seguir o [guia de setup](docs/guia-setup.md) |
| Processo (AGENTS.md, rules, skills) | ✅ pronto: [AGENTS.md](AGENTS.md), [docs das features](docs/sdd.md) |
| Firebase (configuração) | ✅ pronto: [como configurar](#firebase) |
| Sessão anônima (visitante) | ✅ pronto: [como funciona](docs/auth.md) |
| Swipe convergente | ⏳ Sprint 2 |
| Restaurantes (Google Places) | ⏳ Sprint 3 |

## Documentação

| Documento | Para quê |
|---|---|
| [docs/contexto.md](docs/contexto.md) | **Fonte canônica**: produto, stack, arquitetura, regras, modelo de dados, cronograma, decisões |
| [docs/acordo-projeto.md](docs/acordo-projeto.md) · [PDF v1.1](docs/acordo-projeto-v1.1.pdf) | Acordo de projeto (escopo, benchmark, cronograma e frentes) |
| [docs/guia-setup.md](docs/guia-setup.md) | Passo a passo: Flutter, dependências, MVVM, SDD |
| [docs/time-e-rituais.md](docs/time-e-rituais.md) | Frentes, papéis, rituais por aula, DoR/DoD |
| [docs/git-e-prs.md](docs/git-e-prs.md) | Branches, commits, PRs e automações do GitHub |
| [docs/sdd.md](docs/sdd.md) | Como documentar as features entregues (sem spec antes do código) |
| [AGENTS.md](AGENTS.md) · [CLAUDE.md](CLAUDE.md) | Instruções para agentes de IA (e humanos): regras, comandos, workflow |
| [docs/marketing/](docs/marketing/README.md) | Posicionamento, identidade, calendário de conteúdo, briefs |

## Firebase

O app usa o projeto Firebase `rango-f0485` (Android e iOS). Os ids do projeto ficam em
`lib/firebase_options.dart`; as **chaves de API** ficam só no seu `env.json` local, como a do
Places:

```bash
cp env.example.json env.json   # preencha FIREBASE_ANDROID_API_KEY e FIREBASE_IOS_API_KEY
flutter pub get
flutter run --dart-define-from-file=env.json
```

As chaves estão no Google Cloud Console do projeto (APIs e serviços → Credenciais); peça a quem
administra o projeto. Sem elas o app abre normalmente, mas com um usuário falso
(`FakeAuthRepository`), sem falar com o Firebase. É assim que o CI roda.

**Não rode `flutterfire configure`**: ele reescreve o `firebase_options.dart` com as chaves
literais e recria `google-services.json` / `GoogleService-Info.plist` (ignorados pelo git). Detalhes
em [docs/auth.md](docs/auth.md#configuração-do-firebase).

`Firebase.initializeApp` é chamado em `lib/main.dart`; fora dele, o Firebase só é acessado em
`lib/data/`. O acesso aos dados é protegido pelas regras de segurança do Firestore.

## Como contribuir (resumo)

1. Pegue uma issue da sprint atual no board (GitHub Projects) e atribua a você.
2. Crie a branch a partir de `dev` com o número da issue:

```bash
git switch dev && git pull && git switch -c feat/<issue>-<slug>
```

3. Implemente a partir dos critérios da história, com teste primeiro; o PR que conclui a história cria ou atualiza `docs/<feature>.md`.
4. Abra o PR para `dev` com `Closes #<issue>`, espere o CI verde e 1 aprovação.

Detalhes em [git-e-prs.md](docs/git-e-prs.md).

## Backlog

O backlog está versionado em [`.github/backlog/backlog.yml`](.github/backlog/backlog.yml) e é
sincronizado como issues, milestones (uma por sprint) e itens do board pelo workflow **Backlog sync**.
Para mudar o planejamento, edite o arquivo e abra um PR.
