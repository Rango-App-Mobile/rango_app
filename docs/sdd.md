# Processo SDD (Spec-Driven Development)

Toda história de produto é **escrita antes de ser codada**, em três arquivos
curtos que ficam no repositório ao lado do código. Por que: com 2–4 pessoas em
frentes diferentes, a spec é onde Dev, Produto/UX e Marketing concordam sobre o
que vai ser entregue antes de alguém gastar dias no código errado. E é o que um
agente de IA lê para implementar sem inventar.

## O ciclo

```
história (issue)
   │  Produto/UX escreve a história com critérios de aceitação
   ▼
spec.md  ── PR "docs(spec): NNN ..." → revisão de Produto/UX + 1 dev
   ▼
plan.md  ── mesmo PR ou PR seguinte; revisão de 1 dev
   ▼
tasks.md ── cada item vira sub-issue da história
   ▼
implementação, uma task por PR, teste primeiro (TDD)
   ▼
PR → dev (template marca a spec e os critérios cobertos)
   ▼
docs/<feature>.md atualizado (última task)
```

| Etapa | Arquivo | Quem escreve | Quem aprova | Pergunta que responde |
|---|---|---|---|---|
| História | issue | Produto/UX | time na planning | O que a pessoa usuária ganha? |
| Spec | `docs/specs/NNN-slug/spec.md` | dev da história (com Produto/UX) | Produto/UX | **O quê** e como saber que ficou pronto |
| Plano | `plan.md` | dev da história | outro dev | **Como**: camadas, providers, dados, testes |
| Tasks | `tasks.md` + sub-issues | dev da história | — | **Em que ordem**, em PRs pequenos |
| Código | `lib/`, `test/` | quem pega a sub-issue | 1 revisão | Os critérios passam? |
| Doc da feature | `docs/<feature>.md` | quem fecha a última task | revisão do PR | O que existe e por quê |

Numeração: `NNN` sequencial em `docs/specs/` (`001-category-tree`,
`002-anonymous-auth`...). O número não muda depois de criado.

## Quando a spec é obrigatória

| Situação | Spec? | O que fazer |
|---|---|---|
| História nova de produto (tela, fluxo, regra) | **Sim** | Ciclo completo |
| Mudança de modelo de dados (Firestore §8) | **Sim** | Spec curta + atualizar §8 no mesmo PR |
| Integração externa (Firebase, Places, Functions) | **Sim** | Spec; riscos e custo no plano |
| Bug com comportamento esperado claro | Não | Issue com passos para reproduzir; teste que falha primeiro |
| Refatoração sem mudar comportamento | Não | Descrever no PR; testes existentes provam |
| Chore (dependência, CI, lint), docs, texto de UI | Não | PR direto com descrição |
| Spike / experimento | Não | Branch descartável; o aprendizado vira "Decisões" da spec seguinte |

Na dúvida: se mais de uma pessoa vai precisar concordar com o resultado, ou se
leva mais de um dia, escreva a spec. Uma spec curta custa 30 minutos.

## Regras

- **Spec aprovada antes do código.** PR de implementação sem spec aprovada (nos
  casos obrigatórios) volta.
- **Mudou de ideia no meio?** Atualize a spec no mesmo PR e registre em
  "Decisões". Spec desatualizada é pior que spec nenhuma.
- **Decisão que vale além da história** (arquitetura, stack, regra de negócio)
  sobe para `docs/contexto.md` §11.
- **Critério de aceitação = teste.** O PR lista qual teste cobre cada CA.
- **Fora de escopo é explícito.** O que não entra fica escrito, com destino.

## Onde ficam os moldes

| Molde | Arquivo |
|---|---|
| Spec | [`.claude/skills/spec-feature/references/spec.md`](../.claude/skills/spec-feature/references/spec.md) |
| Plano | [`.claude/skills/spec-feature/references/plan.md`](../.claude/skills/spec-feature/references/plan.md) |
| Tasks | [`.claude/skills/spec-feature/references/tasks.md`](../.claude/skills/spec-feature/references/tasks.md) |
| Doc da feature | [`.claude/skills/implement-task/references/feature-doc.md`](../.claude/skills/implement-task/references/feature-doc.md) |
| Brief de marketing | [`docs/marketing/briefs/_template.md`](marketing/briefs/_template.md) |

Os moldes ficam junto das skills que os usam (mesmo padrão do the-final-backend:
`SKILL.md` + `references/`). Quem escreve spec sem agente copia o molde para
`docs/specs/NNN-slug/`. A pasta `docs/specs/` nasce com a primeira spec.

A doc da feature fica direto em `docs/`, um arquivo por feature (`docs/swipe.md`,
`docs/restaurantes.md`), escrita quando a feature é entregue. Ela explica o que
existe e por quê; a spec explica o que ia ser feito.

## Com agentes de IA

- `spec-feature` gera spec/plan/tasks a partir da issue e para a cada etapa
  para revisão humana.
- `implement-task` implementa uma task com teste primeiro, lendo a spec e o
  plano.
- `pr-review-rango` revisa o PR contra as regras e os critérios da spec.

O agente propõe; uma pessoa do time aprova cada etapa.
