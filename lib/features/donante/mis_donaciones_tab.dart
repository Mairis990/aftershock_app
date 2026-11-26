import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_body.dart';
import '../campanas/models.dart';
import 'donante_service.dart';

class MisDonacionesTab extends StatefulWidget {
  const MisDonacionesTab({super.key});

  @override
  State<MisDonacionesTab> createState() => _MisDonacionesTabState();
}

class _MisDonacionesTabState extends State<MisDonacionesTab> {
  late Future<List<Donacion>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DonanteService>().mias();
  }

  void _recargar() => setState(() => _future = context.read<DonanteService>().mias());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBody<List<Donacion>>(
        future: _future,
        onRetry: _recargar,
        builder: (context, lista) {
          final total = lista.fold<int>(0, (a, d) => a + d.monto);
          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                const Text('Mis donaciones',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                if (lista.isEmpty)
                  const EmptyState(
                    icono: Icons.receipt_long_outlined,
                    titulo: 'Aún no has donado',
                    texto: 'Cuando hagas tu primera donación, aparecerá aquí con su comprobante.',
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total donado (simulado)',
                            style: TextStyle(color: Color(0xFFD5DEEB))),
                        const SizedBox(height: 4),
                        Text(pesos(total),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(
                          lista.length == 1 ? 'en 1 donación' : 'en ${lista.length} donaciones',
                          style: const TextStyle(color: Color(0xFFD5DEEB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final d in lista) _DonacionCard(donacion: d),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DonacionCard extends StatelessWidget {
  const _DonacionCard({required this.donacion});
  final Donacion donacion;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFDCE6F3), shape: BoxShape.circle),
            child: const Icon(Icons.favorite, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donacion.campanaNombre ?? 'Campaña #${donacion.campanaId}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${donacion.metodoPago} · ${fechaHora(donacion.fecha)}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(pesos(donacion.monto), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(donacion.estado,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
