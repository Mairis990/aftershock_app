import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../campanas/models.dart';

class ComprobanteScreen extends StatelessWidget {
  const ComprobanteScreen({super.key, required this.donacion});
  final Donacion donacion;

  Widget _fila(String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text('¡Gracias por tu donación!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Tu apoyo ayuda a que la ayuda llegue a quienes la necesitan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _fila('Comprobante', '#${donacion.id}'),
                  const Divider(height: 1),
                  _fila('Campaña', donacion.campanaNombre ?? 'Campaña #${donacion.campanaId}'),
                  const Divider(height: 1),
                  _fila('Monto', pesos(donacion.monto)),
                  const Divider(height: 1),
                  _fila('Método', donacion.metodoPago),
                  const Divider(height: 1),
                  _fila('Fecha', fechaHora(donacion.fecha)),
                  const Divider(height: 1),
                  _fila('Estado', donacion.estado),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                donacion.aviso ?? 'Donación simulada: no se realizó ningún cobro real.',
                style: const TextStyle(color: Color(0xFF8A5A00), height: 1.35),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/inicio'),
              child: const Text('Volver a campañas'),
            ),
          ],
        ),
      ),
    );
  }
}
