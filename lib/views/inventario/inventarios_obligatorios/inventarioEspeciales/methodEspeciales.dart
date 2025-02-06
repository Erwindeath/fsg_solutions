import 'dart:convert';

import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/claseInventarioEspecial.dart';

List<InventarioEspecialClass> parseProductoReconteo(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<InventarioEspecialClass>((json) {
    return InventarioEspecialClass(
        cadNovedad: json["Cab_Novedad"],
        codProducto: json["Cod_Producto"],
        descripcion: json["Descripcion"],
        unidad: json["Unidad"],
        fraccion: json["Fraccion"],
        cajasEscaneadas: json["Cajas_Buenas"],
        fraccionesEscaneadas: json["Fracciones_Buenas"],
        cantReal: double.parse(json["Cant_Real"].toString()),
        codUsuario: json["Cod_Usuario"],
        fracciondv: json["FraccionDv"],
        cajasFinal: json["Cajas_Buenas"],
        fraccionesFinal: json["Fracciones_Buenas"],
        cantRealFinal: double.parse(json["Cant_Real_Final"].toString()));
  }).toList();
}
