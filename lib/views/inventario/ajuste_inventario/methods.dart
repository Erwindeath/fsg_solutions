import 'dart:convert';

import 'package:fsg_solutions/views/inventario/ajuste_inventario/clase_ajuste.dart';

List<AjusteInventarioLaboratorio> parsearDataLaboratorio(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<AjusteInventarioLaboratorio>((json) {
    return AjusteInventarioLaboratorio(
      codProducto: json['Cod_Producto'],
      codBarra: json['Cod_Barra'],
      producto: json['Descripcion'],
      iva: json['iva'],
      costoPromedio: json['Costo_promedio'].toDouble(),
      precioPublico: json['Precio_Publico'].toDouble(),
      unidad: json['unidad'],
      fraccion: json['fraccion'],
      fracciones: json['Fracciones'],
      pVenta: json['Pventa'].toDouble(),
      unidadA: json['unidad'],
      fraccionA: json['fraccion'],
      isEdited: false,
      codTipo: json["Tipo"].toString()
    );
  }).toList();
}
