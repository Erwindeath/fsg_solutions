import 'dart:convert';

import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:http/http.dart' as http;
int valor = 30;
Future<http.Response> obtenerFarmacias(
    int codUsuario, String token, String fecha) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_farmacias_inventario'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': token
        },
        body: jsonEncode(
          {'codUsuario': codUsuario, 'fecha': fecha},
        ),
      )
      .timeout( Duration(seconds:valor));
}
