String _dos(int n) => n.toString().padLeft(2, '0');

/// 10/11/2026  19:36
String fechaHora(DateTime d) =>
    '${_dos(d.day)}/${_dos(d.month)}/${d.year}  ${_dos(d.hour)}:${_dos(d.minute)}';

String urgenciaEtiqueta(String urgencia) => switch (urgencia) {
      'urgente' => 'Urgente',
      'critica' => 'Crítica',
      _ => 'Normal',
    };

/// 12500000 -> $12.500.000
String pesos(int valor) {
  final digitos = valor.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) b.write('.');
    b.write(digitos[i]);
  }
  return '\$${valor < 0 ? '-' : ''}$b';
}

/// 850 -> "850 m", 2340 -> "2,3 km", 245000 -> "245 km"
String distanciaTexto(double metros) {
  if (metros < 1000) return '${metros.round()} m';
  final km = metros / 1000;
  if (km >= 100) return '${km.round()} km';
  return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
}
