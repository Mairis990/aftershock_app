import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/estado_chip.dart';
import '../../widgets/future_body.dart';
import '../../widgets/status_timeline.dart';
import '../campanas/models.dart';
import '../solicitudes/models.dart';
import 'admin_service.dart';

/// Pasos válidos que puede dar el administrador (iguales a los del backend).
const Map<String, List<String>> _transiciones = {
  'Pendiente': ['En revisión', 'Rechazada'],
  'En revisión': ['En proceso', 'Rechazada'],
  'En proceso': ['Atendida', 'Rechazada'],
};

String _textoAvance(String estado) => switch (estado) {
      'En revisión' => 'Pasar a revisión',
      'En proceso' => 'Iniciar proceso',
      'Atendida' => 'Marcar atendida',
      _ => 'Pasar a "$estado"',
    };

class SolicitudAdminScreen extends StatefulWidget {
  const SolicitudAdminScreen({super.key, required this.id});
  final int id;

  @override
  State<SolicitudAdminScreen> createState() => _SolicitudAdminScreenState();
}

class _SolicitudAdminScreenState extends State<SolicitudAdminScreen> {
  late Future<Solicitud> _future;
  Solicitud? _actual;
  bool _trabajando = false;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  /// Carga el detalle y lo guarda también en `_actual` para la barra de acciones.
  Future<Solicitud> _cargar() async {
    final service = context.read<AdminService>();
    final s = await service.detalle(widget.id);
    if (mounted) setState(() => _actual = s);
    return s;
  }

  void _recargar() => setState(() => _future = _cargar());

