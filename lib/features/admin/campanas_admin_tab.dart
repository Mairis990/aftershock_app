import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../widgets/campana_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_body.dart';
import '../campanas/models.dart';
import 'admin_service.dart';

class CampanasAdminTab extends StatefulWidget {
  const CampanasAdminTab({super.key});

  @override
  State<CampanasAdminTab> createState() => _CampanasAdminTabState();
}

class _CampanasAdminTabState extends State<CampanasAdminTab> {
  late Future<List<Campana>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AdminService>().campanas();
  }

  void _recargar() => setState(() => _future = context.read<AdminService>().campanas());

  Future<void> _verificar(Campana c) async {
    final service = context.read<AdminService>();
    try {
      await service.verificarCampana(c.id, !c.verificada);
      if (!mounted) return;
      _recargar();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _nueva() async {
    final creada = await context.push<bool>('/admin/campana/nueva');
    if (!mounted) return;
    if (creada == true) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Campañas',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: _nueva,
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBody<List<Campana>>(
              future: _future,
              onRetry: _recargar,
              builder: (context, lista) => RefreshIndicator(
                onRefresh: () async => _recargar(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    if (lista.isEmpty)
                      const EmptyState(
                        icono: Icons.campaign_outlined,
                        titulo: 'Aún no hay campañas',
                        texto: 'Crea la primera con el botón "Nueva".',
                      )
                    else
                      for (final c in lista)
                        CampanaCard(
                          campana: c,
                          acciones: Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: () => _verificar(c),
                              child: Text(c.verificada ? 'Quitar verificación' : 'Verificar campaña'),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
