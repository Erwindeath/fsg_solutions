import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/clase.dart';

class RespuestasNotifier extends StateNotifier<List<Categoria>> {
  RespuestasNotifier() : super([]);

  void actualizarRespuesta(int indexCategoria, int indexPregunta, int indexRespuesta, bool seleccionada) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == indexCategoria)
          Categoria(
            codCategoria: state[i].codCategoria,
            nombre: state[i].nombre,
            preguntas: [
              for (int j = 0; j < state[i].preguntas.length; j++)
                if (j == indexPregunta)
                  Pregunta(
                    codPreguntas: state[i].preguntas[j].codPreguntas,
                    nombre: state[i].preguntas[j].nombre,
                    llevaObservacion: state[i].preguntas[j].llevaObservacion,
                    respuestas: [
                      for (int k = 0; k < state[i].preguntas[j].respuestas.length; k++)
                        if (k == indexRespuesta)
                          Respuesta(
                            codRespuesta: state[i].preguntas[j].respuestas[k].codRespuesta,
                            dato: state[i].preguntas[j].respuestas[k].dato,
                            seleccionada: seleccionada,
                            observacion: state[i].preguntas[j].respuestas[k].observacion,
                          )
                        else
                          state[i].preguntas[j].respuestas[k],
                    ],
                  )
                else
                  state[i].preguntas[j],
            ],
          )
        else
          state[i],
    ];
  }

  void cargarPreguntas(List<Categoria> nuevasCategorias) {
    state = nuevasCategorias;
  }

  bool areAllQuestionsAnswered() {
    return state.every((categoria) => areAllAnswersSelected(categoria));
  }

  // Verifica si todas las preguntas en una categoría específica han sido respondidas
  bool areAllAnswersSelected(Categoria categoria) {
    return categoria.preguntas.every((pregunta) => pregunta.respuestas.any((respuesta) => respuesta.seleccionada));
  }

  String getAllCategoryDescriptions() {
    StringBuffer buffer = StringBuffer();

    for (var categoria in state) {
      buffer.writeln(categoria.describe());
    }

    return buffer.toString();
  }
}


