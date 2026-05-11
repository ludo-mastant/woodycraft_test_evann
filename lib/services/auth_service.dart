// Appels API pour l'authentification.
import 'api_service.dart';

// Service de connexion et d'inscription.
class AuthService {
  final ApiService _api;

  const AuthService({ApiService api = const ApiService()}) : _api = api;

  // Connecte un utilisateur.
  Future<String?> login(String email, String password) async {
    final data = await _api.post('login', {
      'email': email,
      'password': password,
    });

    final map = readMap(data);
    final token = map['token'] ?? map['access_token'];
    return token?.toString();
  }

  // Crée un compte.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _api.post('register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }
}
