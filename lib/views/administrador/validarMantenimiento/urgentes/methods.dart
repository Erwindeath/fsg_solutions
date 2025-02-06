import 'dart:convert';
import '../clase_mantenimientos.dart';

List<Mantenimientos> convertirMantenimientos(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Mantenimientos>((json) {
    final jsonImagenes = json["imagenes"];
    // Decodificar la cadena JSON en una lista de objetos
    final listaImagenes = jsonDecode(jsonImagenes) as List<dynamic>;
    return Mantenimientos(
        codSolicitud: json["Cod_Mantenimiento_Solicitud"],
        codBodega: json["Cod_Bodega"],
        bodega: json["bodega"],
        descripcionTipo: json["DescripcionTipo"],
        descripcionDetalle: json["DescripcionDetalle"],
        detalle: json["detalle"],
        fechaSolicitud: json["Fecha_Solicitud"],
        nombreSolicitante: json["Nombres"].toString(),
        imagenes: listaImagenes.map((item) => item["ruta_imagen"]).toList(),
        codTipoMantenimiento: json["Cod_Tipo_Mantenimiento"]);
  }).toList();
}

List<RutaConMantenimientos> convertirDatosARutasConMantenimientos(String responseBody) {
  final respuesta = json.decode(responseBody);
  List<RutaConMantenimientos> rutasConMantenimientos = [];

  if (respuesta["msg"] == "ok") {
    List<dynamic> datos = respuesta["data"];
    for (var rutaJson in datos) {
      // Decodifica la cadena DetallesJSON a una lista de objetos Dart
      List<dynamic> detalles = json.decode(rutaJson["DetallesJSON"]);
      List<Mantenimientos> mantenimientos = [];

      for (var detalleJson in detalles) {
        // Aquí asumimos que el campo imagenes ya es una lista, si no, también debes decodificarlo
        List<dynamic> imagenesList = detalleJson["imagenes"] is String ? json.decode(detalleJson["imagenes"]) : detalleJson["imagenes"];

        Mantenimientos mantenimiento = Mantenimientos(
          codSolicitud: detalleJson["Cod_Mantenimiento_Solicitud"],
          codBodega: detalleJson["Cod_Bodega"],
          bodega: detalleJson["bodega"],
          descripcionTipo: detalleJson["DescripcionTipo"],
          descripcionDetalle: detalleJson["DescripcionDetalle"],
          detalle: detalleJson["Detalle"],
          fechaSolicitud: detalleJson["Fecha_Solicitud"],
          nombreSolicitante: detalleJson["Nombres"],
          imagenes: List<String>.from(imagenesList.map((imagen) => imagen["ruta_imagen"])),
          codTipoMantenimiento: detalleJson["Cod_Tipo_Mantenimiento"],
        );
        mantenimientos.add(mantenimiento);
      }

      RutaConMantenimientos rutaConMantenimientos = RutaConMantenimientos(
        codRuta: rutaJson["Cod_Ruta"],
        descripcionRuta: rutaJson["Descripcion"],
        mantenimientos: mantenimientos,
      );

      rutasConMantenimientos.add(rutaConMantenimientos);
    }
  }

  return rutasConMantenimientos;
}
