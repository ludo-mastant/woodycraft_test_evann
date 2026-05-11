// Écran du détail puzzle.
import 'package:flutter/material.dart';

import '../composants/app_colors.dart';
import '../modeles/puzzle.dart';
import 'create_puzzle_page.dart';

// Page de détail d'un puzzle.
class PuzzleDetailPage extends StatelessWidget {
  final Puzzle puzzle;

  const PuzzleDetailPage({super.key, required this.puzzle});

  // Ouvre la modification.
  Future<void> _edit(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreatePuzzlePage(puzzle: puzzle)),
    );

    if (saved == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  // Affiche le détail puzzle.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(puzzle.nom)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    puzzle.nom,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Prix : ${puzzle.prix.toStringAsFixed(2)} €'),
                  Text('Stock : ${puzzle.stock}'),
                  Text('Catégorie : ${puzzle.categorieId}'),
                  if (puzzle.image.isNotEmpty) Text('Image : ${puzzle.image}'),
                  const SizedBox(height: 12),
                  Text(
                    puzzle.description.isEmpty
                        ? 'Aucune description.'
                        : puzzle.description,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Page simple pour lire les infos du puzzle.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
