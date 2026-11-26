import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../features/admin/campana_form_screen.dart';
import '../features/admin/ubicacion_picker_screen.dart';
import '../features/admin/solicitud_admin_screen.dart';
import '../features/afectada/nueva_solicitud_screen.dart';
import '../features/afectada/perfil_edit_screen.dart';
import '../features/afectada/solicitud_detalle_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/campanas/models.dart';
import '../features/donante/campana_detalle_screen.dart';
import '../features/donante/comprobante_screen.dart';
import '../features/donante/donar_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import 'session/session.dart';

GoRouter crearRouter(Session session) {
  const rutasPublicas = ['/bienvenida', '/login', '/registro'];

  return GoRouter(
    initialLocation: '/cargando',
    refreshListenable: session,
    redirect: (context, state) {
      final ruta = state.matchedLocation;
      switch (session.status) {
        case SessionStatus.loading:
          return ruta == '/cargando' ? null : '/cargando';
        case SessionStatus.anonymous:
          return rutasPublicas.contains(ruta) ? null : '/bienvenida';
        case SessionStatus.authenticated:
          return (rutasPublicas.contains(ruta) || ruta == '/cargando') ? '/inicio' : null;
      }
    },
    routes: [
      GoRoute(
        path: '/cargando',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/bienvenida', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/registro',
        builder: (context, state) =>
            RegisterScreen(rolInicial: state.uri.queryParameters['rol']),
      ),
      GoRoute(path: '/inicio', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/perfil/editar', builder: (context, state) => const PerfilEditScreen()),
      // "nueva" va antes que ":id" para que no se confunda con un número.
      GoRoute(
        path: '/solicitud/nueva',
        builder: (context, state) => const NuevaSolicitudScreen(),
      ),
      GoRoute(
        path: '/admin/solicitud/:id',
        builder: (context, state) => SolicitudAdminScreen(
          id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/admin/ubicacion',
        builder: (context, state) {
          final inicial = state.extra;
          return UbicacionPickerScreen(inicial: inicial is LatLng ? inicial : null);
        },
      ),
      GoRoute(
        path: '/admin/campana/nueva',
        builder: (context, state) => const CampanaFormScreen(),
      ),
      GoRoute(
        path: '/campana/:id',
        builder: (context, state) => CampanaDetalleScreen(
          id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/campana/:id/donar',
        builder: (context, state) => DonarScreen(
          campanaId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/comprobante',
        builder: (context, state) {
          final donacion = state.extra;
          if (donacion is Donacion) return ComprobanteScreen(donacion: donacion);
          return const Scaffold(body: Center(child: Text('Comprobante no disponible')));
        },
      ),
      GoRoute(
        path: '/solicitud/:id',
        builder: (context, state) => SolicitudDetalleScreen(
          id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
    ],
  );
}
