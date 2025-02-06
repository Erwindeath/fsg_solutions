import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/clase_ajuste.dart';

class AjusteLaboratorioNotifier extends StateNotifier<List<AjusteInventarioLaboratorio>> {
  AjusteLaboratorioNotifier() : super([]);

  void setData(List<AjusteInventarioLaboratorio> data) {
    state = data;
  }

  /*void updateUnidad(int index, int unidad, int unidadA, WidgetRef ref) {
    var newState = [...state]; // Clona el estado actual para evitar mutaciones directas
    if (index < newState.length) {
      newState[index] = newState[index].copyWith(unidad: unidad, isEdited: unidad != unidadA);
      ref.read(enviar.notifier).state = unidad != unidadA;
    }
    state = newState; // Actualiza el estado con el nuevo arreglo modificado
  }

  void updateFraccion(int index, int fraccion, int fraccionA, WidgetRef ref) {
    var newState = [...state];
    if (index < newState.length) {
      newState[index] = newState[index].copyWith(fraccion: fraccion, isEdited: fraccion != fraccionA);
      ref.read(enviar.notifier).state = fraccion != fraccionA;
    }
    state = newState;
  }*/
  void updateUnidad(int index, int unidad, int unidadA, WidgetRef ref) {
    var newState = [...state]; // Clona el estado actual para evitar mutaciones directas
    if (index < newState.length) {
      newState[index].unidad = unidad;
      newState[index].isEdited = unidad != unidadA;
      ref.read(enviar.notifier).state = unidad != unidadA;
    }
    state = newState; // Actualiza el estado con el nuevo arreglo modificado
  }

  void updateFraccion(int index, int fraccion, int fraccionA, WidgetRef ref) {
    var newState = [...state];
    if (index < newState.length) {
      newState[index].fraccion = fraccion;
      newState[index].isEdited = fraccion != fraccionA;
      ref.read(enviar.notifier).state = fraccion != fraccionA;
    }
    state = newState;
  }
}

final ajusteLaboratorioProvider = StateNotifierProvider<AjusteLaboratorioNotifier, List<AjusteInventarioLaboratorio>>((ref) {
  return AjusteLaboratorioNotifier();
});

final enviando = StateProvider<bool>((ref) => false);
final enviar = StateProvider<bool>((ref) => false);
final habilitado = StateProvider<bool>((ref) => true);

final long = StateProvider<double>((ref) => 0.00);
final lat = StateProvider<double>((ref) => 0.00);
