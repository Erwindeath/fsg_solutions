// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/laboratorios.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/logica_inventario_general.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/methods.dart';
import 'package:intl/intl.dart';

class AjustarMovimientosPendientes extends StatefulWidget {
  final String json;
  final String fecha;
  final String token;
  final String codBodega;
  final String codigoInv;
  const AjustarMovimientosPendientes(
      {Key? key, required this.json, required this.fecha, required this.token, required this.codBodega, required this.codigoInv})
      : super(key: key);

  @override
  State<AjustarMovimientosPendientes> createState() => _AjustarMovimientosPendientesState();
}

class _AjustarMovimientosPendientesState extends State<AjustarMovimientosPendientes> {
  List<Ajuste> valoresAjustes = [];
  double sumaTotalValor = 0.0;
  double sumaTotalBase0 = 0.0;
  double sumaTotalIva = 0.0;
  double baseIva = 0.0;
  double porIva = 0.0;
  String perdiodo = "";
  bool estadoBoton = true;
  bool estadoBotonp = true;
  String nombreBodega = "";
  final SecureStorage storage = SecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async {
                await Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text('Ajustes pendientes'),
        ),
        body: datos(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: estadoBotonp
              ? () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          scrollable: true,
                          title: const Text('¿Está seguro de procesar estos datos?'),
                          content: const Text('No podrá volver atrás'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              onPressed: estadoBoton
                                  ? () async {
                                      await Fluttertoast.showToast(
                                        backgroundColor: Colors.yellow,
                                        textColor: Colors.black,
                                        msg: "Procesando datos, por favor espere...",
                                        gravity: ToastGravity.BOTTOM,
                                        toastLength: Toast.LENGTH_SHORT,
                                      );
                                      setState(() {
                                        estadoBoton = false;
                                      });
                                      Navigator.of(context).pop();
                                      var codUsuario = await storage.readSecureData("cod_usuario");

                                      await calcularValores();
                                      await ajustar(widget.token, int.parse(codUsuario), widget.fecha, perdiodo, sumaTotalValor, sumaTotalBase0,
                                          baseIva, sumaTotalIva, int.parse(widget.codBodega), int.parse(widget.codigoInv));

                                      //    Navigator.of(context).pop();
                                    }
                                  : null,
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      });
                    },
                  );
                }
              : null,
          label: const Row(
            children: [
              Icon(Icons.adjust), // Ícono que deseas mostrar
              SizedBox(width: 8), // Espacio entre el ícono y el texto
              Text("Ajustar"),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  Future<void> datosIniciales() async {
    String nombreUsuario = await storage.readSecureData("nombreBodega");
     String valorIva= await storage.readSecureData("valorIva");
    int valor= int.parse(valorIva);
    nombreBodega = nombreUsuario;
    valoresAjustes = parsearAjustes(widget.json);
    sumaTotalValor = valoresAjustes.fold(0, (sum, item) => sum + item.totalValor);
    sumaTotalBase0 = valoresAjustes.fold(0, (sum, item) => sum + item.totalBase0);
    sumaTotalIva = valoresAjustes.fold(0, (sum, item) => sum + item.totalIva);
    porIva=(valor/100);
    setState(() {});
  }

  Widget datos() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
          child: Text(nombreBodega.length > 30 ? nombreBodega.substring(0, 30) : nombreBodega,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: listaAjuste()),
        Card(
          elevation: 1.0,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Valor total:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('\$${sumaTotalValor.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget listaAjuste() {
    if (valoresAjustes.isEmpty) {
      return const Center(
        child: Text("Sin datos para ajustar."),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: valoresAjustes.length,
          itemBuilder: (BuildContext context, int indice) {
            Ajuste ajuste = valoresAjustes[indice];

            return Card(
              elevation: 4.0,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ajuste.nombreLaboratorio.length > 30 ? ajuste.nombreLaboratorio.substring(0, 30) : ajuste.nombreLaboratorio,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              // color: Colores.esquemaColor, // Define el color adecuado
                            ),
                          ),
                          Text('${ajuste.totalValor}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> ajustar(String token, int codUsuario, String fecha, String periodo, double total, double baseCero, double baseIva, double iva,
      int codBodega, int codIventario) async {
    var datos = await ajustarNovedadesPendientes(token, codUsuario, fecha, periodo, total, baseCero, baseIva, iva, codBodega, codIventario);
    var decodificado = jsonDecode(datos.body);
  //  print(decodificado);

    if (decodificado["msg"] == "ok") {
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              confirmButtonText: "Aceptar",
              title: "Ajustes realizados con éxito",
              // text: "Bienvenido",
              confirmButtonColor: Colores.esquemaColor));
      await Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContextcontext) => const LabotarotiosInventario()), (Route<dynamic> route) => false);
    } else {
      setState(() {
        estadoBoton = true;
        estadoBotonp = true;
      });
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Ocurrió un error: $decodificado",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> calcularValores() async {
    setState(() {
      estadoBotonp = false;
    });
    DateTime now = DateTime.now();

    // Formatea la fecha en el formato deseado (año y mes)
    String formattedDate = DateFormat('yyyyMM').format(now);

    perdiodo = formattedDate;
    if (sumaTotalIva == 0) {
      sumaTotalBase0 = sumaTotalValor;
      sumaTotalIva = 0;
      baseIva = 0; // si también tienes una variable para Base_Iva
    } else {
      if (sumaTotalValor < 0) {
        if (sumaTotalValor.abs() < sumaTotalBase0.abs()) {
          if (sumaTotalBase0 < 0) {
            sumaTotalBase0 = sumaTotalValor;
            sumaTotalIva = 0;
            baseIva = 0; // si también tienes una variable para Base_Iva
          } else {
            sumaTotalBase0 = 0;
            sumaTotalIva = ((sumaTotalValor - sumaTotalBase0) / (1 + porIva)) * porIva;
            baseIva = sumaTotalValor - sumaTotalIva - sumaTotalBase0; // si también tienes una variable para Base_Iva
          }
        } else {
          if (sumaTotalBase0 > 0) {
            sumaTotalBase0 = 0;
            sumaTotalIva = ((sumaTotalValor - sumaTotalBase0) / (1 + porIva)) * porIva;
            baseIva = sumaTotalValor - sumaTotalIva - sumaTotalBase0; // si también tienes una variable para Base_Iva
          } else {
            sumaTotalIva = ((sumaTotalValor - sumaTotalBase0) / (1 + porIva)) * porIva;
            baseIva = sumaTotalValor - sumaTotalIva - sumaTotalBase0; // si también tienes una variable para Base_Iva
          }
        }
      } else {
        if (sumaTotalValor.abs() < sumaTotalBase0.abs()) {
          if (sumaTotalBase0 < 0) {
            sumaTotalBase0 = 0;
            sumaTotalIva = ((sumaTotalValor - sumaTotalBase0) / (1 + porIva)) * porIva;
            baseIva = sumaTotalValor - sumaTotalIva - sumaTotalBase0; // si también tienes una variable para Base_Iva
          } else {
            sumaTotalBase0 = sumaTotalValor;
            sumaTotalIva = 0;
            baseIva = 0; // si también tienes una variable para Base_Iva
          }
        } else {
          if (sumaTotalBase0 < 0) {
            sumaTotalBase0 = 0;
            sumaTotalIva = ((sumaTotalValor - sumaTotalBase0) / (1 + porIva)) * porIva;
            baseIva = sumaTotalValor - sumaTotalIva - sumaTotalBase0; // si también tienes una variable para Base_Iva
          } else {
            sumaTotalIva = ((sumaTotalValor - sumaTotalBase0) / (1 + porIva)) * porIva;
            baseIva = sumaTotalValor - sumaTotalIva - sumaTotalBase0; // si también tienes una variable para Base_Iva
          }
        }
      }
    }
  }
}
