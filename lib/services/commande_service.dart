import '../core/api_client.dart';
import '../core/json_helper.dart';
import '../models/commande.dart';

class CommandeService {
  final ApiClient _api;

  const CommandeService({ApiClient api = const ApiClient()}) : _api = api;

  Future<List<Commande>> fetchCommandes() async {
    final data = await _api.get('paniers');
    return readList(data).map((item) => Commande.fromJson(readMap(item))).toList();
  }

  Future<Commande> fetchCommandeDetail(int id) async {
    final data = await _api.get('paniers/$id');
    return Commande.fromJson(readMap(data));
  }

  Future<void> validerCommande(int id) async {
    await _api.put('paniers/$id/validate', {});
  }

  Future<void> expedierCommande(int id) async {
    await _api.put('paniers/$id/checkout', {});
  }

  Future<void> supprimerCommande(int id) async {
    await _api.delete('paniers/$id');
  }
}
