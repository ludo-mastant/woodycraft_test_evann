import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../services/puzzle_service.dart';
import '../widgets/app_colors.dart';
import '../widgets/message_views.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final _service = const PuzzleService();
  late Future<List<Puzzle>> _futurePuzzles;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futurePuzzles = _service.fetchPuzzles();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _futurePuzzles;
  }

  Future<void> _changeStock(Puzzle puzzle, int newStock) async {
    if (newStock < 0) return;

    try {
      await _service.updateStock(puzzle.id, newStock);
      if (!mounted) return;
      setState(_load);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
        actions: [
          IconButton(onPressed: () => setState(_load), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<Puzzle>>(
        future: _futurePuzzles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: () => setState(_load));
          }

          final puzzles = snapshot.data ?? [];
          if (puzzles.isEmpty) {
            return const EmptyView(message: 'Aucun puzzle trouvé.');
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: puzzles.length,
              itemBuilder: (context, index) {
                final puzzle = puzzles[index];
                final isLow = puzzle.stock <= 3;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      isLow ? Icons.warning_amber : Icons.inventory_2_outlined,
                      color: isLow ? AppColors.danger : AppColors.primary,
                    ),
                    title: Text(
                      puzzle.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(isLow ? 'Stock bas' : 'Stock correct'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _changeStock(puzzle, puzzle.stock - 1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        SizedBox(
                          width: 34,
                          child: Text(
                            puzzle.stock.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeStock(puzzle, puzzle.stock + 1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
