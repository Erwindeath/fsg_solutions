// ignore_for_file: unused_import, import_of_legacy_library_into_null_safe, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fsg_solutions/complementos/calendario/utils/widget_app_bar.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/main.dart';
import 'package:fsg_solutions/views/supervisores/cuestionario_inicial.dart';
import 'package:fsg_solutions/views/home_user/home_user.dart';
import 'package:fsg_solutions/views/inicio_sesion/models/logica_login.dart';
import 'dart:convert';

import 'package:fsg_solutions/views/supervisores/menuSuper.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  StreamSubscription? fdwListener;

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  final bool _isLoading = false;
  bool scannerInitialized = false;
  bool _isObscure = true;
  final SecureStorage _storage = SecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /*appBar: AppBar(
          title: const WidgetImageBar(),
        ),*/
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10.0),
                  children: [
                    Column(
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset('assets/images/logoFSG.png', width: (MediaQuery.of(context).size.width / 1.5))),
                          Padding(padding: const EdgeInsets.all(15.0), child: titulo()),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0), child: usuario()),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0), child: password()),
                          botonlogin(),
                        ]),
                      ],
                    ),
                  ],
                ),
              ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget usuario() {
    return TextField(
      controller: _usuarioController,
      decoration: const InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(500.0))),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          labelText: "Ingrese su usuario",
          hintText: "Nombre de usuario"),
    );
  }

  Widget password() {
    return TextField(
      obscureText: _isObscure,
      enableSuggestions: false,
      autocorrect: false,
      controller: _contrasenaController,
      decoration: InputDecoration(
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(500.0))),
          prefixIcon: const Icon(
            Icons.lock,
            color: Colors.black,
          ),
          labelText: "Ingrese su contraseña",
          hintText: "Contraseña",
          suffixIcon: IconButton(
            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          )),
    );
  }

  Widget titulo() {
    return Text(
      "GESTOR 360",
      style: TextStyle(
        decoration: TextDecoration.none,
        color: Theme.of(context).primaryColor,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget botonlogin() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  elevation: 4.0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(500.0),
                  ))),
              onPressed: () async {
                if (_usuarioController.text == "" || _contrasenaController.text == "") {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text('Debe rellenar todos los campos'),
                      backgroundColor: Colors.red,
                    ));
                } else {
                  String tokenFirebase = await _storage.readSecureData("token_firebase");

                  if (tokenFirebase != "") {
                    try {
                      var login = await loginBodegaUsuario(_usuarioController.text.trim(), _contrasenaController.text.trim(), tokenFirebase);
                      var datoDecodificado = jsonDecode(login.body);

                      if (datoDecodificado["msg"] != "err") {
                        await registrarDatosUsuariosBodega(datoDecodificado);
                        await ArtSweetAlert.show(
                            barrierDismissible: false,
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.success,
                                confirmButtonText: "Aceptar",
                                title: "Usuario verificado!",
                                text: "Bienvenido",
                                confirmButtonColor: Colores.esquemaColor));
                        String codPerfil = await _storage.readSecureData("cod_perfil");
                        if (codPerfil == '9' || codPerfil == '42') {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (BuildContext context) => const MenuSuper()), (Route<dynamic> route) => false);
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (BuildContext context) => const HomeUser()), (Route<dynamic> route) => false);
                        }
                      } else {
                        
                        ArtSweetAlert.show(
                            barrierDismissible: false,
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.danger,
                                title: "Error de verificación!",
                                confirmButtonText: "Aceptar",
                                text: "Usuario/clave incorrectos",
                                confirmButtonColor: Colores.esquemaColor));
                      }
                    } on TimeoutException catch (e) {
                      ArtSweetAlert.show(
                          barrierDismissible: false,
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.danger,
                              title: "Error: $e",
                              confirmButtonText: "Aceptar",
                              text: "Comuníquese con el administrador",
                              confirmButtonColor: Colores.esquemaColor));
                    }
                  } else {
                    ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Error!!",
                            confirmButtonText: "Aceptar",
                            text: "Comuníquese con el administrador",
                            confirmButtonColor: Colores.esquemaColor));
                  }
                }
              },
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Iniciar sesión"),
                SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.send,
                    size: 20.0,
                  ),
                )
              ]),
            )),
      ),
    );
  }
}
