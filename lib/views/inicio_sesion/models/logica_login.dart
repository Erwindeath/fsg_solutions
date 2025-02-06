// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

int valor = 30;
final SecureStorage _storage = SecureStorage();

Future<http.Response> loginBodegaUsuario(String user, String pass, String token) {
  return http.post(
    Uri.parse(URL + 'api/creedenciales/autentificar-usuario'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'usuario': user, 'clave': pass, 'token': token}),
  );
}

Future<bool> registrarDatosUsuariosBodega(json) async {
  var codUsuario = json["data"]["respuesta"][0]["Cod_Usuario"];
  var codPerfil = json["data"]["respuesta"][0]["cod_perfil"];
  var nombre = json["data"]["respuesta"][0]["nombres"];
  var cargo = json["data"]["respuesta"][0]["descripcion_perfil"];
  var token = json["data"]["tokens"];
  var codSesion = json["data"]["dato"][0]["Cod_Sesion"];
  var codEstacion = json["data"]["dato"][0]["Estacion"];
  /*if (canal != "") {
        await FirebaseMessaging.instance.subscribeToTopic(canal);
        await _storage.writeSecureData("canal", canal.toString());
      } else {
        await FirebaseMessaging.instance.subscribeToTopic(canales);
        await _storage.writeSecureData("canal", canales.toString());
      }*/

  await _storage.writeSecureData("cod_usuario", codUsuario.toString());
  await _storage.writeSecureData("cod_perfil", codPerfil.toString());
  await _storage.writeSecureData("token", token.toString());
  await _storage.writeSecureData("Nombre", nombre.toString());
  await _storage.writeSecureData("Cargo", cargo.toString());
  await _storage.writeSecureData("codSesion", codSesion.toString());
  await _storage.writeSecureData("Estacion", codEstacion.toString());

  return true;
}

Future<bool> logout() async {
  try {
    await _storage.deleteSecureData("cod_usuario");
    await _storage.deleteSecureData("cod_perfil");
    await _storage.deleteSecureData("token");
    await _storage.deleteSecureData("Nombre");
    await _storage.deleteSecureData("Cargo");
    await _storage.deleteSecureData("codSesion");
    await _storage.deleteSecureData("Estacion");
    return true;
  } catch (e) {
    return false;
  }
}

Future<http.Response> loginBodega(String qr) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/autenticar-farmacia'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'api-token': 'apitoken'},
        body: jsonEncode(<String, String>{
          'clave_logueo': qr,
        }),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> guardarSesionDatos(int codUsuario, double longitud, double latitud, int codBodega, String token) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/guardar_credenciales_datos_bodega'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'api-token': token},
        body: jsonEncode({
          'codUsuario': codUsuario,
          'longitud': longitud,
          'latitud': latitud,
          'codBodega': codBodega,
        }),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerBodega(String codigo, String token) {
  return http
      .post(
        Uri.parse(URL + 'api/creedenciales/login_supervisores_bodega'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'api-token': token},
        body: jsonEncode({
          'codigo': codigo,
        }),
      )
      .timeout(Duration(seconds: valor));
}

Future<void> guardarDatosBodega(String codBodega, String nombreBodega, String? metodo) async {
  await _storage.writeSecureData("codBodega", codBodega);
  await _storage.writeSecureData("nombreBodega", nombreBodega);
  await _storage.writeSecureData("LoginBodega", codBodega);
  await _storage.writeSecureData("metodo", metodo!);
}

Future<bool> logoutFarmacia() async {
  try {
    await _storage.deleteSecureData("codBodega");
    await _storage.deleteSecureData("nombreBodega");
    await _storage.deleteSecureData("LoginBodega");
    await _storage.deleteSecureData("encuesta");
    await _storage.deleteSecureData("codInventario");
    await _storage.deleteSecureData("metodo");
    return true;
  } catch (e) {
    return false;
  }
}
