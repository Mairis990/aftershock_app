import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session/session.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/estado_chip.dart';
import '../../widgets/future_body.dart';
import '../solicitudes/models.dart';
import 'admin_service.dart';

const List<String> _estados = [
  'Pendiente',
  'En revisión',
  'En proceso',
  'Atendida',
  'Rechazada',
  'Cancelada',
];

class PanelTab extends StatefulWidget {
  const PanelTab({super.key, required this.onVerSolicitudes});
  final void Function(String? estado) onVerSolicitudes;

  @override
  State<PanelTab> createState() => _PanelTabState();
}

class _PanelTabState extends State<PanelTab> {
  late Future<List<Solicitud>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AdminService>().solicitudes();
  }

  void _recargar() => setState(() => _future = context.read<AdminService>().solicitudes());

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<Session>().usuario;
    return SafeArea(
      child: FutureBody<List<Solicitud>>(
        future: _future,
        onRetry: _recargar,
        builder: (context, lista) {
          final conteo = {for (final e in _estados) e: lista.where((s) => s.estado == e).length};
          final criticas = lista
              .where((s) =>
                  s.urgencia == 'critica' &&
                  (s.estado == 'Pendiente' || s.estado == 'En revisión' || s.estado == 'En proceso'))
              .length;

          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Panel',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                          Text('Hola, ${usuario?.primerNombre ?? ''}',
                              style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar sesión',
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<Session>().logout(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (criticas > 0) ...[
                  Material(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onVerSolicitudes(null),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                criticas == 1
                                    ? 'Hay 1 solicitud crítica abierta'
                                    : 'Hay $criticas solicitudes críticas abiertas',
                                style: const TextStyle(
                                    color: AppColors.error, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.error),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text('Total de solicitudes: ${lista.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    for (final e in _estados)
                      _Contador(
                        estado: e,
                        cantidad: conteo[e] ?? 0,
                        onTap: () => widget.onVerSolicitudes(e),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.estado, required this.cantidad, required this.onTap});
  final String estado;
  final int cantidad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = coloresEstado(estado);
    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$cantidad',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: texto)),
              Text(estado, style: TextStyle(fontWeight: FontWeight.w700, color: texto)),
            ],
          ),
        ),
      ),
    );
  }
}
