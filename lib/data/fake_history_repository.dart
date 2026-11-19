import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/models/order_channel.dart';

/// In-memory Histórico, shared by every account (the uid is ignored). With no
/// arguments it holds [sample], a few decisions spread over three months so
/// the stacked list can be seen working.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository({List<HistoryEntry>? entries})
    : _entries = [...entries ?? sample];

  final List<HistoryEntry> _entries;

  /// What [save] received, in order, for tests.
  final List<HistoryEntry> saved = [];

  static final sample = [
    HistoryEntry(
      id: 'h1',
      foodId: 'acai',
      restaurantId: 'p1',
      channel: OrderChannel.delivery,
      restaurantName: 'Oakberry',
      decidedAt: DateTime(2026, 9, 6, 15, 20),
      cuisine: 'Açaiteria · Cidade Baixa',
    ),
    HistoryEntry(
      id: 'h2',
      foodId: 'pastel',
      restaurantId: 'p2',
      channel: OrderChannel.delivery,
      restaurantName: 'Pastelaria do Mercado',
      decidedAt: DateTime(2026, 9, 13, 12, 10),
      cuisine: 'Pastelaria · Centro Histórico',
    ),
    HistoryEntry(
      id: 'h3',
      foodId: 'barbecue',
      restaurantId: 'p3',
      channel: OrderChannel.call,
      restaurantName: 'Galpão Crioulo',
      decidedAt: DateTime(2026, 9, 20, 13),
      cuisine: 'Churrascaria · Menino Deus',
    ),
    HistoryEntry(
      id: 'h4',
      foodId: 'brigadeiro',
      restaurantId: 'p4',
      channel: OrderChannel.delivery,
      restaurantName: 'Doce Doce',
      decidedAt: DateTime(2026, 9, 27, 16, 45),
      cuisine: 'Doceria · Bom Fim',
    ),
    HistoryEntry(
      id: 'h5',
      foodId: 'xis',
      restaurantId: 'p5',
      channel: OrderChannel.delivery,
      restaurantName: 'Rosário Lanches',
      decidedAt: DateTime(2026, 10, 4, 21, 30),
      cuisine: 'Lancheria · Rio Branco',
    ),
    HistoryEntry(
      id: 'h6',
      foodId: 'sushi',
      restaurantId: 'p6',
      channel: OrderChannel.call,
      restaurantName: 'Norimon',
      decidedAt: DateTime(2026, 10, 11, 20),
      cuisine: 'Japonesa · Moinhos de Vento',
    ),
    HistoryEntry(
      id: 'h7',
      foodId: 'hot_dog',
      restaurantId: 'p7',
      channel: OrderChannel.delivery,
      restaurantName: "Lucho's",
      decidedAt: DateTime(2026, 10, 18, 19, 15),
      cuisine: 'Lanches · Cidade Baixa',
    ),
    HistoryEntry(
      id: 'h8',
      foodId: 'pizza',
      restaurantId: 'p8',
      channel: OrderChannel.delivery,
      restaurantName: 'Pizzaria Bella Napoli',
      decidedAt: DateTime(2026, 10, 25, 20, 40),
      cuisine: 'Pizzaria · Petrópolis',
    ),
    HistoryEntry(
      id: 'h9',
      foodId: 'spaghetti',
      restaurantId: 'p9',
      channel: OrderChannel.call,
      restaurantName: 'Cantina da Nona',
      decidedAt: DateTime(2026, 11, 1, 12, 30),
      cuisine: 'Italiana · Moinhos de Vento',
    ),
  ];

  @override
  Future<List<HistoryEntry>> fetchAll(String uid) async =>
      List.unmodifiable(_entries);

  @override
  Future<void> save(String uid, HistoryEntry entry) async {
    saved.add(entry);
    _entries.add(entry.copyWith(id: 'saved-${saved.length}'));
  }
}
