# NNN — <título> · Plano

> Spec: [spec.md](spec.md) · Status: rascunho | aprovado

## Resumo técnico

<3–5 linhas: a abordagem escolhida e a principal alternativa descartada.>

## Camadas e arquivos afetados

| Camada | Arquivo | Novo / alterado | O que muda |
|---|---|---|---|
| model | `lib/models/...` | | |
| data | `lib/data/...` | | |
| view_model | `lib/screens/<tela>/<tela>_view_model.dart` | | |
| estado da tela | `lib/screens/<tela>/<tela>_state.dart` | | |
| view | `lib/screens/<tela>/<tela>_screen.dart` (+ `widgets/`) | | |
| app | `lib/app/router.dart` | | |

## Providers

| Provider | Tipo | Depende de | Quem observa |
|---|---|---|---|
| `xRepositoryProvider` | `Provider<XRepository>` | — | `XViewModel` |
| `xViewModelProvider` | `AsyncNotifierProvider<XViewModel, XState>` | `xRepositoryProvider` | `XScreen` |

## Modelo de dados

<Models `freezed` novos ou alterados, com campos. Coleções/campos do Firestore
tocados (e a atualização correspondente em `docs/contexto.md` §8). Formato de
request/response externo, se houver.>

## Testes

| Critério | Teste | Tipo |
|---|---|---|
| CA1 | `test/screens/<tela>/x_test.dart` ou `test/models/x_test.dart` — `'...'` | unit / view model / widget |

## Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| <ex.: cota do Places estourar em demo> | | |
