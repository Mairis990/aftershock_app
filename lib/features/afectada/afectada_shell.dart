import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'inicio_tab.dart';
import 'perfil_tab.dart';
import 'solicitudes_tab.dart';

/// Estructura de la persona afectada: tres pestañas abajo.
class AfectadaShell extends StatefulWidget {
  const AfectadaShell({super.key});

  @override
  State<AfectadaShell> createState() => _AfectadaShellState();
}

class _AfectadaShellState extends State<AfectadaShell> {
  int _tab = 0;
  int _version = 0;

  /// Cuando algo cambia (nueva solicitud, cancelación...), las pestañas se vuelven a cargar.
  void _refrescar() => setState(() => _version++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          InicioTab(
            key: ValueKey('inicio$_version'),
            onCambio: _refrescar,
            irASolicitudes: () => setState(() => _tab = 1),
          ),
          SolicitudesTab(key: ValueKey('solicitudes$_version'), onCambio: _refrescar),
          PerfilTab(key: ValueKey('perfil$_version'), onCambio: _refrescar),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFFDCE6F3),
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Mis solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
