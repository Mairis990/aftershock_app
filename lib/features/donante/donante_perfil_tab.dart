import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/future_body.dart';
import '../campanas/models.dart';
import 'donante_service.dart';
import 'insignias.dart';

class DonantePerfilTab extends StatefulWidget {
  const DonantePerfilTab({super.key});

  @override
  State<DonantePerfilTab> createState() => _DonantePerfilTabState();
}

class _DonantePerfilTabState extends State<DonantePerfilTab> {
  late Future<List<Donacion>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DonanteService>().mias();
  }

  void _recargar() => setState(() => _future = context.read<DonanteService>().mias());

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<Session>().usuario;
    if (usuario == null) return const SizedBox.shrink();

    return SafeArea(
      child: FutureBody<List<Donacion>>(
        future: _future,
        onRetry: _recargar,
        builder: (context, donaciones) {
          final insignias = calcularInsignias(donaciones);
          final total = donaciones.fold<int>(0, (a, d) => a + d.monto);
          final ganadas = insignias.where((i) => i.ganada).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    usuario.nombre.trim().isEmpty ? '?' : usuario.nombre.trim()[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _Dato(valor: '${donaciones.length}', etiqueta: 'Donaciones')),
                  const SizedBox(width: 12),
                  Expanded(child: _Dato(valor: pesos(total), etiqueta: 'Total donado')),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text('Mis insignias',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  Text('$ganadas de ${insignias.length}',
                      style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [for (final i in insignias) _InsigniaCard(insignia: i)],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.read<Session>().logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.valor, required this.etiqueta});
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(valor,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(etiqueta, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _InsigniaCard extends StatelessWidget {
  const _InsigniaCard({required this.insignia});
  final Insignia insignia;

  @override
  Widget build(BuildContext context) {
    final ganada = insignia.ganada;
    final avance = insignia.actual > insignia.meta ? insignia.meta : insignia.actual;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ganada ? AppColors.accent : AppColors.border, width: ganada ? 1.5 : 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: ganada ? AppColors.accent : const Color(0xFFEDEAE4),
            child: Icon(insignia.icono, color: ganada ? Colors.white : AppColors.muted, size: 26),
          ),
          const SizedBox(height: 10),
          Text(insignia.nombre,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: ganada ? AppColors.text : AppColors.muted,
              )),
          const SizedBox(height: 2),
          Text(insignia.descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.25)),
          const SizedBox(height: 8),
          if (ganada)
            const Text('Conseguida',
                style: TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 12.5))
          else
            Text('$avance de ${insignia.meta}',
                style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 12.5)),
        ],
      ),
    );
  }
}
