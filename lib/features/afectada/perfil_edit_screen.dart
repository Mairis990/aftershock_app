import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_button.dart';
import '../solicitudes/solicitudes_service.dart';

class PerfilEditScreen extends StatefulWidget {
  const PerfilEditScreen({super.key});

  @override
  State<PerfilEditScreen> createState() => _PerfilEditScreenState();
}

class _PerfilEditScreenState extends State<PerfilEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documento = TextEditingController();
  final _telefono = TextEditingController();
  final _ubicacion = TextEditingController();
  bool _cargandoInicial = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _precargar();
  }

  @override
  void dispose() {
    _documento.dispose();
    _telefono.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  Future<void> _precargar() async {
    final service = context.read<SolicitudesService>();
    try {
      final perfil = await service.perfil();
      if (perfil != null) {
        _documento.text = perfil.documento;
        _telefono.text = perfil.telefono;
        _ubicacion.text = perfil.ubicacion;
      }
    } on ApiException catch (_) {
      // Si falla, simplemente se deja el formulario vacío.
    }
    if (mounted) setState(() => _cargandoInicial = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final service = context.read<SolicitudesService>();
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await service.guardarPerfil(
        documento: _documento.text.trim(),
        telefono: _telefono.text.trim(),
        ubicacion: _ubicacion.text.trim(),
      );
      if (!mounted) return;
      context.pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: _cargandoInicial
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estos datos nos ayudan a ubicarte y a que la ayuda te llegue. Solo los ve el equipo administrador.',
                      style: TextStyle(height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    if (_error != null) ...[
                      ErrorBanner(_error!),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      controller: _documento,
                      label: 'Número de documento',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) => RegExp(r'^\d{5,12}$').hasMatch((v ?? '').trim())
                          ? null
                          : 'Solo números, entre 5 y 12 dígitos',
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _telefono,
                      label: 'Teléfono de contacto',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) => RegExp(r'^\d{7,12}$').hasMatch((v ?? '').trim())
                          ? null
                          : 'Solo números, entre 7 y 12 dígitos',
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _ubicacion,
                      label: 'Dónde estás (barrio, dirección o referencia)',
                      prefixIcon: Icons.place_outlined,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          (v ?? '').trim().length < 5 ? 'Describe tu ubicación' : null,
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(texto: 'Guardar', cargando: _guardando, onPressed: _guardar),
                  ],
                ),
              ),
            ),
    );
  }
}
