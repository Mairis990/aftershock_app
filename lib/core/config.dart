/// Configuración general de la app.
class AppConfig {
  /// Dirección del backend. Con `adb reverse` (celular por USB) o en Windows,
  /// "localhost" apunta a tu computador. Cuando despleguemos en Render se cambia aquí.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.40.42:3000/api/v1',
  );
}
