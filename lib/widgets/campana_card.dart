import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formato.dart';
import '../features/campanas/models.dart';

/// Tarjeta de campaña con barra de progreso. `acciones` permite agregar botones debajo.
class CampanaCard extends StatelessWidget {
  const CampanaCard({
    super.key,
    required this.campana,
    this.onTap,
    this.acciones,
    this.distancia,
  });
  final Campana campana;
  final String? distancia;
  final VoidCallback? onTap;
  final Widget? acciones;

  @override
  Widget build(BuildContext context) {
    final verificada = campana.verificada;
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: verificada ? const Color(0xFFDDF3E6) : const Color(0xFFFFF3D6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(verificada ? Icons.verified : Icons.hourglass_top_rounded,
                              size: 14,
                              color: verificada ? const Color(0xFF1E6B43) : const Color(0xFF8A5A00)),
                          const SizedBox(width: 4),
                          Text(verificada ? 'Verificada' : 'En revisión',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: verificada ? const Color(0xFF1E6B43) : const Color(0xFF8A5A00),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(campana.nombre,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(campana.entidadResponsable,
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                if (campana.direccion != null || distancia != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 16, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            if (campana.direccion != null) campana.direccion!,
                            if (distancia != null) 'a $distancia',
                          ].join(' · '),
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
                if (campana.etiquetaNecesidad != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE6F3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volunteer_activism_outlined,
                            size: 15, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            campana.etiquetaNecesidad!,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(campana.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(height: 1.35)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: campana.progreso,
                    minHeight: 10,
                    backgroundColor: AppColors.border,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('${pesos(campana.recaudo)} de ${pesos(campana.meta)}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    Text(campana.metaAlcanzada ? 'Meta alcanzada' : '${campana.porcentaje}%',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                if (acciones != null) ...[
                  const SizedBox(height: 12),
                  acciones!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
