import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formato.dart';
import '../features/solicitudes/models.dart';
import 'estado_chip.dart';

/// Línea de tiempo vertical con los cambios de estado de una solicitud.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline(this.cambios, {super.key});
  final List<Cambio> cambios;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < cambios.length; i++)
          _Fila(cambio: cambios[i], ultimo: i == cambios.length - 1),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.cambio, required this.ultimo});
  final Cambio cambio;
  final bool ultimo;

  @override
  Widget build(BuildContext context) {
    final (_, colorTexto) = coloresEstado(cambio.estadoNuevo);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: colorTexto, shape: BoxShape.circle),
                ),
                if (!ultimo)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(alignment: Alignment.centerLeft, child: EstadoChip(cambio.estadoNuevo)),
                  const SizedBox(height: 4),
                  Text(fechaHora(cambio.fecha),
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  if (cambio.motivo != null && cambio.motivo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(cambio.motivo!, style: const TextStyle(height: 1.3)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
