// Écran du tableau de bord admin.
import 'package:flutter/material.dart';

import '../composants/app_colors.dart';
import '../composants/message_views.dart';
import '../modeles/dashboard_resume.dart';
import '../services/admin_dashboard_service.dart';

// Page des statistiques admin.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  // Crée l'état de la page.
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

// Charge et affiche les chiffres du dashboard.
class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _dashboardService = const AdminDashboardService();
  late Future<DashboardResume> _futureResume;

  // Charge au démarrage.
  @override
  void initState() {
    super.initState();
    _load();
  }

  // Charge les stats.
  void _load() {
    _futureResume = _dashboardService.fetchResume();
  }

  // Recharge la page.
  Future<void> _refresh() async {
    setState(_load);
    await _futureResume;
  }

  // Affiche le dashboard.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(onPressed: () => setState(_load), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<DashboardResume>(
        future: _futureResume,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: () => setState(_load));
          }

          final resume = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _headerCard(),
                const SizedBox(height: 16),
                _statCard(
                  title: 'Commandes en attente',
                  value: resume.commandesEnAttente.toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                ),
                _statCard(
                  title: 'Puzzles en stock bas',
                  value: resume.puzzlesStockBas.toString(),
                  icon: Icons.warning_amber,
                  color: AppColors.danger,
                ),
                _statCard(
                  title: 'Chiffre du mois',
                  value: '${resume.chiffreAffaireMois.toStringAsFixed(2)} €',
                  icon: Icons.euro,
                  color: AppColors.success,
                ),
                _statCard(
                  title: 'Clients',
                  value: resume.totalClients.toString(),
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Affiche le titre.
  Widget _headerCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 34),
            SizedBox(height: 12),
            Text(
              'Administration WoodyCraft',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text('Résumé simple de l’activité du site.'),
          ],
        ),
      ),
    );
  }

  // Affiche une statistique.
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
