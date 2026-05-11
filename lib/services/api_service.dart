// Base commune pour parler à Laravel.
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// Erreur renvoyée quand l'API répond mal.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  // Retourne le message lisible.
  @override
  String toString() => message;
}

// Client HTTP commun pour toutes les requêtes API.
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8080/api',
  );

  static const Duration timeout = Duration(seconds: 10);

  const ApiService();

  // Prépare l'URL API.
  Uri _url(String endpoint) {
    final cleanEndpoint = endpoint.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse('$baseUrl/$cleanEndpoint');
  }

  // Prépare les headers.
  Map<String, String> _headers({bool jsonBody = false}) {
    return {
      'Accept': 'application/json',
      if (jsonBody) 'Content-Type': 'application/json',
    };
  }

  // Récupère des données.
  Future<dynamic> get(String endpoint) {
    return _send(http.get(_url(endpoint), headers: _headers()));
  }

  // Crée une donnée.
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) {
    return _send(
      http.post(
        _url(endpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  // Modifie une donnée.
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) {
    return _send(
      http.put(
        _url(endpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  // Modifie une partie.
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) {
    return _send(
      http.patch(
        _url(endpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  // Supprime une donnée.
  Future<dynamic> delete(String endpoint) {
    return _send(http.delete(_url(endpoint), headers: _headers()));
  }

  // Envoie la requête.
  Future<dynamic> _send(Future<http.Response> request) async {
    try {
      final response = await request.timeout(timeout);
      final data = _decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      throw ApiException(
        _errorMessage(data, response.statusCode),
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const ApiException('Temps de réponse API dépassé.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Impossible de contacter l\'API : $e');
    }
  }

  // Décode le JSON.
  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  // Cherche le message d'erreur.
  String _errorMessage(dynamic data, int statusCode) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message != null) return message.toString();
    }
    return 'Erreur API ($statusCode)';
  }
}

// Lit un entier.
int readInt(dynamic value, [int defaultValue = 0]) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? defaultValue;
}

// Lit un nombre décimal.
double readDouble(dynamic value, [double defaultValue = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse((value?.toString() ?? '').replaceAll(',', '.')) ??
      defaultValue;
}

// Lit un texte.
String readString(dynamic value, [String defaultValue = '']) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return defaultValue;
  return text;
}

// Lit une liste.
List<dynamic> readList(dynamic value) {
  if (value is List) return value;
  if (value is Map && value['data'] is List) return value['data'] as List;
  return [];
}

// Lit un objet JSON.
Map<String, dynamic> readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
