// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/globals/esqueleto.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/ajuste_laboratorio.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/logicaAjuste.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/providers.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/encuesta.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:intl/intl.dart' as inta;

import '../inventarios_obligatorios/logica_inventario_general.dart';

class AjusteInventario extends ConsumerStatefulWidget {
  const AjusteInventario({super.key});

  @override
  ConsumerState<AjusteInventario> createState() => _AjusteInventarioState();
}

class _AjusteInventarioState extends ConsumerState<AjusteInventario> {
  List<Map<String, dynamic>> laboratoriosInventario = [];
  List<Map<String, dynamic>> valores = [];
  String token = "";
  String codBodega = "";
  TextEditingController editingController = TextEditingController();
  bool validar = false;
  bool _estaSeleccionando = false;
  SecureStorage storage = SecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuste Laboratorios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const HomeFarma(),
              ),
              (route) => false,
            );
          },
        ),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            datosIniciales();
          },
          child: datos()),
    );
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  Future<void> datosIniciales() async {
    token = await storage.readSecureData("token");
    var codUsuario = await storage.readSecureData("cod_usuario");
    codBodega = await storage.readSecureData("codBodega");
    var lab = await obtenerLaboratorios(token, 'obtener_laboratorios_ajuste');
    //var encuesta = await storage.readSecureData("encuesta") ?? "";
    String codInventarios = await storage.readSecureData("codInventario") ?? "";

    bool activar = false;
    if (codInventarios != "") {
      var comprubaFin = await obtenerFarmaciasLaboratorios(
          int.parse(codUsuario), int.parse(codBodega), token, "comprobar_estado_inventario", int.parse(codInventarios));
      var compruebaDecode = jsonDecode(comprubaFin.body);
      //print(compruebaDecode);
      if (compruebaDecode["msg"] != "err") {
        if (compruebaDecode["datos"][0]["Encuesta"] == null) {
          activar = false;
        } else {
          activar = true;
        }
      } else {
        activar = false;
      }
    } else {
      DateTime ahora = DateTime.now();
      // Asegurarse de que solo se compare la fecha, sin la hora
      DateTime fechaActual = DateTime(ahora.year, ahora.month, ahora.day);
      final String formattedDate = DateFormat('dd/MM/yyyy').format(fechaActual);
      activar = true;
      var comprubaFin = await obtenerFarmaciaEncuestaBodega(int.parse(codBodega), token, "comprobar_encuesta_bodega", formattedDate);
      var compruebaDecode = jsonDecode(comprubaFin.body);
      if (compruebaDecode["msg"] != "err") {
        activar = true;
      } else {
        activar = true;
      }
      /*if (encuesta != "") {
        activar = true;
      }*/
    }

    /*if (!activar) {
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => EncuestaInicial(
                    codInventario: 0,
                    codBodega: int.parse(codBodega),
                    codUsuario: int.parse(codUsuario),
                    valida: false,
                  )),
          (Route<dynamic> route) => false);
    }*/
    try {
      if (jsonDecode(lab.body)["msg"] != "err") {
        List<Map<String, dynamic>> laboratorios = (jsonDecode(lab.body)["data"] as List).map((e) => e as Map<String, dynamic>).toList();

        setState(() {
          laboratoriosInventario = laboratorios;
          valores = laboratorios;
          validar = true;
        });
      } else {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Ocurrió un error al obtener los laboratorios",
                confirmButtonText: "Aceptar",
                onConfirm: () async {
                  await Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                },
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
  }

  Widget datos() {
    return laboratoriosInventario.isEmpty && !validar ? const MenuSkeleton() : principal(laboratoriosInventario);
  }

  Widget principal(List<Map<String, dynamic>> laboratorios) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: editingController,
            decoration: const InputDecoration(
              labelText: "Buscar laboratorio",
              hintText: "Buscar laboratorio",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) async {
              await filterSearch(value);
            },
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var laboratorioss = laboratorios[index];
                    var descripcion = laboratorioss['Nombres'];
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              descripcion,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colores.esquemaColor,
                              ),
                            ),
                            trailing: Icon(
                              MdiIcons.clipboardList,
                              color: Colores.esquemaColor,
                            ),
                            onTap: () async {
                              if (_estaSeleccionando) return;
                              // Indica que la selección ha comenzado
                              _estaSeleccionando = true;
                              var data = await obtenerDataLaboratorio(laboratorioss["Cod_Laboratorio"], int.parse(codBodega), token);
                              var dataDeco = jsonDecode(data.body);
                              if (dataDeco["msg"] != "err") {
                                _estaSeleccionando = false;
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.green,
                                  textColor: Colors.black,
                                  msg: "Obteniendo datos, por favor espere...",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                                final now = DateTime.now();
                                final fechaInicio = inta.DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
                                ref.read(ajusteLaboratorioProvider.notifier).setData([]);
                                var shouldClearData = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => AjusteLaboratorio(
                                        data: data,
                                        fechaInicio: fechaInicio,
                                        codLaboratorio: laboratorioss["Cod_Laboratorio"],
                                        codBodega: int.parse(codBodega)),
                                  ),
                                );

                                // Si shouldClearData es true, limpiar los datos del proveedor
                                if (shouldClearData == true) {
                                  setState(() {
                                    // Limpiar los datos del proveedor
                                  });
                                }
                                /* final dbHelper = DatabaseHelper();
                                await dbHelper.deleteTable();
                                await storage.deleteSecureData("codLaboratorio");
                                await storage.deleteSecureData("nombreLaboratorio");
                                await storage.deleteSecureData("codInventarioDet");
                                await storage.deleteSecureData("fechaInventario");
                                guardarData(laboratorioss["Cod_Laboratorio"].toString(), descripcion, laboratorioss["codIventario"].toString(),
                                    laboratorioss["C_Inventario_Det"].toString());

                                */
                              } else {
                                await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.danger,
                                        title: "Error",
                                        text: "Este laboratorio no tiene productos",
                                        confirmButtonText: "Aceptar",
                                        showCancelBtn: true,
                                        cancelButtonText: "Cancelar",
                                        confirmButtonColor: Colores.esquemaColor));
                              }

                              // Después de manejar la selección, restablece el estado de selección
                              _estaSeleccionando = false;
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: laboratorios.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> filterSearch(String query) async {
    List<Map<String, dynamic>> tempList = [];

    if (query.isNotEmpty) {
      for (var item in laboratoriosInventario) {
        String descripcion = item['Nombres'];
        if (descripcion.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      }
      tempList.sort((a, b) => (a['Nombres']).toLowerCase().compareTo((b['Nombres']).toLowerCase()));
      setState(() {
        laboratoriosInventario = tempList;
      });
    } else {
      setState(() {
        laboratoriosInventario = List.from(valores);
        laboratoriosInventario.sort((a, b) => (a['Nombres']).toLowerCase().compareTo((b['Nombres']).toLowerCase()));
      });
    }
  }
}
