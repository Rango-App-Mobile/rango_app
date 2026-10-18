## O que muda

<!-- Resumo em 1–3 linhas. Uma issue por PR. -->

Closes #

## Tipo

- [ ] Código do app (frente dev)
- [ ] Documentação (docs/, CLAUDE.md, AGENTS.md, .claude/)
- [ ] Marketing / produto (docs/marketing, assets)

## Critérios de aceitação cobertos

| CA | Teste |
|---|---|
| CA1 | `test/...` |

## Checklist — código

- [ ] `dart format --output=none --set-exit-if-changed .`, `flutter analyze` e `flutter test` passam (sem `env.json`)
- [ ] View não tem lógica de negócio; ViewModel não importa Firebase/HTTP
- [ ] Testes novos para o comportamento novo (ViewModel e/ou repositório)
- [ ] Mexeu em model? Gerados (`*.g.dart`, `*.freezed.dart`) no commit
- [ ] Dependência nova? Justificativa em Observações
- [ ] Nenhum segredo no diff (chaves ficam em `env.json`, fora do git)
- [ ] Mudou coleção/campo do Firestore? `docs/contexto.md` §8 atualizado
- [ ] Mudou decisão? `docs/contexto.md` §11 atualizado
- [ ] História concluída? `docs/<feature>.md` criado/atualizado

## Checklist — docs/marketing

- [ ] Brief ou doc linkado na issue
- [ ] Revisado por alguém da frente

## Como testar

<!-- Passos para o revisor ver funcionando. Prints/vídeo para mudanças de UI. -->

## Observações
