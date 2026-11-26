import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Ajustes compartidos por todos los mapas de la app (OpenStreetMap, sin llave de pago).
const String kUrlMosaicos = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String kPaqueteApp = 'com.aftershock.aftershock_app';

/// Vista general de Colombia.
const LatLng kCentroColombia = LatLng(4.6, -74.1);
const double kZoomColombia = 5.4;

TileLayer capaMosaicos() =>
    TileLayer(urlTemplate: kUrlMosaicos, userAgentPackageName: kPaqueteApp);

Widget atribucionOsm() => RichAttributionWidget(
      attributions: [TextSourceAttribution('OpenStreetMap contributors')],
    );
