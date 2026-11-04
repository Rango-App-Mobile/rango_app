# Restaurantes

**Escopo:** o fluxo 03 do Figma, "Encontrar o restaurante": localização com
permissão (Figma 09), restaurantes do Google Places no mapa (Figma 08 e 05) e
opções de contato (Figma 06), com "Pedir no delivery" e "Ligar" (issues
#15, #16, #17, #18 e #19).

As regras de produto vêm do §7 (R4 e R5), do §8 (coleção `restaurants`) e das
decisões de 2026-10-29 no §11 de `docs/contexto.md`. Este documento explica o
porquê das escolhas de implementação; não repete o contexto.

## O fluxo

| # | O que a pessoa faz | O que acontece |
|---|---|---|
| 1 | Toca "Ver restaurantes perto" no Deu match | `push('/restaurants?category=<id>')`. O `RestaurantsViewModel` acha a comida no `CategoryRepository` e mostra o mapa com o chip "Procurando <comida> perto de você" (Figma 08) |
| 2 | — | `LocationRepository.currentPosition()` confere se a localização do celular está ligada e pede a permissão **só agora**, ao chegar na busca. Negada, o mapa dá lugar à tela 09 |
| 3 | — | `RestaurantRepository.search()` chama o Places (Text Search) com o termo da comida (R3) e passa o resultado por `RestaurantRanking.rank` (R4: até 3 km, mais perto primeiro, no máximo 20) |
| 4 | Vê os pins (Figma 05) | O mais perto já vem selecionado: pin maior com balão "Nome ★ nota" e a prévia (Restaurant Card Row) na base. Os chips mostram a comida e "N lugares em até 3 km" |
| 5 | Toca outro pin | Ele vira o selecionado (só um por vez), a prévia troca e a foto do Places é buscada só para ele |
| 6 | Toca a prévia | `push('/restaurants/contact', extra: RestaurantContactArgs)`. O mapa continua na pilha |
| 7 | Vê "Como você quer pedir?" (Figma 06) | O `RestaurantContactViewModel` busca, em paralelo, o telefone (Place Details, só deste restaurante) e os links de delivery (`restaurants/{placeId}` no Firestore) |
| 8 | Toca "Pedir no delivery" | R5: link do iFood → primeiro outro link → busca "<nome> delivery" no Google. Abre fora do app |
| 9 | Toca "Ligar" | Abre o discador. Sem telefone, o botão não aparece |
| 10 | Volta | Do contato, `pop()` ao mapa com o mesmo pin selecionado. Do mapa, `go('/home')` |

## Mapa: Google ou desenhado

| Situação | Mapa | Restaurantes |
|---|---|---|
| `env.json` com a chave da plataforma | `GoogleRestaurantMap` (`google_maps_flutter`), com o estilo creme de `assets/map/rango_map_style.json` e os pins desenhados em `Canvas` | `PlacesRestaurantRepository` |
| Sem chave (clone novo, CI, testes) | `DrawnRestaurantMap`: fundo no estilo do Map base do Figma, pins como widgets na posição real em relação à pessoa | `FakeRestaurantRepository`: restaurantes fixos ao redor da pessoa |

Quem escolhe é `useGoogleMapProvider` (`lib/screens/restaurants/widgets/restaurant_map.dart`),
a partir de `Env.hasGoogleKey`. Os widget tests usam o mapa desenhado, que deixa
tocar nos pins; o `GoogleMap` é uma platform view e não roda em `flutter test`.

Por que não `flutter_map` (OpenStreetMap): a política do Places proíbe mostrar
os resultados num mapa que não seja do Google.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| R4: até 3 km, mais perto primeiro, no máximo 20 | `RestaurantRanking.rank` (`lib/models/`) | Teste unitário instantâneo; vale para o Places e para o fake |
| O mais perto abre selecionado | `RestaurantsViewModel` | Estado da tela |
| R5: iFood → outros → Google, só `https` | `deliveryUriFor` (`lib/models/delivery_links.dart`) | Regra pura; a tela só abre a `Uri` pronta |
| Só `https` e `tel` saem do app | `ExternalLinkLauncher` (`lib/data/`) | Última barreira antes do `url_launcher`, mesmo que a regra acima mude |
| Permissão pedida só na busca, posição nunca salva | `GeolocatorLocationRepository` | A posição vira `GeoPoint` e só vai para a busca |
| Telefone e foto só do restaurante escolhido | `RestaurantRepository.fetchPhone` / `fetchPhotoUri`, chamados pelos ViewModels | Cada chamada ao Places custa; a busca pede só os campos da lista (`X-Goog-FieldMask`) |
| Chave fora do git e restrita por app | `Env` + headers `X-Android-Package`/`X-Android-Cert`/`X-Ios-Bundle-Identifier` | A chave vai no app; a restrição no Google Cloud é o que a protege |

## Erros

| Situação | `Failure` | O que a tela mostra |
|---|---|---|
| Permissão negada | `LocationDeniedFailure` | Tela 09: "Permitir localização" (pede de novo) e "Abrir ajustes do celular" |
| Permissão negada para sempre | `LocationDeniedForeverFailure` | Tela 09 com "Abrir ajustes do celular" como ação principal |
| Localização do celular desligada | `LocationServiceDisabledFailure` | "Sua localização está desligada", com "Abrir ajustes de localização" |
| GPS não respondeu em 10 s | `UnexpectedFailure` | Erro com "Tentar de novo" e "Voltar ao início" |
| Sem rede ou timeout no Places | `NetworkFailure` | Erro com "Tentar de novo" e "Voltar ao início" |
| Places respondeu algo inesperado | `UnexpectedFailure` | Idem |
| Nenhum lugar a até 3 km | — | "Nenhum lugar perto", com "Tentar de novo" e "Voltar ao início" |
| Falha ao ler o Firestore | — (o repositório devolve `null`) | Nada: "Pedir no delivery" cai na busca no Google |
| Falha ao buscar telefone ou foto | — | "Ligar" some; o card usa a cor da comida |
| O celular não abre o link | — | SnackBar "Não deu para abrir. Tente de novo." |

## Configuração

### Chaves do Google (opcional para desenvolver)

Sem elas, o app roda com o mapa desenhado e restaurantes fake.

1. No [Google Cloud Console](https://console.cloud.google.com/), no projeto do
   Firebase do Rango, vincule uma conta de faturamento (obrigatório mesmo
   dentro da cota gratuita).
2. Em **APIs e serviços → Biblioteca**, ative **Maps SDK for Android**,
   **Maps SDK for iOS** e **Places API (New)**.
3. Em **Credenciais**, crie uma chave por plataforma e restrinja:
   - Android: app Android `br.senac.rango_app` + SHA-1 do keystore
     (`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`);
     APIs Maps SDK for Android e Places API (New).
   - iOS: app iOS `br.senac.rangoApp`; APIs Maps SDK for iOS e Places API (New).
4. No seu `env.json` (nunca no git), preencha `GOOGLE_ANDROID_API_KEY`,
   `GOOGLE_IOS_API_KEY` e `ANDROID_CERT_SHA1` (o mesmo SHA-1, com os `:`).

Como a chave chega ao nativo: o Flutter repassa os valores do
`--dart-define-from-file` como `DART_DEFINES`. No iOS, o `Info.plist` expõe
`DartDefines` e o `AppDelegate` só chama `GMSServices.provideAPIKey` se achar a
chave (sem ela o SDK derrubaria o app, por isso o Dart nem cria o `GoogleMap`).
No Android, o `build.gradle.kts` decodifica `dart-defines` para o
`manifestPlaceholders["mapsApiKey"]`.

### iOS usa CocoaPods

O `google_maps_flutter_ios` só é distribuído por CocoaPods, então o iOS agora
tem `ios/Podfile` (alvo mínimo iOS 15) ao lado do Swift Package Manager. Quem
roda no iOS precisa do `pod` instalado (`brew install cocoapods`); o
`flutter run` chama o `pod install` sozinho.

### Links de delivery no Firestore

Cadastrados à mão no console, um documento por restaurante, com o `placeId` do
Google como id:

```
restaurants/{placeId}
  deliveryLinks:
    ifood: "https://www.ifood.com.br/delivery/..."   # opcional
    others: ["https://..."]                           # opcional, em ordem de preferência
```

Para achar o `placeId` de um restaurante, use o
[Place ID Finder](https://developers.google.com/maps/documentation/places/web-service/place-id).
Só links `https` são usados; o resto é ignorado. As regras de segurança da
coleção (leitura para usuário autenticado, sem escrita pelo app) ficam na
E4-S2 (#22).

## Testes

| Arquivo | O que cobre |
|---|---|
| `test/models/geo_point_test.dart`, `restaurant_ranking_test.dart`, `delivery_links_test.dart` | Distância, R4 (corte em 3 km, ordem, limite de 20) e R5 (ordem e só `https`) |
| `test/data/geolocator_location_repository_test.dart` | Serviço desligado, permissão concedida, negada, negada para sempre, timeout do GPS, ajustes |
| `test/data/places_restaurant_repository_test.dart` | Requisição (método, caminho, field mask, corpo, chave e headers de restrição), mapeamento, entradas malformadas, raio, erros de rede e de resposta, telefone e foto |
| `test/data/firestore_delivery_link_repository_test.dart` | Leitura de `restaurants/{id}`, campos parciais, formatos inválidos, erro e timeout viram `null` |
| `test/data/external_link_launcher_test.dart` | Só `https` e `tel` saem do app |
| `test/data/fake_*_repository_test.dart` | Os fakes que rodam sem chave |
| `test/core/widgets/restaurant_card_test.dart`, `test/core/format/restaurant_format_test.dart` | Restaurant Card (Vertical e Row), chips, semântica, 375×667; formato de nota e distância |
| `test/screens/restaurants/` | ViewModel (estados, seleção, foto, ajustes) e tela (chip de busca, pins, troca de seleção, prévia → contato, recentralizar, 09, vazio, erro, 375×667), Map Pin |
| `test/screens/restaurant_contact/` | ViewModel (iFood, outros, Google, telefone) e tela (botões, "Ligar" sem telefone, sem "Abrir no mapa" nem histórico, voltar, 375×667) |
| `test/app/app_test.dart` | Fluxo swipe → Deu match → mapa → contato com os fakes |

**Sem teste automatizado:** o `GoogleRestaurantMap` (platform view) e a
abertura real de links e do discador. Roteiro manual com as chaves no
`env.json`: abrir o mapa, conferir o estilo creme e os pins na cor da comida,
tocar pins, recentralizar, abrir o contato, "Pedir no delivery" e "Ligar";
negar a permissão nos ajustes e voltar ao app para ver a tela 09.

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Salvar o restaurante e o canal no histórico; chip "Salvo no seu histórico" e "Ir para o histórico" | E2-S4 (#13), quando houver login |
| Lista de restaurantes como alternativa ao mapa | E3-S6 (#47) |
| App de delivery preferido nas preferências | E10-S3 (#66) |
| "Abrir no mapa" na tela 06 | Removido (decisão de 2026-10-29) |
| Tempo de entrega no card | O Places não informa; o chip fica oculto |
| Ícones do Figma (hoje Material Icons) | #52 |

## Pendências

- Regras do Firestore para `restaurants` (E4-S2, #22).
- Tirar "Abrir no mapa" da tela 06 no Figma (Produto/UX).
- O halo da localização pulsa só no mapa desenhado; no Google ele é fixo.
