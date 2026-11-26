DateTime _fecha(dynamic v) => DateTime.parse(v as String).toLocal();
DateTime? _fechaOpt(dynamic v) => v == null ? null : _fecha(v);

class Necesidad {
  Necesidad({required this.id, required this.nombre});
  factory Necesidad.fromJson(Map<String, dynamic> j) =>
      Necesidad(id: j['id'] as int, nombre: j['nombre'] as String);
  final int id;
  final String nombre;
}

class Perfil {
  Perfil({required this.documento, required this.telefono, required this.ubicacion});
  factory Perfil.fromJson(Map<String, dynamic> j) => Perfil(
        documento: j['documento'] as String,
        telefono: j['telefono'] as String,
        ubicacion: j['ubicacion'] as String,
      );
  final String documento;
  final String telefono;
  final String ubicacion;
}

class Ayuda {
  Ayuda({
    required this.id,
    required this.tipo,
    required this.cantidad,
    required this.fechaEntrega,
    this.campanaNombre,
  });
  factory Ayuda.fromJson(Map<String, dynamic> j) => Ayuda(
        id: j['id'] as int,
        tipo: j['tipo'] as String,
        cantidad: j['cantidad'] as int,
        fechaEntrega: _fecha(j['fechaEntrega']),
        campanaNombre: j['campanaNombre'] as String?,
      );
  final int id;
  final String tipo;
  final int cantidad;
  final DateTime fechaEntrega;
  final String? campanaNombre;
}

/// Un cambio de estado dentro del historial de una solicitud.
class Cambio {
  Cambio({this.estadoAnterior, required this.estadoNuevo, this.motivo, required this.fecha});
  factory Cambio.fromJson(Map<String, dynamic> j) => Cambio(
        estadoAnterior: j['estadoAnterior'] as String?,
        estadoNuevo: j['estadoNuevo'] as String,
        motivo: j['motivo'] as String?,
        fecha: _fecha(j['fecha']),
      );
  final String? estadoAnterior;
  final String estadoNuevo;
  final String? motivo;
  final DateTime fecha;
}

/// Un cambio de estado, pero visto desde "Novedades" (incluye qué solicitud es).
class Novedad {
  Novedad({
    required this.solicitudId,
    this.estadoAnterior,
    required this.estadoNuevo,
    this.motivo,
    required this.fecha,
  });
  factory Novedad.fromJson(Map<String, dynamic> j) => Novedad(
        solicitudId: j['solicitudId'] as int,
        estadoAnterior: j['estadoAnterior'] as String?,
        estadoNuevo: j['estadoNuevo'] as String,
        motivo: j['motivo'] as String?,
        fecha: _fecha(j['fecha']),
      );
  final int solicitudId;
  final String? estadoAnterior;
  final String estadoNuevo;
  final String? motivo;
  final DateTime fecha;

  String get texto {
    if (estadoAnterior == null) return 'Enviaste la solicitud #$solicitudId';
    if (estadoNuevo == 'Cancelada') return 'Cancelaste la solicitud #$solicitudId';
    return 'Tu solicitud #$solicitudId pasó a "$estadoNuevo"';
  }
}

/// Datos de la persona que hizo la solicitud (los ve el administrador).
class PersonaSolicitud {
  PersonaSolicitud({
    required this.nombre,
    required this.correo,
    this.documento,
    this.telefono,
    this.ubicacion,
  });
  factory PersonaSolicitud.fromJson(Map<String, dynamic> j) => PersonaSolicitud(
        nombre: j['nombre'] as String,
        correo: j['correo'] as String,
        documento: j['documento'] as String?,
        telefono: j['telefono'] as String?,
        ubicacion: j['ubicacion'] as String?,
      );
  final String nombre;
  final String correo;
  final String? documento;
  final String? telefono;
  final String? ubicacion;
}

class Solicitud {
  Solicitud({
    required this.id,
    required this.estado,
    required this.urgencia,
    this.descripcion,
    this.motivoRechazo,
    this.otraNecesidad,
    this.confirmadaEn,
    required this.creadoEn,
    required this.necesidades,
    this.ayudas = const [],
    this.historial = const [],
    this.personaNombre,
    this.persona,
  });

  factory Solicitud.fromJson(Map<String, dynamic> j) => Solicitud(
        id: j['id'] as int,
        estado: j['estado'] as String,
        urgencia: j['urgencia'] as String,
        descripcion: j['descripcion'] as String?,
        motivoRechazo: j['motivoRechazo'] as String?,
        otraNecesidad: j['otraNecesidad'] as String?,
        confirmadaEn: _fechaOpt(j['confirmadaEn']),
        creadoEn: _fecha(j['creadoEn']),
        necesidades: ((j['necesidades'] as List<dynamic>?) ?? const [])
            .map((e) => e as String)
            .toList(),
        ayudas: ((j['ayudas'] as List<dynamic>?) ?? const [])
            .map((e) => Ayuda.fromJson(e as Map<String, dynamic>))
            .toList(),
        historial: ((j['historial'] as List<dynamic>?) ?? const [])
            .map((e) => Cambio.fromJson(e as Map<String, dynamic>))
            .toList(),
        personaNombre: j['personaNombre'] as String?,
        persona: j['persona'] == null
            ? null
            : PersonaSolicitud.fromJson(j['persona'] as Map<String, dynamic>),
      );

  final int id;
  final String estado;
  final String urgencia;
  final String? descripcion;
  final String? motivoRechazo;
  final String? otraNecesidad;
  final DateTime? confirmadaEn;
  final DateTime creadoEn;
  final List<String> necesidades;
  final List<Ayuda> ayudas;
  final List<Cambio> historial;
  final String? personaNombre;
  final PersonaSolicitud? persona;

  bool get puedeCancelar => estado == 'Pendiente';
  bool get puedeConfirmar => estado == 'Atendida' && confirmadaEn == null;

  /// Necesidades de la lista + la que escribió en "Otro".
  List<String> get todasLasNecesidades => [
        ...necesidades,
        if (otraNecesidad != null && otraNecesidad!.isNotEmpty) 'Otro: $otraNecesidad',
      ];
}
