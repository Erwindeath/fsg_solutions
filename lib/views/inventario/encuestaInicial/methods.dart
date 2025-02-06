import 'dart:convert';
import 'package:fsg_solutions/views/inventario/encuestaInicial/clase.dart';
import 'package:http/http.dart' as http;
import 'package:fsg_solutions/complementos/globals/url.dart';

int valor = 30;
Future<http.Response> obtenerEncuesta(int codInventario, String token) {
  return http
      .post(
        Uri.parse('${URL}api/encuesta/obtener_preguntas'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codInventario': codInventario},
        ),
      )
      .timeout(Duration(seconds: valor));
}

/*List<Categoria> parsearEncuenta(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Categoria>((json) {
    return Categoria(
      codCategoria: json["Cod_Categoria"],
      nombre: json["Nombre"],
      preguntas: (jsonDecode(json["preguntas"]) as List<dynamic>).map((e) => Pregunta.fromJson(e)).toList(),  
    );
  }).toList();
}*/
List<Categoria> parsearEncuesta(String responseBody, bool valido) {
  if (valido) {
    final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();

    return parsed.map<Categoria>((json) => Categoria.fromJson(json)).toList();
  } else {
    final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
    // Se espera una lista de Categoría, por lo tanto, cada mapeo debe devolver un solo objeto Categoría.
    return parsed.map<Categoria>((jsons) {
      // Decodificamos el campo 'preguntas' si es un String JSON (aunque parece ser ya una lista)
      var preguntasData = jsons['preguntas'];
      var preguntasJson = preguntasData is String ? jsonDecode(preguntasData) : preguntasData;

      // Asumimos que preguntasJson es una lista con un solo objeto que contiene las preguntas.
      var categoriaData = preguntasJson[0]; // Accedemos al primer objeto que debería contener la estructura esperada.
      List<Pregunta> preguntasList =
          (categoriaData['preguntas'] as List).map((preguntaJson) => Pregunta.fromJson(preguntaJson as Map<String, dynamic>)).toList();
      return Categoria(
        codCategoria: categoriaData['Cod_Categoria'],
        nombre: categoriaData['Nombre'],
        preguntas: preguntasList,
      );
    }).toList();
    // return parsed.map<Categoria>((json) => Categoria.fromJson(json)).toList();
  }
}

Future<http.Response> enviarEncuesta(String token, int bodega, List<Map<String, dynamic>> data, int codInventario, int codUsuario) {
  return http
      .post(
        Uri.parse('${URL}api/encuesta/enviar_encuesta'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {"bodega": bodega, 'data': data, 'codInventario': codInventario, 'codUsuario': codUsuario},
        ),
      )
      .timeout(const Duration(seconds: 20));
}
