import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session/session.dart';
import '../admin/admin_shell.dart';
import '../afectada/afectada_shell.dart';
import '../donante/donante_shell.dart';

/// Lleva a cada rol a su propio inicio.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<Session>().usuario;
    if (usuario == null) return const SizedBox.shrink();
    return switch (usuario.rol) {
      'afectada' => const AfectadaShell(),
      'donante' => const DonanteShell(),
      'administrador' => const AdminShell(),
      _ => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.read<Session>().logout(),
              child: const Text('Cerrar sesión'),
            ),
          ),
        ),
    };
  }
}
