// Appels API pour les puzzles.
import '../modeles/puzzle.dart';
import 'api_service.dart';

// Service des appels liés aux puzzles.
class PuzzleService {
  final ApiService _api;

  const PuzzleService({ApiService api = const ApiService()}) : _api = api;

  // Charge les puzzles.
  Future<List<Puzzle>> fetchPuzzles() async {
    final data = await _api.get('puzzles');
    return readList(data).map((item) => Puzzle.fromJson(readMap(item))).toList();
  }

  // Ajoute un puzzle.
  Future<void> createPuzzle(Puzzle puzzle) async {
    await _api.post('puzzles', puzzle.toJson());
  }

  // Modifie un puzzle.
  Future<void> updatePuzzle(Puzzle puzzle) async {
    await _api.put('puzzles/${puzzle.id}', puzzle.toJson());
  }

  // Met à jour le stock.
  Future<void> updateStock(int puzzleId, int stock) async {
    await _api.patch('puzzles/$puzzleId', {
      'stock': stock,
      'quantite': stock,
    });
  }

  // Supprime un puzzle.
  Future<void> deletePuzzle(int id) async {
    await _api.delete('puzzles/$id');
  }
}
