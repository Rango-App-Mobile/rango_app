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
| Processo SDD (AGENTS.md, rules, skills, specs) | ⏳ Sprint 2: [guia de setup, passo 5](docs/guia-setup.md) |
| Firebase + sessão anônima | ⏳ Sprint 2 |
| Swipe convergente | ⏳ Sprint 2 |
| Restaurantes (Google Places) | ⏳ Sprint 3 |

## Documentação

| Documento | Para quê |
|---|---|
| [docs/contexto.md](docs/contexto.md) | **Fonte canônica**: produto, stack, arquitetura, regras, modelo de dados, cronograma, decisões |
| [docs/acordo-projeto.md](docs/acordo-projeto.md) · [PDF v1.1](docs/acordo-projeto-v1.1.pdf) | Acordo de projeto (escopo, benchmark, cronograma e frentes) |
| [docs/guia-setup.md](docs/guia-setup.md) | Passo a passo: Flutter, dependências, MVVM, SDD |
| [docs/processo/time-e-rituais.md](docs/processo/time-e-rituais.md) | Frentes, papéis, rituais por aula, DoR/DoD |
| [docs/processo/git-e-prs.md](docs/processo/git-e-prs.md) | Branches, commits, PRs e automações do GitHub |
| [docs/marketing/](docs/marketing/README.md) | Posicionamento, identidade, calendário de conteúdo, briefs |

## Como contribuir (resumo)

1. Pegue uma issue da sprint atual no board (GitHub Projects) e atribua a você.
2. Crie a branch a partir de `dev` com o número da issue:

```bash
git switch dev && git pull && git switch -c feat/<issue>-<slug>
```

3. Histórias com lógica nova começam por uma spec em `docs/specs/` (processo SDD).
4. Abra o PR para `dev` com `Closes #<issue>`, espere o CI verde e 1 aprovação.

Detalhes em [git-e-prs.md](docs/processo/git-e-prs.md).

## Backlog

O backlog está versionado em [`.github/backlog/backlog.yml`](.github/backlog/backlog.yml) e é
sincronizado como issues, milestones (uma por sprint) e itens do board pelo workflow **Backlog sync**.
Para mudar o planejamento, edite o arquivo e abra um PR.
