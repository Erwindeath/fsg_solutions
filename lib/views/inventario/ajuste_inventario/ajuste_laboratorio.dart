// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/clase_ajuste.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/home_ajuste_inventario.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/logicaAjuste.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/methods.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/providers.dart';
import 'package:fsg_solutions/views/inventario/enviando.dart';
import 'package:http/http.dart';

import '../../home_user/methods/get_ubicacion.dart';

class AjusteLaboratorio extends ConsumerStatefulWidget {
  Response data;
  final String fechaInicio;
  final int codLaboratorio;
  final int codBodega;
  AjusteLaboratorio({required this.data, required this.fechaInicio, required this.codLaboratorio, required this.codBodega, super.key});

  @override
  ConsumerState<AjusteLaboratorio> createState() => _AjusteLaboratorioState();
}

class _AjusteLaboratorioState extends ConsumerState<AjusteLaboratorio> {
  // Datos de ejemplo para llenar la tabla

  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');
  StreamSubscription<dynamic>? fdwListener;
  ScrollController scrollController = ScrollController();
  int? highlightedIndex;

  List<AjusteInventarioLaboratorio> reportItems = [];
  String token = "";
  String codBodega = "";
  double totalInicial = 0.0;
  double totalFinal = 0.0;
  SecureStorage storage = SecureStorage();
  List<TextEditingController> unidadControllers = [];
  List<FocusNode> unidadFocusNodes = [];
  List<TextEditingController> fraccionControllers = [];
  List<FocusNode> fraccionFocusNodes = [];
  //bool habilitado=true;
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(enviando);
    final enviars = ref.watch(enviar);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuste Laboratorio'),
        actions: [
          IconButton(
              onPressed: !isLoading && enviars
                  ? () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                              return WillPopScope(
                                child: AlertDialog(
                                  title: const Text("¿Está seguro de continuar?"),
                                  content: const Text("Si presiona en aceptar se harán los ajustes correspondientes"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("Cancelar"),
                                      onPressed: () {
                                        ref.read(enviando.notifier).state = false;
                                        Navigator.pop(context); // Cierra el diálogo
                                      },
                                    ),
                                    TextButton(
                                      onPressed: !isLoading
                                          ? () async {
                                              ref.read(enviando.notifier).state = true;
                                              Navigator.pop(context);
                                              await enviarDatos();
                                            }
                                          : null,
                                      child: const Text("Aceptar"),
                                    ),
                                  ],
                                ),
                                onWillPop: () async => Future.value(false),
                              );
                            });
                          });
                    }
                  : null,
              icon: const Icon(Icons.save))
        ],
      ),
      body: Stack(
        children: <Widget>[
          datos(),
          if (isLoading)
            const CargandoEnvio(
              texto: 'Procesando datos, por favor espere.',
              colorTexto: Colores.esquemaColor,
              width: 300.0,
              height: 300.0,
              tamanoTexto: 14,
            )
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AjusteLaboratorio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      ref.read(ajusteLaboratorioProvider.notifier).setData([]); // Limpiar los datos
    }
  }

  Future<void> enviarDatos() async {
    final data = ref.watch(ajusteLaboratorioProvider);
    //primerInforme.motivos.map((e) => e.toJson()).toList(),
    //print(data.map((e) => e.toJson()));
    String codUsuario = await storage.readSecureData("cod_usuario");
    String codSesion = await storage.readSecureData("codSesion");
    String codEstacion = await storage.readSecureData("Estacion");
    try {
      String totalInicialFormatted = totalInicial.toStringAsFixed(2);
      var datos = await procesarAjustes(
          data.map((e) => e.toJson()).toList(),
          widget.codBodega,
          int.parse(codUsuario),
          widget.codLaboratorio,
          ref.watch(long),
          ref.watch(lat),
          widget.fechaInicio,
          int.parse(codSesion),
          int.parse(codEstacion),
          double.parse(totalInicialFormatted),
          totalFinal,
          token);
      var decode = jsonDecode(datos.body);
      if (decode["msg"] != "err") {
        if (mounted) {
          ref.read(enviando.notifier).state = false;
          Future.microtask(() async {
            await ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Correcto",
                text: "Ajustes realizados con éxito",
                confirmButtonText: "Aceptar",
                confirmButtonColor: Colores.esquemaColor,
                onConfirm: () async {
                  await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const AjusteInventario(),
                    ),
                    (route) => false,
                  );
                },
              ),
            );
          });
        }
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "Ocurrió un error al procesar: $decode",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG,
        );
        ref.read(enviando.notifier).state = false;
      }
    } on TimeoutException catch (e) {
      ref.read(enviando.notifier).state = false;

      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Comuníquese con el administrador ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    } on SocketException catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Comuníquese con el administrador ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    }
    //ref.read(enviando.notifier).state = false;
  }

  Widget datos() {
    return Column(
      children: [
        Expanded(child: tablaPrincipal()), // Ahora `Expanded` está dentro de `Column`
        total() // Este widget muestra el total sin ser `Expanded`
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (mounted) {
        reportItems.clear();
        ref.read(ajusteLaboratorioProvider.notifier).setData([]);
        ref.read(ajusteLaboratorioProvider.notifier).setData(parsearDataLaboratorio(widget.data.body));
        totalInicial = calcularTotalInicial();
        ref.read(enviando.notifier).state = false; // Calcular el total inicial
        ref.read(enviar.notifier).state = false;
        var retorno = await conseguirUbicacion();
        String longActual = retorno["longitude"] ?? "0.0";
        String latActual = retorno["latitude"] ?? "0.0";
        ref.read(long.notifier).state = double.parse(longActual);
        ref.read(lat.notifier).state = double.parse(latActual);
        token = await storage.readSecureData("token");
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    fdwListener?.cancel();
    super.dispose();
  }

  double calcularTotalInicial() {
    final reportItems = ref.watch(ajusteLaboratorioProvider);
    iniciarScanner(reportItems);
    return reportItems.fold(0.0, (sum, ajuste) {
      double totalProducto = (ajuste.unidad + (ajuste.fraccion / ajuste.fracciones)) * ajuste.pVenta;
      return sum + totalProducto;
    });
  }

  void iniciarScanner(List<AjusteInventarioLaboratorio> reportItems) async {
    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {
        final codBarra = code.data.toString().trim();
        int index = reportItems.indexWhere((item) => item.codBarra == codBarra);
        if (index != -1) {
          // Calcula la posición de scroll deseada
          double scrollPosition = index * 50.0; // Asumiendo una altura de fila de 50.0
          scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          setState(() {
            highlightedIndex = index; // Resaltar la fila encontrada
          });
          Future.delayed(const Duration(seconds: 2), () {
            // Des-resaltar después de 2 segundos
            if (mounted) {
              setState(() {
                highlightedIndex = null;
              });
            }
          });
          // Opcional: puedes resaltar la fila o realizar otra acción aquí
        } else {
          // Opcional: manejar el caso de no encontrar el producto
          Fluttertoast.showToast(
            msg: "Producto no encontrado",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          setState(() {
            highlightedIndex = null; // Quitar el resaltado si no se encuentra
          });
        }
      });
    }
  }

  Widget tablaPrincipal() {
    final reportItems = ref.watch(ajusteLaboratorioProvider);
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.vertical,
      child: Card(
        child: DataTable(
          columnSpacing: 10,
          showBottomBorder: true,
          headingRowHeight: 40,
          dataRowMaxHeight: 50,
          columns: const [
            DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('PVP', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Unid', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Frac', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(reportItems.length, (index) {
            final item = reportItems[index];
            return DataRow(cells: [
              DataCell(SizedBox(
                width: 190,
                child: Text(
                  item.producto,
                  softWrap: true,
                  style: TextStyle(
                    color: index == highlightedIndex
                        ? Colors.white
                        : (item.isEdited ? Colors.red : (item.codTipo == "02" ? Colors.orange : Colors.black)),
                    backgroundColor: index == highlightedIndex ? Colors.blue : Colors.transparent,
                  ),
                ),
              )),
              DataCell(Text(item.precioPublico.toString())),
              DataCell(TextFormField(
                initialValue: item.unidad.toString(),
                enabled: item.codTipo != "02",
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    if (int.parse(value) != item.unidad) {
                      ref.read(ajusteLaboratorioProvider.notifier).updateUnidad(index, int.parse(value), item.unidadA, ref);
                    }
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: "El valor de cajas no puede ir vacío",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_LONG,
                    );
                  }
                },
              )),
              DataCell(TextFormField(
                enabled: item.fracciones > 1 && item.codTipo != "02",
                keyboardType: TextInputType.number,
                initialValue: item.fraccion.toString(),
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty && int.parse(value) <= item.fracciones) {
                    if (/*item.fraccionA != int.parse(value) && item.fraccion != item.fraccionA &&*/ int.parse(value) != item.fraccion) {
                      ref.read(ajusteLaboratorioProvider.notifier).updateFraccion(index, int.parse(value), item.fraccionA, ref);
                    }
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: "El valor de fracciones no puede ir vacío o superar a la cantidad fraccionada",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_LONG,
                    );
                  }
                },
              )),
            ]);
          }),
        ),
      ),
    );
  }

  Widget total() {
    final reportItems = ref.watch(ajusteLaboratorioProvider);

    double totalGeneral = reportItems.fold(0.0, (sum, ajuste) {
      double totalProducto = (ajuste.unidad + (ajuste.fraccion / ajuste.fracciones)) * ajuste.pVenta;
      return sum + totalProducto;
    });
    double total = 0.0;
    total = totalGeneral - totalInicial;

    String totalAnterior = totalGeneral.toStringAsFixed(2);
    String totalInicialFormatted = totalInicial.toStringAsFixed(2); // Usar para mostrar el total inicial
    totalFinal = double.parse(totalAnterior);
    String diferencia = total.toStringAsFixed(2);
    return Card(
      //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(diferencia), Text(totalInicialFormatted), Text(totalAnterior)],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Diferencia",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Anterior",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Total",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
