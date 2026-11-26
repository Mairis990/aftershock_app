import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';

enum SessionStatus { loading, anonymous, authenticated }

class Usuario {
  Usuario({required this.id, required this.nombre, required this.correo, required this.rol});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        rol: json['rol'] as String,
      );

  final String id;
  final String nombre;
  final String correo;

  /// 'afectada', 'donante' o 'administrador'
  final String rol;

  String get rolEtiqueta => switch (rol) {
        'afectada' => 'Persona afectada',
        'donante' => 'Donante',
        'administrador' => 'Administrador',
        _ => rol,
      };

  String get primerNombre => nombre.trim().split(' ').first;
}

/// Guarda quién está logueado. La app entera escucha este objeto.
class Session extends ChangeNotifier {
  Session() {
    api = ApiClient(tokenProvider: () => _token, onUnauthorized: logout);
  }

  late final ApiClient api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'aftershock_token';

  String? _token;
  Usuario? usuario;
  SessionStatus status = SessionStatus.loading;

  /// Se llama al abrir la app: si había una sesión guardada, la recupera.
  Future<void> restore() async {
    try {
      _token = await _storage.read(key: _tokenKey);
    } catch (_) {
      _token = null;
    }
    if (_token == null) {
      status = SessionStatus.anonymous;
      notifyListeners();
      return;
    }
    try {
      final data = await api.get('/me') as Map<String, dynamic>;
      usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
      status = SessionStatus.authenticated;
    } on ApiException catch (e) {
      if (e.status == 401) {
        _token = null;
        await _borrarToken();
      }
      status = SessionStatus.anonymous;
    }
    notifyListeners();
  }

  Future<void> login(String correo, String clave) async {
    final data = await api.post('/auth/login', {'correo': correo, 'clave': clave});
    await _iniciar(data as Map<String, dynamic>);
  }

  Future<void> registro({
    required String nombre,
    required String correo,
    required String clave,
    required String rol,
  }) async {
    final data = await api.post('/auth/registro', {
      'nombre': nombre,
      'correo': correo,
      'clave': clave,
      'rol': rol,
    });
    await _iniciar(data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    _token = null;
    usuario = null;
    status = SessionStatus.anonymous;
    await _borrarToken();
    notifyListeners();
  }

  Future<void> _iniciar(Map<String, dynamic> data) async {
    _token = data['token'] as String;
    usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
    status = SessionStatus.authenticated;
    try {
      await _storage.write(key: _tokenKey, value: _token);
    } catch (_) {
      // Si no se puede guardar, la sesión sigue funcionando hasta cerrar la app.
    }
    notifyListeners();
  }

  Future<void> _borrarToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
  }
}
