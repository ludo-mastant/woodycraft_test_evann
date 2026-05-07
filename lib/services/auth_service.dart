import '../core/api_client.dart';
import '../core/json_helper.dart';

class AuthService {
  final ApiClient _api;

  const AuthService({ApiClient api = const ApiClient()}) : _api = api;

  Future<String?> login(String email, String password) async {
    final data = await _api.post('login', {
      'email': email,
      'password': password,
    });

    final map = readMap(data);
    final token = map['token'] ?? map['access_token'];
    return token?.toString();
  }

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
