# Restaurantes

**Escopo:** o fluxo 03 do Figma, "Encontrar o restaurante": localização com
permissão (Figma 09), restaurantes no mapa (Figma 08 e 05) e opções de contato
(Figma 06), com "Pedir no delivery" e "Ligar" (issues #15, #16, #17, #18 e #19).

**Os restaurantes ainda são fictícios.** O mapa é real, mas os lugares vêm do
`FakeRestaurantRepository`. Os restaurantes do time entram com a E3-S7.

As regras de produto vêm do §7 (R4 e R5), do §8 (coleção `restaurants`) e das
decisões de 2026-11-05 no §11 de `docs/contexto.md`. Este documento explica o
porquê das escolhas de implementação; não repete o contexto.

## O fluxo

| # | O que a pessoa faz | O que acontece |
|---|---|---|
| 1 | Toca "Ver restaurantes perto" no Deu match | `push('/restaurants?category=<id>')`. O `RestaurantsViewModel` acha a comida no `CategoryRepository` e mostra o mapa com o chip "Procurando <comida> perto de você" (Figma 08) |
| 2 | — | `LocationRepository.currentPosition()` confere se a localização do celular está ligada e pede a permissão **só agora**, ao chegar na busca. Negada, o mapa dá lugar à tela 09 |
| 3 | — | `RestaurantRepository.search()` monta os restaurantes fictícios ao redor da pessoa e passa o resultado por `RestaurantRanking.rank` (R4: até 3 km, mais perto primeiro, no máximo 20) |
| 4 | Vê os pins (Figma 05) | O mais perto já vem selecionado: pin maior com balão "Nome ★ nota" e a prévia (Restaurant Card Row) na base. Os chips mostram a comida e "N lugares em até 3 km" |
| 5 | Toca outro pin | Ele vira o selecionado (só um por vez), a prévia troca e o mapa centraliza nele. A prévia usa a foto da comida |
| 6 | Toca a prévia | `push('/restaurants/contact', extra: RestaurantContactArgs)`. O mapa continua na pilha |
| 7 | Vê "Como você quer pedir?" (Figma 06) | O `RestaurantContactViewModel` busca, em paralelo, o telefone (fictício, só em parte dos lugares) e os links de delivery (`restaurants/{placeId}` no Firestore) |
| 8 | Toca "Pedir no delivery" | R5: link do iFood → primeiro outro link → busca "<nome> delivery" no Google. Abre fora do app |
| 9 | Toca "Ligar" | Abre o discador. Sem telefone, o botão não aparece |
| 10 | Volta | Do contato, `pop()` ao mapa com o mesmo pin selecionado. Do mapa, `go('/home')` |

## Mapa: OpenStreetMap ou desenhado

| Situação | Mapa |
|---|---|
| Com a posição da pessoa | `OsmRestaurantMap`: `flutter_map` com o OpenStreetMap, nas cores originais, e os pins e a pessoa como widgets (`MapPin`, `UserLocationMarker`) |
| Enquanto o GPS responde | `DrawnRestaurantMap`: fundo no estilo do Map base do Figma, sem rede |
| Widget tests da tela | `DrawnRestaurantMap`, escolhido por `useTileMapProvider` (`lib/screens/restaurants/widgets/restaurant_map.dart`) |

Por que OpenStreetMap: o Google exige uma forma de pagamento cadastrada mesmo
dentro da cota gratuita, e o OpenStreetMap não pede chave nem cartão.

O servidor público do OpenStreetMap tem [regras de uso](https://operations.osmfoundation.org/policies/tiles/):
o app se identifica com `userAgentPackageName`, mostra o crédito (`MapCredit`) e
usa o cache embutido do `flutter_map`. Não há garantia de disponibilidade. Se o
servidor ficar fora do ar, os pins continuam aparecendo sobre um fundo liso.
Trocar de provedor é mudar a URL em `osm_restaurant_map.dart`.

O crédito fica na tela, e não dentro do mapa, porque só a tela sabe o que está
por cima: ele aparece acima da prévia, ao lado do botão de centralizar.

## Onde cada regra mora

| Regra | Onde é garantida | Por quê ali |
|---|---|---|
| R4: até 3 km, mais perto primeiro, no máximo 20 | `RestaurantRanking.rank` (`lib/models/`) | Teste unitário instantâneo; vale para o Places e para o fake |
| O mais perto abre selecionado | `RestaurantsViewModel` | Estado da tela |
| R5: iFood → outros → Google, só `https` | `deliveryUriFor` (`lib/models/delivery_links.dart`) | Regra pura; a tela só abre a `Uri` pronta |
| Só `https` e `tel` saem do app | `ExternalLinkLauncher` (`lib/data/`) | Última barreira antes do `url_launcher`, mesmo que a regra acima mude |
| Permissão pedida só na busca, posição nunca salva | `GeolocatorLocationRepository` | A posição vira `GeoPoint` e só vai para a busca |
| Telefone e foto só do restaurante escolhido | `RestaurantRepository.fetchPhone` / `fetchPhotoUri`, chamados pelos ViewModels | Contrato mantido para a E3-S7; hoje o fake não devolve foto |

## Erros

| Situação | `Failure` | O que a tela mostra |
|---|---|---|
| Permissão negada | `LocationDeniedFailure` | Tela 09: "Permitir localização" (pede de novo) e "Abrir ajustes do celular" |
| Permissão negada para sempre | `LocationDeniedForeverFailure` | Tela 09 com "Abrir ajustes do celular" como ação principal |
| Localização do celular desligada | `LocationServiceDisabledFailure` | "Sua localização está desligada", com "Abrir ajustes de localização" |
| GPS não respondeu em 10 s | `UnexpectedFailure` | Erro com "Tentar de novo" e "Voltar ao início" |
| Sem rede para baixar o mapa | — | Os pins aparecem sobre o fundo liso; o mapa volta quando a rede voltar |
| Nenhum lugar a até 3 km | — | "Nenhum lugar perto", com "Tentar de novo" e "Voltar ao início" |
| Falha ao ler o Firestore | — (o repositório devolve `null`) | Nada: "Pedir no delivery" cai na busca no Google |
| Falha ao buscar telefone ou foto | — | "Ligar" some; o card usa a cor da comida |
| O celular não abre o link | — | SnackBar "Não deu para abrir. Tente de novo." |

## Configuração

### Mapa

Não há nada para configurar: o mapa não usa chave nem conta. Só precisa de
internet.

### iOS e CocoaPods

O `ios/Podfile` continua no projeto, hoje só com o pod do Flutter. Quem roda no
iOS ainda precisa do `pod` instalado (`brew install cocoapods`); o `flutter run`
chama o `pod install` sozinho.

### Links de delivery no Firestore

Cadastrados à mão no console, um documento por restaurante, com o `placeId` do
restaurante como id. Com os lugares fictícios, os ids são `fake-0`, `fake-1` etc.:

```
restaurants/{placeId}
  deliveryLinks:
    ifood: "https://www.ifood.com.br/delivery/..."   # opcional
    others: ["https://..."]                           # opcional, em ordem de preferência
```

Só links `https` são usados; o resto é ignorado. As regras de segurança da
coleção (leitura para usuário autenticado, sem escrita pelo app) ficam na
E4-S2 (#22).

### Sincronização da planilha

A planilha [restaurantes](https://docs.google.com/spreadsheets/d/1Wct3C90S9gJr21CMIERYt2uC27NPNv5idFiwdhmYnlQ/edit)
é a fonte dos restaurantes reais. Um Google Apps Script instalado nela grava a
aba principal em `restaurants`, uma vez por dia de madrugada ou na hora, pelo
menu **Rango > Sincronizar agora**. O resultado aparece na aba **Sincronização**.
Uma alteração feita hoje só chega ao app na próxima rodada, se ninguém usar o
botão. O app ainda não lê esses dados: a troca do `FakeRestaurantRepository` faz
parte da E3-S7.

O código fica em `tools/restaurant_sync/`, que é a fonte: uma mudança passa por
PR e depois é copiada para o editor do Apps Script.

| Na planilha | O que acontece |
|---|---|
| Linha nova ou alterada | Grava no Firestore; o que não mudou não é regravado |
| Linha apagada | O documento fica com `active: false`, nunca é excluído |
| Linha com problema (coordenada inválida, comida fora do cardápio, nome repetido) | Fica de fora, com o motivo na aba Sincronização; o documento que já existia não muda |
| Nenhuma comida do cardápio | Não entra: o app nunca a mostraria |
| Planilha vazia, sem uma coluna obrigatória ou com menos da metade dos restaurantes ativos | Para sem alterar nada, avisa na aba e manda e-mail para quem ligou a rotina |
| Documento cadastrado à mão (sem `source: sheet`) | Não é tocado |

As comidas são deduzidas por palavras-chave nas colunas "Tipo de comida" e
"Comidas Servidas". A coluna opcional **Comidas (correção)** substitui a dedução:
aceita os nomes do cardápio separados por ponto e vírgula, ou `Nenhuma`. O id do
documento vem do nome e do bairro; renomear um restaurante cria um documento novo
e desativa o antigo.

Os links de pedido são os endereços guardados dentro das células da coluna "Links
para pedir", não o texto que elas mostram, como "iFood | 99Food". A "Pesquisa
Google" não é gravada, porque o app já oferece essa busca quando o restaurante
não tem link. A rotina procura as colunas pelo nome exato: quem renomear "Nota
principal (Google > iFood > outras)", "Links para pedir (Google quando não houver
link direto)" ou outra coluna obrigatória faz a sincronização parar, sem alterar
nada, até o nome voltar ou o código mudar. A aba **Comidas sem cobertura** não
entra na sincronização.

Por que Apps Script: rotina agendada dentro do Firebase exige Cloud Functions,
que só funciona no plano Blaze, com cartão (§11, 2026-11-05). O Apps Script é
gratuito e fica à mão de quem cuida da planilha.

**Para instalar**, com uma conta que edite a planilha e o projeto `rango-f0485`:

1. No [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts?project=rango-f0485),
   crie uma conta de serviço com o papel **Usuário do Cloud Datastore**. Em
   *Chaves > Adicionar chave > JSON*, baixe a chave. Ela nunca vai para o git.
2. Na planilha, abra *Extensões > Apps Script* e crie os arquivos `rules.gs` e
   `sync.gs` com o conteúdo de `tools/restaurant_sync/`. Em *Configurações do
   projeto*, ligue "Mostrar appsscript.json" e cole o `appsscript.json`.
3. Ainda em *Configurações do projeto*, crie a propriedade do script
   `FIRESTORE_SERVICE_ACCOUNT` com o JSON inteiro da chave. Depois apague o
   arquivo baixado.
4. Recarregue a planilha, use **Rango > Sincronizar agora** e autorize. O Google
   avisa que o app não foi verificado: *Avançado > Acessar*. Confira a aba
   Sincronização.
5. Use **Rango > Ligar sincronização diária**. A rotina roda na conta de quem fez
   isso; se ela perder o acesso à planilha, a rotina para.

**Cuidado com quem edita a planilha:** quem edita também abre o Apps Script e
pode ler a chave, e essa conta de serviço lê e grava todo o Firestore, inclusive
`users`. Dê acesso de edição só a quem cuida dos dados e deixe os demais como
leitores. Se a chave vazar, apague-a no console e crie outra.

## Testes

| Arquivo | O que cobre |
|---|---|
| `test/models/geo_point_test.dart`, `restaurant_ranking_test.dart`, `delivery_links_test.dart` | Distância, R4 (corte em 3 km, ordem, limite de 20) e R5 (ordem e só `https`) |
| `test/data/geolocator_location_repository_test.dart` | Serviço desligado, permissão concedida, negada, negada para sempre, timeout do GPS, ajustes |
| `test/data/firestore_delivery_link_repository_test.dart` | Leitura de `restaurants/{id}`, campos parciais, formatos inválidos, erro e timeout viram `null` |
| `test/data/external_link_launcher_test.dart` | Só `https` e `tel` saem do app |
| `test/data/fake_*_repository_test.dart` | Os fakes que rodam sem chave |
| `test/core/widgets/restaurant_card_test.dart`, `test/core/format/restaurant_format_test.dart` | Restaurant Card (Vertical e Row), chips, semântica, 375×667; formato de nota e distância |
| `test/screens/restaurants/` | ViewModel (estados, seleção, foto, ajustes) e tela (chip de busca, pins, troca de seleção, prévia → contato, recentralizar, crédito do mapa, 09, vazio, erro, 375×667), Map Pin |
| `test/screens/restaurants/widgets/osm_restaurant_map_test.dart` | Mapa real sem rede: um pin por restaurante, toque, balão só no selecionado, ponta do pin na coordenada, centralizar, mapa desenhado sem posição, identificação do app e URL do servidor |
| `test/screens/restaurant_contact/` | ViewModel (iFood, outros, Google, telefone) e tela (botões, "Ligar" sem telefone, sem "Abrir no mapa" nem histórico, voltar, 375×667) |
| `test/app/app_test.dart` | Fluxo swipe → Deu match → mapa → contato com os fakes |
| `test/restaurant_sync_test.mjs` | Leitura da planilha (nota, telefone, posição, links, comidas, correção, linhas inválidas), ids das comidas iguais aos do cardápio, o que gravar ou desativar, e parada sem alterações quando a planilha está quebrada. Roda com `node --test` |

**Sem teste automatizado:** a sincronização contra o Google de verdade (assinatura
da chave, Firestore, gatilho diário), o download real do mapa e a abertura real de
links e do discador. Roteiro manual: abrir o mapa, conferir o mapa real, o crédito e os
pins na cor da comida, tocar pins, recentralizar, abrir o contato, "Pedir no
delivery" e "Ligar"; negar a permissão nos ajustes e voltar ao app para ver a
tela 09.

## O que não está aqui

| Fora desta entrega | Onde vai |
|---|---|
| Salvar o restaurante e o canal no histórico; chip "Salvo no seu histórico" e "Ir para o histórico" | E2-S4 (#13), quando houver login |
| Lista de restaurantes como alternativa ao mapa | E3-S6 (#47) |
| App de delivery preferido nas preferências | E10-S3 (#66) |
| "Abrir no mapa" na tela 06 | Removido (decisão de 2026-10-29) |
| Restaurantes reais, com posição e comidas | E3-S7 |
| Tempo de entrega no card | Não temos esse dado; o chip fica oculto |
| Ícones do Figma (hoje Material Icons) | #52 |

## Pendências

- Regras do Firestore para `restaurants` (E4-S2, #22).
- Tirar "Abrir no mapa" da tela 06 no Figma (Produto/UX).
- O crédito do OpenStreetMap é só texto; a orientação deles sugere também um
  link para <https://www.openstreetmap.org/copyright>.
- O mapa usa as cores originais do OpenStreetMap, diferentes do Map base do
  Figma (Produto/UX).
