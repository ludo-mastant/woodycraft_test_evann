// Modèle du résumé dashboard.
import '../services/api_service.dart';

// Résumé des chiffres du tableau de bord.
class DashboardResume {
  final int commandesEnAttente;
  final int puzzlesStockBas;
  final double chiffreAffaireMois;
  final int totalClients;

  const DashboardResume({
    required this.commandesEnAttente,
    required this.puzzlesStockBas,
    required this.chiffreAffaireMois,
    required this.totalClients,
  });

  // Crée le résumé depuis l'API.
  factory DashboardResume.fromJson(Map<String, dynamic> json) {
    return DashboardResume(
      commandesEnAttente: readInt(
        json['commandes_en_attente'] ?? json['commandesEnAttente'],
      ),
      puzzlesStockBas: readInt(
        json['puzzles_stock_bas'] ?? json['stock_bas'] ?? json['puzzlesStockBas'],
      ),
      chiffreAffaireMois: readDouble(
        json['chiffre_affaire_mois'] ??
            json['ventes_mois'] ??
            json['chiffreAffaireMois'],
      ),
      totalClients: readInt(json['total_clients'] ?? json['totalClients']),
    );
  }
}
