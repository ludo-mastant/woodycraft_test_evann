// Écran du formulaire puzzle.
import 'package:flutter/material.dart';

import '../composants/app_colors.dart';
import '../modeles/puzzle.dart';
import '../services/puzzle_service.dart';

// Page de création ou modification d'un puzzle.
class CreatePuzzlePage extends StatefulWidget {
  final Puzzle? puzzle;

  const CreatePuzzlePage({super.key, this.puzzle});

  // Crée l'état du formulaire.
  @override
  State<CreatePuzzlePage> createState() => _CreatePuzzlePageState();
}

// Gère le formulaire du puzzle.
class _CreatePuzzlePageState extends State<CreatePuzzlePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = const PuzzleService();

  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _prixController;
  late final TextEditingController _categorieController;
  late final TextEditingController _stockController;

  bool _isSaving = false;

  // Vérifie si on modifie.
  bool get _isEdit => widget.puzzle != null;

  // Prépare les champs.
  @override
  void initState() {
    super.initState();
    final puzzle = widget.puzzle;
    _nomController = TextEditingController(text: puzzle?.nom ?? '');
    _descriptionController = TextEditingController(text: puzzle?.description ?? '');
    _imageController = TextEditingController(text: puzzle?.image ?? 'default.jpg');
    _prixController = TextEditingController(text: puzzle?.prix.toString() ?? '');
    _categorieController = TextEditingController(text: puzzle?.categorieId.toString() ?? '1');
    _stockController = TextEditingController(text: puzzle?.stock.toString() ?? '0');
  }

  // Nettoie les champs.
  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _prixController.dispose();
    _categorieController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Sauvegarde le puzzle.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final puzzle = Puzzle(
      id: widget.puzzle?.id ?? 0,
      nom: _nomController.text.trim(),
      description: _descriptionController.text.trim(),
      image: _imageController.text.trim().isEmpty
          ? 'default.jpg'
          : _imageController.text.trim(),
      prix: double.parse(_prixController.text.replaceAll(',', '.')),
      categorieId: int.parse(_categorieController.text),
      stock: int.parse(_stockController.text),
    );

    setState(() => _isSaving = true);

    try {
      if (_isEdit) {
        await _service.updatePuzzle(puzzle);
      } else {
        await _service.createPuzzle(puzzle);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Champ obligatoire.
  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ obligatoire';
    return null;
  }

  // Vérifie un nombre.
  String? _number(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ obligatoire';
    final cleaned = value.replaceAll(',', '.');
    if (double.tryParse(cleaned) == null) return 'Nombre invalide';
    return null;
  }

  // Vérifie un entier.
  String? _integer(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ obligatoire';
    if (int.tryParse(value) == null) return 'Nombre entier invalide';
    return null;
  }

  // Affiche le formulaire.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Modifier le puzzle' : 'Ajouter un puzzle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix'),
              validator: _number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock'),
              validator: _integer,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ID catégorie'),
              validator: _integer,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEdit ? 'Enregistrer' : 'Créer'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simple : les champs suivent les colonnes principales de l’API.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
