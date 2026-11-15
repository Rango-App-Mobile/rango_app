# Splash e loading animado

O app abre sem "pulo" visual: a splash nativa e o loading em Flutter mostram o
mesmo xis sobre o mesmo fundo pistache (`#2F5D3A`), vindos do frame
**00 Loading** do Figma (nó `142:2228`).

## O que existe

- **Splash nativa** (`flutter_native_splash`, seção `flutter_native_splash:` do
  `pubspec.yaml`): cor `#2F5D3A` e o xis montado em `assets/splash/xis.png`
  (export do Figma em escala 4x, 402x470 pt). No Android 12+ a imagem fica
  dentro de uma máscara circular, então usa `assets/splash/xis_android12.png`
  (xis reduzido, com folga).
- **`RangoLoadingView`** (`lib/core/widgets/rango_loading_view.dart`): o xis
  montando em loop (4,7 s) sobre o pistache, com `message` opcional abaixo. É
  o estado de carregamento de `StartupScreen` e pode ser usado como overlay.
- **Movimento reduzido** (`MediaQuery.disableAnimations`): mostra o xis já
  montado, parado, sem rodar o controller.

## Como funciona a animação

Um único `AnimationController` (4700 ms, `repeat`) dirige tudo.

- `rango_loading_data.dart` descreve as camadas (SVGs em
  `assets/images/loading/`, posição, inclinação fixa) e os keyframes de cada
  uma, exportados do Figma (`get_motion_context`). **É um arquivo gerado**:
  não edite à mão; se o Figma mudar, exporte de novo.
- `rango_loading_motion.dart` tem os blocos reutilizáveis: `Track` (keyframes
  com easing por segmento), `SampledCurve` (as molas `linear(...)` do Figma),
  `LayerMotion`, `LoadingLayer` e `LoadingStroke`.
- Maionese e vapor são traços que "se desenham" (path-trim): o `d` do SVG fica
  embutido nos dados e é desenhado com `Path.computeMetrics()` + `extractPath`.

## Como regenerar a splash nativa

Depois de mudar `assets/splash/*` ou a seção no `pubspec.yaml`:

```bash
dart run flutter_native_splash:create
```

Os arquivos gerados em `ios/` e `android/` vão no commit.
