import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/campana_card.dart';
import '../../widgets/future_body.dart';
import '../campanas/models.dart';
import 'donante_service.dart';

class CampanaDetalleScreen extends StatefulWidget {
  const CampanaDetalleScreen({super.key, required this.id});
  final int id;

  @override
  State<CampanaDetalleScreen> createState() => _CampanaDetalleScreenState();
}

class _CampanaDetalleScreenState extends State<CampanaDetalleScreen> {
  late Future<Campana> _future;
  Campana? _actual;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<Campana> _cargar() async {
    final service = context.read<DonanteService>();
    final c = await service.campana(widget.id);
    if (mounted) setState(() => _actual = c);
    return c;
  }

  void _recargar() => setState(() => _future = _cargar());

  Future<void> _donar() async {
    await context.push<void>('/campana/${widget.id}/donar');
    if (!mounted) return;
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final actual = _actual;
    return Scaffold(
      appBar: AppBar(title: const Text('Campaña')),
      bottomNavigationBar: (actual == null || !actual.verificada)
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: FilledButton(onPressed: _donar, child: const Text('Donar a esta campaña')),
              ),
            ),
      body: FutureBody<Campana>(
        future: _future,
        onRetry: _recargar,
        builder: (context, c) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CampanaCard(campana: c),
            _Seccion(
              titulo: 'Sobre esta campaña',
              child: Text(c.descripcion, style: const TextStyle(height: 1.45)),
            ),
            if (c.necesidad != null) ...[
              const SizedBox(height: 12),
              _Seccion(
                titulo: 'Necesidad que atiende',
                child: Row(
                  children: [
                    const Icon(Icons.volunteer_activism_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(c.etiquetaNecesidad ?? c.necesidad!,
                          style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _Seccion(
              titulo: '¿En qué se usa tu dinero?',
              child: Column(
                children: [
                  for (final d in c.destinos)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(d.concepto,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Text('${d.porcentaje}%',
                                  style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: d.porcentaje / 100,
                              minHeight: 8,
                              backgroundColor: AppColors.border,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Seccion(
              titulo: 'Impacto',
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.ayudasEntregadas == 0
                          ? 'Aún no se registran ayudas entregadas con esta campaña.'
                          : c.ayudasEntregadas == 1
                              ? 'Con esta campaña se ha entregado 1 ayuda.'
                              : 'Con esta campaña se han entregado ${c.ayudasEntregadas} ayudas.',
                      style: const TextStyle(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Llevan ${pesos(c.recaudo)} recaudados de ${pesos(c.meta)}.',
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.child});
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
