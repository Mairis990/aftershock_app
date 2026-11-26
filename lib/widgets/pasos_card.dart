import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Tarjeta corta con pasos numerados ("¿Cómo funciona?").
class PasosCard extends StatelessWidget {
  const PasosCard({super.key, required this.titulo, required this.pasos});
  final String titulo;
  final List<String> pasos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          for (var i = 0; i < pasos.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.primary,
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(pasos[i], style: const TextStyle(height: 1.3))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
