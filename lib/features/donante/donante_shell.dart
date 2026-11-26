import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'campanas_donante_tab.dart';
import 'donante_perfil_tab.dart';
import 'mis_donaciones_tab.dart';

/// Estructura del donante: tres pestañas abajo.
class DonanteShell extends StatefulWidget {
  const DonanteShell({super.key});

  @override
  State<DonanteShell> createState() => _DonanteShellState();
}

class _DonanteShellState extends State<DonanteShell> {
  int _tab = 0;
  int _version = 0;

  void _refrescar() => setState(() => _version++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          CampanasDonanteTab(key: ValueKey('campanas$_version'), onCambio: _refrescar),
          MisDonacionesTab(key: ValueKey('donaciones$_version')),
          DonantePerfilTab(key: ValueKey('perfil$_version')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFFDCE6F3),
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Mis donaciones',
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
