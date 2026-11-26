import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/future_body.dart';
import '../../widgets/loading_button.dart';
import '../solicitudes/models.dart';
import '../solicitudes/solicitudes_service.dart';

class _Datos {
  _Datos(this.necesidades, this.tienePerfil);
  final List<Necesidad> necesidades;
  final bool tienePerfil;
}

class NuevaSolicitudScreen extends StatefulWidget {
  const NuevaSolicitudScreen({super.key});

  @override
  State<NuevaSolicitudScreen> createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  late Future<_Datos> _future;
  final Set<String> _seleccion = {};
  bool _otro = false;
  final _otroCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _perfilKey = GlobalKey<FormState>();
  final _doc = TextEditingController();
  final _tel = TextEditingController();
  final _ubi = TextEditingController();
  String _urgencia = 'normal';
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  @override
  void dispose() {
    _otroCtrl.dispose();
    _descCtrl.dispose();
    _doc.dispose();
    _tel.dispose();
    _ubi.dispose();
    super.dispose();
  }

  Future<_Datos> _cargar() async {
    final service = context.read<SolicitudesService>();
    final (necesidades, perfil) = await (service.necesidades(), service.perfil()).wait;
    return _Datos(necesidades, perfil != null);
  }

  void _recargar() => setState(() => _future = _cargar());

  Future<void> _enviar(bool tienePerfil) async {
    final perfilOk = tienePerfil || (_perfilKey.currentState?.validate() ?? false);
    final otroTexto = _otroCtrl.text.trim();
    if (_otro && otroTexto.isEmpty) {
      setState(() => _error = 'Describe qué otra cosa necesitas o desmarca "Otro".');
      return;
    }
    if (_seleccion.isEmpty && !_otro) {
      setState(() => _error = 'Selecciona al menos una necesidad.');
      return;
    }
    if (!perfilOk) {
      setState(() => _error = 'Completa tus datos de contacto.');
      return;
    }
    final service = context.read<SolicitudesService>();
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      // La primera vez, se guardan los datos de contacto junto con la solicitud.
      if (!tienePerfil) {
        await service.guardarPerfil(
          documento: _doc.text.trim(),
          telefono: _tel.text.trim(),
          ubicacion: _ubi.text.trim(),
        );
      }
      final solicitud = await service.crear(
        necesidades: _seleccion.toList(),
        otraNecesidad: _otro ? otroTexto : null,
        urgencia: _urgencia,
        descripcion: _descCtrl.text.trim(),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('¡Solicitud enviada!'),
          content: Text(
              'Tu número de solicitud es #${solicitud.id}. Puedes seguir su estado en cualquier momento.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Ver seguimiento'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.pushReplacement('/solicitud/${solicitud.id}');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _chip(String etiqueta, bool seleccionado, VoidCallback onTap) {
    return FilterChip(
      label: Text(etiqueta),
      selected: seleccionado,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: seleccionado ? AppColors.primary : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : AppColors.text,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _formulario(List<Necesidad> necesidades, bool tienePerfil) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('¿Qué necesitas?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Puedes elegir varias opciones.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in necesidades)
              _chip(n.nombre, _seleccion.contains(n.nombre), () {
                setState(() {
                  if (!_seleccion.add(n.nombre)) _seleccion.remove(n.nombre);
                });
              }),
            _chip('Otro', _otro, () => setState(() => _otro = !_otro)),
          ],
        ),
        if (_otro) ...[
          const SizedBox(height: 14),
          AppTextField(
            controller: _otroCtrl,
            label: 'Describe qué otra cosa necesitas',
            prefixIcon: Icons.edit_outlined,
          ),
        ],
        const SizedBox(height: 28),
        const Text('¿Qué tan urgente es?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _UrgenciaCard(
                titulo: 'Normal',
                detalle: 'Puedo esperar',
                color: AppColors.primary,
                seleccionado: _urgencia == 'normal',
                onTap: () => setState(() => _urgencia = 'normal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _UrgenciaCard(
                titulo: 'Urgente',
                detalle: 'Lo antes posible',
                color: AppColors.warning,
                seleccionado: _urgencia == 'urgente',
                onTap: () => setState(() => _urgencia = 'urgente'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _UrgenciaCard(
                titulo: 'Crítica',
                detalle: 'Es una emergencia',
                color: AppColors.error,
                seleccionado: _urgencia == 'critica',
                onTap: () => setState(() => _urgencia = 'critica'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        AppTextField(
          controller: _descCtrl,
          label: 'Cuéntanos más (opcional)',
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        if (!tienePerfil) ...[
          const Text('Tus datos de contacto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Solo te los pedimos esta vez. Los ve únicamente el equipo administrador.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          Form(
            key: _perfilKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _doc,
                  label: 'Número de documento',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (v) => RegExp(r'^\d{5,12}$').hasMatch((v ?? '').trim())
                      ? null
                      : 'Solo números, entre 5 y 12 dígitos',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _tel,
                  label: 'Teléfono de contacto',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) => RegExp(r'^\d{7,12}$').hasMatch((v ?? '').trim())
                      ? null
                      : 'Solo números, entre 7 y 12 dígitos',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _ubi,
                  label: 'Dónde estás (barrio, dirección o referencia)',
                  prefixIcon: Icons.place_outlined,
                  validator: (v) => (v ?? '').trim().length < 5 ? 'Describe tu ubicación' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (_error != null) ...[
          ErrorBanner(_error!),
          const SizedBox(height: 16),
        ],
        LoadingButton(
          texto: 'Enviar solicitud',
          cargando: _enviando,
          onPressed: () => _enviar(tienePerfil),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedir ayuda')),
      body: FutureBody<_Datos>(
        future: _future,
        onRetry: _recargar,
        builder: (context, datos) => _formulario(datos.necesidades, datos.tienePerfil),
      ),
    );
  }
}

class _UrgenciaCard extends StatelessWidget {
  const _UrgenciaCard({
    required this.titulo,
    required this.detalle,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  final String titulo;
  final String detalle;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: seleccionado ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: seleccionado ? color : AppColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.flag_rounded, color: seleccionado ? Colors.white : color),
            const SizedBox(height: 6),
            Text(titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: seleccionado ? Colors.white : AppColors.text,
                )),
            const SizedBox(height: 2),
            Text(detalle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: seleccionado ? Colors.white : AppColors.muted,
                )),
          ],
        ),
      ),
    );
  }
}
