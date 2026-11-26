import '../../core/api/api_client.dart';
import 'models.dart';

/// Todas las llamadas al backend relacionadas con solicitudes y perfil.
class SolicitudesService {
  SolicitudesService(this.api);
  final ApiClient api;

  List<Map<String, dynamic>> _lista(dynamic data) =>
      (data as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();

  Future<List<Necesidad>> necesidades() async =>
      _lista(await api.get('/necesidades')).map(Necesidad.fromJson).toList();

  Future<List<Solicitud>> mias() async =>
      _lista(await api.get('/solicitudes/mias')).map(Solicitud.fromJson).toList();

  Future<List<Novedad>> novedades() async =>
      _lista(await api.get('/solicitudes/novedades')).map(Novedad.fromJson).toList();

  Future<Solicitud> detalle(int id) async =>
      Solicitud.fromJson(await api.get('/solicitudes/$id') as Map<String, dynamic>);

  Future<Solicitud> crear({
    required List<String> necesidades,
    String? otraNecesidad,
    required String urgencia,
    String? descripcion,
  }) async {
    final data = await api.post('/solicitudes', {
      'necesidades': necesidades,
      if (otraNecesidad != null && otraNecesidad.isNotEmpty) 'otraNecesidad': otraNecesidad,
      'urgencia': urgencia,
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
    });
    return Solicitud.fromJson(data as Map<String, dynamic>);
  }

  Future<Solicitud> cancelar(int id) async =>
      Solicitud.fromJson(await api.post('/solicitudes/$id/cancelar') as Map<String, dynamic>);

  Future<Solicitud> confirmarRecepcion(int id) async =>
      Solicitud.fromJson(await api.post('/solicitudes/$id/confirmar') as Map<String, dynamic>);

  /// null si la persona todavía no completó su perfil.
  Future<Perfil?> perfil() async {
    final data = await api.get('/me') as Map<String, dynamic>;
    final p = data['perfil'];
    return p == null ? null : Perfil.fromJson(p as Map<String, dynamic>);
  }

  Future<Perfil> guardarPerfil({
    required String documento,
    required String telefono,
    required String ubicacion,
  }) async {
    final data = await api.put('/me/perfil', {
      'documento': documento,
      'telefono': telefono,
      'ubicacion': ubicacion,
    }) as Map<String, dynamic>;
    return Perfil.fromJson(data['perfil'] as Map<String, dynamic>);
  }
}
