# Time, frentes e rituais

Como o time do Rango se organiza para tocar o projeto ao longo das 6 sprints (cronograma em
[contexto.md §10](contexto.md#10-cronograma-e-sprints)).

## Integrantes e frentes

> Preencher na reunião do time. Depois, atualize o `.github/CODEOWNERS` com os @ de cada frente.

| Integrante | GitHub | Frente principal | Frente de apoio |
|---|---|---|---|
| Antônio Cláudio Costa Junior | @antoniocostajr01 | Dev | Produto/UX |
| | | | |
| | | | |
| | | | |

### As frentes

Todas as frentes usam o **mesmo board** (GitHub Projects, campo *Frente*) e as mesmas sprints.

| Frente | Cuida de | Produz | Onde documenta |
|---|---|---|---|
| **Dev (app)** | Features do app, testes, CI, arquitetura | Código + PRs | `docs/specs/`, `docs/<feature>.md` |
| **Marketing e divulgação** | Posicionamento, identidade visual, redes sociais, landing page, pesquisa com usuários, seminário e pitch | Briefs, peças, posts, material de apresentação | `docs/marketing/` |
| **Produto/UX** (pode ser acumulada) | Priorizar o backlog, protótipos, conteúdo da árvore de categorias, critérios de aceitação | Protótipos, specs de produto, `backlog.yml` | `docs/contexto.md`, `docs/specs/` |

As frentes se cruzam em pontos fixos:
- **Identidade visual → tema do app:** a paleta e a tipografia de marketing viram o `ThemeData` (Sprint 2).
- **Seminário (22/10) e pitch (03/12):** dev prepara a demo, marketing prepara slides e roteiro, e os dois ensaiam juntos.
- **Pesquisa com usuários (Sprint 4):** marketing conduz, produto transforma os achados em issues e dev implementa.

## Papéis rotativos

Com 2–4 pessoas não há papéis fixos de Scrum. A cada sprint alguém assume:

| Papel | Responsabilidade | Rodízio |
|---|---|---|
| **Facilitador da sprint** | Conduz planning, review e retro; garante que a issue "Sprint N — acompanhamento" tenha as notas | A cada sprint |
| **Guardião do board** | Mantém o board atualizado, cobra issue sem responsável, roda o `Backlog sync` quando o `backlog.yml` muda | A cada sprint |

## Rituais (amarrados às aulas)

| Quando | Ritual | Entrada | Saída |
|---|---|---|---|
| Aula de review (fim da sprint) | **Review** (demo do incremento) | Relatório automático da sprint (comentado na terça à noite) | Feedback anotado na issue da sprint |
| Logo após a review | **Retro** (manter / melhorar / parar) | — | Até 3 ações de melhoria, viram issues ou regras |
| Mesma aula, depois da retro | **Planning** da próxima sprint | `backlog.yml` + feedback | PR no `backlog.yml` ajustando a sprint; responsáveis atribuídos |
| Aula do meio da sprint | **Checkpoint** | Board | Impedimentos resolvidos (label `blocked`) |
| Assíncrono (grupo do time) | **Daily curta** (2–3x por semana) | "Fiz / vou fazer / travado" | — |

O workflow **Sprint report** comenta toda terça às 20h, na issue "Sprint N — acompanhamento", o progresso por frente e as issues em aberto. É o roteiro da review.

## Definition of Ready (DoR)

Uma história só entra na sprint se:
- tiver critérios de aceitação verificáveis;
- tiver frente, estimativa e responsável;
- para histórias de dev com lógica nova: a spec (`docs/specs/NNN-…/spec.md`) tiver sido aprovada, ou o time tiver decidido explicitamente que não precisa (ver o processo SDD);
- para campanhas e pesquisas de marketing: tiver brief em `docs/marketing/briefs/`.

## Definition of Done (DoD)

- **Dev:** PR aprovado por 1 pessoa, CI verde (format, analyze, test), critérios de aceitação conferidos, doc da feature atualizada, issue fechada (o `Closes #N` fecha).
- **Marketing/produto:** entregável publicado ou anexado na issue, revisado por outra pessoa, métrica do brief registrada quando houver.

## Limites de trabalho

- **No máximo 2 issues em "In Progress" por pessoa.** Terminar antes de começar.
- Travou por mais de 1 dia? Coloque a label `blocked` e explique no comentário.
- Issue sem movimento há uma semana volta para *Todo* e perde o responsável.

## Board (GitHub Projects)

| Status | Significado | Como a issue chega aqui |
|---|---|---|
| Backlog | Planejada para depois (sem sprint) | Sync do `backlog.yml` |
| Todo | Na sprint, ninguém começou | Sync / planning |
| In Progress | Alguém está trabalhando | **Automático** ao criar a branch `feat/<issue>-…` (ou manual) |
| In Review | PR aberto | **Automático** ao abrir PR com `Closes #<issue>` |
| Done | Concluída | **Automático** ao fechar a issue ou dar merge no PR |

Views sugeridas: *Sprint atual* (filtro Sprint), *Por frente* (agrupado por Frente), *Roadmap* (agrupado por Sprint).
