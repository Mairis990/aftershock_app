import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Mensaje de error visible dentro de un formulario.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.mensaje, {super.key});
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(mensaje, style: const TextStyle(color: AppColors.error, height: 1.3)),
          ),
        ],
      ),
    );
  }
}
