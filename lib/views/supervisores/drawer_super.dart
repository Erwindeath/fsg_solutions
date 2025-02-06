// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/inicio_sesion/models/logica_login.dart';
import 'package:fsg_solutions/views/inicio_sesion/principal.dart';

class DrawerSuper extends StatefulWidget {
  const DrawerSuper({Key? key}) : super(key: key);

  @override
  _DrawerSuperViewState createState() => _DrawerSuperViewState();
}

class _DrawerSuperViewState extends State<DrawerSuper> {
  final SecureStorage storage = SecureStorage();

  //String rol_usuario = "";
  String nombreDisplay = "";
  //String id_usr = "";
  String nombreFarmacia = "";
  String telefonSistemas = "";
  bool controlSalir = false;
  @override
  void initState() {
    super.initState();

    checkCredentials();
  }

  Future<void> checkCredentials() async {
    //String data = await _storage.readSecureData("Rol") ?? "";
    String nombreUsuario = await storage.readSecureData("Nombre");
    //String id_bodega = await _storage.readSecureData("id_usuario");
    //String telefonoSistemas = await _storage.readSecureData("telefono_sistemas");*/
    setState(() {
      nombreFarmacia = nombreUsuario;
    });
  }

  Future<void> goToHome2() async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const PrincipalLogin(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  const Expanded(
                    child: Text('Usuario:', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  ),
                  Text(nombreFarmacia, style: const TextStyle(color: Color(0xff804850)), textAlign: TextAlign.right),
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
                var logoutCheck = await logout();
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
        ],
      ),
    );
  }
}
