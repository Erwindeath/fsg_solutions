import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*final activaBotonPrincipal = StateProvider<bool>((ref) {
  return false; // Estado inicial
});

final activaBotonPrincipalFracciones = StateProvider<bool>((ref) {
  return false; // Estado inicial
});
*/
final codProductoProvider = StateProvider<int>((ref) => 0);

final primerEscaneoProvider = StateProvider<bool>((ref) {
  return true; // Estado inicial
});

final validacionInicialProvider = StateProvider<bool>((ref) {
  return false; // Estado inicial
});

final codigoBarraAnteriorProvider = StateProvider<String>((ref) {
  return ""; // Estado inicial
});

final cantidadCajasProvider = StateProvider<int>((ref) => 0);
final cajasEscaneadasTextProvider = StateProvider<TextEditingController>((ref) => TextEditingController());

final loadReconteo = StateProvider<bool>((ref) {
  return false; // Estado inicial
});

final loadReconteoProducto = StateProvider<bool>((ref) {
  return false; // Estado inicial
});

final enviandoProductoReconteo = StateProvider<bool>((ref) {
  return false; // Estado inicial
});
final enviandoProductoReconteoPrincipal = StateProvider<bool>((ref) {
  return false; // Estado inicial
});
final cantidadCajasReconteo = StateProvider<int>((ref) => 0);
final cantidadFraccionesReconteo = StateProvider<int>((ref) => 0);