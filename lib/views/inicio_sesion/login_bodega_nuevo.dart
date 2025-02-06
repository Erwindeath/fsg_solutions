// ignore_for_file: use_build_context_synchronously, unused_field, prefer_final_fields, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inicio_sesion/models/logica_login.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginBodegaNuevo extends StatefulWidget {
  const LoginBodegaNuevo({Key? key}) : super(key: key);

  @override
  State<LoginBodegaNuevo> createState() => _LoginBodegaNuevo();
}

class _LoginBodegaNuevo extends State<LoginBodegaNuevo> {
  final SecureStorage _storage = SecureStorage();
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int controlSesion = 0;
  String controlClave = "";
  String _lon = "0.0";
  String _lat = "0.0";
  String _geohash = "0";
  String qr = "";
  //String id_usr = "";

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    await controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    checkCredentials();
  }

  Future<void> checkCredentials() async {
    //String data = await _storage.readSecureData("Rol") ?? "";
    final prefs = await SharedPreferences.getInstance();
    String valor = prefs.getString('qr').toString();

    // print("Este valor:"+ qr_data);
    setState(() {
      //rol_usuario = data;
      qr = valor;
      //id_usr = id_bodega;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null && mounted) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Inicio farmacia"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
            child: FutureBuilder(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                return snapshot.data == false ? const Icon(Icons.flash_off) : const Icon(Icons.flash_on);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
            child: FutureBuilder(
              future: controller?.getCameraInfo(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return const Icon(Icons.flip_camera_android);
                } else {
                  return const Text('loading');
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Para iniciar debe escanear el código QR del adhesivo colocado en el punto venta.",
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 5, child: _buildQrView(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _displayTextInputDialog(context);
        },
        child: const Icon(Icons.keyboard),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: Colores.esquemaColor, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      await this.controller?.pauseCamera();
      //print("valor del scaner: " + scanData.code);+

      String codUsuario = await _storage.readSecureData("cod_usuario");
      String token = await _storage.readSecureData("token");
      try {
        var loginBodega = await obtenerBodega(scanData.code.toString(), token);
        var loginDecode = jsonDecode(loginBodega.body);
        if (loginDecode["msg"] == "ok") {
          await guardarSesionDatos(
              int.parse(codUsuario),
              double.parse(loginDecode["data"]["respuesta"][0]["Longitude"].toString()),
              double.parse(loginDecode["data"]["respuesta"][0]["Latitude"].toString()),
              int.parse(loginDecode["data"]["respuesta"][0]["Cod_Bodega"].toString()),
              token);

          await guardarDatosBodega(
              loginDecode["data"]["respuesta"][0]["Cod_Bodega"].toString(), loginDecode["data"]["respuesta"][0]["Descripcion"].toString(),"");
          await ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  confirmButtonText: "Aceptar",
                  title: "Bodega verificada!",
                  text: "Bienvenido",
                  confirmButtonColor: Colores.esquemaColor));
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const HomeFarma(),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('El codigo escaneado no es correcto'),
              backgroundColor: Colors.red,
            ));
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

        // if(loginDecode)
      }
      await this.controller?.resumeCamera();
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('no Permission'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    bool isobscured = true;
    return ArtSweetAlert.show(
        barrierDismissible: false,
        context: context,
        artDialogArgs: ArtDialogArgs(
          customColumns: [
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: TextField(
                enableSuggestions: false,
                autocorrect: false,
                controller: _textFieldController,
                decoration: const InputDecoration(
                  hintText: "Clave de seguridad",
                  suffixIcon: Icon(Icons.visibility),
                ),
              ),
            )
          ],
          confirmButtonText: "Aceptar",
          showCancelBtn: true,
          cancelButtonText: "Cancelar",
          cancelButtonColor: Colores.esquemaColor,
          title: "Ingrese clave de seguridad!",
          confirmButtonColor: Colores.esquemaColor,
          onCancel: () {
            Navigator.pop(context);
          },
          onConfirm: () async {
            if (qr.toLowerCase() == _textFieldController.text.toString().trim().toLowerCase()) {
              // await guardarDatosBodega(codBodega, nombreBodega);
              await ArtSweetAlert.show(
                  barrierDismissible: false,
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.success,
                      confirmButtonText: "Aceptar",
                      title: "Bodega verificada!",
                      text: "Bienvenido",
                      confirmButtonColor: Colores.esquemaColor));
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomeFarma(),
                ),
                (route) => false,
              );
            } else {
              ArtSweetAlert.show(
                  barrierDismissible: false,
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.danger,
                      title: "Error de verificación!",
                      confirmButtonText: "Aceptar",
                      text: "Clave ingresada no pertenece a la farmacia seleccionada",
                      confirmButtonColor: Colores.esquemaColor));
            }
          },
        ));
  }
}

/*Future<void> obtenerubicacionLogin() async {
  var retorno = await conseguirUbicacion();
  if (retorno["estado"] == "false") return;
  String _lon_ = retorno["longitude"] ?? "0.0";
  String _lat_ = retorno["latitude"] ?? "0.0";
  String _geohash_ =
      await conseguirGeoHash(double.parse(_lon_), double.parse(_lat_));

  final SecureStorage _guardar = SecureStorage();

  await _guardar.writeSecureData("longitud", _lon_);
  await _guardar.writeSecureData("latitud", _lat_);
}*/

