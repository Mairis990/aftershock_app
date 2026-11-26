import 'package:flutter/material.dart';

/// Botón principal que muestra un círculo de carga y se bloquea mientras trabaja.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.texto,
    required this.onPressed,
    required this.cargando,
  });

  final String texto;
  final VoidCallback onPressed;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: cargando ? null : onPressed,
      child: cargando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            )
          : Text(texto),
    );
  }
}
