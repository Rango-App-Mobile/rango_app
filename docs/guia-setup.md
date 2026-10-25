# Guia de setup — Rango

Passo a passo para transformar o clone vazio de `rango_app` num projeto Flutter
com arquitetura MVVM, Riverpod, testes, CI verde e o processo SDD
(spec → plan → tasks) pronto para a Sprint 2.

**Para quem:** quem vai fazer o primeiro PR de código do repositório. O resto do
time só precisa ler as seções 3 (estrutura) e 5 (SDD).

**O que sai no fim:** um PR `chore/setup-flutter` → `dev` com o app rodando uma
tela de escolhas binárias sobre dados falsos, testes de model, ViewModel e
widget, e os arquivos que orientam humanos e agentes (`AGENTS.md`,
`.claude/`, `docs/specs/`, `docs/sdd.md`).

**O que fica de fora de propósito:** Firebase, Google Places e permissão de
localização. Cada um tem a sua história (ver [Próximos passos](#próximos-passos)).

> Validado em 24/09/2026 com **Flutter 3.44.4 (stable) / Dart 3.12.2**. As
> versões de pacote citadas são as que o `flutter pub add` resolveu nesse dia;
> as suas podem ser mais novas. Não copie versão deste guia para o
> `pubspec.yaml`: deixe o `pub add` escolher.

## Como ler cada passo

| Bloco | O que é |
|---|---|
| **Objetivo** | O que existe no fim do passo |
| **Comandos** | Um comando por bloco, sempre a partir da raiz do repositório |
| **Arquivos** | O que criar ou substituir, com o conteúdo |
| **Por quê** | A decisão por trás, em poucas linhas |
| **✅ Checkpoint** | Como provar que deu certo antes de seguir |
| **Commit** | Mensagem sugerida (Conventional Commits, em inglês) |

## Visão geral

| Passo | Resultado | Commits |
|---|---|---|
| 0 | Ferramentas ok, branch criada a partir de `dev` | — |
| 1 | Projeto Flutter inicializado, lints estritos, contador removido | 2 |
| 2 | Dependências do MVP instaladas (sem Firebase) | 1 |
| 3 | Estrutura MVVM por telas + exemplo da tela de swipe com testes | 3 |
| 4 | Configuração por ambiente e segredos fora do git | 1 |
| 5 | `AGENTS.md`, `CLAUDE.md`, `.claude/`, templates e processo SDD | 4 |
| 6 | PR aberto para `dev`, CI verde, revisão | — |

---

## Passo 0 — Pré-requisitos

**Objetivo:** máquina pronta e branch `chore/setup-flutter` criada a partir de
um `dev` atualizado.

Instale, se ainda não tiver:

| Ferramenta | Para quê |
|---|---|
| Flutter SDK (canal stable) | Compilar e testar o app |
| Xcode + CocoaPods (só macOS) | Rodar no simulador iOS |
| Android Studio (SDK + emulador) | Rodar no Android |
| VS Code + extensões Dart e Flutter | Editor sugerido (`launch.json` no passo 4) |
| `gh` (GitHub CLI), autenticado | Abrir PR e usar a skill `sprint-status` |

**Comandos**

```bash
flutter doctor
```

```bash
flutter --version
```

```bash
cd ~/Desktop/Projects/Rango
```

```bash
git fetch origin
```

```bash
git switch dev
```

```bash
git pull
```

```bash
git switch -c chore/setup-flutter
```

**Por quê**

- Todo trabalho sai de `dev` e volta para `dev` por PR. `main` só recebe as
  entregas de cada sprint review.
- Anote a versão do Flutter: todos do time devem estar na mesma versão *minor*
  (ex.: 3.44.x). O `flutter create` grava no `pubspec.yaml` um `sdk: ^3.12.x`
  que colegas (e o CI) com Flutter mais antigo não conseguem resolver.

> Se `git switch dev` responder que a branch não existe, o `dev` ainda não foi
> criado no remoto. Peça para quem configurou o repositório criar (a partir de
> `main`) antes de seguir; não crie o setup direto em `main`.

**✅ Checkpoint**

- `flutter doctor` sem `✗` nas linhas Flutter, Android toolchain e Xcode (no
  macOS). Avisos `!` de IDEs que você não usa podem ficar.
- `git branch --show-current` imprime `chore/setup-flutter`.
- `git log --oneline -1` mostra o último commit de `dev`.

---

## Passo 1 — Inicializar o Flutter no clone existente

**Objetivo:** projeto Flutter criado na raiz do repositório, sem sobrescrever o
que já existe, com lints estritos e sem o app de contador.

### 1.1 Criar o projeto

```bash
flutter create --org br.senac --project-name rango_app --platforms android,ios .
```

| Flag | Efeito | Por quê |
|---|---|---|
| `.` | Cria na pasta atual | O repositório já existe e tem `docs/` e `.github/`; não queremos uma subpasta |
| `--project-name rango_app` | Nome do pacote Dart | Sem ela o Flutter usaria o nome da pasta, `Rango`. Nome de pacote Dart precisa ser minúsculo com `_`, então `Rango` é inválido e o comando falha |
| `--org br.senac` | Prefixo dos identificadores | Gera `br.senac.rango_app` no Android e `br.senac.rangoApp` no iOS (o iOS não aceita `_`; o Flutter converte para camelCase) |
| `--platforms android,ios` | Só mobile | Sem pastas `web/`, `macos/`, `windows/`, `linux/` para manter, e a chave do Places é restrita por app (passo 4) |

**O que o comando não toca:** o `flutter create` não sobrescreve arquivos que já
existem (a sobrescrita exige `--overwrite`). `README.md`, `docs/`, `.github/`
continuam iguais. Isso vale também para o `.gitignore`: se o repositório já
tinha um, o do Flutter **não** é criado. Confira:

```bash
git status
```

```bash
git diff .gitignore
```

Se o `.gitignore` já existia, acrescente ao final dele as entradas que o Flutter
precisa:

```gitignore
# Flutter/Dart
.dart_tool/
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/
/coverage/
**/ios/Flutter/.last_build_id
**/doc/api/
app.*.symbols
app.*.map.json
/android/app/debug
/android/app/profile
/android/app/release

# IDE
*.iml
*.ipr
*.iws
.idea/
.DS_Store
```

Os arquivos `.idea/` e `rango_app.iml` que o comando cria ficam ignorados. O
`.metadata` **deve** ser versionado: o Flutter usa para migrações futuras.

Edite a linha `description:` do `pubspec.yaml`:

```yaml
description: "Rango: escolhas binárias que viram restaurante perto de você."
```

**Commit**

```bash
git add .
```

```bash
git commit -m "chore: bootstrap flutter project for android and ios"
```

### 1.2 Trocar `flutter_lints` por `very_good_analysis`

```bash
flutter pub remove flutter_lints
```

```bash
flutter pub add dev:very_good_analysis
```

Substitua o `analysis_options.yaml` inteiro:

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"

linter:
  rules:
    # App, não pacote publicado: doc comment obrigatório em todo membro
    # público vira ruído. Documente o porquê onde ele não é óbvio.
    public_member_api_docs: false
    # Repositório começa com um método só (fetchAll) e cresce depois.
    # A interface existe para trocar Fake por Firestore, não por tamanho.
    one_member_abstracts: false
```

**Por quê**

- `flutter_lints` é o mínimo. `very_good_analysis` liga ~200 regras (tipos
  explícitos onde importa, `avoid_print`, imports com `package:`, ordem de
  dependências no `pubspec.yaml`). Com 2–4 pessoas e revisão entre colegas,
  deixar a ferramenta pegar estilo libera a revisão para lógica.
- Os arquivos gerados (`*.g.dart`, `*.freezed.dart`) são excluídos: não foram
  escritos por ninguém do time e não devem gerar aviso.
- Cada versão *major* do `very_good_analysis` liga regras novas. Atualizar é um
  PR próprio, não algo que acontece de carona.

### 1.3 Remover o app de contador

Substitua `lib/main.dart` por um placeholder (o passo 3 substitui de novo):

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('Rango'))),
    ),
  );
}
```

Apague o teste do contador:

```bash
rm test/widget_test.dart
```

Crie `test/smoke_test.dart`, só para provar que a toolchain de testes roda (ele
é apagado no passo 3, quando chegam os testes de verdade):

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toolchain runs tests', () {
    expect(1 + 1, 2);
  });
}
```

**✅ Checkpoint**

```bash
flutter analyze
```

Deve terminar em `No issues found!`.

```bash
flutter test
```

Deve terminar em `All tests passed!`.

```bash
flutter run
```

Abre um emulador/simulador com "Rango" no centro da tela.

**Commit**

```bash
git add .
```

```bash
git commit -m "chore: adopt very_good_analysis and remove counter template"
```

---

## Passo 2 — Dependências

**Objetivo:** pacotes do MVP instalados, **sem Firebase**.

| Pacote | Tipo | Para quê | Camada que usa |
|---|---|---|---|
| `flutter_riverpod` | app | Estado e injeção de dependência: os Notifiers **são** os ViewModels | view_model, view, providers de data |
| `go_router` | app | Rotas declarativas; `redirect` vai proteger telas quando existir auth | app |
| `freezed_annotation` | app | Anotações dos models imutáveis (`copyWith`, `==`, `toString`) | model |
| `json_annotation` | app | Anotações de (de)serialização JSON (Firestore e Places devolvem mapas) | model |
| `dio` | app | Cliente HTTP do Places: interceptors, timeout, cancelamento | data |
| `geolocator` | app | Posição do usuário para buscar restaurantes próximos | data |
| `url_launcher` | app | Abrir rota no Maps / telefone do restaurante | view |
| `build_runner` | dev | Executa os geradores de código | — |
| `freezed` | dev | Gera `*.freezed.dart` | — |
| `json_serializable` | dev | Gera `*.g.dart` (`fromJson`/`toJson`) | — |
| `mocktail` | dev | Mocks sem codegen para testes | test |

**Comandos**

```bash
flutter pub add flutter_riverpod
```

```bash
flutter pub add go_router
```

```bash
flutter pub add freezed_annotation
```

```bash
flutter pub add json_annotation
```

```bash
flutter pub add dio
```

```bash
flutter pub add geolocator
```

```bash
flutter pub add url_launcher
```

```bash
flutter pub add dev:build_runner
```

```bash
flutter pub add dev:freezed
```

```bash
flutter pub add dev:json_serializable
```

```bash
flutter pub add dev:mocktail
```

Confira qual `freezed` foi resolvido:

```bash
grep -A5 "name: freezed$" pubspec.lock
```

Em 24/09/2026, com Flutter 3.44, o `pub add` escolheu `4.0.0-dev.3` (uma
pré-release), porque o `freezed 4.0.x` estável exige um `analyzer` mais novo do
que o Flutter 3.44 permite. Se o seu `version:` terminar em `-dev`, fixe a
última estável que resolve:

```bash
flutter pub add "dev:freezed:^3.2.0"
```

Por fim, **ordene as dependências em ordem alfabética** no `pubspec.yaml` (o
`pub add` só acrescenta ao final, e a regra `sort_pub_dependencies` do
`very_good_analysis` reclama). Deve ficar parecido com isto (versões podem ser
mais novas):

```yaml
dependencies:
  cupertino_icons: ^1.0.8
  dio: ^5.11.1
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.4.3
  freezed_annotation: ^3.1.0
  geolocator: ^14.0.3
  go_router: ^18.0.1
  json_annotation: ^4.12.0
  url_launcher: ^6.3.2

