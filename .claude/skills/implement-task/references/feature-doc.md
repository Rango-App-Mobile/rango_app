# <Feature>

**Escopo:** <o que este documento cobre: telas, providers, coleções> (specs NNN,
MMM; issues #N).

As regras de produto vêm das seções <X, Y> de `docs/contexto.md`. Este documento
explica o porquê das escolhas de implementação; não repete o contexto.

## O fluxo

<Passo a passo do ponto de vista do usuário, com o que acontece em cada camada.
Tabela ou lista numerada.>

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| <ex.: todo nó não folha tem dois filhos> | `CategoryTree` (model) | <teste unitário barato; vale para Fake e Firestore> |
| <ex.: só o dono lê a sessão> | Security Rules do Firestore | <o cliente não é confiável> |

## Erros

| Situação | `Failure` | O que a tela mostra |
|---|---|---|
| <sem rede> | `NetworkFailure` | <...> |

## Testes

<Quais arquivos cobrem o quê. O que não é coberto por teste automatizado e como
se valida (roteiro manual).>

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| <ex.: cache offline da árvore> | <§9 futuro / issue #> |

## Pendências

- <o que ficou em aberto, com issue>
