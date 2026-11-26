import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'campanas_admin_tab.dart';
import 'panel_tab.dart';
import 'personas_tab.dart';
import 'solicitudes_admin_tab.dart';

/// Estructura del administrador: cuatro pestañas abajo.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _tab = 0;
  int _version = 0;
  String? _filtro;

  void _refrescar() => setState(() => _version++);

  /// Desde el panel: abre la pestaña de solicitudes ya filtrada por estado.
  void _verSolicitudes(String? estado) => setState(() {
        _filtro = estado;
        _tab = 1;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          PanelTab(key: ValueKey('panel$_version'), onVerSolicitudes: _verSolicitudes),
          SolicitudesAdminTab(
            key: ValueKey('solicitudes$_version'),
            filtro: _filtro,
            onFiltro: (f) => setState(() => _filtro = f),
            onCambio: _refrescar,
          ),
          PersonasTab(key: ValueKey('personas$_version')),
          CampanasAdminTab(key: ValueKey('campanas$_version')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFFDCE6F3),
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Personas',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Campañas',
          ),
        ],
      ),
    );
  }
}
