import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_button.dart';
import '../campanas/models.dart';
import '../solicitudes/models.dart';
import '../solicitudes/solicitudes_service.dart';
import 'admin_service.dart';

class _DestinoFila {
  final concepto = TextEditingController();
  final porcentaje = TextEditingController();

  void dispose() {
    concepto.dispose();
    porcentaje.dispose();
  }
}

class CampanaFormScreen extends StatefulWidget {
  const CampanaFormScreen({super.key});

  @override
  State<CampanaFormScreen> createState() => _CampanaFormScreenState();
}

class _CampanaFormScreenState extends State<CampanaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _meta = TextEditingController();
  final _entidad = TextEditingController();
  final List<_DestinoFila> _destinos = [_DestinoFila(), _DestinoFila()];
  bool _guardando = false;
  String? _error;
  int? _necesidadId;
  LatLng? _ubicacion;
  final _direccion = TextEditingController();
  late Future<List<Necesidad>> _necesidades;

  @override
  void initState() {
    super.initState();
    _necesidades = context.read<SolicitudesService>().necesidades();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _meta.dispose();
    _entidad.dispose();
    _direccion.dispose();
    for (final d in _destinos) {
      d.dispose();
    }
    super.dispose();
  }

  int get _suma => _destinos.fold(0, (a, d) => a + (int.tryParse(d.porcentaje.text.trim()) ?? 0));

  Future<void> _elegirUbicacion() async {
    final punto = await context.push<LatLng>('/admin/ubicacion', extra: _ubicacion);
    if (!mounted) return;
    if (punto != null) setState(() => _ubicacion = punto);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_suma != 100) {
      setState(() => _error = 'Los porcentajes deben sumar 100 (ahora suman $_suma).');
      return;
    }
    final service = context.read<AdminService>();
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await service.crearCampana(
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        meta: int.parse(_meta.text.trim()),
        entidadResponsable: _entidad.text.trim(),
        necesidadId: _necesidadId,
        latitud: _ubicacion?.latitude,
        longitud: _ubicacion?.longitude,
        direccion: _direccion.text.trim().isEmpty ? null : _direccion.text.trim(),
        destinos: [
          for (final d in _destinos)
            Destino(
              concepto: d.concepto.text.trim(),
              porcentaje: int.parse(d.porcentaje.text.trim()),
            ),
        ],
      );
      if (!mounted) return;
      context.pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suma = _suma;
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva campaña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'La campaña se crea sin verificar. Cuando la verifiques, los donantes podrán verla y donar.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                ErrorBanner(_error!),
                const SizedBox(height: 16),
              ],
              AppTextField(
                controller: _nombre,
                label: 'Nombre de la campaña',
                prefixIcon: Icons.campaign_outlined,
                textInputAction: TextInputAction.next,
                validator: (v) => (v ?? '').trim().length < 5 ? 'Mínimo 5 letras' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descripcion,
                label: 'Descripción',
                maxLines: 3,
                validator: (v) => (v ?? '').trim().length < 10 ? 'Mínimo 10 letras' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _entidad,
                label: 'Entidad responsable',
                prefixIcon: Icons.apartment_outlined,
                textInputAction: TextInputAction.next,
                validator: (v) => (v ?? '').trim().length < 3 ? 'Mínimo 3 letras' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _meta,
                label: 'Meta en pesos (solo números)',
                prefixIcon: Icons.flag_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => RegExp(r'^[1-9]\d{0,9}$').hasMatch((v ?? '').trim())
                    ? null
                    : 'Escribe solo números, sin puntos',
              ),
              const SizedBox(height: 24),
              const Text('¿Qué necesidad atiende?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Así los donantes ven cuántas solicitudes abiertas hay de esa necesidad.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Necesidad>>(
                future: _necesidades,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (snap.hasError) {
                    return const Text('No se pudieron cargar las necesidades.',
                        style: TextStyle(color: AppColors.muted));
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Ninguna (campaña general)'),
                        selected: _necesidadId == null,
                        onSelected: (_) => setState(() => _necesidadId = null),
                      ),
                      for (final n in snap.data ?? const <Necesidad>[])
                        ChoiceChip(
                          label: Text(n.nombre),
                          selected: _necesidadId == n.id,
                          onSelected: (_) => setState(() => _necesidadId = n.id),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('¿Dónde se puede ayudar?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Marca el lugar en el mapa para que los donantes la vean cerca de ellos. Sin ubicación, la campaña no sale en el mapa.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    _ubicacion == null ? Icons.location_off_outlined : Icons.location_on,
                    color: _ubicacion == null ? AppColors.muted : AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _ubicacion == null
                          ? 'Sin ubicación'
                          : 'Ubicación elegida (${_ubicacion!.latitude.toStringAsFixed(4)}, ${_ubicacion!.longitude.toStringAsFixed(4)})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _elegirUbicacion,
                    child: Text(_ubicacion == null ? 'Elegir en el mapa' : 'Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _direccion,
                label: 'Dirección o referencia (opcional)',
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text('¿En qué se usará el dinero?',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  Text('$suma%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: suma == 100 ? AppColors.success : AppColors.error,
                      )),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Los porcentajes deben sumar 100.',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 12),
              for (var i = 0; i < _destinos.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          controller: _destinos[i].concepto,
                          label: 'Concepto',
                          validator: (v) => (v ?? '').trim().length < 2 ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 84,
                        child: AppTextField(
                          controller: _destinos[i].porcentaje,
                          label: '%',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            return (n == null || n < 1 || n > 100) ? '1-100' : null;
                          },
                        ),
                      ),
                      if (_destinos.length > 1)
                        IconButton(
                          tooltip: 'Quitar',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _destinos.removeAt(i).dispose();
                          }),
                        ),
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: _destinos.length >= 6
                    ? null
                    : () => setState(() => _destinos.add(_DestinoFila())),
                icon: const Icon(Icons.add),
                label: const Text('Agregar concepto'),
              ),
              const SizedBox(height: 20),
              LoadingButton(texto: 'Crear campaña', cargando: _guardando, onPressed: _guardar),
            ],
          ),
        ),
      ),
    );
  }
}
