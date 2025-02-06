// ignore_for_file: unused_field

import 'dart:convert';

import 'package:fsg_solutions/complementos/calendario/utils/model_data.dart';
import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:http/http.dart' as http;

///Classe que controla as requisiÃ§Ãµes dos horÃ¡rios/agendas.
class FakerApi {
  final SecureStorage _storage = SecureStorage();

  ///FunÃ§Ã£o para obter os horÃ¡rios disponÃ­veis com base nos paramÃªtros obrigatórios.
  static Future<List<Data>> getData(String token, int codUsuario) async {
    String peticion = '';
    peticion = '${URL}api/creedenciales/obtener_farmacias_eventos';

    final response = await http.post(
      Uri.parse(peticion),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access-token': token,
      },
      body: jsonEncode(
        {'codUsuario': codUsuario},
      ),
    );

    List<Data> list = parseSchedules(response.body);
    return list;
  }

  static List<Data> parseSchedules(String responseBody) {
    final parsed = jsonDecode(responseBody)["data"];

    return parsed.map<Data>((json) => Data.fromJson(json)).toList();
  }
}
