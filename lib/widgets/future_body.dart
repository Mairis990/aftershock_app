import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';

/// Muestra carga, error con botón "Reintentar" o el contenido cuando llegan los datos.
class FutureBody<T> extends StatelessWidget {
  const FutureBody({
    super.key,
    required this.future,
    required this.builder,
    required this.onRetry,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          final error = snap.error;
          final mensaje = error is ApiException ? error.message : 'No se pudo cargar la información.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.muted),
                  const SizedBox(height: 12),
                  Text(mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
                ],
              ),
            ),
          );
        }
        return builder(context, snap.data as T);
      },
    );
  }
}
