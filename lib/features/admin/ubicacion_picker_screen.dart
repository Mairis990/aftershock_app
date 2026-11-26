import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/location/ubicacion_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/mapa_comun.dart';

/// Pantalla completa para que el administrador marque dónde se puede ayudar.
/// Devuelve el punto elegido (LatLng) al confirmar.
class UbicacionPickerScreen extends StatefulWidget {
  const UbicacionPickerScreen({super.key, this.inicial});
  final LatLng? inicial;

  @override
  State<UbicacionPickerScreen> createState() => _UbicacionPickerScreenState();
}

class _UbicacionPickerScreenState extends State<UbicacionPickerScreen> {
  final MapController _mapa = MapController();
  LatLng? _punto;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _punto = widget.inicial;
  }

  @override
  void dispose() {
    _mapa.dispose();
    super.dispose();
  }

  Future<void> _irAMiUbicacion() async {
    setState(() => _buscando = true);
    final r = await obtenerUbicacion();
    if (!mounted) return;
    setState(() => _buscando = false);
    final pos = r.posicion;
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.motivo ?? 'No pudimos obtener tu ubicación.')),
      );
      return;
    }
    _mapa.move(pos, 14);
  }

  @override
  Widget build(BuildContext context) {
    final punto = _punto;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir ubicación'),
        actions: [
          IconButton(
            tooltip: 'Ir a mi ubicación',
            onPressed: _buscando ? null : _irAMiUbicacion,
            icon: _buscando
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapa,
        options: MapOptions(
          initialCenter: punto ?? kCentroColombia,
          initialZoom: punto == null ? kZoomColombia : 13,
          onTap: (_, p) => setState(() => _punto = p),
        ),
        children: [
          capaMosaicos(),
          if (punto != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: punto,
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on, size: 48, color: AppColors.accent),
                ),
              ],
            ),
          atribucionOsm(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                punto == null
                    ? 'Toca el mapa para marcar el lugar.'
                    : 'Ubicación marcada. Toca otro punto para cambiarla.',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: punto == null ? null : () => context.pop(punto),
                child: const Text('Confirmar ubicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
