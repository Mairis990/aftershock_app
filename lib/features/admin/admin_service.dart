import '../../core/api/api_client.dart';
import '../campanas/models.dart';
import '../solicitudes/models.dart';

class PersonaResumen {
  PersonaResumen({
    required this.id,
    required this.nombre,
    required this.correo,
    this.documento,
    this.telefono,
    this.ubicacion,
    required this.totalSolicitudes,
  });
  factory PersonaResumen.fromJson(Map<String, dynamic> j) => PersonaResumen(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        correo: j['correo'] as String,
        documento: j['documento'] as String?,
        telefono: j['telefono'] as String?,
        ubicacion: j['ubicacion'] as String?,
        totalSolicitudes: (j['totalSolicitudes'] as num).toInt(),
      );
  final String id;
  final String nombre;
  final String correo;
  final String? documento;
  final String? telefono;
  final String? ubicacion;
  final int totalSolicitudes;
}

/// Llamadas al backend que solo usa el administrador.
class AdminService {
  AdminService(this.api);
  final ApiClient api;

  List<Map<String, dynamic>> _lista(dynamic data) =>
      (data as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();

  Future<List<Solicitud>> solicitudes() async =>
      _lista(await api.get('/solicitudes')).map(Solicitud.fromJson).toList();

  Future<Solicitud> detalle(int id) async =>
      Solicitud.fromJson(await api.get('/solicitudes/$id') as Map<String, dynamic>);

  Future<void> cambiarEstado(int id, String estado, {String? motivo}) async {
    await api.patch('/solicitudes/$id/estado', {
      'estado': estado,
      if (motivo != null && motivo.isNotEmpty) 'motivo': motivo,
    });
  }

  Future<void> registrarAyuda(
    int id, {
    required String tipo,
    required int cantidad,
    int? campanaId,
  }) async {
    await api.post('/solicitudes/$id/ayudas', {
      'tipo': tipo,
      'cantidad': cantidad,
      'campanaId': ?campanaId,
    });
  }

  Future<List<PersonaResumen>> personas() async =>
      _lista(await api.get('/personas')).map(PersonaResumen.fromJson).toList();

  Future<List<Campana>> campanas() async =>
      _lista(await api.get('/campanas')).map(Campana.fromJson).toList();

  Future<void> crearCampana({
    required String nombre,
    required String descripcion,
    required int meta,
    required String entidadResponsable,
    required List<Destino> destinos,
    int? necesidadId,
    double? latitud,
    double? longitud,
    String? direccion,
  }) async {
    await api.post('/campanas', {
      'nombre': nombre,
      'descripcion': descripcion,
      'meta': meta,
      'entidadResponsable': entidadResponsable,
      'necesidadId': ?necesidadId,
      'latitud': ?latitud,
      'longitud': ?longitud,
      'direccion': ?direccion,
      'destinos': [
        for (final d in destinos) {'concepto': d.concepto, 'porcentaje': d.porcentaje},
      ],
    });
  }

  Future<void> verificarCampana(int id, bool verificada) async {
    await api.patch('/campanas/$id/verificar', {'verificada': verificada});
  }
}
