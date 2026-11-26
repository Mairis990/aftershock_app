import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../widgets/empty_state.dart';
import '../../widgets/future_body.dart';
import '../../widgets/solicitud_card.dart';
import '../solicitudes/models.dart';
import '../solicitudes/solicitudes_service.dart';

class SolicitudesTab extends StatefulWidget {
  const SolicitudesTab({super.key, required this.onCambio});
  final VoidCallback onCambio;

  @override
  State<SolicitudesTab> createState() => _SolicitudesTabState();
}

class _SolicitudesTabState extends State<SolicitudesTab> {
  late Future<List<Solicitud>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<SolicitudesService>().mias();
  }

  void _recargar() => setState(() => _future = context.read<SolicitudesService>().mias());

  Future<void> _abrir(int id) async {
    await context.push<void>('/solicitud/$id');
    if (!mounted) return;
    widget.onCambio();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Mis solicitudes',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: FutureBody<List<Solicitud>>(
              future: _future,
              onRetry: _recargar,
              builder: (context, lista) => RefreshIndicator(
                onRefresh: () async => _recargar(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    if (lista.isEmpty)
                      const EmptyState(
                        icono: Icons.inbox_outlined,
                        titulo: 'Aún no tienes solicitudes',
                        texto: 'Cuando pidas ayuda, aquí verás el estado de cada solicitud.',
                      )
                    else
                      for (final s in lista) SolicitudCard(solicitud: s, onTap: () => _abrir(s.id)),
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