  /// Ejecuta una acción, muestra errores en un aviso y vuelve a cargar el detalle.
  Future<void> _ejecutar(Future<void> Function(AdminService s) accion) async {
    final service = context.read<AdminService>();
    setState(() => _trabajando = true);
    try {
      await accion(service);
      if (mounted) setState(() => _future = _cargar());
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _cambiarEstado(Solicitud s, String nuevo) async {
    String? motivo;
    if (nuevo == 'Rechazada') {
      motivo = await showDialog<String>(
        context: context,
        builder: (_) => const _MotivoDialog(),
      );
      if (motivo == null) return;
    }
    if (!mounted) return;
    await _ejecutar((service) => service.cambiarEstado(s.id, nuevo, motivo: motivo));
  }

  Future<void> _registrarAyuda(Solicitud s) async {
    final service = context.read<AdminService>();
    var campanas = <Campana>[];
    try {
      campanas = (await service.campanas()).where((c) => c.verificada).toList();
    } on ApiException catch (_) {
      // Si no se pueden cargar las campañas, se puede registrar la ayuda sin asociarla.
    }
    if (!mounted) return;
    final datos = await showDialog<(String, int, int?)>(
      context: context,
      builder: (_) => _AyudaDialog(campanas: campanas),
    );
    if (datos == null || !mounted) return;
    await _ejecutar((svc) =>
        svc.registrarAyuda(s.id, tipo: datos.$1, cantidad: datos.$2, campanaId: datos.$3));
  }

  @override
  Widget build(BuildContext context) {
    final actual = _actual;
    return Scaffold(
      appBar: AppBar(title: Text('Solicitud #${widget.id}')),
      bottomNavigationBar: actual == null
          ? null
          : _BarraAcciones(
              solicitud: actual,
              trabajando: _trabajando,
              onEstado: (e) => _cambiarEstado(actual, e),
              onAyuda: () => _registrarAyuda(actual),
            ),
      body: FutureBody<Solicitud>(
        future: _future,
        onRetry: _recargar,
        builder: (context, s) {
          final siguientes = _transiciones[s.estado] ?? const <String>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (s.persona != null)
                _Tarjeta(
                  titulo: 'Persona',
                  child: Column(
                    children: [
                      _Dato(Icons.person_outline, s.persona!.nombre),
                      _Dato(Icons.mail_outline, s.persona!.correo),
                      _Dato(Icons.badge_outlined, s.persona!.documento ?? 'Sin documento'),
                      _Dato(Icons.phone_outlined, s.persona!.telefono ?? 'Sin teléfono'),
                      _Dato(Icons.place_outlined, s.persona!.ubicacion ?? 'Sin ubicación'),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              _Tarjeta(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        EstadoChip(s.estado),
                        const SizedBox(width: 12),
                        UrgenciaBadge(s.urgencia),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Enviada el ${fechaHora(s.creadoEn)}',
                        style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 14),
                    const Text('Necesidades', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final n in s.todasLasNecesidades)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCE6F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(n,
                                style: const TextStyle(
                                    color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    if (s.descripcion != null && s.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Mensaje', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(s.descripcion!, style: const TextStyle(height: 1.4)),
                    ],
                  ],
                ),
              ),
              if (s.estado == 'Rechazada' && s.motivoRechazo != null) ...[
                const SizedBox(height: 12),
                ErrorBanner('Motivo del rechazo: ${s.motivoRechazo}'),
              ],
              const SizedBox(height: 12),
              _Tarjeta(titulo: 'Seguimiento', child: StatusTimeline(s.historial)),
              const SizedBox(height: 12),
              _Tarjeta(
                titulo: 'Ayudas entregadas',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.ayudas.isEmpty)
                      const Text('Todavía no se registra ninguna ayuda.',
                          style: TextStyle(color: AppColors.muted)),
                    for (final a in s.ayudas)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${a.cantidad} × ${a.tipo}',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  if (a.campanaNombre != null)
                                    Text('Campaña ${a.campanaNombre}',
                                        style: const TextStyle(
                                            color: AppColors.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(fechaHora(a.fechaEntrega),
                                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (s.confirmadaEn != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF3E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            'La persona confirmó que recibió su ayuda el ${fechaHora(s.confirmadaEn!)}.',
                            style: const TextStyle(color: Color(0xFF1E6B43), height: 1.3)),
                      ),
                    ],
                  ),
                ),
              ],
              if (siguientes.isEmpty) ...[
                const SizedBox(height: 20),
                const Text('Esta solicitud ya no admite cambios de estado.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Barra fija abajo con las acciones disponibles según el estado.
class _BarraAcciones extends StatelessWidget {
  const _BarraAcciones({
    required this.solicitud,
    required this.trabajando,
    required this.onEstado,
    required this.onAyuda,
  });

  final Solicitud solicitud;
  final bool trabajando;
  final void Function(String estado) onEstado;
  final VoidCallback onAyuda;

  @override
  Widget build(BuildContext context) {
    final siguientes = _transiciones[solicitud.estado] ?? const <String>[];
    if (siguientes.isEmpty) return const SizedBox.shrink();
    final avance = siguientes.firstWhere((e) => e != 'Rechazada', orElse: () => '');
    final puedeRechazar = siguientes.contains('Rechazada');

    return Container(
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
            if (solicitud.estado == 'En proceso')
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton.icon(
                  onPressed: trabajando ? null : onAyuda,
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar ayuda entregada'),
                ),
              ),
            Row(
              children: [
                if (puedeRechazar)
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: trabajando ? null : () => onEstado('Rechazada'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                if (puedeRechazar && avance.isNotEmpty) const SizedBox(width: 10),
                if (avance.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: FilledButton(
                      onPressed: trabajando ? null : () => onEstado(avance),
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                      child: Text(_textoAvance(avance)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({this.titulo, required this.child});
  final String? titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) ...[
            Text(titulo!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.icono, this.texto);
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: const TextStyle(height: 1.3))),
        ],
      ),
    );
  }
}

class _MotivoDialog extends StatefulWidget {
  const _MotivoDialog();

  @override
  State<_MotivoDialog> createState() => _MotivoDialogState();
}

class _MotivoDialogState extends State<_MotivoDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aceptar() {
    final texto = _controller.text.trim();
    if (texto.length < 5) {
      setState(() => _error = 'Escribe el motivo (mínimo 5 letras).');
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Motivo del rechazo'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        maxLength: 300,
        decoration: InputDecoration(
          hintText: 'La persona verá este mensaje',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Volver')),
        TextButton(onPressed: _aceptar, child: const Text('Rechazar')),
      ],
    );
  }
}

class _AyudaDialog extends StatefulWidget {
  const _AyudaDialog({required this.campanas});
  final List<Campana> campanas;

  @override
  State<_AyudaDialog> createState() => _AyudaDialogState();
}

class _AyudaDialogState extends State<_AyudaDialog> {
  final _tipo = TextEditingController();
  final _cantidad = TextEditingController();
  int? _campanaId;
  String? _error;

  @override
  void dispose() {
    _tipo.dispose();
    _cantidad.dispose();
    super.dispose();
  }

  void _aceptar() {
    final tipo = _tipo.text.trim();
    final cantidad = int.tryParse(_cantidad.text.trim());
    if (tipo.length < 2) {
      setState(() => _error = 'Indica qué se entregó.');
      return;
    }
    if (cantidad == null || cantidad <= 0) {
      setState(() => _error = 'La cantidad debe ser un número mayor que 0.');
      return;
    }
    Navigator.of(context).pop((tipo, cantidad, _campanaId));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar ayuda'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tipo,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Qué se entregó (ej. Mercado, Agua)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cantidad,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad', errorText: _error),
            ),
            if (widget.campanas.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Campaña que la financió (opcional)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in widget.campanas)
                    ChoiceChip(
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(c.nombre, overflow: TextOverflow.ellipsis),
                      ),
                      selected: _campanaId == c.id,
                      onSelected: (v) => setState(() => _campanaId = v ? c.id : null),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Volver')),
        TextButton(onPressed: _aceptar, child: const Text('Guardar')),
      ],
    );
  }
}
