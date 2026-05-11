import '../services/api_service.dart';

class CommandeItem {
  final int puzzleId;
  final String nom;
  final int quantite;
  final double prix;

  const CommandeItem({
    required this.puzzleId,
    required this.nom,
    required this.quantite,
    required this.prix,
  });

  // Crée une ligne commande.
  factory CommandeItem.fromJson(Map<String, dynamic> json) {
    final puzzle = readMap(json['puzzle']);

    return CommandeItem(
      puzzleId: readInt(json['puzzle_id'] ?? puzzle['id'] ?? json['id']),
      nom: readString(
        json['nom'] ?? json['name'] ?? puzzle['nom'] ?? puzzle['name'],
        'Produit',
      ),
      quantite: readInt(json['quantite'] ?? json['quantity'] ?? json['qty'], 1),
      prix: readDouble(
        json['prix'] ?? json['prix_unitaire'] ?? json['price'] ?? puzzle['prix'],
      ),
    );
  }

  // Calcule le sous-total.
  double get sousTotal => prix * quantite;
}

class CommandeClient {
  final int id;
  final String nom;
  final String email;
  final String telephone;

  const CommandeClient({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
  });

  // Crée le client.
  factory CommandeClient.fromJson(Map<String, dynamic> json) {
    return CommandeClient(
      id: readInt(json['id']),
      nom: readString(json['nom'] ?? json['name'], 'Client inconnu'),
      email: readString(json['email']),
      telephone: readString(json['telephone'] ?? json['phone']),
    );
  }
}

class AdresseLivraison {
  final String rue;
  final String ville;
  final String codePostal;
  final String pays;

  const AdresseLivraison({
    required this.rue,
    required this.ville,
    required this.codePostal,
    required this.pays,
  });

  // Crée l'adresse.
  factory AdresseLivraison.fromJson(Map<String, dynamic> json) {
    return AdresseLivraison(
      rue: readString(json['rue'] ?? json['adresse'] ?? json['address']),
      ville: readString(json['ville'] ?? json['city']),
      codePostal: readString(json['code_postal'] ?? json['postal_code']),
      pays: readString(json['pays'] ?? json['country']),
    );
  }

  // Met l'adresse en texte.
  String get formatted {
    final parts = [rue, codePostal, ville, pays].where((part) => part.isNotEmpty);
    return parts.join(', ');
  }
}

class Commande {
  final int id;
  final String statut;
  final double total;
  final List<CommandeItem> items;
  final String modePaiement;
  final String dateCommande;
  final CommandeClient? client;
  final AdresseLivraison? adresseLivraison;

  const Commande({
    required this.id,
    required this.statut,
    required this.total,
    required this.items,
    required this.modePaiement,
    required this.dateCommande,
    required this.client,
    required this.adresseLivraison,
  });

  // Crée une commande depuis l'API.
  factory Commande.fromJson(Map<String, dynamic> json) {
    final clientJson = readMap(json['client'] ?? json['user']);
    final adresseJson = readMap(json['adresse_livraison'] ?? json['adresse']);
    final rawItems = readList(
      json['items'] ?? json['lignes'] ?? json['details'] ?? json['puzzles'],
    );

    return Commande(
      id: readInt(json['id']),
      statut: readString(json['statut'] ?? json['status'], 'en attente'),
      total: readDouble(json['total'] ?? json['montant_total'] ?? json['amount']),
      items: rawItems.map((item) => CommandeItem.fromJson(readMap(item))).toList(),
      modePaiement: readString(json['mode_paiement'] ?? json['payment_method']),
      dateCommande: readString(json['created_at'] ?? json['date_commande']),
      client: clientJson.isEmpty ? null : CommandeClient.fromJson(clientJson),
      adresseLivraison:
          adresseJson.isEmpty ? null : AdresseLivraison.fromJson(adresseJson),
    );
  }
}
