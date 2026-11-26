import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/future_body.dart';
import '../../widgets/solicitud_card.dart';
import '../solicitudes/models.dart';
import 'admin_service.dart';

const List<String> _estados = [
  'Pendiente',
  'En revisión',
  'En proceso',
  'Atendida',
  'Rechazada',
  'Cancelada',
];

class SolicitudesAdminTab extends StatefulWidget {
  const SolicitudesAdminTab({
    super.key,
    required this.filtro,
    required this.onFiltro,
    required this.onCambio,
  });

  /// Estado seleccionado (null = todas). Lo guarda el padre para no perderlo al refrescar.
  final String? filtro;
  final void Function(String? filtro) onFiltro;
  final VoidCallback onCambio;

  @override
  State<SolicitudesAdminTab> createState() => _SolicitudesAdminTabState();
}

class _SolicitudesAdminTabState extends State<SolicitudesAdminTab> {
  late Future<List<Solicitud>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AdminService>().solicitudes();
  }

  void _recargar() => setState(() => _future = context.read<AdminService>().solicitudes());

  Future<void> _abrir(int id) async {
    await context.push<void>('/admin/solicitud/$id');
    if (!mounted) return;
    widget.onCambio();
  }

  int _rangoUrgencia(String u) => switch (u) {
        'critica' => 0,
        'urgente' => 1,
        _ => 2,
      };

  bool _cerrada(String estado) =>
      estado == 'Atendida' || estado == 'Rechazada' || estado == 'Cancelada';

  /// Primero las abiertas, luego por urgencia, luego las más nuevas.
  List<Solicitud> _ordenar(List<Solicitud> lista) {
    final copia = [...lista];
    copia.sort((a, b) {
      final cerrada = (_cerrada(a.estado) ? 1 : 0).compareTo(_cerrada(b.estado) ? 1 : 0);
      if (cerrada != 0) return cerrada;
      final urgencia = _rangoUrgencia(a.urgencia).compareTo(_rangoUrgencia(b.urgencia));
      if (urgencia != 0) return urgencia;
      return b.creadoEn.compareTo(a.creadoEn);
    });
    return copia;
  }

  Widget _pastilla(String etiqueta, bool seleccionada, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(etiqueta),
        selected: seleccionada,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        showCheckmark: false,
        side: BorderSide(color: seleccionada ? AppColors.primary : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(
          color: seleccionada ? Colors.white : AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Solicitudes',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _pastilla('Todas', widget.filtro == null, () => widget.onFiltro(null)),
                for (final e in _estados)
                  _pastilla(e, widget.filtro == e, () => widget.onFiltro(e)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBody<List<Solicitud>>(
              future: _future,
              onRetry: _recargar,
              builder: (context, todas) {
                final lista = _ordenar(
                  widget.filtro == null
                      ? todas
                      : todas.where((s) => s.estado == widget.filtro).toList(),
                );
                return RefreshIndicator(
                  onRefresh: () async => _recargar(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      if (lista.isEmpty)
                        const EmptyState(
                          icono: Icons.inbox_outlined,
                          titulo: 'No hay solicitudes aquí',
                          texto: 'Cuando haya solicitudes con este estado, aparecerán en esta lista.',
                        )
                      else
                        for (final s in lista)
                          SolicitudCard(
                            solicitud: s,
                            mostrarPersona: true,
                            onTap: () => _abrir(s.id),
                          ),
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
