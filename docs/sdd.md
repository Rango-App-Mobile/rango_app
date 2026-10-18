# Documentação das features

O time não escreve spec, plano ou lista de tasks antes de implementar. A
história (issue gerada do `backlog.yml`) com os critérios de aceitação é o
ponto de partida; a implementação vai direto para o código, com teste primeiro.

`docs/` registra **o que foi entregue e como funciona**, não o que ia ser feito.

## O ciclo

```
história (issue com critérios de aceitação)
   ▼
implementação, teste primeiro, PR → dev
   ▼
docs/<feature>.md criado ou atualizado no PR que conclui a história
```

## A doc da feature

Um arquivo por feature, direto em `docs/` (`docs/swipe.md`, `docs/auth.md`,
`docs/restaurantes.md`), em português, escrito quando a feature é entregue.
Responde:

- **O fluxo:** o que a pessoa usuária vê e o que acontece em cada camada.
- **Onde cada regra mora:** model, repositório, regras do Firestore, e por quê ali.
- **Erros:** cada `Failure` e o que a tela mostra.
- **Testes:** que arquivos cobrem o quê e o que se valida à mão.

Molde: [`.claude/skills/implement-task/references/feature-doc.md`](../.claude/skills/implement-task/references/feature-doc.md).

## O que continua valendo

- **Critério de aceitação = teste.** O PR lista qual teste cobre cada critério.
- **Decisão que vale além da história** (arquitetura, stack, regra de negócio)
  vai para `docs/contexto.md` §11 no mesmo PR; mudou regra ou modelo de dados,
  atualize §7 ou §8.
- **Fora do escopo da história** vira issue nova no `backlog.yml`, não código a mais.
