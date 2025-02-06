import 'package:flutter_riverpod/flutter_riverpod.dart';

final respuestasProvider = StateNotifierProvider<RespuestasNotifier, Map<String, bool>>((ref) {
  return RespuestasNotifier();
});

class RespuestasNotifier extends StateNotifier<Map<String, bool>> {
  RespuestasNotifier() : super({});

  void actualizarRespuesta(String preguntaId, bool valor) {
    state = {...state, preguntaId: valor};
  }

  // Aquí puedes añadir más lógica según sea necesario
}

