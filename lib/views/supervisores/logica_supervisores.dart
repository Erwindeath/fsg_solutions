// ignore_for_file: unused_import

import 'dart:convert';
import 'package:hl_image_picker_android/hl_image_picker_android.dart';
import 'package:http/http.dart' as http;

import '../../complementos/globals/url.dart';

int valor = 30;
Future<http.Response> obtenerBodegasYMantenimientos(String token) {
  return http.post(
    Uri.parse('${URL}api/supervision/obtener_bodegas_mantenientos'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  ).timeout(Duration(seconds: valor));
}

Future<http.StreamedResponse> enviarFotos(List<HLPickerItem> imagenes) async {
  var request = http.MultipartRequest('POST', Uri.parse('${URL2}allku/mantenimientos'));
  request.fields["archivo"] = "mantenimientos";
  // Aquí deberías agregar las imágenes al request. Por ejemplo:
  for (var imagen in imagenes) {
    // Suponiendo que HLPickerItem tiene una propiedad que te permite acceder a un archivo o a los bytes de la imagen.
    // Necesitarías ajustar esto según la estructura de HLPickerItem.
    request.files.add(await http.MultipartFile.fromPath('uploadfile', imagen.path));
  }

  // Envía la solicitud
  var response = await request.send().timeout(Duration(seconds: valor));

  // Si necesitas el objeto MultipartRequest por alguna razón, deberías reconsiderar
  // qué es lo que realmente necesitas retornar. Aquí estamos retornando el StreamedResponse.
  // Si solo necesitas confirmar que la solicitud fue enviada, podrías ajustar el tipo de retorno.
  // Por ejemplo, podrías retornar un Future<bool> indicando si la solicitud fue exitosa o no.

  return response;
}

Future<http.StreamedResponse> enviarFotosCompletadas(List<HLPickerItem> imagenes) async {
  var request = http.MultipartRequest('POST', Uri.parse('${URL2}allku/mantenimientos'));
  request.fields["archivo"] = "mantenimientos-completados";
  // Aquí deberías agregar las imágenes al request. Por ejemplo:
  for (var imagen in imagenes) {
    // Suponiendo que HLPickerItem tiene una propiedad que te permite acceder a un archivo o a los bytes de la imagen.
    // Necesitarías ajustar esto según la estructura de HLPickerItem.
    request.files.add(await http.MultipartFile.fromPath('uploadfile', imagen.path));
  }

  // Envía la solicitud
  var response = await request.send().timeout(Duration(seconds: valor));

  // Si necesitas el objeto MultipartRequest por alguna razón, deberías reconsiderar
  // qué es lo que realmente necesitas retornar. Aquí estamos retornando el StreamedResponse.
  // Si solo necesitas confirmar que la solicitud fue enviada, podrías ajustar el tipo de retorno.
  // Por ejemplo, podrías retornar un Future<bool> indicando si la solicitud fue exitosa o no.

  return response;
}

Future<http.Response> eliminarFotos(List<dynamic> llaves) {
  return http
      .post(
        Uri.parse('${URL2}allku/mantenimientos_eliminar'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'files': llaves}),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> eliminarFotosNuevo(List<dynamic> llaves) {
  return http
      .post(
        Uri.parse('${URL2}allku/mantenimientos_eliminar'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'files': llaves}),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> enviarMantenimiento(
    String token, int codUsuario, int codBodega, int tipoSeleccionado, int detalleSeleccionado, String descripcion, Map<String, dynamic> fotos) {
  return http
      .post(
        Uri.parse('${URL}api/supervision/enviar_solicitud_mantenimiento'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codUsuario': codUsuario,
            'codBodega': codBodega,
            'tipoSeleccionado': tipoSeleccionado,
            'detalleSeleccionado': detalleSeleccionado,
            'descripcion': descripcion,
            'fotos': fotos,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}
