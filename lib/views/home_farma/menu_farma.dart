// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_user/home_user.dart';
import 'package:fsg_solutions/views/inicio_sesion/models/logica_login.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../inventario/encuestaInicial/encuesta_sqlite.dart';

class MenuFarma extends StatefulWidget {
  const MenuFarma({Key? key}) : super(key: key);

  @override
  _MenuFarmaViewState createState() => _MenuFarmaViewState();
}

class _MenuFarmaViewState extends State<MenuFarma> {
  final SecureStorage storage = SecureStorage();

  final dbHelper = DatabaseHelperEncuesta();
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  //String rol_usuario = "";
  String nombreDisplay = "";
  //String id_usr = "";
  String nombreFarmacia = "";
  String telefonSistemas = "";
  bool controlSalir = false;
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    checkCredentials();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    packageInfo = info;
  }

  Future<void> checkCredentials() async {
    //String data = await _storage.readSecureData("Rol") ?? "";
    String nombreUsuario = await storage.readSecureData("nombreBodega");
    //String id_bodega = await _storage.readSecureData("id_usuario");
    //String telefonoSistemas = await _storage.readSecureData("telefono_sistemas");*/
    setState(() {
      nombreFarmacia = nombreUsuario;
      //rol_usuario = data;
      /*nombre_display = nombre_usuario;
      //id_usr = id_bodega;
      telefono_sistemas = telefonoSistemas;*/
    });
  }

  Future<void> goToHome2() async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const HomeUser(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Configuración"),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: <Widget>[
          Card(
              child: Row(
            children: <Widget>[
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain, // otherwise the logo will be tiny
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              const Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      "GESTOR 360",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    /*Text(
                        'Versión ${packageInfo.version} (${packageInfo.buildNumber})',
                        textAlign: TextAlign.center),*/

                    //En pubspec.yaml 1.0.0+1 1.0.0 es la versión
                    //Text('(26 ago. 2021)'),
                    /*    Text('(22 oct. 2021)'),
                        Text('Farmacias San Gregorio', textAlign: TextAlign.center),*/
                  ],
                ),
              ),
            ],
          )),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: <Widget>[
                  const Text('Bodega:', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  Expanded(
                    child: Text(nombreFarmacia, style: const TextStyle(color: Color(0xff804850)), textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text('Contacto de soporte:', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  ),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: "0982316315"));
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(const SnackBar(content: Text('Contacto de soporte copiado al portapapeles')));
                    },
                    child: const Text("0982316315", style: TextStyle(color: Color(0xff804850)), textAlign: TextAlign.right),
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                var logoutCheck = await logoutFarmacia();
                if (logoutCheck) {
                  await goToHome2();
                }
                //}
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Cerrar Sesión'),
                    SizedBox(width: 10),
                    Icon(Icons.logout),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                _showDeleteDialog(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Limpiar'),
                    SizedBox(width: 10),
                    Icon(Icons.restart_alt),
                  ],
                ),
              ),
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                /* var logoutCheck = await logoutFarmacia();
                if (logoutCheck) {
                  await goToHome2();
                }*/
                //}
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Reiniciar datos'),
                    SizedBox(width: 10),
                    Icon(Icons.restart_alt),
                  ],
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    String clave = "6542";
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de seguridad'),
          content: TextField(
            controller: passwordController,
            obscureText: true, // Esto es para que la entrada sea oculta
            decoration: const InputDecoration(
              hintText: 'Ingrese su clave',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {
                // Aquí puedes verificar la clave
                if (passwordController.text == clave) {
                  Navigator.of(context).pop();
                  await storage.deleteSecureData("encuesta");
                  await dbHelper.deleteTable();
                  await storage.deleteSecureData("validacionInventario");

                  // Puedes agregar aquí un mensaje de éxito
                  Fluttertoast.showToast(
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    msg: "Datos eliminados correctamente",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Datos eliminados correctamente.")));
                } else {
                  Navigator.of(context).pop();
                  // Mensaje de error si la clave es incorrecta
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "Clave incorrecta",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                 // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Clave incorrecta.")));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
