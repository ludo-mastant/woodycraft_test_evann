import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  const ApiClient();

  Uri _uri(String endpoint) {
    final cleanEndpoint = endpoint.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse('${ApiConfig.baseUrl}/$cleanEndpoint');
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    return {
      'Accept': 'application/json',
      if (jsonBody) 'Content-Type': 'application/json',
    };
  }

  Future<dynamic> get(String endpoint) {
    return _send(http.get(_uri(endpoint), headers: _headers()));
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) {
    return _send(
      http.post(
        _uri(endpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) {
    return _send(
      http.put(
        _uri(endpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) {
    return _send(
      http.patch(
        _uri(endpoint),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> delete(String endpoint) {
    return _send(http.delete(_uri(endpoint), headers: _headers()));
  }

  Future<dynamic> _send(Future<http.Response> request) async {
    try {
      final response = await request.timeout(ApiConfig.timeout);
      final data = _decodeBody(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final message = _extractErrorMessage(data, response.statusCode);
      throw ApiException(message, statusCode: response.statusCode);
    } on TimeoutException {
      throw const ApiException('Temps de réponse API dépassé.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Impossible de contacter l\'API : $e');
    }
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractErrorMessage(dynamic data, int statusCode) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message != null) return message.toString();
    }
    return 'Erreur API ($statusCode)';
  }
}
