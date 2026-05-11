// Écran de gestion des commandes.
import 'package:flutter/material.dart';

import '../composants/app_colors.dart';
import '../composants/message_views.dart';
import '../modeles/commande.dart';
import '../services/commandes_service.dart';
import 'order_detail_page.dart';

// Page de gestion des commandes.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  // Crée l'état de la page.
  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

// Charge les commandes et gère les actions.
class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final _service = const CommandesService();
  late Future<List<Commande>> _futureCommandes;

  // Charge au démarrage.
  @override
  void initState() {
    super.initState();
    _load();
  }

  // Charge les commandes.
  void _load() {
    _futureCommandes = _service.fetchCommandes();
  }

  // Recharge la liste.
  Future<void> _refresh() async {
    setState(_load);
    await _futureCommandes;
  }

  // Choisit la couleur statut.
  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value.contains('valid')) return AppColors.success;
    if (value.contains('exp')) return AppColors.primary;
    if (value.contains('annul')) return AppColors.danger;
    return AppColors.warning;
  }

  // Lance une action API.
  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) return;
      setState(_load);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Demande avant suppression.
  Future<void> _delete(Commande commande) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la commande ?'),
        content: Text('Supprimer la commande #${commande.id} ?'),
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

    if (confirm == true) {
      await _runAction(() => _service.supprimerCommande(commande.id));
    }
  }

  // Affiche les commandes.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
        actions: [
          IconButton(onPressed: () => setState(_load), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<Commande>>(
        future: _futureCommandes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: () => setState(_load));
          }

          final commandes = snapshot.data ?? [];
          if (commandes.isEmpty) {
            return const EmptyView(message: 'Aucune commande trouvée.');
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: commandes.length,
              itemBuilder: (context, index) => _orderCard(commandes[index]),
            ),
          );
        },
      ),
    );
  }

  // Affiche une commande.
  Widget _orderCard(Commande commande) {
    final color = _statusColor(commande.statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Commande #${commande.id}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${commande.total.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(commande.statut),
              labelStyle: TextStyle(color: color),
              side: BorderSide(color: color),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailPage(commandeId: commande.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Détail'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _runAction(() => _service.validerCommande(commande.id)),
                  icon: const Icon(Icons.check),
                  label: const Text('Valider'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _runAction(() => _service.expedierCommande(commande.id)),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Expédier'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _delete(commande),
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  label: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
