import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../services/puzzle_service.dart';
import '../widgets/app_colors.dart';
import '../widgets/message_views.dart';
import 'puzzle_form_screen.dart';

class PuzzlesScreen extends StatefulWidget {
  const PuzzlesScreen({super.key});

  @override
  State<PuzzlesScreen> createState() => _PuzzlesScreenState();
}

class _PuzzlesScreenState extends State<PuzzlesScreen> {
  final _puzzleService = const PuzzleService();
  late Future<List<Puzzle>> _futurePuzzles;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futurePuzzles = _puzzleService.fetchPuzzles();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _futurePuzzles;
  }

  Future<void> _openForm([Puzzle? puzzle]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PuzzleFormScreen(puzzle: puzzle)),
    );

    if (saved == true) setState(_load);
  }

  Future<void> _deletePuzzle(Puzzle puzzle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le puzzle ?'),
        content: Text('Supprimer "${puzzle.nom}" du catalogue ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _puzzleService.deletePuzzle(puzzle.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puzzle supprimé.')),
      );
      setState(_load);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzles'),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.extension, color: AppColors.primary),
                    title: Text(
                      puzzle.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${puzzle.prix.toStringAsFixed(2)} € • Stock : ${puzzle.stock} • Catégorie : ${puzzle.categorieId}',
                    ),
                    onTap: () => _openForm(puzzle),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      onPressed: () => _deletePuzzle(puzzle),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
