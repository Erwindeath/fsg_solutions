// ignore_for_file: import_of_legacy_library_into_null_safe, unused_import, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/logica_farmacias.dart';
import 'package:fsg_solutions/views/home_farma/menu_farma.dart';
import 'package:fsg_solutions/views/home_farma/principal_home_menu.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/home_ajuste_inventario.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventario.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/laboratorios.dart';
import 'package:fsg_solutions/views/inventario/informe_inventario/informeInventario.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:upgrader/upgrader.dart';

class HomeFarma extends StatefulWidget {
  const HomeFarma({Key? key}) : super(key: key);

  @override
  State<HomeFarma> createState() => _HomeFarmaState();
}

class _HomeFarmaState extends State<HomeFarma> {
  bool valida = false;
  String codPerfil = "";
  String codUsuarioP = "";
  final SecureStorage _storage = SecureStorage();
  List<Map<String, dynamic>> menu = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MenuFarma(),
      appBar: AppBar(
        title: Image.asset('assets/images/logoFSG.png', color: Colors.white, width: MediaQuery.of(context).size.width / 3 - 20),
        actions: [
          Builder(
              builder: (context) => IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.menu),
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ))
        ],
      ),
      body: UpgradeAlert(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(child: Builder(builder: (context) {
              // Crea un nuevo contexto para usar con Scaffold.of(context)
              return data();
            }), onRefresh: () async {
              obtenerCodPerfil();
            })),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    obtenerCodPerfil();
  }

  Widget data() {
    if (valida == true) {
      return Principal(
        children: [
          MenuAcciones(
            itemPorLinea: 2,
            children: [
              if (menu.isNotEmpty)
                for (int i = 0; i < menu.length; i++)
                  if (menu[i] != null)
                    BotonMenu(
                      nombre: menu[i]["Descripcion"],
                      valida: false,
                      icono:
                          getIcon(menu[i]["icono"]), // Reemplaza 'getIcon' con la función que obtiene el IconData correspondiente al nombre del icono
                      callback: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return getRoute(menu[i][
                                "Descripcion"]); // Reemplaza 'getRoute' con la función que obtiene la ruta de la página correspondiente al nombre de la opción
                          }),
                        );
                      },
                      color: Colores.esquemaColor,
                      habilitado: menu[i]["valor"] == 1 ? true : false,
                    ),
            ],
          ),
        ],
      );
    } else {
      return const Center(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.blueGrey,
          ),
        ),
      );
    }
  }

  Future<void> obtenerCodPerfil() async {
    await Upgrader.clearSavedSettings();
    String data = await _storage.readSecureData("cod_perfil");
    String codUsuario = await _storage.readSecureData("cod_usuario");
    String token = await _storage.readSecureData("token");

    try {
      var response = await obtenerDataMenu(int.parse(data), token);
      var valorIva = jsonDecode(response.body);
      if (jsonDecode(response.body)["data"] != null) {
        await _storage.writeSecureData("valorIva", valorIva["iva"][0]["ValorIva"].toString());

        setState(() {
          menu = (jsonDecode(response.body)["data"] as List).map((e) => e as Map<String, dynamic>).toList();
          codPerfil = data;
          codUsuarioP = codUsuario;
          valida = true;
        });
      } else {
        await Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "Error, comuníquese con el administrador",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
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
  }

  IconData getIcon(String iconName) {
    // Mapea el nombre del icono a su correspondiente IconData
    switch (iconName) {
      case 'activities':
        return Icons.inventory_outlined;
      case 'alarma':
        return Icons.notifications;
      case 'chipboard':
        return MdiIcons.clipboard;
      case 'clipboard_list':
        return MdiIcons.clipboardList;
      case 'note':
        return MdiIcons.notebookEdit;
      default:
        return Icons.error; // Icono por defecto en caso de que no se encuentre el nombre del icono
    }
  }

  Widget getRoute(String routeName) {
    // Mapea el nombre de la ruta a su correspondiente widget de Flutter
    switch (routeName) {
      case 'Inventario':
        return const LabotarotiosInventario();
      case 'Ajuste de inventario':
        return const AjusteInventario();

      default:
        return Container(); // Widget por defecto en caso de que no se encuentre la ruta
    }
  }
}
