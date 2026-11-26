import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_button.dart';
import 'auth_hero.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.rolInicial});

  /// 'afectada' o 'donante' (viene de la pantalla de entrada).
  final String? rolInicial;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  late String _rol = widget.rolInicial == 'donante' ? 'donante' : 'afectada';
  bool _cargando = false;
  bool _verClave = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<Session>();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await session.registro(
        nombre: _nombre.text.trim(),
        correo: _correo.text.trim(),
        clave: _clave.text,
        rol: _rol,
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHero(
              titulo: 'Crea tu cuenta',
              subtitulo: 'Solo toma un minuto. Elige cómo quieres participar.',
              conAtras: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) ...[
                      ErrorBanner(_error!),
                      const SizedBox(height: 16),
                    ],
                    const Text('¿Cómo quieres participar?',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _RolCard(
                            icono: Icons.health_and_safety_outlined,
                            titulo: 'Necesito ayuda',
                            seleccionado: _rol == 'afectada',
                            onTap: () => setState(() => _rol = 'afectada'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RolCard(
                            icono: Icons.favorite_outline,
                            titulo: 'Quiero ayudar',
                            seleccionado: _rol == 'donante',
                            onTap: () => setState(() => _rol = 'donante'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _nombre,
                      label: 'Nombre completo',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v ?? '').trim().length < 3 ? 'Escribe tu nombre completo' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _correo,
                      label: 'Correo electrónico',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Escribe tu correo';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _clave,
                      label: 'Contraseña (mínimo 8 caracteres)',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_verClave,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _enviar(),
                      suffixIcon: IconButton(
                        icon: Icon(_verClave ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _verClave = !_verClave),
                      ),
                      validator: (v) =>
                          (v ?? '').length < 8 ? 'Debe tener al menos 8 caracteres' : null,
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(texto: 'Crear cuenta', cargando: _cargando, onPressed: _enviar),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta?'),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Ingresar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RolCard extends StatelessWidget {
  const _RolCard({
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icono, color: seleccionado ? Colors.white : AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: seleccionado ? Colors.white : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
