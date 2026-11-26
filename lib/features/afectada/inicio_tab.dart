import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/session/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../widgets/future_body.dart';
import '../../widgets/solicitud_card.dart';
import '../solicitudes/models.dart';
import '../solicitudes/solicitudes_service.dart';

class _Datos {
  _Datos(this.solicitudes, this.novedades);
  final List<Solicitud> solicitudes;
  final List<Novedad> novedades;
}

class InicioTab extends StatefulWidget {
  const InicioTab({super.key, required this.onCambio, required this.irASolicitudes});
  final VoidCallback onCambio;
  final VoidCallback irASolicitudes;

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  late Future<_Datos> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<_Datos> _cargar() async {
    final service = context.read<SolicitudesService>();
    final (solicitudes, novedades) = await (service.mias(), service.novedades()).wait;
    return _Datos(solicitudes, novedades);
  }

  void _recargar() => setState(() => _future = _cargar());

  Future<void> _pedirAyuda() async {
    await context.push<void>('/solicitud/nueva');
    if (!mounted) return;
    widget.onCambio();
  }

  Future<void> _abrir(int id) async {
    await context.push<void>('/solicitud/$id');
    if (!mounted) return;
    widget.onCambio();
  }

  Widget _titulo(String texto, {Widget? accion}) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            ?accion,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<Session>().usuario;
    return SafeArea(
      child: FutureBody<_Datos>(
        future: _future,
        onRetry: _recargar,
        builder: (context, d) => RefreshIndicator(
          onRefresh: () async => _recargar(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text('Hola, ${usuario?.primerNombre ?? ''}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('¿Cómo podemos ayudarte hoy?',
                  style: TextStyle(color: AppColors.muted, fontSize: 15)),
              const SizedBox(height: 20),
              Material(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _pedirAyuda,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pedir ayuda',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800)),
                              SizedBox(height: 6),
                              Text('Cuéntanos qué necesitas y lo gestionamos.',
                                  style: TextStyle(color: Color(0xFFFFE4DC), height: 1.3)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (d.solicitudes.isEmpty) ...[
                const SizedBox(height: 16),
                const _AyudaPrimeraVez(),
              ],
              if (d.solicitudes.isNotEmpty) ...[
                _titulo(
                  'Tu última solicitud',
                  accion: TextButton(
                    onPressed: widget.irASolicitudes,
                    child: const Text('Ver todas'),
                  ),
                ),
                SolicitudCard(
                  solicitud: d.solicitudes.first,
                  onTap: () => _abrir(d.solicitudes.first.id),
                ),
              ],
              _titulo('Novedades'),
              if (d.novedades.isEmpty)
                const Text('Aún no hay novedades. Cuando cambie el estado de una solicitud, lo verás aquí.',
                    style: TextStyle(color: AppColors.muted, height: 1.4))
              else
                for (final n in d.novedades.take(5))
                  _NovedadTile(novedad: n, onTap: () => _abrir(n.solicitudId)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NovedadTile extends StatelessWidget {
  const _NovedadTile({required this.novedad, required this.onTap});
  final Novedad novedad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFDCE6F3), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none_rounded,
                  size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(novedad.texto, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (novedad.motivo != null && novedad.motivo!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(novedad.motivo!,
                          style: const TextStyle(color: AppColors.muted, height: 1.3)),
                    ),
                  const SizedBox(height: 2),
                  Text(fechaHora(novedad.fecha),
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Explicación corta para quien todavía no ha pedido ayuda. Desaparece sola.
class _AyudaPrimeraVez extends StatelessWidget {
  const _AyudaPrimeraVez();

  Widget _paso(String numero, String texto) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.primary,
              child: Text(numero,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(texto, style: const TextStyle(height: 1.3))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Cómo funciona?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          _paso('1', 'Pide ayuda y elige lo que necesitas.'),
          _paso('2', 'Nuestro equipo revisa tu solicitud.'),
          _paso('3', 'Sigue el estado aquí, en Novedades.'),
        ],
      ),
    );
  }
}
