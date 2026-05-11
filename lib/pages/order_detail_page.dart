import 'package:flutter/material.dart';

import '../composants/app_colors.dart';
import '../composants/message_views.dart';
import '../modeles/commande.dart';
import '../services/commandes_service.dart';

class OrderDetailPage extends StatefulWidget {
  final int commandeId;

  const OrderDetailPage({super.key, required this.commandeId});

  // Crée l'état de la page.
  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final _service = const CommandesService();
  late Future<Commande> _futureCommande;

  // Charge au démarrage.
  @override
  void initState() {
    super.initState();
    _load();
  }

  // Charge la commande.
  void _load() {
    _futureCommande = _service.fetchCommandeDetail(widget.commandeId);
  }

  // Affiche le détail.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Commande #${widget.commandeId}')),
      body: FutureBuilder<Commande>(
        future: _futureCommande,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: () => setState(_load));
          }

          final commande = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _infoCard(commande),
              const SizedBox(height: 12),
              _clientCard(commande.client),
              const SizedBox(height: 12),
              _addressCard(commande.adresseLivraison),
              const SizedBox(height: 12),
              const Text(
                'Articles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (commande.items.isEmpty)
                const Card(child: ListTile(title: Text('Aucun article.')))
              else
                ...commande.items.map(_itemCard),
            ],
          );
        },
      ),
    );
  }

  // Affiche les infos.
  Widget _infoCard(Commande commande) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total : ${commande.total.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Statut : ${commande.statut}'),
            if (commande.dateCommande.isNotEmpty) Text('Date : ${commande.dateCommande}'),
            if (commande.modePaiement.isNotEmpty) Text('Paiement : ${commande.modePaiement}'),
          ],
        ),
      ),
    );
  }

  // Affiche le client.
  Widget _clientCard(CommandeClient? client) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_outline, color: AppColors.primary),
        title: Text(client?.nom ?? 'Client non renseigné'),
        subtitle: Text([
          client?.email ?? '',
          client?.telephone ?? '',
        ].where((value) => value.isNotEmpty).join('\n')),
      ),
    );
  }

  // Affiche l'adresse.
  Widget _addressCard(AdresseLivraison? adresse) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
        title: const Text('Adresse de livraison'),
        subtitle: Text(adresse?.formatted.isNotEmpty == true
            ? adresse!.formatted
            : 'Adresse non renseignée'),
      ),
    );
  }

  // Affiche un article.
  Widget _itemCard(CommandeItem item) {
    return Card(
      child: ListTile(
        title: Text(item.nom),
        subtitle: Text('${item.quantite} x ${item.prix.toStringAsFixed(2)} €'),
        trailing: Text('${item.sousTotal.toStringAsFixed(2)} €'),
      ),
    );
  }
}
