import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/clase_mantenimientos.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class Cargando extends StateNotifier<bool> {
  Cargando() : super(false);

  void cambiarEstado() {
    state = !state;
  }
}

final cargandoProvider = StateNotifierProvider<Cargando, bool>((ref) {
  return Cargando();
});

class Cargado extends StateNotifier<bool> {
  Cargado() : super(false);

  void cambiarEstado() {
    state = !state;
  }
}

final cargadoProvider = StateNotifierProvider<Cargado, bool>((ref) {
  return Cargado();
});

class MantenimientosNotifier extends StateNotifier<List<RutaConMantenimientos>> {
  MantenimientosNotifier() : super([]);

  // Método para actualizar la lista de mantenimientos
  void actualizarMantenimientos(List<RutaConMantenimientos> mantenimientos) {
    state = mantenimientos;
  }

  // Método para limpiar la lista de mantenimientos
  void limpiarMantenimientos() {
    state = [];
  }
}

// Definición del provider
final mantenimientosProvider = StateNotifierProvider<MantenimientosNotifier, List<RutaConMantenimientos>>((ref) {
  return MantenimientosNotifier();
});
