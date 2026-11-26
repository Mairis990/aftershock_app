class Destino {
  Destino({required this.concepto, required this.porcentaje});
  factory Destino.fromJson(Map<String, dynamic> j) =>
      Destino(concepto: j['concepto'] as String, porcentaje: (j['porcentaje'] as num).toInt());
  final String concepto;
  final int porcentaje;
}

class Campana {
  Campana({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.verificada,
    required this.meta,
    required this.recaudo,
    required this.entidadResponsable,
    required this.destinos,
    this.necesidadId,
    this.necesidad,
    this.solicitudesAbiertas,
    this.ayudasEntregadas = 0,
    this.latitud,
    this.longitud,
    this.direccion,
  });

  factory Campana.fromJson(Map<String, dynamic> j) => Campana(
        id: j['id'] as int,
        nombre: j['nombre'] as String,
        descripcion: j['descripcion'] as String,
        verificada: j['verificada'] as bool,
        meta: (j['meta'] as num).toInt(),
        recaudo: (j['recaudo'] as num).toInt(),
        entidadResponsable: j['entidadResponsable'] as String,
        destinos: ((j['destinos'] as List<dynamic>?) ?? const [])
            .map((e) => Destino.fromJson(e as Map<String, dynamic>))
            .toList(),
        necesidadId: j['necesidadId'] as int?,
        necesidad: j['necesidad'] as String?,
        solicitudesAbiertas: (j['solicitudesAbiertas'] as num?)?.toInt(),
        ayudasEntregadas: (j['ayudasEntregadas'] as num?)?.toInt() ?? 0,
        latitud: (j['latitud'] as num?)?.toDouble(),
        longitud: (j['longitud'] as num?)?.toDouble(),
        direccion: j['direccion'] as String?,
      );

  final int id;
  final String nombre;
  final String descripcion;
  final bool verificada;
  final int meta;
  final int recaudo;
  final String entidadResponsable;
  final List<Destino> destinos;
  final int? necesidadId;
  final String? necesidad;
  final int? solicitudesAbiertas;
  final int ayudasEntregadas;
  final double? latitud;
  final double? longitud;
  final String? direccion;

  bool get tieneUbicacion => latitud != null && longitud != null;

  double get progreso => meta <= 0 ? 0 : (recaudo / meta).clamp(0.0, 1.0).toDouble();
  int get porcentaje => (progreso * 100).round();
  bool get metaAlcanzada => meta > 0 && recaudo >= meta;

  /// "Agua · 2 solicitudes abiertas" (null si la campaña es general).
  String? get etiquetaNecesidad {
    final n = necesidad;
    if (n == null) return null;
    final abiertas = solicitudesAbiertas;
    if (abiertas == null) return n;
    return '$n · ${abiertas == 1 ? '1 solicitud abierta' : '$abiertas solicitudes abiertas'}';
  }
}

/// Donación simulada hecha por un donante.
class Donacion {
  Donacion({
    required this.id,
    required this.campanaId,
    this.campanaNombre,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    required this.fecha,
    this.aviso,
  });

  factory Donacion.fromJson(Map<String, dynamic> j) => Donacion(
        id: j['id'] as int,
        campanaId: j['campanaId'] as int,
        campanaNombre: j['campanaNombre'] as String?,
        monto: (j['monto'] as num).toInt(),
        metodoPago: j['metodoPago'] as String,
        estado: j['estado'] as String,
        fecha: DateTime.parse(j['fecha'] as String).toLocal(),
        aviso: j['aviso'] as String?,
      );

  final int id;
  final int campanaId;
  final String? campanaNombre;
  final int monto;
  final String metodoPago;
  final String estado;
  final DateTime fecha;
  final String? aviso;

  Donacion conCampana(String nombre) => Donacion(
        id: id,
        campanaId: campanaId,
        campanaNombre: nombre,
        monto: monto,
        metodoPago: metodoPago,
        estado: estado,
        fecha: fecha,
        aviso: aviso,
      );
}
