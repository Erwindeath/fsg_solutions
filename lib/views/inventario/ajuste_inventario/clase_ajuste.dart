class AjusteInventarioLaboratorio {
  final int codProducto;
  final String codBarra;
  final String producto;
  final bool iva;
  final double costoPromedio;
  final double precioPublico;
  int unidad; // Cambiado a no final para permitir modificación
  int fraccion;
  final int fracciones;
  final double pVenta;
  int unidadA;
  int fraccionA;
  bool isEdited;
  final String codTipo;

  AjusteInventarioLaboratorio({
    required this.codBarra,
    required this.codProducto,
    required this.producto,
    required this.iva,
    required this.costoPromedio,
    required this.precioPublico,
    required this.unidad,
    required this.fraccion,
    required this.fracciones,
    required this.pVenta,
    required this.unidadA,
    required this.fraccionA,
    required this.isEdited,
    required this.codTipo,
  });
  @override
  String toString() {
    return 'AjusteInventarioLaboratorio(producto: $producto, unidad: $unidad, fraccion: $fraccion, fracciones: $fracciones, pVenta: $pVenta,barra:$codBarra)';
  }

  Map<String, dynamic> toJson() {
    // Calcula los valores actuales y ajustados
    final actual = unidad + (fraccion / fracciones);
    final ajustado = unidadA + (fraccionA / fracciones);

    return {
      'COD_PRODUCTO': codProducto,
      'CANT_UNIDAD': unidad,
      'CANT_FRACCION': fraccion,
      'COSTO': costoPromedio,
      'Parcial': actual * costoPromedio, // Usar el cálculo directamente
      'CANT_REAL': actual,
      'ajustado': ajustado
    };
  }

  AjusteInventarioLaboratorio copyWith({
    int? unidad,
    int? fraccion,
    bool? isEdited,
  }) {
    return AjusteInventarioLaboratorio(
      codProducto: codProducto,
      codBarra: codBarra,
      producto: producto,
      iva: iva,
      costoPromedio: costoPromedio,
      precioPublico: precioPublico,
      unidad: unidad ?? this.unidad,
      fraccion: fraccion ?? this.fraccion,
      fracciones: fracciones,
      pVenta: pVenta,
      unidadA: unidadA,
      fraccionA: fraccionA,
      isEdited: isEdited ?? this.isEdited,
      codTipo: codTipo
    );
  }
}
