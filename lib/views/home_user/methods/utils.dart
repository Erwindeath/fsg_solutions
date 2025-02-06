// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unnecessary_new, unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fsg_solutions/complementos/globals/globales.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';

import 'package:fsg_solutions/views/inicio_sesion/login_bodega.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../inicio_sesion/login_bodega_nuevo.dart';

Widget generarFarmacias(List<Map<String, dynamic>> valor, BuildContext context, String longitud, String latitud) {
  var _Globales = new Globales();
  final SecureStorage _storage = SecureStorage();
  return ListView.builder(
    itemCount: valor.length,
    itemBuilder: (context, index) {
      var farmacia = valor[index];
      // Crea aquí el widget Card para cada farmacia
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: GestureDetector(
          onTap: () async {
            print(farmacia);
            iniciarSesionBodega(farmacia["codInventario"].toString(), farmacia["LlaveQR"].toString(), farmacia["codBodega"].toString(),
                farmacia["Nombre"].toString(), context, _storage, longitud, latitud, farmacia["metodo"]);
          },
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            farmacia["Nombre"].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff804850)),
                          ),
                          Text(farmacia["Ciudad"].toString()),
                          SizedBox(width: 200, child: Text(farmacia["Ubicacion"].toString())),
                          //Text(farmacia["id_actividad"].toString()),
                          Text("${double.parse(farmacia["distancia"].toString()).toStringAsFixed(2)} Km", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Expanded(
                          child: TextButton(
                        onPressed: () async {
                          await _Globales.platform
                              .invokeMethod('sendMap', {"ubicacion": "google.navigation:q=${farmacia["lat"]},${farmacia["long"]}"});
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.place_rounded,
                              size: 50.0,
                              color: Color(0xff804850),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/*List<Widget> generarFarmaciass(List<Map<String, dynamic>> valor, BuildContext context, String longitud, String latitud) {
  var _Globales = new Globales();
  final SecureStorage _storage = SecureStorage();
  List<Widget> listadoFarmacia = [];
  for (var farmacia in valor) {
    listadoFarmacia.add(
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: GestureDetector(
          onTap: () async {
            iniciarSesionBodega(farmacia["codInventario"].toString(), farmacia["LlaveQR"].toString(), farmacia["codBodega"].toString(),
                farmacia["Nombre"].toString(), context, _storage, longitud, latitud);
          },
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            farmacia["Nombre"].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff804850)),
                          ),
                          Text(farmacia["Ciudad"].toString()),
                          SizedBox(width: 200, child: Text(farmacia["Ubicacion"].toString())),
                          //Text(farmacia["id_actividad"].toString()),
                          Text("${double.parse(farmacia["distancia"].toString()).toStringAsFixed(2)} Km", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Expanded(
                          child: TextButton(
                        onPressed: () async {
                          await _Globales.platform
                              .invokeMethod('sendMap', {"ubicacion": "google.navigation:q=${farmacia["lat"]},${farmacia["long"]}"});
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.place_rounded,
                              size: 50.0,
                              color: Color(0xff804850),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  return listadoFarmacia;
}
*/
Future<void> iniciarSesionNormal(BuildContext context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return const LoginBodegaNuevo();
  }));
}

Future<void> iniciarSesionBodega(String actividad, String llaveQr, String codBodega, String nombreBodega, BuildContext context,
    SecureStorage _storage, String longitud, String latitud, bool metodo) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("qr", llaveQr.toString());
  await _storage.writeSecureData("codInventario", actividad);
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return LoginBodega(
      codBodega: codBodega,
      nombreBodega: nombreBodega,
      longitud: longitud,
      latitud: latitud,
      comprueba: 1,
      metodo: metodo.toString(),
    );
  }));
}
