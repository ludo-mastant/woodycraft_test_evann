import '../services/api_service.dart';

class Puzzle {
  final int id;
  final String nom;
  final String description;
  final String image;
  final double prix;
  final int categorieId;
  final int stock;

  const Puzzle({
    required this.id,
    required this.nom,
    required this.description,
    required this.image,
    required this.prix,
    required this.categorieId,
    required this.stock,
  });

  // Crée un puzzle depuis l'API.
  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: readInt(json['id']),
      nom: readString(json['nom'] ?? json['name'], 'Sans nom'),
      description: readString(json['description']),
      image: readString(json['image'], 'default.jpg'),
      prix: readDouble(json['prix'] ?? json['price']),
      categorieId: readInt(json['categorie_id'] ?? json['categorieId'], 1),
      stock: readInt(json['stock'] ?? json['quantite'] ?? json['quantity']),
    );
  }

  // Prépare l'envoi API.
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'image': image,
      'prix': prix,
      'categorie_id': categorieId,
      'stock': stock,
    };
  }

  // Copie avec changements.
  Puzzle copyWith({
    int? id,
    String? nom,
    String? description,
    String? image,
    double? prix,
    int? categorieId,
    int? stock,
  }) {
    return Puzzle(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      image: image ?? this.image,
      prix: prix ?? this.prix,
      categorieId: categorieId ?? this.categorieId,
      stock: stock ?? this.stock,
    );
  }
}
