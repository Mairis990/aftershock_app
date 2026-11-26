import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/future_body.dart';
import '../../widgets/loading_button.dart';
import '../campanas/models.dart';
import 'donante_service.dart';

class DonarScreen extends StatefulWidget {
  const DonarScreen({super.key, required this.campanaId});
  final int campanaId;

  @override
  State<DonarScreen> createState() => _DonarScreenState();
}

class _DonarScreenState extends State<DonarScreen> {
  static const List<int> _rapidos = [10000, 20000, 50000, 100000];

  late Future<Campana> _future;
  int? _rapido = 20000;
  final _otro = TextEditingController();
  String _metodo = 'PSE';
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = context.read<DonanteService>().campana(widget.campanaId);
  }

  @override
  void dispose() {
    _otro.dispose();
    super.dispose();
  }

  void _recargar() =>
      setState(() => _future = context.read<DonanteService>().campana(widget.campanaId));

  /// El monto escrito a mano manda sobre los botones rápidos.
  int? get _monto {
    final texto = _otro.text.trim();
    if (texto.isNotEmpty) return int.tryParse(texto);
    return _rapido;
  }

  Future<void> _enviar(Campana campana) async {
    final monto = _monto;
    if (monto == null || monto < 1000) {
      setState(() => _error = 'Elige o escribe un monto de al menos ${pesos(1000)}.');
      return;
    }
    if (monto > 100000000) {
      setState(() => _error = 'El monto máximo es ${pesos(100000000)}.');
      return;
    }
    final service = context.read<DonanteService>();
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final donacion =
          await service.donar(campanaId: campana.id, monto: monto, metodoPago: _metodo);
      if (!mounted) return;
      context.pushReplacement('/comprobante', extra: donacion.conCampana(campana.nombre));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donar')),
      body: FutureBody<Campana>(
        future: _future,
        onRetry: _recargar,
        builder: (context, campana) {
          final monto = _monto;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(campana.nombre,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(campana.entidadResponsable, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 24),
              const Text('¿Cuánto quieres donar?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in _rapidos)
                    ChoiceChip(
                      label: Text(pesos(v)),
                      selected: _otro.text.trim().isEmpty && _rapido == v,
                      onSelected: (_) => setState(() {
                        _rapido = v;
                        _otro.clear();
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _otro,
                label: 'Otro monto (solo números)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {
                  _rapido = null;
                  _error = null;
                }),
              ),
              const SizedBox(height: 24),
              const Text('Método de pago',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetodoCard(
                      icono: Icons.credit_card,
                      titulo: 'Tarjeta',
                      seleccionado: _metodo == 'Tarjeta',
                      onTap: () => setState(() => _metodo = 'Tarjeta'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetodoCard(
                      icono: Icons.account_balance,
                      titulo: 'PSE',
                      seleccionado: _metodo == 'PSE',
                      onTap: () => setState(() => _metodo = 'PSE'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetodoCard(
                      icono: Icons.swap_horiz,
                      titulo: 'Transferencia',
                      seleccionado: _metodo == 'Transferencia',
                      onTap: () => setState(() => _metodo = 'Transferencia'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF8A5A00), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Esta es una donación simulada: no se realiza ningún cobro y no se piden datos de tarjeta.',
                        style: TextStyle(color: Color(0xFF8A5A00), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrorBanner(_error!),
              ],
              const SizedBox(height: 20),
              LoadingButton(
                texto: monto == null ? 'Confirmar donación' : 'Confirmar donación · ${pesos(monto)}',
                cargando: _enviando,
                onPressed: () => _enviar(campana),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetodoCard extends StatelessWidget {
  const _MetodoCard({
    required this.icono,
    required this.titulo,
    required this.seleccionado,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icono, color: seleccionado ? Colors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: seleccionado ? Colors.white : AppColors.text,
                )),
          ],
        ),
      ),
    );
  }
}