dev_dependencies:
  build_runner: ^2.15.1
  flutter_test:
    sdk: flutter
  freezed: ^3.2.0
  json_serializable: ^6.14.1
  mocktail: ^1.0.5
  very_good_analysis: ^10.3.0
```

```bash
flutter pub get
```

**Por quê**

- **Riverpod sem codegen (`riverpod_generator`).** Já temos um gerador
  (`freezed`); um segundo aumenta o tempo de build e esconde a API. Com
  `Notifier`/`AsyncNotifier` escritos à mão, o provider é uma linha e quem está
  aprendendo vê exatamente o que acontece.
- **Riverpod 3.** A API mudou em relação a tutoriais antigos (2.x): não existe
  mais `StateNotifier`/`StateNotifierProvider` no pacote principal,
  `ProviderContainer.test()` existe para testes, e providers que falham são
  **refeitos automaticamente** (retry) por padrão. Desconfie de exemplo da
  internet anterior a 2025.
- **Firebase fica para a história da Sprint 2.** `firebase_core`,
  `firebase_auth` e `cloud_firestore` exigem rodar `flutterfire configure`
  contra o projeto Firebase **do time**, que gera `firebase_options.dart`,
  `google-services.json` e `GoogleService-Info.plist`. Sem isso o app não
  inicializa. Colocar agora deixaria o `main` quebrado para quem clonar antes do
  projeto Firebase existir, e o setup precisa compilar em qualquer máquina e no
  CI sem credencial nenhuma. Enquanto isso, os repositórios têm implementação
  `Fake` (passo 3).
- **Permissões do `geolocator` ficam para a Sprint 3.** O pacote instala, mas
  pedir localização exige `NSLocationWhenInUseUsageDescription` no
  `ios/Runner/Info.plist` e `ACCESS_COARSE_LOCATION`/`ACCESS_FINE_LOCATION` no
  `android/app/src/main/AndroidManifest.xml`. Isso entra com a história de
  restaurantes próximos, junto com o texto de justificativa que a Produto/UX
  escrever.

**✅ Checkpoint**

```bash
flutter pub get
```

Termina em `Got dependencies!`.

```bash
flutter analyze
```

`No issues found!` (se aparecer `sort_pub_dependencies`, a ordem ainda não
está alfabética).

**Commit**

```bash
git add pubspec.yaml pubspec.lock
```

```bash
git commit -m "chore: add riverpod, go_router, freezed, dio and test dependencies"
```

---

## Passo 3 — Estrutura MVVM por telas

**Objetivo:** pastas no lugar, regras de import claras e uma fatia vertical
funcionando (a tela de escolhas sobre dados falsos) com teste em cada camada.

### 3.1 A árvore

```
lib/
  main.dart                       só runApp(ProviderScope(...))
  app/
    app.dart                      MaterialApp.router + tema
    router.dart                   GoRouter exposto por provider
    theme/app_theme.dart          ThemeData do app
  core/                           infraestrutura compartilhada
    config/env.dart               valores de --dart-define (passo 4)
    error/failure.dart            erros que o ViewModel sabe mostrar
    widgets/                      widgets reutilizáveis sem regra de negócio
  models/                         dados do domínio, usados por várias telas
    food_category.dart
    category_tree.dart            regra de convergência
  data/                           repositórios e services (Firebase, HTTP, GPS)
    category_repository.dart      interface + provider
    fake_category_repository.dart
  screens/                        uma pasta por tela: View + ViewModel
    swipe/
      swipe_screen.dart           View
      swipe_view_model.dart       ViewModel (+ provider)
      swipe_state.dart            estado da tela (freezed)
