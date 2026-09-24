# Git, PRs e automação do GitHub

## Branches

| Branch | Para quê | Recebe merge de |
|---|---|---|
| `main` | O que foi apresentado nas reviews. Sempre demonstrável. | `dev`, na aula de review |
| `dev` | Integração do dia a dia | branches de trabalho, via PR |
| `feat/<issue>-<slug>` | Funcionalidade | — |
| `fix/<issue>-<slug>` | Correção | — |
| `docs/<issue>-<slug>` | Specs, docs, marketing | — |
| `chore/<issue>-<slug>` | Setup, CI, dependências | — |

Sempre comece pelo **número da issue** (`feat/14-swipe-screen`). Assim o board move a issue para *In Progress* sozinho.

```bash
git switch dev && git pull
```

```bash
git switch -c feat/14-swipe-screen
```

## Commits

Convencionais, **em inglês**, no imperativo, com a issue no fim:

```
feat: add swipe session notifier (#14)
fix: keep list position when returning from detail (#31)
docs: add spec 001 category tree (#9)
chore: configure very_good_analysis (#5)
test: cover empty places response (#22)
```

Tipos: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`.

## Pull requests

- **Alvo:** `dev`. Uma issue por PR, e PR pequeno (idealmente menos de 400 linhas de diff, sem contar gerados).
- O corpo segue o template e tem **`Closes #<issue>`**, o que move a issue para *In Review* e a fecha no merge.
- **1 aprovação** de outra pessoa antes do merge. Se a mudança tocar `lib/`, ao menos um revisor da frente dev.
- **CI verde:** `format`, `analyze` e `test`. Rode antes de abrir o PR:

```bash
dart format . && flutter analyze && flutter test
```

- Merge com **squash** (histórico limpo em `dev`). Na review da sprint, `dev` → `main` com merge commit.
- Revisão assistida: a skill `pr-review-rango` (ver [guia de setup, passo 5](../guia-setup.md)) aplica o checklist do projeto. O humano decide o que comentar.

## Proteção de branches

Regras do time (valem mesmo que o GitHub não consiga obrigar em repo privado no plano gratuito):
- ninguém faz push direto em `main` ou `dev`;
- nada de `push --force` em `main`/`dev`;
- merge só com CI verde e 1 aprovação.

## Automação (GitHub Actions)

| Workflow | Quando roda | O que faz |
|---|---|---|
| **CI** (`ci.yml`) | PR e push em `main`/`dev` | `dart format`, `flutter analyze`, `flutter test --coverage`. É pulado enquanto não existe `pubspec.yaml`. |
| **Backlog sync** (`backlog-sync.yml`) | Push em `main` alterando o `backlog.yml`, ou manual | Cria/atualiza labels, milestones (sprints), issues, sub-issues e campos do board. Não duplica e não fecha o que foi removido. |
| **Project automation** (`project-automation.yml`) | Criação de branch e abertura/edição de PR | `feat/<n>-…` → issue n em *In Progress*; PR com `Closes #n` → *In Review*. Nunca volta status. |
| **Sprint report** (`sprint-report.yml`) | Terça 20h (Brasília) ou manual | Resumo da sprint por frente comentado na issue "Sprint N — acompanhamento". |

Os workflows nativos do Project (configurados no próprio board, em *Workflows*) cuidam de: auto-add de issues/PRs do repo, *item fechado → Done* e *PR merged → Done*.

### Mudar o backlog

1. Edite `.github/backlog/backlog.yml` numa branch `docs/<n>-backlog-sprint-x` (ou direto no planning).
2. Valide localmente (opcional):

```bash
python3 .github/scripts/backlog_sync.py --offline
```

3. PR → merge em `dev` → na review vai para `main` e o sync roda. Para aplicar na hora, rode **Actions → Backlog sync → Run workflow** (desmarque *dry run*) escolhendo a branch.

### Configuração (uma vez)

| Item | Onde | Valor |
|---|---|---|
| Variável `PROJECT_NUMBER` | Settings → Secrets and variables → Actions → Variables | Número do board (`…/projects/<N>`) |
| Secret `PROJECT_TOKEN` | Settings → Secrets and variables → Actions → Secrets | Token fine-grained com acesso a **Projects (org): read/write** e **Issues/Pull requests (repo): read** |

Sem o `PROJECT_TOKEN`, o CI e a criação de issues continuam funcionando; só a movimentação no board é pulada.

> A org vai ser renomeada: nada nos workflows usa o nome dela fixo (`github.repository_owner`). Depois do rename, atualize o remote local:

```bash
git remote set-url origin git@github.com:<novo-nome-da-org>/rango_app.git
```
