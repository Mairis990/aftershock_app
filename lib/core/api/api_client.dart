import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Error "amigable" que se puede mostrar tal cual al usuario.
class ApiException implements Exception {
  ApiException(this.message, [this.status]);
  final String message;
  final int? status;

  @override
  String toString() => message;
}

/// Cliente único para hablar con el backend. Agrega el token y traduce errores.
class ApiClient {
  ApiClient({required this.tokenProvider, this.onUnauthorized});

  final String? Function() tokenProvider;
  final void Function()? onUnauthorized;

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, [Object? body]) => _send('POST', path, body);
  Future<dynamic> put(String path, [Object? body]) => _send('PUT', path, body);
  Future<dynamic> patch(String path, [Object? body]) => _send('PATCH', path, body);

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final token = tokenProvider();
    final request = http.Request(method, Uri.parse('${AppConfig.apiUrl}$path'));
    request.headers['Content-Type'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      final dynamic data =
          response.body.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) return data;

      final mensaje = (data is Map && data['error'] is String)
          ? data['error'] as String
          : 'Ocurrió un error inesperado (${response.statusCode}).';
      if (response.statusCode == 401 && token != null) onUnauthorized?.call();
      throw ApiException(mensaje, response.statusCode);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder. Intenta de nuevo.');
    } on SocketException {
      throw ApiException('No hay conexión con el servidor. Revisa tu internet.');
    } on http.ClientException {
      throw ApiException('No hay conexión con el servidor. Revisa tu internet.');
    } on FormatException {
      throw ApiException('El servidor respondió algo que no se entiende.');
    }
  }
}
