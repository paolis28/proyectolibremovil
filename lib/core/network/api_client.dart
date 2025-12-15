import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';

/// Cliente HTTP centralizado para todas las peticiones de la app
class ApiClient {
  final http.Client client;
  final String baseUrl;
  String? _token;

  ApiClient({
    required this.client,
    required this.baseUrl,
  });

  /// Establece el token de autenticación
  void setToken(String? token) {
    _token = token;
  }

  /// Headers base para las peticiones
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  /// GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// Maneja la respuesta HTTP
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw ServerException('No autorizado', 401);
    } else if (response.statusCode == 403) {
      throw ServerException('Acceso denegado', 403);
    } else if (response.statusCode == 404) {
      throw ServerException('Recurso no encontrado', 404);
    } else if (response.statusCode >= 500) {
      throw ServerException('Error del servidor', response.statusCode);
    } else {
      final errorData = json.decode(response.body);
      throw ServerException(
        errorData['message'] ?? 'Error desconocido',
        response.statusCode,
      );
    }
  }
}