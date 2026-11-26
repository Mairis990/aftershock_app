import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_body.dart';
import 'admin_service.dart';

class PersonasTab extends StatefulWidget {
  const PersonasTab({super.key});

  @override
  State<PersonasTab> createState() => _PersonasTabState();
}

class _PersonasTabState extends State<PersonasTab> {
  late Future<List<PersonaResumen>> _future;
  final _busqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = context.read<AdminService>().personas();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _recargar() => setState(() => _future = context.read<AdminService>().personas());

  @override
  Widget build(BuildContext context) {
    final texto = _busqueda.text.trim().toLowerCase();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Personas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppTextField(
              controller: _busqueda,
              label: 'Buscar por nombre o documento',
              prefixIcon: Icons.search,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBody<List<PersonaResumen>>(
              future: _future,
              onRetry: _recargar,
              builder: (context, todas) {
                final lista = todas
                    .where((p) =>
                        texto.isEmpty ||
                        p.nombre.toLowerCase().contains(texto) ||
                        (p.documento ?? '').contains(texto))
                    .toList();
                return RefreshIndicator(
                  onRefresh: () async => _recargar(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      if (lista.isEmpty)
                        const EmptyState(
                          icono: Icons.people_outline,
                          titulo: 'No hay personas para mostrar',
                          texto: 'Aquí aparecen las personas afectadas que se registran en la app.',
                        )
                      else
                        for (final p in lista) _PersonaCard(persona: p),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  const _PersonaCard({required this.persona});
  final PersonaResumen persona;

  Widget _fila(IconData icono, String texto) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 16, color: AppColors.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(texto, style: const TextStyle(height: 1.3))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final completo = persona.documento != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(persona.nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE6F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  persona.totalSolicitudes == 1
                      ? '1 solicitud'
                      : '${persona.totalSolicitudes} solicitudes',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          _fila(Icons.mail_outline, persona.correo),
          if (completo) ...[
            _fila(Icons.badge_outlined, persona.documento!),
            _fila(Icons.phone_outlined, persona.telefono ?? ''),
            _fila(Icons.place_outlined, persona.ubicacion ?? ''),
          ] else
            _fila(Icons.info_outline, 'Aún no completa su perfil'),
        ],
      ),
    );
  }
}
