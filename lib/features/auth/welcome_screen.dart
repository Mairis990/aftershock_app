import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'auth_hero.dart';

/// Primera pantalla para quien no ha iniciado sesión.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHero(
              titulo: 'Ayuda que llega a quien la necesita',
              subtitulo: 'Conectamos a las personas afectadas con quienes quieren ayudar.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                children: [
                  _Opcion(
                    icono: Icons.health_and_safety_outlined,
                    titulo: 'Necesito ayuda',
                    detalle: 'Pide ayuda y sigue el estado de tu solicitud.',
                    color: AppColors.accent,
                    onTap: () => context.go('/registro?rol=afectada'),
                  ),
                  const SizedBox(height: 12),
                  _Opcion(
                    icono: Icons.favorite_outline,
                    titulo: 'Quiero donar',
                    detalle: 'Apoya campañas y mira el impacto de tu ayuda.',
                    color: AppColors.primary,
                    onTap: () => context.go('/registro?rol=donante'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta?'),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Ingresar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
                  child: Icon(icono, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(detalle,
                          style: const TextStyle(color: AppColors.muted, height: 1.3)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
