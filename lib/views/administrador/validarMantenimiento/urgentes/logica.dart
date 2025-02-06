import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../complementos/globals/url.dart';

Future<http.Response> obtenerMantenimientos(String token) {
  return http.post(Uri.parse('${URL}api/mantenimientos/obtener_solicitudes_mantenimiento'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token}).timeout(const Duration(seconds: 30));
}

Future<http.Response> obtenerMantenimientosPlanificables(String token) {
  return http.post(Uri.parse('${URL}api/mantenimientos/obtener_solicitudes_mantenimiento_planificables'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token}).timeout(const Duration(seconds: 30));
}

Future<http.Response> obtenerMantenimientosPendientes(String token) {
  return http.post(Uri.parse('${URL}api/mantenimientos/obtener_solicitudes_mantenimiento_pendientes'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token}).timeout(const Duration(seconds: 30));
}

Future<http.Response> rechazarMantenimiento(String token, int codUsuario, int codSolicitud, String descripcion, String urls) {
  return http
      .post(
        Uri.parse('${URL}api/supervision/$urls'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codUsuario': codUsuario, 'codSolicitud': codSolicitud, 'descripcion': descripcion},
        ),
      )
      .timeout(const Duration(seconds: 30));
}
Future<http.Response> completarMantenimiento(String token, int codUsuario, int codSolicitud, String descripcion, String urls,Map<String, dynamic> fotos) {
  return http
      .post(
        Uri.parse('${URL}api/supervision/$urls'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codUsuario': codUsuario, 'codSolicitud': codSolicitud, 'descripcion': descripcion, 'fotos':fotos},
        ),
      )
      .timeout(const Duration(seconds: 30));
}


Future<http.Response> reprogramaMantenimiento(String token, int codUsuario, String fecha, int codSolicitud, String descripcion, String urls) {
  return http
      .post(
        Uri.parse('${URL}api/supervision/$urls'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codUsuario': codUsuario, 'codSolicitud': codSolicitud, 'descripcion': descripcion, 'fecha': fecha},
        ),
      )
      .timeout(const Duration(seconds: 30));
}

Future<http.Response> aceptarMantenimiento(String token, int codUsuario, String fecha, int codSolicitud, String urls) {
  return http
      .post(
        Uri.parse('${URL}api/supervision/$urls'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codUsuario': codUsuario, 'codSolicitud': codSolicitud, 'fecha': fecha},
        ),
      )
      .timeout(const Duration(seconds: 30));
}

Future<http.Response> aceptarMantenimientosMultiples(String token, int codUsuario, String fecha, List<int> codSolicitudes, String urls) {
  return http
      .post(
        Uri.parse('${URL}api/supervision/$urls'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codUsuario': codUsuario, 'codSolicitudes': codSolicitudes, 'fecha': fecha},
        ),
      )
      .timeout(const Duration(seconds: 30));
}
