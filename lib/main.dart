import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/session/session.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/admin_service.dart';
import 'features/donante/donante_service.dart';
import 'features/solicitudes/solicitudes_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AftershockApp());
}

class AftershockApp extends StatefulWidget {
  const AftershockApp({super.key});

  @override
  State<AftershockApp> createState() => _AftershockAppState();
}

class _AftershockAppState extends State<AftershockApp> {
  final Session _session = Session();
  late final SolicitudesService _solicitudes = SolicitudesService(_session.api);
  late final AdminService _admin = AdminService(_session.api);
  late final DonanteService _donante = DonanteService(_session.api);
  late final GoRouter _router = crearRouter(_session);

  @override
  void initState() {
    super.initState();
    _session.restore();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Session>.value(value: _session),
        Provider<SolicitudesService>.value(value: _solicitudes),
        Provider<AdminService>.value(value: _admin),
        Provider<DonanteService>.value(value: _donante),
      ],
      child: MaterialApp.router(
        title: 'Aftershock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
