import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/models/history_entry.dart';

/// In-memory Histórico. With no arguments it holds [sample], a few decisions
/// spread over two months so the stacked list can be seen working.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository({List<HistoryEntry>? entries})
    : _entries = List.unmodifiable(entries ?? sample);

  final List<HistoryEntry> _entries;

  static final sample = [
    HistoryEntry(
      id: 'h1',
      foodId: 'acai',
      restaurantName: 'Oakberry',
      decidedAt: DateTime(2026, 9, 6, 15, 20),
      cuisine: 'Açaiteria · Cidade Baixa',
    ),
    HistoryEntry(
      id: 'h2',
      foodId: 'pastel',
      restaurantName: 'Pastelaria do Mercado',
      decidedAt: DateTime(2026, 9, 13, 12, 10),
      cuisine: 'Pastelaria · Centro Histórico',
    ),
    HistoryEntry(
      id: 'h3',
      foodId: 'barbecue',
      restaurantName: 'Galpão Crioulo',
      decidedAt: DateTime(2026, 9, 20, 13),
      cuisine: 'Churrascaria · Menino Deus',
    ),
    HistoryEntry(
      id: 'h4',
      foodId: 'brigadeiro',
      restaurantName: 'Doce Doce',
      decidedAt: DateTime(2026, 9, 27, 16, 45),
      cuisine: 'Doceria · Bom Fim',
    ),
    HistoryEntry(
      id: 'h5',
      foodId: 'xis',
      restaurantName: 'Rosário Lanches',
      decidedAt: DateTime(2026, 10, 4, 21, 30),
      cuisine: 'Lancheria · Rio Branco',
    ),
    HistoryEntry(
      id: 'h6',
      foodId: 'sushi',
      restaurantName: 'Norimon',
      decidedAt: DateTime(2026, 10, 11, 20),
      cuisine: 'Japonesa · Moinhos de Vento',
    ),
    HistoryEntry(
      id: 'h7',
      foodId: 'hot_dog',
      restaurantName: "Lucho's",
      decidedAt: DateTime(2026, 10, 18, 19, 15),
      cuisine: 'Lanches · Cidade Baixa',
    ),
    HistoryEntry(
      id: 'h8',
      foodId: 'pizza',
      restaurantName: 'Pizzaria Bella Napoli',
      decidedAt: DateTime(2026, 10, 25, 20, 40),
      cuisine: 'Pizzaria · Petrópolis',
    ),
    HistoryEntry(
      id: 'h9',
      foodId: 'spaghetti',
      restaurantName: 'Cantina da Nona',
      decidedAt: DateTime(2026, 11, 1, 12, 30),
      cuisine: 'Italiana · Moinhos de Vento',
    ),
  ];

  @override
  Future<List<HistoryEntry>> fetchAll() async => _entries;
}
