import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Qué puede hacer la persona si no tenemos su ubicación.
enum AccionUbicacion { reintentar, ajustesApp, ajustesGps }

class ResultadoUbicacion {
  const ResultadoUbicacion({this.posicion, this.motivo, this.accion = AccionUbicacion.reintentar});
  final LatLng? posicion;
  final String? motivo;
  final AccionUbicacion accion;
}

/// Pide permiso y obtiene la ubicación actual. Nunca lanza errores: devuelve un motivo.
/// La ubicación solo se usa en el celular para calcular distancias; no se envía al servidor.
Future<ResultadoUbicacion> obtenerUbicacion() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const ResultadoUbicacion(
        motivo: 'Activa el GPS de tu celular para ver las campañas cercanas.',
        accion: AccionUbicacion.ajustesGps,
      );
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.deniedForever) {
      return const ResultadoUbicacion(
        motivo: 'El permiso de ubicación está bloqueado. Actívalo en los ajustes de la app.',
        accion: AccionUbicacion.ajustesApp,
      );
    }
    if (permiso == LocationPermission.denied) {
      return const ResultadoUbicacion(
        motivo: 'Permite el acceso a tu ubicación para ver las campañas cercanas.',
      );
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return ResultadoUbicacion(posicion: LatLng(pos.latitude, pos.longitude));
  } catch (_) {
    return const ResultadoUbicacion(
      motivo: 'No pudimos obtener tu ubicación. Revisa que el GPS esté activo.',
    );
  }
}

/// Distancia en metros entre dos puntos.
double distanciaEntre(LatLng a, double lat, double lng) =>
    Geolocator.distanceBetween(a.latitude, a.longitude, lat, lng);
