class InventarioEspecialClass {
  final int cadNovedad;
  final int codProducto;
  final String descripcion;
  final int unidad;
  final int fraccion;
  final int cajasEscaneadas;
  final int fraccionesEscaneadas;
  final double cantReal;
  final int codUsuario;
  final int fracciondv;
  int cajasFinal;
  int fraccionesFinal;
  double cantRealFinal;
  

  InventarioEspecialClass(
      {required this.cadNovedad,
      required this.codProducto,
      required this.descripcion,
      required this.unidad,
      required this.fraccion,
      required this.cajasEscaneadas,
      required this.fraccionesEscaneadas,
      required this.cantReal,
      required this.codUsuario,
      required this.fracciondv,
      required this.cajasFinal,
      required this.fraccionesFinal,
      required this.cantRealFinal});
}
