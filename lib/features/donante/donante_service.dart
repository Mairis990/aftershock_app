import '../../core/api/api_client.dart';
import '../campanas/models.dart';

/// Llamadas al backend que usa el donante.
class DonanteService {
  DonanteService(this.api);
  final ApiClient api;

  List<Map<String, dynamic>> _lista(dynamic data) =>
      (data as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();

  Future<List<Campana>> campanas() async =>
      _lista(await api.get('/campanas?estado=Verificada')).map(Campana.fromJson).toList();

  Future<Campana> campana(int id) async =>
      Campana.fromJson(await api.get('/campanas/$id') as Map<String, dynamic>);

  Future<Donacion> donar({
    required int campanaId,
    required int monto,
    required String metodoPago,
  }) async {
    final data = await api.post('/donaciones', {
      'campanaId': campanaId,
      'monto': monto,
      'metodoPago': metodoPago,
    });
    return Donacion.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Donacion>> mias() async =>
      _lista(await api.get('/donaciones/mias')).map(Donacion.fromJson).toList();
}
