import 'dart:convert';

import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:http/http.dart' as http;
int valor = 30;
Future<http.Response> obtenerDataMenu(int codPerfil, String token) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener-data-menu'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codPerfil': codPerfil,
        }),
      )
      .timeout( Duration(seconds:valor));
}

Future<http.Response> obtenerDataMenuSuper(int codPerfil, String token) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener-data-menu-super'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode({
          'codPerfil': codPerfil,
        }),
      )
      .timeout( Duration(seconds:valor));
}
