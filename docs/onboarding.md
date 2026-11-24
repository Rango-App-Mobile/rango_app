# Onboarding

**Escopo:** a tela `onboarding` (View e ViewModel), o `OnboardingRepository` com
`SharedPrefsOnboardingRepository` e `FakeOnboardingRepository`, o `redirect` do
router e a linha "Como funciona o app" no Profile Sheet.

As regras de produto vêm das seções §6 e §7 (R2 e R4) de `docs/contexto.md`.
Este documento explica o que foi entregue e por quê; não repete o contexto.

No Figma, as telas estão na seção "07 · Onboarding" da página "📱 Telas", com os
keyframes de cada animação nos próprios frames.

## O que a pessoa vê

| # | Quando | O que aparece |
| --- | --- | --- |
| 1 | Primeira abertura do app | O onboarding em tela cheia, antes da Home |
| 2 | Qualquer outro dia | Nada: a Home abre direto |
| 3 | Perfil → **Como funciona o app** | O mesmo onboarding, de novo, por cima do app |

São três páginas, com barra de progresso no topo, "Pular" (some na última) e o
botão "Próximo" (na última, "Começar"). Dá para arrastar as páginas também.

| Página | Mensagem | Animação (em loop enquanto a página está na tela) |
| --- | --- | --- |
| 1 · Doce ou salgado? | A primeira escolha define a lista de comidas | Os cards Salgado e Doce entram; um toque simulado escolhe o Salgado e o Doce recua |
| 2 · Curta ou passe | Direita curte, esquerda passa, três curtidas na mesma comida dão match (R2) | Mostra todos os estados em sequência: curtir (carimbo "Curti!", sai pela direita), passar (carimbo "Passo!", sai pela esquerda), curtir e curtir de novo. O Like Meter sobe a cada curtida até 3 e entra o "Deu match!" com confete |
| 3 · Rango de Porto Alegre | Os restaurantes são locais, até 3 km (R4) | Os pins caem um a um e o card do restaurante sobe da base |

O restaurante da página 3 (Cantina da Nona) é ilustrativo: nada vem do Firestore.

## Como funciona

- **Lembrar que já viu.** `OnboardingRepository.hasSeen` é síncrono e guarda um
  `bool` no aparelho (`shared_preferences`). Local de propósito: o visitante
  anônimo não grava nada online (R1). O `main()` lê o `SharedPreferences` uma
  vez e sobrescreve o provider, assim o `redirect` do router decide a primeira
  rota sem esperar. O padrão do provider é o `FakeOnboardingRepository`, que
  começa como "já visto": testes e um clone sem configuração nunca caem no
  onboarding.
- **Primeira abertura.** O `redirect` do `GoRouter` leva a `/onboarding` enquanto
  `hasSeen` for falso. Usa `ref.read`, não `watch`, para `markSeen` não
  reconstruir o router.
- **Terminar.** "Começar" e "Pular" chamam `finish()` (que marca como visto).
  Depois, se existe rota para voltar (`context.canPop()`, o caso do Perfil), faz
  `pop`; senão (primeira abertura) vai para `/home`. Não há parâmetro entre os dois
  casos.
- **Um relógio só.** A tela tem um `AnimationController` que gira em loop e é
  compartilhado entre a ilustração da página atual e a barra de progresso. As
  animações leem o tempo em segundos (`seg`/`lerp` em `widgets/clock_builder.dart`)
  com os mesmos números dos keyframes do Figma.
- **Reduzir Movimento.** Com a opção ligada, o relógio fica parado no fim da
  animação (página 2 mostra o Like Meter cheio e o "Deu match!") e o "Próximo"
  troca de página sem animar (`jumpToPage`: `animateToPage` recusa duração zero).
- **Acessibilidade.** As ilustrações são decorativas (`ExcludeSemantics`); o título
  e o subtítulo dizem o mesmo. A barra de progresso fala "Passo N de 3".

## Dívidas conhecidas

- A página 2 importa `LikeMeter` e `SwipeButton` de `screens/swipe/widgets/`, e a
  página 3 importa `MapPin` e `DrawnRestaurantMap` de
  `screens/restaurants/widgets/`. Só widgets, nunca ViewModel, mas o ideal é
  subir esses quatro para `lib/core/widgets/` quando uma terceira tela precisar
  deles.
- Sugerir o login no onboarding continua na história E7-S4, fora deste escopo.
