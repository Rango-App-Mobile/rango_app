# Rango — contexto do projeto

> **Fonte canônica** de produto, regras, arquitetura e decisões. Specs, rules, skills e PRs citam este
> arquivo **pela seção** (ex.: "contexto.md §7"). Mudou algo relevante? Atualize aqui no mesmo PR e
> registre em §11.
>
> Origem: [acordo de projeto](acordo-projeto.md) (v1.1). Responsável: Antônio Cláudio Costa Junior.

## Sumário

1. [Produto e dor](#1-produto-e-dor)
2. [Benchmark](#2-benchmark)
3. [Diferenciais](#3-diferenciais)
4. [Stack](#4-stack)
5. [Arquitetura](#5-arquitetura)
6. [Fluxo do MVP](#6-fluxo-do-mvp)
7. [Regras de negócio](#7-regras-de-negócio)
8. [Modelo de dados](#8-modelo-de-dados)
9. [Escopo: MVP vs. futuro](#9-escopo-mvp-vs-futuro)
10. [Cronograma e sprints](#10-cronograma-e-sprints)
11. [Decisões](#11-decisões)
12. [Em aberto](#12-em-aberto)

---

## 1. Produto e dor

Nos apps de delivery (iFood, Rappi, Uber Eats), o usuário precisa decidir **o que** comer antes de
decidir **onde** pedir. É nessa primeira etapa que está a maior fricção, a *decision fatigue*, que
piora quando a decisão é em grupo ("sei lá, você escolhe"). Os apps de delivery resolvem "onde
pedir", não "o que pedir".

**Objetivo:** resolver a etapa anterior ao pedido com uma sessão curta de escolhas binárias por
swipe. A sessão começa ampla (salgado vs. doce) e converge até um tipo de comida específico. No
mesmo fluxo, o app recomenda restaurantes reais e próximos que servem esse tipo, prontos para abrir
no delivery de preferência.

## 2. Benchmark

Nenhum concorrente direto junta as duas etapas (convergir o gosto e descobrir o restaurante real). Cada um resolve metade.

| App | Mecânica | Ponto forte | Lacuna que o Rango explora |
|---|---|---|---|
| WhatToEat — Food Picker | Swipe individual em pratos, filtros de dieta/orçamento | Onboarding visual, bons filtros | Para no "quero isso"; não acha restaurante; sem grupo |
| imdecisive | Sessão em grupo por código, swipe por categoria de refeição | Multiplayer nativo | Só EUA/Coreia; sem restaurante real |
| BiteSwipe (CleverCraft) | Swipe em grupo por restaurante real, filtros robustos | Fecha o loop no restaurante | Não converge o tipo de comida antes; tração ínfima |
| BiteSwipe (Allset) | Mesmo conceito do anterior | Confirma a validação do mercado | Nome duplicado, sem avaliações |
| Food Swipe | Sessão compartilhada até dar match num restaurante | Simples e social | Sem convergência de tipo; app novo |

O detalhamento completo está no [acordo](acordo-projeto.md#2-benchmark-de-concorrentes-diretos).

## 3. Diferenciais

- **Fluxo unificado:** convergência de gosto + restaurante real no mesmo fluxo.
- **Foco no Brasil:** nenhum concorrente tem presença ou catálogo aqui.
- **Sem cadastro:** autenticação anônima, então a sessão começa na hora.
- **Pronto para evoluir:** MVVM + Firebase desde o MVP permite adicionar o modo grupo sem redesenhar o backend.
- **Dados reais:** restaurantes via Google Places (endereço, distância, avaliação), não uma lista estática.

## 4. Stack

| Camada | Tecnologia | Função |
|---|---|---|
| Cliente | Flutter (Dart) | Código único iOS + Android |
| Estado | Riverpod | Camada ViewModel do MVVM (Notifier/AsyncNotifier) |
| Dados | Cloud Firestore | Sessões, histórico de escolhas, preferências |
| Auth | Firebase Authentication (anônima) | Identifica a sessão sem cadastro |
| Restaurantes | Google Places API | Restaurantes reais próximos por tipo de comida |
| Futuro | Cloud Functions | Orquestração do modo grupo em tempo real |

## 5. Arquitetura

MVVM com uma camada Repository/Service, organizada **por telas**: cada tela tem
a sua pasta com View e ViewModel lado a lado; models e repositórios ficam em
pastas compartilhadas, porque várias telas usam os mesmos dados.

```
lib/
├─ app/                 # MaterialApp, rotas (go_router), ThemeData (theme/app_theme.dart)
├─ core/                # config/env, erros (Failure), tokens do tema (theme/), widgets compartilhados
├─ models/              # dados do domínio, imutáveis, Dart puro (sem Flutter)
├─ data/                # repositórios/serviços: único lugar que fala com Firebase/HTTP/GPS
└─ screens/<tela>/
   ├─ <tela>_screen.dart      # View: renderiza o estado e captura interação
   ├─ <tela>_view_model.dart  # ViewModel: Notifier Riverpod (estado + ações da tela)
   ├─ <tela>_state.dart       # estado da tela (freezed), quando precisar
   └─ widgets/                # widgets usados só por essa tela
```

| Camada | Onde | Responsabilidade | Pode depender de | Não pode depender de |
|---|---|---|---|---|
| View | `screens/<tela>/<tela>_screen.dart` | Renderizar e capturar interação | o ViewModel da própria tela, models, `core/widgets` | `data/`, Firebase, HTTP |
| ViewModel | `screens/<tela>/<tela>_view_model.dart` | Estado da tela, orquestrar as ações | models, interfaces de `data/` | widgets, `BuildContext`, Firebase/HTTP diretamente, o ViewModel de outra tela |
| Model | `models/` | Dados imutáveis e regras de negócio (FoodCategory, CategoryTree, SwipeChoice, Session, Restaurant) | nada além de Dart | Flutter |
| Data | `data/` | Abstrair a origem dos dados (CategoryRepository, FirestoreRepository, PlacesService) | models, SDKs externos | `screens/` |

Telas previstas (numeração do Figma): `swipe` (01–03, Sprint 2), `result` (04)
e `restaurants` (05, 08, Sprint 3), `restaurant_contact` (06) e `login` (Sprint 4),
`history` (07, 10, Sprint 4), `history_detail` (12) e o Profile Sheet (11, Sprint 4–5).
A sessão anônima não tem tela: é um repositório em `data/`. Como montar a estrutura: [guia de setup](guia-setup.md), passo 3.

## 6. Fluxo do MVP

Telas em alta fidelidade e protótipo: [Figma do Rango](https://www.figma.com/design/s7aWG29SRZn5tjGGzY6svm)
(página 📱 Telas; design system e componentes nas páginas de Design System e Components).

1. O usuário abre o app como **visitante**: a sessão anônima é criada automaticamente, sem cadastro.
2. A primeira escolha é ampla (salgado vs. doce). Cada escolha seguinte, por toque ou arrastando o card, afunila (salgado → massa → macarrão).
3. Ao convergir num tipo específico ("Deu match!"), o app consulta o Google Places por restaurantes próximos que servem esse tipo.
4. O usuário vê os restaurantes **no mapa** (nome, nota, distância), escolhe um e decide como pedir: delivery, mapa ou ligação.
5. Quem **entra com conta** (pelo perfil) tem as decisões salvas no **Histórico**, estatísticas e preferências. O visitante usa o fluxo inteiro, mas nada dele é salvo.

## 7. Regras de negócio

> Preencher conforme as specs forem aprovadas. Cada regra cita a spec de origem.

- **R1:** toda sessão pertence a um usuário do Firebase Auth: anônimo (visitante) ou com conta. Só sessões de usuário com conta são salvas no Firestore; do visitante não se grava histórico, estatística nem preferência. *(E1, decisão de 2026-09-30)*
- **R2:** cada escolha avança exatamente um nível da árvore de categorias; a sessão termina numa folha. *(spec 001, a definir)*
- **R3:** cada folha da árvore tem um termo de busca para o Google Places. *(spec 001)*
- **R4:** a recomendação considera só restaurantes próximos à localização atual; o raio está em §12.

## 8. Modelo de dados

> Rascunho, a validar na spec de persistência (E2-S4).

```
users/{uid}                       # só usuário com conta (visitante não grava)
  createdAt
  preferences: { deliveryApp, notifications }
users/{uid}/sessions/{sessionId}
  startedAt, finishedAt
  choices: [{ level, optionA, optionB, chosen, at }]
  result: { categoryId, label, placesQuery }
  restaurant: { placeId, name, cuisine, rating }   # escolhido na tela de contato
  channel: delivery | map | call                   # alimenta o "Pedir de novo"
```

Árvore de categorias: começa como dado local versionado no app (`lib/data/`). Mover para o Firestore é decisão futura (§12).

## 9. Escopo: MVP vs. futuro

| MVP (fase 1) | Evolução futura |
|---|---|
| Sessão solo como visitante, sem cadastro | Sessão em grupo (vários usuários votando, via Firebase/Functions) |
| Entrar com conta (opcional) para salvar os rangos | Onboarding que sugere o login na primeira abertura |
| Convergência de gosto por swipe binário | Favoritos |
| Recomendação de restaurante via Google Places, no mapa | Lista de restaurantes como visualização alternativa ao mapa (Sprint 5) |
| Histórico de rangos, estatísticas e preferências (com conta) | Filtros avançados (preço, dieta, distância) e envio de notificações |

## 10. Cronograma e sprints

Sprints de **2 semanas**, sempre terminando na aula de review. O backlog de cada sprint está em
[`.github/backlog/backlog.yml`](../.github/backlog/backlog.yml) e no board do GitHub Projects.

| Aula | Data | Conteúdo previsto | Sprint |
|---|---|---|---|
| 01 | 06/08 | Contexto e simulação profissional | — |
| 02 | 13/08 | Formação das equipes e integração (conjunta) | — |
| 03 | 20/08 | Ideação e Design Thinking (conjunta) | — |
| 04 | 27/08 | Benchmarking, visão do produto e definição do MVP | — |
| 05 | 03/09 | Backlog e modelagem inicial | — |
| 06 | 10/09 | Arquitetura e planejamento da Sprint 1 (conjunta) | Planning S1 |
| 07 | 17/09 | Sprint 1: construção do primeiro incremento | S1 |
| 08 | 24/09 | Review e retrospectiva da Sprint 1 | Review S1 · Planning S2 |
| 09 | 01/10 | Sprint 2: evolução do fluxo principal | S2 |
| 10 | 08/10 | Review e retrospectiva da Sprint 2 | Review S2 · Planning S3 |
| 11 | 15/10 | Sprint 3: consolidação para o seminário | S3 |
| 12 | 22/10 | Seminário de andamento e Review da Sprint 3 (conjunta) | Review S3 · Planning S4 |
| 13 | 29/10 | Sprint 4: evolução orientada por feedback | S4 |
| 14 | 05/11 | Review da Sprint 4, estratégia e validação (conjunta) | Review S4 · Planning S5 |
| 15 | 12/11 | Sprint 5: consolidação funcional e técnica | S5 |
| 16 | 19/11 | Review e retrospectiva da Sprint 5 | Review S5 · Planning S6 |
| 17 | 26/11 | Sprint 6: estabilização e preparação do pitch | S6 |
| 18 | 03/12 | Apresentação final e encerramento da Sprint 6 (conjunta) | Review S6 |
| 19 | 10/12 | Feedback 360° e encerramento avaliativo | — |
| 20 | 17/12 | Fechamento dos conceitos e do diário de classe | — |

| Sprint | Período | Meta |
|---|---|---|
| 1 | 10/09 → 24/09 | Fundação: repo, gestão, arquitetura, frentes do time |
| 2 | 24/09 → 08/10 | Firebase + sessão anônima, árvore de categorias, swipe convergente; posicionamento e identidade |
| 3 | 08/10 → 22/10 | Localização + Places + lista: **fluxo completo para o seminário**; landing page e slides |
| 4 | 22/10 → 05/11 | Feedback do seminário: detalhe, abrir no delivery, persistência; pesquisa com usuários |
| 5 | 05/11 → 19/11 | Erros e estados vazios, regras do Firestore, testes; pré-lançamento |
| 6 | 19/11 → 03/12 | Estabilização, build de release, pitch e vídeo demo |

Rituais e frentes: [time-e-rituais.md](time-e-rituais.md).

## 11. Decisões

| Data | Decisão | Motivo |
|---|---|---|
| 2026-09-24 | ~~Organização feature-first dentro do MVVM~~ (substituída em 2026-09-28) | Cada pessoa pega uma feature com menos conflito de merge |
| 2026-09-24 | Backlog versionado em `backlog.yml` + GitHub Issues/Projects | Fonte única editável por PR, sincronizada por Actions |
| 2026-09-24 | Branches `main` (entregas) e `dev` (integração) | Mesmo fluxo do the-final-backend; `main` só recebe o que foi para review |
| 2026-09-24 | Firebase entra na Sprint 2, não no scaffold | O app deve compilar e passar no CI sem depender do projeto Firebase do time |
| 2026-09-24 | Time dividido em frentes (Dev, Marketing e divulgação, Produto/UX) | Divulgação e validação com usuários fazem parte da avaliação |
| 2026-09-28 | Branch padrão do repositório é a `dev` | O `Closes #N` só fecha issues em merge na branch padrão, e os PRs vão para a `dev` |
| 2026-09-28 | MVVM organizado **por telas** (`screens/<tela>/` com View + ViewModel), com `models/` e `data/` compartilhados; substitui o feature-first | Mais simples para o time entender: a pasta espelha o que o usuário vê. Dados são usados por várias telas, então não pertencem a uma só. Mesmo desenho da documentação oficial de arquitetura do Flutter |
| 2026-09-30 | Histórico entra no MVP (aba Home/Histórico, como no Figma) | O Figma de Produto/UX pôs o Histórico na navegação principal; é o que dá motivo para voltar ao app |
| 2026-09-30 | Visitante (anônimo) não salva nada; login opcional salva escolhas, histórico, estatísticas e preferências no Firebase | Separa quem só quer decidir agora de quem quer acompanhar os rangos. Onboarding sugerindo o login fica para o futuro |
| 2026-09-30 | Restaurantes aparecem primeiro no mapa; a lista vem depois só como outra visualização | Segue o Figma (tela 05); o mapa mostra na hora o que está perto |
| 2026-09-30 | A tela de detalhe do restaurante vira "Opções de contato" (delivery, mapa, ligar) | Segue o Figma (tela 06): a pessoa já escolheu, falta só decidir como pedir |
| 2026-10-15 | Tokens do design system em `lib/core/theme/` (ThemeExtensions `AppColors`, `AppTextStyles`, `FoodColors` e constantes `AppSpace`/`AppRadius`/`AppShadows`); `lib/app/theme/app_theme.dart` só monta o `ThemeData` | Os widgets compartilhados de `lib/core/widgets/` precisam dos tokens, e `core/` não importa `app/` |
| 2026-10-24 | O voltar das telas de escolha sai do fluxo e volta à Home com a sessão zerada (não desfaz a última escolha); a Tab Bar só aparece na Home (nível 1) e no Histórico | Segue a doc da Top Bar do Figma: o fluxo é curto (três escolhas) e recomeçar é mais simples que desfazer passo a passo. A Tab Bar some nas escolhas como no mock da tela 02 e na E8-S5 |
| 2026-10-24 | As chaves de API do Firebase saem do git e vêm do `env.json` (`FIREBASE_ANDROID_API_KEY`, `FIREBASE_IOS_API_KEY`); `google-services.json`, `GoogleService-Info.plist` e `firebase.json` não são mais versionados e o `firebase_options.dart` passa a ser escrito à mão. Sem as chaves o app roda com `FakeAuthRepository` | O secret scanning do GitHub abriu alertas para as chaves commitadas. Elas foram trocadas e restringidas por app no Google Cloud; mantê-las fora do git evita novos alertas e segue o padrão de `env.json` + `--dart-define-from-file` já previsto para chaves |
| 2026-10-24 | A `PLACES_API_KEY` sai do `env.example.json` e do `Env` até a história que trouxer a busca de restaurantes | O app ainda não usa o Places; nenhuma credencial fica configurada sem uso. A fonte dos restaurantes (Places ou base própria) volta a ser discutida nessa história |

## 12. Em aberto

- Integrantes e frente de cada um (reunião de 24/09 à noite).
- Raio de busca padrão e ordenação (distância vs. avaliação).
- Chamar o Places direto do app (chave restrita) ou via Cloud Function (proxy).
- Árvore de categorias local ou no Firestore (editável sem publicar o app).
- Como "abrir no delivery": deep link por app ou busca pelo nome no navegador.
- Pacote de mapa: `google_maps_flutter` (mesma conta do Places, chave por plataforma) ou `flutter_map` (OSM, sem chave).
- Método de login: e-mail, Google e/ou Apple (E6-S3 e E1-S3).
- O que as notificações avisam (a preferência existe no perfil; o envio é futuro).
- Fotos das comidas: licença das fotos do Figma ou banco próprio (E8-S7).
- Nome definitivo e identidade (frente de marketing, Sprint 2).
