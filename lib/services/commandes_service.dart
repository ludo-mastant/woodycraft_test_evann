import '../modeles/commande.dart';
import 'api_service.dart';

class CommandesService {
  final ApiService _api;

  const CommandesService({ApiService api = const ApiService()}) : _api = api;

  // Charge les commandes.
  Future<List<Commande>> fetchCommandes() async {
    final data = await _api.get('paniers');
    return readList(data).map((item) => Commande.fromJson(readMap(item))).toList();
  }

  // Charge une commande.
  Future<Commande> fetchCommandeDetail(int id) async {
    final data = await _api.get('paniers/$id');
    return Commande.fromJson(readMap(data));
  }

  // Valide une commande.
  Future<void> validerCommande(int id) async {
    await _api.put('paniers/$id/validate', {});
  }

  // Passe en expédition.
  Future<void> expedierCommande(int id) async {
    await _api.put('paniers/$id/checkout', {});
  }

  // Supprime une commande.
  Future<void> supprimerCommande(int id) async {
    await _api.delete('paniers/$id');
  }
}
