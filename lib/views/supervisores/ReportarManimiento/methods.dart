
import 'dart:convert';

import 'package:fsg_solutions/views/supervisores/ReportarManimiento/clases_reporte_mantenimiento.dart';

List<Bodegas> parseBodegas(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Bodegas>((json) {
    return Bodegas(
      codBodega: json["Codigo"],
      nombreBodega: json["Nombre"]
    );
  }).toList();
}

List<Mantenimientos> parseMantenimientos(String responseBody) {
  final parsed = json.decode(responseBody)["dataMantenimientos"].cast<Map<String, dynamic>>();
  return parsed.map<Mantenimientos>((json) => Mantenimientos.fromJson(json)).toList();
}