import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/estado_chip.dart';
import '../../widgets/future_body.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/status_timeline.dart';
import '../solicitudes/models.dart';
import '../solicitudes/solicitudes_service.dart';

class SolicitudDetalleScreen extends StatefulWidget {
  const SolicitudDetalleScreen({super.key, required this.id});
  final int id;

  @override
  State<SolicitudDetalleScreen> createState() => _SolicitudDetalleScreenState();
}

class _SolicitudDetalleScreenState extends State<SolicitudDetalleScreen> {
  late Future<Solicitud> _future;
  bool _trabajando = false;

  @override
  void initState() {
    super.initState();
    _future = context.read<SolicitudesService>().detalle(widget.id);
  }

  void _recargar() =>
      setState(() => _future = context.read<SolicitudesService>().detalle(widget.id));

  /// Ejecuta una acción (cancelar / confirmar) y muestra el resultado sin volver a pedir todo.
  Future<void> _ejecutar(Future<Solicitud> Function(SolicitudesService s) accion) async {
    final service = context.read<SolicitudesService>();
    setState(() => _trabajando = true);
    try {
      final nueva = await accion(service);
      if (mounted) setState(() => _future = Future.value(nueva));
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _cancelar(Solicitud s) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cancelar la solicitud?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await _ejecutar((service) => service.cancelar(s.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Solicitud #${widget.id}')),
      body: FutureBody<Solicitud>(
        future: _future,
        onRetry: _recargar,
        builder: (context, s) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                    const Text('Tu mensaje', style: TextStyle(fontWeight: FontWeight.w800)),
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
            _Tarjeta(
              titulo: 'Seguimiento',
              child: StatusTimeline(s.historial),
            ),
            if (s.ayudas.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Tarjeta(
                titulo: 'Ayudas recibidas',
                child: Column(
                  children: [
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
                                    Text('Gracias a la campaña ${a.campanaNombre}',
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
            ],
            const SizedBox(height: 20),
            if (s.puedeConfirmar)
              LoadingButton(
                texto: 'Ya recibí mi ayuda',
                cargando: _trabajando,
                onPressed: () => _ejecutar((service) => service.confirmarRecepcion(s.id)),
              ),
            if (s.estado == 'Atendida' && s.confirmadaEn != null)
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
                      child: Text('Confirmaste que recibiste tu ayuda el ${fechaHora(s.confirmadaEn!)}.',
                          style: const TextStyle(color: Color(0xFF1E6B43), height: 1.3)),
                    ),
                  ],
                ),
              ),
            if (s.puedeCancelar)
              OutlinedButton(
                onPressed: _trabajando ? null : () => _cancelar(s),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancelar solicitud'),
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
