import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session/session.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/future_body.dart';
import '../solicitudes/models.dart';
import '../solicitudes/solicitudes_service.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key, required this.onCambio});
  final VoidCallback onCambio;

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  late Future<Perfil?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<SolicitudesService>().perfil();
  }

  void _recargar() => setState(() => _future = context.read<SolicitudesService>().perfil());

  Future<void> _editar() async {
    await context.push<bool>('/perfil/editar');
    if (!mounted) return;
    widget.onCambio();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<Session>().usuario;
    if (usuario == null) return const SizedBox.shrink();

    return SafeArea(
      child: FutureBody<Perfil?>(
        future: _future,
        onRetry: _recargar,
        builder: (context, perfil) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.primary,
                child: Text(
                  usuario.nombre.trim().isEmpty ? '?' : usuario.nombre.trim()[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(usuario.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(usuario.correo,
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: perfil == null
                  ? const Text(
                      'Aún no completas tu perfil. Lo necesitas para poder pedir ayuda.',
                      style: TextStyle(color: AppColors.muted, height: 1.4),
                    )
                  : Column(
                      children: [
                        _Dato(icono: Icons.badge_outlined, etiqueta: 'Documento', valor: perfil.documento),
                        _Dato(icono: Icons.phone_outlined, etiqueta: 'Teléfono', valor: perfil.telefono),
                        _Dato(icono: Icons.place_outlined, etiqueta: 'Ubicación', valor: perfil.ubicacion),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _editar,
              child: Text(perfil == null ? 'Completar mi perfil' : 'Editar mi perfil'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => context.read<Session>().logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.etiqueta, required this.valor});
  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
