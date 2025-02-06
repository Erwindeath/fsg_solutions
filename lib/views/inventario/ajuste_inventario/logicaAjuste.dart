import 'dart:convert';

import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:http/http.dart' as http;

int valor = 30;
Future<http.Response> obtenerLaboratorios(String token, String url) {
  return http.get(
    Uri.parse('${URL}api/creedenciales/$url'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
  ).timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerDataLaboratorio(int codLaboratorio, int codBodega, String token) {
  return http
      .post(
        Uri.parse('${URL}api/ajuste/obtener_data_bodega_laboratorio'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codLaboratorio': codLaboratorio},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> procesarAjustes(List<Map<String, dynamic>> datosEditados, int codBodega, int codusuario, int codLaboratorio, double longitud,
    double latitud, String fechaInicio, int codSesion, int codEstacion, double totalInicial, double totalFinal, String token) {
  return http
      .post(
        Uri.parse('${URL}api/ajuste/enviar_data_laboratorio'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            "dataInventario": datosEditados,
            "codBodega": codBodega,
            "codUsuario": codusuario,
            "codLaboratorio": codLaboratorio,
            "longitud": longitud,
            "latitud": latitud,
            "fechaInicio": fechaInicio,
            "codSesion": codSesion,
            "codEstacion": codEstacion,
            "totalInicial": totalInicial,
            "totalFinal": totalFinal,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}
