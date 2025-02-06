import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsg_solutions/views/inventario/informe_inventario/clases/respuestasNotifierd.dart';

import '../encuestaInicial/clase.dart';
import 'clases/clases_informe.dart';

final seleccionProvider = StateProvider<List<LabelValue>>((ref) {
  return [];
});
final enviando = StateProvider<bool>((ref) => false);
final respuestasProvider = StateNotifierProvider<RespuestasNotifier, List<Categoria>>((ref) {
  return RespuestasNotifier();
});