test/                             espelha lib/ (mesmo caminho, sufixo _test)
  models/category_tree_test.dart
  screens/swipe/swipe_view_model_test.dart
  screens/swipe/swipe_screen_test.dart
```

**Por que por telas:** quem abre o projeto encontra o app do jeito que o usuário
vê: cada tela é uma pasta com a sua View e o seu ViewModel, lado a lado. O que
é **dado** (models) e **acesso a dado** (repositórios) não pertence a uma tela
só: a categoria escolhida no swipe é lida pela tela de resultado e pela de
restaurantes. Por isso `models/` e `data/` ficam compartilhados. É o mesmo
desenho da documentação oficial de arquitetura do Flutter.

Telas previstas: as de `docs/contexto.md` §5, com a numeração do Figma (`swipe`,
`result`, `restaurants`, `restaurant_contact`, `login`, `history`, `history_detail`). A pasta de uma tela nasce com a história dela.
O login anônimo não tem tela: é um repositório em `data/`.

**Nomes dentro da pasta de uma tela** (`lib/screens/<tela>/`):

| Arquivo | Papel |
|---|---|
| `<tela>_screen.dart` | View: o widget da tela |
| `<tela>_view_model.dart` | ViewModel (`Notifier`/`AsyncNotifier`) e o provider dele |
| `<tela>_state.dart` | Estado da tela, `freezed`, quando for mais que um valor simples |
| `widgets/` | Widgets usados só por essa tela |

```bash
mkdir -p lib/app/theme lib/core/config lib/core/error lib/core/widgets lib/models lib/data lib/screens/swipe
```

```bash
mkdir -p test/models test/screens/swipe
```

O git não versiona pasta vazia: elas entram no commit junto com os primeiros
arquivos (3.3 em diante).

### 3.2 Quem pode importar quem

| Onde | Pode importar | Não pode importar | Por quê |
|---|---|---|---|
| `models/` | Dart puro, `freezed_annotation`, `json_annotation`, outros `models/` | `package:flutter/*`, Riverpod, Firebase, `dio`, `data/`, `screens/` | É a regra de negócio. Dart puro roda em teste unitário instantâneo e não muda quando a UI muda |
| `data/` | `models/`, Riverpod (para declarar o provider do repositório), Firebase, `dio`, `geolocator`, `core/` | `screens/`, `package:flutter/material.dart` | Traduz o mundo externo (Firestore, HTTP, GPS) em models e `Failure`. Nenhuma tela sabe que Firestore existe |
| `screens/<tela>/<tela>_view_model.dart` | `models/`, a **interface** e o provider de `data/`, Riverpod, `core/`, o `<tela>_state.dart` | Firebase, `dio`, `geolocator`, widgets, `BuildContext` | O ViewModel guarda o estado da tela e decide o que acontece. Sem Firebase/HTTP direto, o teste troca o repositório por um fake com um `override` |
| `screens/<tela>/<tela>_screen.dart` e `widgets/` | o ViewModel **da própria tela**, `models/` (para ler), `core/widgets/`, Flutter, `url_launcher` | `data/`, Firebase, `dio` | Widget só desenha o estado e repassa gestos ao ViewModel. Regra de negócio em widget só é testável com teste de widget, que é lento |
| `screens/A/` | `models/`, `data/` (interfaces), `core/` | o ViewModel de `screens/B/` | Uma tela não controla outra. O que passa de uma tela para a seguinte vai pela rota (parâmetro) ou por um provider em `data/`, decidido no plano da história |
| `app/` | tudo acima | — | É a composição: rotas, tema, `ProviderScope` |
| `core/` | Dart, Flutter (só em `core/widgets/`) | `models/`, `data/`, `screens/` | Infraestrutura não pode depender do domínio nem de uma tela |

### 3.3 Models: `FoodCategory` e `CategoryTree`

`lib/models/food_category.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_category.freezed.dart';
part 'food_category.g.dart';

/// One node of the choice tree. A node with no children is a food type
/// the app can search for on Google Places.
@freezed
abstract class FoodCategory with _$FoodCategory {
  const factory FoodCategory({
    required String id,
    required String label,
    String? parentId,
    String? placesKeyword,
  }) = _FoodCategory;

  factory FoodCategory.fromJson(Map<String, dynamic> json) =>
      _$FoodCategoryFromJson(json);
}
```

A lista é plana (cada nó aponta para o pai via `parentId`) porque é assim que
ela vai morar numa coleção do Firestore. A árvore é montada em memória:

`lib/models/category_tree.dart`

```dart
import 'package:rango_app/models/food_category.dart';

/// Immutable view over the flat category list. Holds the convergence rule:
/// every non-leaf node has exactly two children (a binary choice).
class CategoryTree {
  CategoryTree(List<FoodCategory> categories)
    : _byParent = _groupByParent(categories) {
    final roots = _byParent[null] ?? const [];
    if (roots.length != 1) {
      throw ArgumentError(
        'Tree must have exactly one root, got ${roots.length}',
      );
    }
    root = roots.single;
    for (final entry in _byParent.entries) {
      if (entry.key != null && entry.value.length != 2) {
        throw ArgumentError('Node ${entry.key} must have exactly 2 children');
      }
    }
  }

  late final FoodCategory root;
  final Map<String?, List<FoodCategory>> _byParent;

  List<FoodCategory> childrenOf(FoodCategory node) =>
      _byParent[node.id] ?? const [];

  bool isLeaf(FoodCategory node) => childrenOf(node).isEmpty;

  static Map<String?, List<FoodCategory>> _groupByParent(
    List<FoodCategory> categories,
  ) {
    final map = <String?, List<FoodCategory>>{};
    for (final category in categories) {
      map.putIfAbsent(category.parentId, () => []).add(category);
    }
    return map;
  }
}
```

Notas:

- No `freezed` 3 a classe precisa ser `abstract class` (ou `sealed class`) com
  `with _$Nome`. Sem o `abstract`, o erro é "Missing concrete implementation".
- Os nomes do documento de arquitetura (`SwipeChoice`, `Session`, `Restaurant`)
  chegam em `models/` com as histórias que precisam deles. Não crie model sem
  uso.

Gere o código:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Durante o desenvolvimento, deixe o gerador rodando em outro terminal:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

**Versione os arquivos gerados** (`*.freezed.dart`, `*.g.dart`). O CI roda só
`dart format`, `flutter analyze` e `flutter test`, sem `build_runner`; se os
gerados não estiverem no commit, o CI não compila. Para que eles apareçam
recolhidos no diff do PR, crie `.gitattributes` na raiz:

```gitattributes
*.g.dart linguist-generated=true
*.freezed.dart linguist-generated=true
```

### 3.4 Data: interface, fake e provider

`lib/data/category_repository.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/models/food_category.dart';

abstract interface class CategoryRepository {
  Future<List<FoodCategory>> fetchAll();
}

/// Swapped for the Firestore implementation in the Sprint 2 story.
/// Tests override this provider; nobody instantiates a repository directly.
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => FakeCategoryRepository(),
);
```

`lib/data/fake_category_repository.dart`

```dart
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/models/food_category.dart';

class FakeCategoryRepository implements CategoryRepository {
  static const seed = [
    FoodCategory(id: 'root', label: 'O que bate hoje?'),
    FoodCategory(id: 'savory', label: 'Salgado', parentId: 'root'),
    FoodCategory(id: 'sweet', label: 'Doce', parentId: 'root'),
    FoodCategory(id: 'pasta', label: 'Massa', parentId: 'savory'),
    FoodCategory(
      id: 'burger',
      label: 'Hambúrguer',
      parentId: 'savory',
      placesKeyword: 'hamburgueria',
    ),
    FoodCategory(
      id: 'spaghetti',
      label: 'Macarrão',
      parentId: 'pasta',
      placesKeyword: 'restaurante italiano',
    ),
    FoodCategory(
      id: 'pizza',
      label: 'Pizza',
      parentId: 'pasta',
      placesKeyword: 'pizzaria',
    ),
    FoodCategory(
      id: 'ice_cream',
      label: 'Sorvete',
      parentId: 'sweet',
      placesKeyword: 'sorveteria',
    ),
    FoodCategory(
      id: 'cake',
      label: 'Bolo',
      parentId: 'sweet',
      placesKeyword: 'confeitaria',
    ),
  ];

  @override
  Future<List<FoodCategory>> fetchAll() async => seed;
}
```

**Por quê:** o fake devolve `Future` mesmo tendo os dados em memória, porque o
Firestore vai devolver `Future`. Assim o ViewModel já nasce assíncrono e a troca
para `FirestoreCategoryRepository` (spec 001) muda uma linha: o corpo do
provider.

### 3.5 A tela de swipe: estado e ViewModel

O estado pertence à tela (é o que ela desenha), então mora na pasta dela.

`lib/screens/swipe/swipe_state.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';

part 'swipe_state.freezed.dart';

@freezed
abstract class SwipeState with _$SwipeState {
  const factory SwipeState({
    required FoodCategory current,
    required List<FoodCategory> options,
    @Default(<FoodCategory>[]) List<FoodCategory> history,
    FoodCategory? result,
  }) = _SwipeState;

  const SwipeState._();

  bool get hasConverged => result != null;
}
```

`const SwipeState._();` é o que permite getters próprios (`hasConverged`). Rode
o `build_runner` de novo depois de criar este arquivo.

`lib/screens/swipe/swipe_view_model.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/models/category_tree.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_state.dart';

final swipeViewModelProvider =
    AsyncNotifierProvider<SwipeViewModel, SwipeState>(SwipeViewModel.new);

class SwipeViewModel extends AsyncNotifier<SwipeState> {
  late CategoryTree _tree;

  @override
  Future<SwipeState> build() async {
    final categories = await ref.watch(categoryRepositoryProvider).fetchAll();
    _tree = CategoryTree(categories);
    return _initialState();
  }

  void choose(FoodCategory option) {
    final current = state.requireValue;
    if (current.hasConverged || !current.options.contains(option)) return;

    final history = [...current.history, option];
    state = AsyncData(
      _tree.isLeaf(option)
          ? current.copyWith(
              history: history,
              options: const [],
              result: option,
            )
          : current.copyWith(
              current: option,
              options: _tree.childrenOf(option),
              history: history,
            ),
    );
  }

  void reset() => state = AsyncData(_initialState());

  SwipeState _initialState() =>
      SwipeState(current: _tree.root, options: _tree.childrenOf(_tree.root));
}
```

Pontos para quem está aprendendo:

- O ViewModel é um `AsyncNotifier` do Riverpod: é ele que faz o papel de
  ViewModel do MVVM. `Async` porque o estado inicial depende de I/O; a View
  recebe `AsyncValue<SwipeState>` e desenha carregando/erro/dados sem `if`
  manual.
- `build()` usa `ref.watch` no repositório: se o provider do repositório mudar
  (ex.: override em teste), o ViewModel se reconstrói.
- O estado **nunca é mutado**: `[...current.history, option]` e `copyWith` criam
  objetos novos. O Riverpod só notifica a View quando a referência muda.
- A regra de convergência (dois filhos por nó) mora no model (`CategoryTree`), e
  não aqui. O ViewModel orquestra; o model decide.

### 3.6 View, router e app

`lib/screens/swipe/swipe_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

class SwipeScreen extends ConsumerWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(swipeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rango')),
      body: Center(
        child: session.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => const Text('Não deu para carregar as opções.'),
          data: (state) => switch (state.result) {
            final result? => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Bora de ${result.label}!'),
                TextButton(
                  onPressed: () =>
                      ref.read(swipeViewModelProvider.notifier).reset(),
                  child: const Text('Recomeçar'),
                ),
              ],
            ),
            null => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.current.label),
                for (final option in state.options)
                  ElevatedButton(
                    onPressed: () => ref
                        .read(swipeViewModelProvider.notifier)
                        .choose(option),
                    child: Text(option.label),
                  ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
```

`ref.watch` no `build` para **ler estado**; `ref.read(...notifier)` dentro do
callback para **disparar ação**. Os botões são provisórios: o gesto de swipe
(cartas) é a história "swipe convergente" e troca só a View, porque o ViewModel
já expõe `choose`.

`lib/app/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    colorSchemeSeed: const Color(0xFFE85D04),
  );
}
```

A cor é placeholder até a frente de Marketing definir a identidade visual
(`docs/marketing/identidade.md`).

`lib/app/router.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';

/// Provider (not a global) so the auth story can add a `redirect`
/// that watches the auth state later.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SwipeScreen(),
      ),
    ],
  );
});
```

`lib/app/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/app/router.dart';
import 'package:rango_app/app/theme/app_theme.dart';

class RangoApp extends ConsumerWidget {
  const RangoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rango',
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
```

`lib/main.dart` (substitui o placeholder do passo 1)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/app/app.dart';

void main() {
  runApp(const ProviderScope(child: RangoApp()));
}
```

`lib/core/error/failure.dart`

```dart
/// Errors the ViewModel knows how to show. Repositories translate
/// Firebase/HTTP exceptions into one of these; the View never sees raw ones.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Algo deu errado.']);
}
```

`sealed` faz o compilador exigir que um `switch` sobre `Failure` trate todos os
casos: quando alguém criar `LocationDeniedFailure`, toda tela que mostra erro
aponta onde falta tratar.

`core/widgets/` ainda está vazia; ela entra no git quando ganhar o primeiro
widget compartilhado.

**Commit**

```bash
git add lib .gitattributes
```

```bash
git commit -m "feat(swipe): add category tree, fake repository and swipe screen (#4)"
```

### 3.7 Testes

Apague o smoke test do passo 1:

```bash
rm test/smoke_test.dart
```

`test/models/category_tree_test.dart` (unitário, Dart puro)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/models/category_tree.dart';
import 'package:rango_app/models/food_category.dart';

void main() {
  group('CategoryTree', () {
    final tree = CategoryTree(FakeCategoryRepository.seed);

    test('exposes the single root and its two children', () {
      expect(tree.root.id, 'root');
      expect(tree.childrenOf(tree.root).map((c) => c.id), ['savory', 'sweet']);
    });

    test('treats a node without children as a leaf', () {
      const pizza = FoodCategory(
        id: 'pizza',
        label: 'Pizza',
        parentId: 'pasta',
      );
      expect(tree.isLeaf(pizza), isTrue);
    });

    test('rejects a node with a number of children other than two', () {
      expect(
        () => CategoryTree(const [
          FoodCategory(id: 'root', label: 'Root'),
          FoodCategory(id: 'only', label: 'Only child', parentId: 'root'),
        ]),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON', () {
      const category = FoodCategory(
        id: 'cake',
        label: 'Bolo',
        parentId: 'sweet',
      );
      expect(FoodCategory.fromJson(category.toJson()), category);
    });
  });
}
```

`test/screens/swipe/swipe_view_model_test.dart` (ViewModel com
`ProviderContainer` e repositório trocado)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

FoodCategory _byId(String id) =>
    FakeCategoryRepository.seed.firstWhere((c) => c.id == id);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
      ],
    );
  });

  test('starts at the root with its two options', () async {
    final state = await container.read(swipeViewModelProvider.future);

    expect(state.current.id, 'root');
    expect(state.options.map((c) => c.id), ['savory', 'sweet']);
    expect(state.hasConverged, isFalse);
  });

  test('converges after choosing down to a leaf', () async {
    await container.read(swipeViewModelProvider.future);
    container.read(swipeViewModelProvider.notifier)
      ..choose(_byId('savory'))
      ..choose(_byId('pasta'))
      ..choose(_byId('pizza'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.result?.id, 'pizza');
    expect(state.history.map((c) => c.id), ['savory', 'pasta', 'pizza']);
  });

  test('ignores an option that is not currently offered', () async {
    await container.read(swipeViewModelProvider.future);
    container.read(swipeViewModelProvider.notifier).choose(_byId('pizza'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.current.id, 'root');
    expect(state.history, isEmpty);
  });

  test('reset goes back to the root and clears history', () async {
    await container.read(swipeViewModelProvider.future);
    container.read(swipeViewModelProvider.notifier)
      ..choose(_byId('sweet'))
      ..reset();

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.current.id, 'root');
    expect(state.history, isEmpty);
  });

  test('exposes the error when the repository fails', () async {
    final repository = _MockCategoryRepository();
    when(repository.fetchAll).thenThrow(Exception('offline'));
    final failing = ProviderContainer.test(
      overrides: [categoryRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );

    await expectLater(
      failing.read(swipeViewModelProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}
```

- `ProviderContainer.test()` descarta o container sozinho no fim do teste.
- `retry: (_, _) => null` desliga o retry automático do Riverpod 3; sem isso o
  teste de erro fica esperando novas tentativas.
- O fake serve para o caminho feliz; o mock (`mocktail`) serve para forçar o
  que o fake não faz, como falhar.

`test/screens/swipe/swipe_screen_test.dart` (widget)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';

void main() {
  testWidgets('walks the choices until a food type', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            FakeCategoryRepository(),
          ),
        ],
        child: const MaterialApp(home: SwipeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salgado'));
    await tester.pump();
    await tester.tap(find.text('Massa'));
    await tester.pump();
    await tester.tap(find.text('Pizza'));
    await tester.pump();

    expect(find.text('Bora de Pizza!'), findsOneWidget);
  });
}
```

O override é explícito mesmo o provider já devolvendo o fake: quando o padrão
virar Firestore, este teste continua sem rede.

**✅ Checkpoint**

```bash
dart format .
```

```bash
flutter analyze
```

`No issues found!`

```bash
flutter test
```

`All tests passed!` com 10 testes.

```bash
flutter run
```

Tela "O que bate hoje?" com Salgado/Doce; Salgado → Massa → Pizza mostra
"Bora de Pizza!" e "Recomeçar" volta ao início.

**Commit**

```bash
git add test
```

```bash
git commit -m "test(swipe): cover category tree, swipe view model and swipe screen (#4)"
```

`git status` deve estar limpo agora. Se o `dart format .` mudou algo em `lib/`,
inclua no commit acima antes de seguir (`git add lib` e
`git commit --amend --no-edit`, que é seguro porque nada foi para o remoto
ainda).

---

## Passo 4 — Configuração por ambiente e segredos

**Objetivo:** a chave do Google Places entra no app em tempo de compilação, sem
nunca ir para o git, e o app compila sem ela.

> **Atualização (2026-10-24):** a `PLACES_API_KEY` saiu do `env.example.json` e
> do `Env`: o app ainda não consulta o Places e não deve existir credencial sem
> uso. Hoje o `env.json` tem só as chaves do Firebase (`docs/auth.md`). O
> mecanismo abaixo continua valendo: a chave volta, documentada, na história
> que trouxer a busca de restaurantes.

`env.example.json` (versionado, na raiz; documenta o que existe)

```json
{
  "PLACES_API_KEY": ""
}
```

Acrescente ao `.gitignore`:

```gitignore
# Segredos locais (ver docs/guia-setup.md, passo 4)
env.json
.env*
```

Crie a sua cópia local e preencha quando tiver a chave:

```bash
cp env.example.json env.json
```

`lib/core/config/env.dart`

```dart
/// Compile-time configuration injected with `--dart-define-from-file`.
abstract final class Env {
  static const placesApiKey = String.fromEnvironment('PLACES_API_KEY');

  static bool get hasPlacesKey => placesApiKey.isNotEmpty;
}
```

Rodar com o arquivo:

```bash
flutter run --dart-define-from-file=env.json
```

```bash
mkdir -p .vscode
```

`.vscode/launch.json` (versionado; o `.gitignore` do Flutter deixa `.vscode/`
fora do ignore de propósito)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "rango (debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": ["--dart-define-from-file=env.json"]
    }
  ]
}
```

No Android Studio: *Run → Edit Configurations → Additional run args* com
`--dart-define-from-file=env.json`.

**Por quê**

- `String.fromEnvironment` é resolvido na compilação e vira constante. Não há
  arquivo `.env` lido em runtime nem pacote extra.
- Sem `env.json` (CI, colega que acabou de clonar) o valor é `''`. O app
  compila e roda; só a busca de restaurantes deve mostrar erro quando
  `Env.hasPlacesKey` for falso. **Nunca** faça o app quebrar no boot por falta
  da chave: o CI não tem chave.
- Trocou o `env.json`? Hot reload não pega. Pare e rode de novo.

> **A chave do Places no app não é segredo de verdade.** Tudo que é compilado
> no app pode ser extraído do APK/IPA. Por isso:
>
> 1. No Google Cloud Console, restrinja a chave por **API** (só *Places API
>    (New)*) e por **aplicativo**: Android com o pacote `br.senac.rango_app` +
>    SHA-1 do certificado; iOS com o bundle `br.senac.rangoApp`. Como cada chave
>    aceita um tipo de restrição de app, use **uma chave por plataforma**.
> 2. Configure cota diária e alerta de orçamento no projeto do Google Cloud.
> 3. Chamada REST (via `dio`) com chave restrita por app precisa mandar os
>    headers de identificação do app (`X-Android-Package`/`X-Android-Cert`,
>    `X-Ios-Bundle-Identifier`). Confirme na documentação do Places quando a
>    história chegar: esses headers podem ser forjados, então a restrição
>    reduz abuso, mas não o impede.
> 4. **O caminho definitivo é um proxy em Cloud Functions** (futuro, ver
>    `docs/contexto.md` §9 e §12): o app chama a função autenticada pelo
>    Firebase, e só a função conhece a chave. Quando isso existir,
>    `PLACES_API_KEY` sai do app.

**✅ Checkpoint**

```bash
git status --ignored
```

`env.json` aparece na lista de ignorados; `env.example.json` aparece como novo.

```bash
git check-ignore -v env.json
```

Mostra a linha do `.gitignore` que ignora o arquivo.

```bash
flutter analyze
```

`No issues found!`

**Commit**

```bash
git add .gitignore env.example.json lib/core/config/env.dart .vscode/launch.json
```

```bash
git commit -m "chore: add compile-time env config and keep secrets out of git"
```

---

## Passo 5 — SDD: arquivos para humanos e agentes

> **Já feito no repositório.** Os arquivos deste passo foram criados a partir
> dos blocos abaixo (com pequenos ajustes no `AGENTS.md` e no PR template).
> Use esta seção para entender o que cada um faz e rode só o checkpoint do
> fim. Se mudar uma regra, mude no arquivo real, não aqui.

**Objetivo:** o repositório explica sozinho como trabalhar nele. Qualquer
pessoa, ou agente (Claude Code, Codex, Cursor, Copilot), lê as mesmas regras,
e toda história passa por spec → plan → tasks antes de virar código.

### Mapa dos arquivos

Estrutura igual à do the-final-backend: um `CLAUDE.md` completo na raiz, regras
por tecnologia em `.claude/rules/` e skills com `SKILL.md` + `references/`. Tudo
que é para agente está **em inglês**; os docs do projeto seguem em português.

| Arquivo | Quem lê | Função |
|---|---|---|
| `CLAUDE.md` | Claude Code e o time | Instruções do repositório: contexto (aponta para `docs/contexto.md` por seção), comandos, estrutura, stack, regras que valem em qualquer arquivo, workflow |
| `AGENTS.md` | outros agentes (Codex, Cursor, Copilot) | Aponta para o `CLAUDE.md` e resume o inegociável |
| `.claude/settings.json` | Claude Code | O que roda sem pedir, o que pergunta, o que não pode ser lido (`env.json`, `.env*`) |
| `.claude/rules/dart.md` | `lib/**/*.dart`, `test/**/*.dart` | Nomes, estilo, async, erros, testes |
| `.claude/rules/flutter.md` | `lib/**` | Camadas MVVM, limites de import, widgets |
| `.claude/rules/riverpod.md` | `lib/screens/**/*_view_model.dart` | Notifiers, estado imutável, overrides |
| `.claude/rules/firebase.md` | `lib/data/**` | Repositórios, Firestore, Places, localização |
| `.claude/skills/pr-review-rango/` | revisão de PR | `SKILL.md` + `references/checklist.md` |
| `.claude/skills/security-review-rango/` | revisão de segurança | `SKILL.md` + `references/{vulnerability-checklist,known-deliberate}.md` |
| `.claude/skills/spec-feature/` | escrever spec | `SKILL.md` + moldes `references/{spec,plan,tasks}.md` |
| `.claude/skills/implement-task/` | implementar task | `SKILL.md` + molde `references/feature-doc.md` |
| `.claude/skills/sprint-status/` | status da sprint por frente | `SKILL.md` |
| `.claude/skills/marketing-brief/` | brief de marketing | `SKILL.md` (molde em `docs/marketing/briefs/_template.md`) |
| `docs/sdd.md` | o time | Ciclo spec → plan → tasks e quando a spec é obrigatória |
| `docs/specs/NNN-slug/` | quem especifica | Nasce com a primeira spec |
| `docs/<feature>.md` | quem entrega a feature | Um arquivo por feature, como os domínios do backend |

Leia os arquivos direto; eles são a fonte. Mudou uma regra? Mude no arquivo, no
mesmo PR que motivou a mudança.

**✅ Checkpoint do passo 5**

```bash
find CLAUDE.md AGENTS.md .claude docs/sdd.md -type f | sort
```

Deve listar todos os arquivos acima.

```bash
python3 -m json.tool .claude/settings.json
```

Imprime o JSON sem erro.

```bash
head -3 .claude/rules/*.md
```

Todo arquivo começa com `---` e `paths:` (string ou lista).

Se usa Claude Code: abra uma sessão na raiz e peça "quais regras se aplicam a
`lib/screens/swipe/swipe_view_model.dart`?". Ele deve citar `riverpod.md`, `flutter.md` e
`dart.md`. Digite `/` e confira se as skills do projeto
aparecem.

**Commits**

```bash
git add AGENTS.md CLAUDE.md
```

```bash
git commit -m "docs: add AGENTS.md and CLAUDE.md with repository rules"
```

```bash
git add .claude/settings.json .claude/rules
```

```bash
git commit -m "chore(claude): add permissions and path-scoped rules"
```

```bash
git add .claude/skills
```

```bash
git commit -m "chore(claude): add project skills for sdd, review and sprint status"
```

```bash
git add CLAUDE.md AGENTS.md .claude docs/sdd.md
```

```bash
git commit -m "docs: add sdd process, spec templates and pr template"
```

---

## Passo 6 — Primeiro PR

**Objetivo:** PR `chore/setup-flutter` → `dev` aberto, CI verde, revisado.

Rode exatamente o que o CI roda:

```bash
dart format --output=none --set-exit-if-changed .
```

Saída `0 changed`. Se reclamar, rode `dart format .`, confira o diff e faça
commit (`style: apply dart format`).

```bash
flutter analyze
```

```bash
flutter test --coverage
```

Confira que nada sensível entrou:

```bash
git log --oneline dev..HEAD
```

```bash
git diff --stat dev...HEAD
```

`env.json` **não** pode aparecer. `env.example.json` sim.

Suba e abra o PR:

```bash
git push -u origin chore/setup-flutter
```

```bash
gh pr create --base dev --title "chore: set up flutter project, mvvm structure and sdd" --web
```

O `--web` abre o navegador com o template preenchível. Na descrição:

- **O que muda:** inicialização do Flutter (android/ios), lints, dependências
  do MVP sem Firebase, estrutura MVVM por telas com a tela de swipe sobre
  dados falsos, env via `--dart-define-from-file`, arquivos de SDD.
- **Spec:** "Não precisa (chore)".
- **Observações:** Firebase e permissões de localização ficaram de fora de
  propósito (ver `docs/guia-setup.md` §2); versão do Flutter usada.

Acompanhe o CI:

```bash
gh pr checks --watch
```

**Por quê:** este é o primeiro PR com `pubspec.yaml`, então é a primeira vez
que os passos de Flutter do `.github/workflows/ci.yml` rodam de verdade. Se o
CI falhar por versão do SDK (`The current Dart SDK version is ...`), a versão
do Flutter no workflow é mais antiga que a sua: alinhe com quem mantém o CI
em vez de baixar o `sdk:` do `pubspec.yaml` no escuro.

**Revisão:** peça a um dev do time. Sugestão de roteiro para quem revisa (15
minutos):

1. Clonar a branch, `flutter pub get`, `flutter test`, `flutter run`.
2. Ler `AGENTS.md` e `docs/sdd.md` inteiros: são o contrato do time.
3. Conferir a tabela de imports (§3.2 deste guia) contra o código de `swipe`.

Merge conforme `docs/git-e-prs.md`.

**✅ Checkpoint**

- `gh pr checks` todo verde.
- 1 aprovação.
- Depois do merge, em outra pasta:

```bash
gh repo clone "$(gh repo view --json nameWithOwner -q .nameWithOwner)" /tmp/rango-check -- --branch dev
```

```bash
cd /tmp/rango-check
```

```bash
flutter pub get
```

```bash
flutter test
```

Um clone limpo de `dev` passa nos testes sem `env.json` e sem rodar
`build_runner`. É isso que prova que o setup funciona para o resto do time.

---

## Próximos passos

Histórias da Sprint 2, nesta ordem (as duas primeiras podem andar em
paralelo):

| # | História | Spec | O que traz |
|---|---|---|---|
| 1 | **Firebase + autenticação anônima** | `002-anonymous-auth` | Projeto Firebase do time; `flutterfire configure`; `firebase_core`, `firebase_auth`, `cloud_firestore`; `Firebase.initializeApp` no `main`; `AuthRepository` + `authStateProvider`; `redirect` no `routerProvider` |
| 2 | **Árvore de categorias** | `001-category-tree` | Coleção de categorias no Firestore (§8); `FirestoreCategoryRepository` no lugar do fake no provider; script/seed da árvore; Security Rules só de leitura |
| 3 | **Swipe convergente** | `003-convergent-swipe` | Gesto de swipe (cartas) no lugar dos botões; models `SwipeChoice` e `Session`; persistir a sessão do usuário anônimo |

Comandos que a história 1 vai usar (não rode agora):

```bash
dart pub global activate flutterfire_cli
```

```bash
flutterfire configure --project=<id-do-projeto-firebase> --platforms=android,ios
```

> **Atualização (2026-10-24):** o projeto Firebase já existe e o
> `flutterfire configure` **não deve mais ser rodado**: ele grava as chaves de
> API literais no código. As chaves agora vêm do `env.json`
> (`FIREBASE_ANDROID_API_KEY`, `FIREBASE_IOS_API_KEY`) e o
> `firebase_options.dart` é escrito à mão. Veja `docs/auth.md`, seção
> "Configuração do Firebase", e `docs/contexto.md` §11.

```bash
flutter pub add firebase_core firebase_auth cloud_firestore
```

Comece a Sprint 2 pela spec 001: use a skill `spec-feature` (ou copie os
templates à mão) e abra o PR da spec antes de qualquer código.

Na Sprint 3: `restaurants` (Places via `dio`, permissões do `geolocator` no
`Info.plist`/`AndroidManifest.xml`, restrição da chave, §4).

---

## Troubleshooting

| Sintoma | Causa provável | Solução |
|---|---|---|
| `"Rango" is not a valid Dart package name` | Faltou `--project-name` | Rode o `flutter create` com `--project-name rango_app` |
| `.gitignore` sem as entradas do Flutter; `build/` e `.dart_tool/` aparecendo no `git status` | O repositório já tinha `.gitignore` e o `flutter create` não sobrescreve | Acrescente o bloco do §1.1 |
| `flutter test` falha com `Failed to find ".../flutter_tester"` | Cache do SDK incompleto | `flutter precache --force`; se persistir, apague `<flutter>/bin/cache` e rode `flutter doctor` |
| `pub get` reclama de `The current Dart SDK version is X` | Flutter mais antigo que o `sdk:` do `pubspec.yaml` | Atualize o Flutter (`flutter upgrade`) para a versão do time |
| `freezed` resolvido como `-dev` | Estável mais novo incompatível com o Flutter atual | `flutter pub add "dev:freezed:^3.2.0"` (§2) |
| `Missing concrete implementation of ...` / `_$X` não encontrado | Classe freezed sem `abstract`, `part` com nome errado, ou gerador não rodou | Confira `abstract class X with _$X`, `part 'x.freezed.dart';` igual ao nome do arquivo, e rode `build_runner build --delete-conflicting-outputs` |
| `build_runner` diz que há "conflicting outputs" | Gerados antigos | Sempre use `--delete-conflicting-outputs` |
| CI falha no `dart format` e local passa | Você não rodou `dart format .` depois de editar, ou regenerou após formatar | `dart format .` como último passo antes do commit |
| `Bad state: No ProviderScope found` | Widget testado ou app sem `ProviderScope` | `main.dart` e todo `testWidgets` embrulham com `ProviderScope` |
| Teste de erro do ViewModel não termina | Retry automático do Riverpod 3 | `ProviderContainer.test(retry: (_, _) => null)` |
| `Env.placesApiKey` vazio | Rodou sem `--dart-define-from-file`, ou fez hot reload depois de mudar `env.json` | Use a configuração do `launch.json` e reinicie o app (não hot reload) |
| `sort_pub_dependencies` no analyze | `pub add` acrescentou fora de ordem | Ordene `dependencies` e `dev_dependencies` alfabeticamente |
| iOS: erro de CocoaPods no `flutter run` | CocoaPods ausente ou repositório de specs velho | `brew install cocoapods`, depois `cd ios && pod install --repo-update` |
| Android: `Android license status unknown` | Licenças não aceitas | `flutter doctor --android-licenses` |
