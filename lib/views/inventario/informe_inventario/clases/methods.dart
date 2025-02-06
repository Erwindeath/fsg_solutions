import 'dart:convert';

import 'package:fsg_solutions/views/inventario/informe_inventario/clases/clases_informe.dart';
import 'package:hl_image_picker_android/hl_image_picker_android.dart';
import 'package:http/http.dart' as http;

import '../../../../complementos/globals/url.dart';

int valor = 30;
Future<http.Response> obtenerDatosInforme(int codInventario, String token) {
  return http
      .post(
        Uri.parse('${URL}api/informe/obtener_datos_informe_inventario'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codInventario': codInventario},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> enviarDatosInforme(
    String token,
    String fechaInicio,
    String fechaFin,
    String fechaActual,
    int bodega,
    List<Map<String, dynamic>> motivos,
    List<Map<String, dynamic>> coordinador,
    List<Map<String, dynamic>> equipo,
    List<Map<String, dynamic>> dependientes,
    String desarrollo,
    double liquidacionInventario,
    double liquidacionMedicinaCaducada,
    String conclusion,
    bool sugiereDesvincular,
    bool sugiereLlamado,
    bool sobrante,
    List<Map<String, dynamic>> observaciones,
    List<Map<String, dynamic>> detalleInventario,
    List<Map<String, String>> fotos) {
  return http
      .post(
        Uri.parse('$URL4/crear-informe-movil'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            "fechaInicio": fechaInicio,
            "fechaFinal": fechaFin,
            "fechaActual": fechaActual,
            "bodega": bodega,
            "motivos": motivos,
            "coordinador": coordinador[0],
            "equipo": equipo,
            "dependientes": dependientes,
            "desarrollo": desarrollo,
            "liquidacion_inventario": liquidacionInventario,
            "liquidacion_medicina_caducada": liquidacionMedicinaCaducada,
            "conclusion": conclusion,
            "sugiereDesvincular": sugiereDesvincular,
            "sugiereLlamado": sugiereLlamado,
            "sobrante": sobrante,
            "observaciones": observaciones,
            "detalleInventario": detalleInventario,
            'llaves': fotos
          },
        ),
      )
      .timeout(const Duration(seconds: 20));
}

List<Informe> parsearInforme(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Informe>((json) {
    List<CobroCaducado> cobroCaducadoList =
        json["CobroCaducado"] != '' ? (jsonDecode(json["CobroCaducado"]) as List<dynamic>).map((e) => CobroCaducado.fromJson(e)).toList() : [];

    // Comprobar y parsear coborInventario
    List<CobroInventario> coborInventarioList =
        json["cobroInventario"] != '' ? (jsonDecode(json["cobroInventario"]) as List<dynamic>).map((e) => CobroInventario.fromJson(e)).toList() : [];
    return Informe(
      codBodega: json["Cod_Bodega"],
      farmacia: json["Farmacia"],
      fechaInicio: json["FechaInicio"],
      fechaFin: json["FechaFin"],
      liquidacionInventario: json["liquidacion_inventario"].toDouble() ?? 0.0,
      liquidacionMedicinaCaducada: json["liquidacion_medicina_caducada"].toDouble() ?? 0.0,
      coordinador: (jsonDecode(json["Coordinador"]) as List<dynamic>).map((e) => Coordinador.fromJson(e)).toList(),
      dependientes: (jsonDecode(json["json_dependientes"]) as List<dynamic>).map((e) => Dependientes.fromJson(e)).toList(),
      equipoInventario: (jsonDecode(json["EquipoInventario"]) as List<dynamic>).map((e) => EquipoInventario.fromJson(e)).toList(),
      cobroCaducado: cobroCaducadoList,
      cobroInventario: coborInventarioList,
      detalleInventario: (jsonDecode(json["detalleInventario"]) as List<dynamic>).map((e) => DetalleInventario.fromJson(e)).toList(),
      observacion: (jsonDecode(json["observacion"]) as List<dynamic>).map((e) => Observacion.fromJson(e)).toList(),
      motivos: (jsonDecode(json["json_motivos"]) as List<dynamic>).map((e) => Motivos.fromJson(e)).toList(),
    );
  }).toList();
}

Future<http.StreamedResponse> enviarFotosMantenimientos(List<HLPickerItem> imagenes) async {
  var request = http.MultipartRequest('POST', Uri.parse('${URL2}allku/mantenimientos'));
  request.fields["archivo"] = "informeinventario";

  for (var imagen in imagenes) {
    request.files.add(await http.MultipartFile.fromPath('uploadfile', imagen.path));
  }

  var response = await request.send().timeout(Duration(seconds: valor));

  return response;
}

Future<http.Response> eliminarFotosInforme(List<dynamic> llaves) {
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
