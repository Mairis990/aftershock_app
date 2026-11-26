import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formato.dart';

/// (fondo, texto) para cada estado de una solicitud.
(Color, Color) coloresEstado(String estado) => switch (estado) {
      'Pendiente' => (const Color(0xFFFFF3D6), const Color(0xFF8A5A00)),
      'En revisión' => (const Color(0xFFE3EEFB), const Color(0xFF1F5FA8)),
      'En proceso' => (const Color(0xFFE6E8F7), const Color(0xFF3B3F9E)),
      'Atendida' => (const Color(0xFFDDF3E6), const Color(0xFF1E6B43)),
      'Rechazada' => (AppColors.errorBg, AppColors.error),
      _ => (const Color(0xFFEDEAE4), AppColors.muted),
    };

class EstadoChip extends StatelessWidget {
  const EstadoChip(this.estado, {super.key});
  final String estado;

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = coloresEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
      child: Text(
        estado,
        style: TextStyle(color: texto, fontWeight: FontWeight.w700, fontSize: 12.5),
      ),
    );
  }
}

class UrgenciaBadge extends StatelessWidget {
  const UrgenciaBadge(this.urgencia, {super.key});
  final String urgencia;

  @override
  Widget build(BuildContext context) {
    final color = switch (urgencia) {
      'critica' => AppColors.error,
      'urgente' => AppColors.warning,
      _ => AppColors.muted,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_rounded, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          urgenciaEtiqueta(urgencia),
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
        ),
      ],
    );
  }
}
