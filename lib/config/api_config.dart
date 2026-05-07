class ApiConfig {
  // Pour changer l'URL sans modifier le code :
  // flutter run --dart-define=API_URL=http://127.0.0.1:8000/api
  // Android émulateur : http://10.0.2.2:8000/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8080/api',
  );

  static const Duration timeout = Duration(seconds: 10);
}
