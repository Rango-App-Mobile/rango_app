---
name: sprint-status
description: Use when the user asks for sprint status or progress in the Rango repository ("como está a sprint", "status da sprint 2", "o que falta", "sprint-status"), or for a summary per team front (Dev, Marketing, Produto/UX).
---

# Sprint status — Rango

Summarizes a sprint milestone per team front using the `frente:*` labels
(`frente:dev`, `frente:marketing`, `frente:produto`). Read-only: never change
issues, labels, milestones or the board. Never hardcode the organization name
(it will be renamed); use `{owner}/{repo}`, which `gh` resolves from the remote.

Sprints are two-week milestones `Sprint 1`..`Sprint 6`, each due on its review
class (`docs/contexto.md` §10). Epics (`type:epic`) and the tracking issue
(`type:sprint`) are not counted as work items.

## Steps

1. Milestones:
   `gh api 'repos/{owner}/{repo}/milestones?state=all' --jq '.[] | {title, due_on, open_issues, closed_issues}'`
2. If the user did not say which, use the open milestone with the nearest
   `due_on` and say which one you picked.
3. Issues of the milestone:
   `gh issue list --milestone "<title>" --state all --limit 200 --json number,title,state,labels,assignees,closedAt,body`
   Story points are in the body as `**Estimativa:** N pts`.
4. Open PRs: `gh pr list --base dev --json number,title,headRefName,reviewDecision,statusCheckRollup,closingIssuesReferences`
5. Group by `frente:*`; an issue with no front goes to "Sem frente" (and that is
   a warning).

## Output (chat, Portuguese, no emojis)

```
## Sprint <N> — vence em <dd/mm> (<X> dias)
Progresso: <fechadas>/<total> issues · <pontos feitos>/<pontos totais> pts

### Dev
- Fechadas: #12 ..., #15 ...
- Em andamento (PR aberto): #18 ... (PR #40, CI verde, aguardando revisão)
- Não iniciadas: #20 ...

### Marketing e divulgação
### Produto/UX
### Sem frente

### Riscos
- <issue sem responsável, PR com CI vermelho, história de dev sem spec a menos
  de 3 dias do fim, label blocked>
```

For the automatic weekly version, see `.github/workflows/sprint-report.yml`.
