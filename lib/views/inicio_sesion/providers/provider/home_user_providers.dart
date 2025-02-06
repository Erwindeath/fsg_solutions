import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final wFarmaciaProvider = StateNotifierProvider<WFarmaciaNotifier, List<Map<String, dynamic>>>((ref) {
  return WFarmaciaNotifier();
});

class WFarmaciaNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  WFarmaciaNotifier() : super([]);

  void actualizarListaFarmacias(List<Map<String, dynamic>> nuevaLista) {
    state = nuevaLista;
  }
}