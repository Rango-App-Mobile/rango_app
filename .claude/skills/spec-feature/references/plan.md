# NNN — <título> · Plano

> Spec: [spec.md](spec.md) · Status: rascunho | aprovado

## Resumo técnico

<3–5 linhas: a abordagem escolhida e a principal alternativa descartada.>

## Camadas e arquivos afetados

| Camada | Arquivo | Novo / alterado | O que muda |
|---|---|---|---|
| model | `lib/features/<f>/model/...` | | |
| data | `lib/features/<f>/data/...` | | |
| view_model | `lib/features/<f>/view_model/...` | | |
| view | `lib/features/<f>/view/...` | | |
| app | `lib/app/router.dart` | | |

## Providers

| Provider | Tipo | Depende de | Quem observa |
|---|---|---|---|
| `xRepositoryProvider` | `Provider<XRepository>` | — | `XNotifier` |
| `xProvider` | `AsyncNotifierProvider<XNotifier, XState>` | `xRepositoryProvider` | `XScreen` |

## Modelo de dados

<Models `freezed` novos ou alterados, com campos. Coleções/campos do Firestore
tocados (e a atualização correspondente em `docs/contexto.md` §8). Formato de
request/response externo, se houver.>

## Testes

| Critério | Teste | Tipo |
|---|---|---|
| CA1 | `test/features/<f>/.../x_test.dart` — `'...'` | unit / notifier / widget |

## Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| <ex.: cota do Places estourar em demo> | | |
