import '../core/json_helper.dart';

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

  factory AdresseLivraison.fromJson(Map<String, dynamic> json) {
    return AdresseLivraison(
      rue: readString(json['rue'] ?? json['adresse'] ?? json['address']),
      ville: readString(json['ville'] ?? json['city']),
      codePostal: readString(json['code_postal'] ?? json['postal_code']),
      pays: readString(json['pays'] ?? json['country']),
    );
  }

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

  factory Commande.fromJson(Map<String, dynamic> json) {
    final rawItems = readList(json['articles'] ?? json['items'] ?? json['lignes']);
    final items = rawItems
        .map((item) => CommandeItem.fromJson(readMap(item)))
        .toList();

    final clientMap = readMap(json['client']);
    final adresseMap = readMap(json['adresse_livraison']);

    CommandeClient? client;
    if (clientMap.isNotEmpty) {
      client = CommandeClient.fromJson(clientMap);
    } else if (json['client_id'] != null || json['email'] != null || json['nom_client'] != null) {
      client = CommandeClient(
        id: readInt(json['client_id']),
        nom: readString(json['nom_client'] ?? json['client_nom'], 'Client inconnu'),
        email: readString(json['email']),
        telephone: readString(json['telephone']),
      );
    }

    AdresseLivraison? adresseLivraison;
    if (adresseMap.isNotEmpty) {
      adresseLivraison = AdresseLivraison.fromJson(adresseMap);
    } else if (json['rue'] != null || json['ville'] != null || json['code_postal'] != null) {
      adresseLivraison = AdresseLivraison.fromJson(json);
    }

    double total = readDouble(json['total']);
    if (total == 0 && items.isNotEmpty) {
      total = items.fold<double>(0, (sum, item) => sum + item.sousTotal);
    }

    return Commande(
      id: readInt(json['id']),
      statut: readString(json['statut'] ?? json['status'], 'en cours'),
      total: total,
      items: items,
      modePaiement: readString(json['mode_paiement'] ?? json['payment_method']),
      dateCommande: readString(json['date_commande'] ?? json['created_at']),
      client: client,
      adresseLivraison: adresseLivraison,
    );
  }
}
