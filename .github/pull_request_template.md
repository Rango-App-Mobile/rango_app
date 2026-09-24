## O que muda

<!-- Resumo em 1–3 linhas. Uma issue por PR. -->

Closes #

## Tipo

- [ ] Código do app (frente dev)
- [ ] Spec / documentação (docs/specs, docs/features, AGENTS.md, rules, skills)
- [ ] Marketing / produto (docs/marketing, assets)

## Checklist — código

- [ ] `dart format`, `flutter analyze` e `flutter test` passam localmente
- [ ] Segue a spec (`docs/specs/NNN-…`) ou explica abaixo por que não precisou
- [ ] View não tem lógica de negócio; ViewModel não importa Firebase/HTTP
- [ ] Testes novos para o comportamento novo (ViewModel e/ou repositório)
- [ ] Nenhum segredo no diff (chaves ficam em `env.json`, fora do git)
- [ ] Mudou modelo de dados/regra? `docs/contexto.md` atualizado
- [ ] História concluída? `docs/features/<feature>.md` criado/atualizado

## Checklist — docs/marketing

- [ ] Brief ou doc linkado na issue
- [ ] Revisado por alguém da frente

## Como testar

<!-- Passos para o revisor ver funcionando. Prints/vídeo para mudanças de UI. -->

## Observações
