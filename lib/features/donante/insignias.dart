import 'package:flutter/material.dart';

import '../campanas/models.dart';

class Insignia {
  Insignia({
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.actual,
    required this.meta,
  });

  final String nombre;
  final String descripcion;
  final IconData icono;
  final int actual;
  final int meta;

  bool get ganada => actual >= meta;
}

/// Las insignias se calculan con el historial de donaciones (no se guardan aparte).
List<Insignia> calcularInsignias(List<Donacion> donaciones) {
  final total = donaciones.length;
  final campanas = donaciones.map((d) => d.campanaId).toSet().length;
  return [
    Insignia(
      nombre: 'Primera donación',
      descripcion: 'Haz tu primera donación',
      icono: Icons.volunteer_activism,
      actual: total,
      meta: 1,
    ),
    Insignia(
      nombre: 'Donante constante',
      descripcion: 'Dona 3 veces',
      icono: Icons.repeat_rounded,
      actual: total,
      meta: 3,
    ),
    Insignia(
      nombre: 'Gran corazón',
      descripcion: 'Dona 5 veces',
      icono: Icons.favorite,
      actual: total,
      meta: 5,
    ),
    Insignia(
      nombre: 'Aliado de causas',
      descripcion: 'Apoya 2 campañas distintas',
      icono: Icons.diversity_3,
      actual: campanas,
      meta: 2,
    ),
  ];
}
