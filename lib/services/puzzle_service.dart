import '../core/api_client.dart';
import '../core/json_helper.dart';
import '../models/puzzle.dart';

class PuzzleService {
  final ApiClient _api;

  const PuzzleService({ApiClient api = const ApiClient()}) : _api = api;

  Future<List<Puzzle>> fetchPuzzles() async {
    final data = await _api.get('puzzles');
    return readList(data).map((item) => Puzzle.fromJson(readMap(item))).toList();
  }

  Future<void> createPuzzle(Puzzle puzzle) async {
    await _api.post('puzzles', puzzle.toJson());
  }

  Future<void> updatePuzzle(Puzzle puzzle) async {
    await _api.put('puzzles/${puzzle.id}', puzzle.toJson());
  }

  Future<void> updateStock(int puzzleId, int stock) async {
    await _api.patch('puzzles/$puzzleId', {
      'stock': stock,
      'quantite': stock,
    });
  }

  Future<void> deletePuzzle(int id) async {
    await _api.delete('puzzles/$id');
  }
}
