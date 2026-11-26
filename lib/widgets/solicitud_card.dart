import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formato.dart';
import '../features/solicitudes/models.dart';
import 'estado_chip.dart';

class SolicitudCard extends StatelessWidget {
  const SolicitudCard({
    super.key,
    required this.solicitud,
    required this.onTap,
    this.mostrarPersona = false,
  });
  final Solicitud solicitud;
  final bool mostrarPersona;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Solicitud #${solicitud.id}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    EstadoChip(solicitud.estado),
                  ],
                ),
                if (mostrarPersona && solicitud.personaNombre != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(solicitud.personaNombre!,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  solicitud.todasLasNecesidades.join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    UrgenciaBadge(solicitud.urgencia),
                    const Spacer(),
                    Text(fechaHora(solicitud.creadoEn),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
