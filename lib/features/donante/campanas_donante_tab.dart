import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/location/ubicacion_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/campana_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_body.dart';
import '../../widgets/mapa_comun.dart';
import '../../widgets/pasos_card.dart';
import '../campanas/models.dart';
import 'donante_service.dart';

class _Datos {
  _Datos(this.campanas, this.yaDono);
  final List<Campana> campanas;
  final bool yaDono;
}

/// Primera pantalla del donante: mapa con las campañas cercanas y lista ordenada por distancia.
class CampanasDonanteTab extends StatefulWidget {
  const CampanasDonanteTab({super.key, required this.onCambio});
  final VoidCallback onCambio;

  @override
  State<CampanasDonanteTab> createState() => _CampanasDonanteTabState();
}

class _CampanasDonanteTabState extends State<CampanasDonanteTab> {
  /// Si la campaña más cercana está a menos de esto, el mapa se centra en la persona.
  static const double _radioCercaMetros = 80000;

  late Future<_Datos> _future;
  final MapController _mapa = MapController();
  bool _mapaListo = false;
  List<Campana> _campanas = const [];
  ResultadoUbicacion? _ubicacion;
  bool _buscandoUbicacion = true;
  Campana? _seleccionada;

  LatLng? get _posicion => _ubicacion?.posicion;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
    _buscarUbicacion();
  }

  @override
  void dispose() {
    _mapa.dispose();
    super.dispose();
  }

  Future<_Datos> _cargar() async {
    final service = context.read<DonanteService>();
    final (campanas, donaciones) = await (service.campanas(), service.mias()).wait;
    _campanas = campanas;
    return _Datos(campanas, donaciones.isNotEmpty);
  }

  void _recargar() => setState(() {
        _mapaListo = false;
        _seleccionada = null;
        _future = _cargar();
      });

  Future<void> _buscarUbicacion() async {
    final r = await obtenerUbicacion();
    if (!mounted) return;
    setState(() {
      _ubicacion = r;
      _buscandoUbicacion = false;
    });
    if (_mapaListo) _irAMi();
  }

  double? _distancia(Campana c) {
    final pos = _posicion;
    if (pos == null || !c.tieneUbicacion) return null;
    return distanciaEntre(pos, c.latitud!, c.longitud!);
  }

  /// Centra el mapa en la persona. Sin `forzar`, solo si hay campañas cerca.
  void _irAMi({bool forzar = false}) {
    final pos = _posicion;
    if (pos == null) return;
    if (!forzar) {
      final distancias = _campanas.map(_distancia).whereType<double>();
      if (distancias.isEmpty || distancias.reduce((a, b) => a < b ? a : b) > _radioCercaMetros) {
        return;
      }
    }
    try {
      _mapa.move(pos, forzar ? 13 : 11.5);
    } catch (_) {
      // El mapa todavía no estaba listo; se queda en la vista general.
    }
  }

  /// Las más cercanas primero; las que no tienen ubicación, al final.
  List<Campana> _ordenadas(List<Campana> lista) {
    final copia = [...lista];
    copia.sort((a, b) {
      final da = _distancia(a);
      final db = _distancia(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return copia;
  }

  Future<void> _abrir(int id) async {
    await context.push<void>('/campana/$id');
    if (!mounted) return;
    widget.onCambio();
  }

  Future<void> _accionUbicacion() async {
    switch (_ubicacion?.accion) {
      case AccionUbicacion.ajustesApp:
        await Geolocator.openAppSettings();
      case AccionUbicacion.ajustesGps:
        await Geolocator.openLocationSettings();
      case AccionUbicacion.reintentar || null:
        break;
    }
    if (!mounted) return;
    setState(() => _buscandoUbicacion = true);
    await _buscarUbicacion();
  }

  List<Marker> _marcadores(List<Campana> campanas) {
    return [
      for (final c in campanas)
        if (c.tieneUbicacion)
          Marker(
            point: LatLng(c.latitud!, c.longitud!),
            width: 44,
            height: 44,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () => setState(() => _seleccionada = c),
              child: Icon(
                Icons.location_on,
                size: 44,
                color: _seleccionada?.id == c.id ? AppColors.accent : AppColors.primary,
              ),
            ),
          ),
      if (_posicion != null)
        Marker(
          point: _posicion!,
          width: 22,
          height: 22,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBody<_Datos>(
        future: _future,
        onRetry: _recargar,
        builder: (context, d) {
          final campanas = _ordenadas(d.campanas);
          final seleccionada = _seleccionada;
          final aviso = _ubicacion?.motivo;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cerca de ti',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                          Text(
                            _buscandoUbicacion
                                ? 'Buscando tu ubicación…'
                                : _posicion != null
                                    ? 'Campañas ordenadas por cercanía.'
                                    : 'Elige una causa y mira cómo ayudas.',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar',
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _recargar();
                        setState(() => _buscandoUbicacion = true);
                        _buscarUbicacion();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 260,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapa,
                          options: MapOptions(
                            initialCenter: _posicion ?? kCentroColombia,
                            initialZoom: kZoomColombia,
                            onTap: (_, _) => setState(() => _seleccionada = null),
                            onMapReady: () {
                              _mapaListo = true;
                              _irAMi();
                            },
                          ),
                          children: [
                            capaMosaicos(),
                            MarkerLayer(markers: _marcadores(campanas)),
                            atribucionOsm(),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: AppColors.surface,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              tooltip: 'Centrar en mi ubicación',
                              icon: const Icon(Icons.my_location),
                              onPressed: _posicion == null ? null : () => _irAMi(forzar: true),
                            ),
                          ),
                        ),
                        if (seleccionada != null)
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Material(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(seleccionada.nombre,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w800)),
                                          Text(
                                            [
                                              seleccionada.necesidad ?? 'Campaña general',
                                              if (_distancia(seleccionada) != null)
                                                'a ${distanciaTexto(_distancia(seleccionada)!)}',
                                            ].join(' · '),
                                            style: const TextStyle(
                                                color: AppColors.muted, fontSize: 12.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 40),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      onPressed: () => _abrir(seleccionada.id),
                                      child: const Text('Ver'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (aviso != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_off_outlined,
                            color: Color(0xFF8A5A00), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(aviso,
                              style: const TextStyle(color: Color(0xFF8A5A00), fontSize: 13)),
                        ),
                        TextButton(onPressed: _accionUbicacion, child: const Text('Activar')),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _recargar(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      if (!d.yaDono) ...[
                        const PasosCard(
                          titulo: '¿Cómo funciona?',
                          pasos: [
                            'Mira en el mapa dónde puedes ayudar.',
                            'Dona el monto que quieras (es una simulación).',
                            'Revisa tu historial e insignias en tu perfil.',
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (campanas.isEmpty)
                        const EmptyState(
                          icono: Icons.campaign_outlined,
                          titulo: 'Aún no hay campañas',
                          texto: 'Cuando el equipo verifique una campaña, la verás aquí.',
                        )
                      else
                        for (final c in campanas)
                          CampanaCard(
                            campana: c,
                            distancia:
                                _distancia(c) == null ? null : distanciaTexto(_distancia(c)!),
                            onTap: () => _abrir(c.id),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
