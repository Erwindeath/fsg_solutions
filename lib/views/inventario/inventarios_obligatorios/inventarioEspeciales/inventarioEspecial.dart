// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/providers.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/logica_inventario_general.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/methods.dart';
import 'package:intl/intl.dart' as inta;
import 'package:badges/badges.dart' as badges;
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/database/inventario_sqlite.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/platform_service.dart';

class InventarioEspecial extends ConsumerStatefulWidget {
  const InventarioEspecial({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InventarioEspecialState();
}

class _InventarioEspecialState extends ConsumerState<InventarioEspecial> {
  bool activa = false;
  FocusNode cajasFocusNode = FocusNode();
  int cantidadCajas = 0;
  int cantidadFracciones = 0;
  /*bool activaBotonPrincipalProvider = false;
  bool activaBotonPrincipalFraccionesProvider = false;*/
  int codProducto = 0;

  String codigoBarraAnterior = "";
  TextEditingController ctrlCajasEscaneadas = TextEditingController();
  TextEditingController ctrlFracciones = TextEditingController();
  final dbHelper = DatabaseHelper();
  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');
  StreamSubscription<dynamic>? fdwListener;
  List<Map<String, dynamic>> filteredValores = [];
  FocusNode fraccionesFocusNode = FocusNode();
  double? left;
  bool primerEscaneo = true;
  bool processing = false;
  List<Inventario> producto = [];
  Inventario? productoEncontrado;
  SecureStorage storage = SecureStorage();
  double? top; // posición inicial top del botón
  bool valida = false;
  bool validacionInicial = false;
  List<Map<String, dynamic>> valores = [];

  final StreamController<double> _progressController = StreamController();

  @override
  void initState() {
    super.initState();
    cajasFocusNode.addListener(() {
      if (cajasFocusNode.hasFocus) {
        ctrlCajasEscaneadas.selection = TextSelection(baseOffset: 0, extentOffset: ctrlCajasEscaneadas.text.length);
      }
    });

    fraccionesFocusNode.addListener(() {
      if (fraccionesFocusNode.hasFocus) {
        ctrlFracciones.selection = TextSelection(baseOffset: 0, extentOffset: ctrlFracciones.text.length);
      }
    });
    datosIniciales();
  }

  Future<String> readSecureData(String key, {String defaultValue = ''}) async {
    try {
      String? value = await storage.readSecureData(key);
      if (value == null || value.isEmpty) {
        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Ocurruó un error al obtener $key",
                confirmButtonText: "Aceptar",
                text: "Comuníquese con el administrador",
                confirmButtonColor: Colores.esquemaColor));
        return defaultValue; // Devolver un valor predeterminado si el resultado es nulo o vacío
      }
      return value;
    } catch (e) {
      // Opcionalmente, manejar errores específicos de lectura
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Ocurruó un error al obtener $key: $e",
              confirmButtonText: "Aceptar",
              text: "Comuníquese con el administrador",
              confirmButtonColor: Colores.esquemaColor));
      throw Exception("Error al leer $key: $e");
    }
  }

  Future<int> parseInt(String value, String cadena, {int defaultValue = 0}) async {
    try {
      return int.parse(value);
    } catch (e) {
      ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "Ocurrió un error: $e",
              confirmButtonText: "Aceptar",
              text: "Error de formato al convertir: $value, $cadena a int, usando valor predeterminado: $defaultValue",
              confirmButtonColor: Colores.esquemaColor));
      Fluttertoast.showToast(
        msg: "Error de formato al convertir: $value, $cadena a int, usando valor predeterminado: $defaultValue",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return defaultValue;
    }
  }

  Future<void> recargarDatos() async {
    iniciarScanner();
  }

  Widget datos() {
    if (!activa) {
      return circularPrimero();
    } else if (!valida) {
      return circularUltimo('Generando inventario....');
    } else if (processing) {
      return circularUltimo('Enviando inventario....');
    } else {
      return principal();
    }
  }

  Widget circularPrimero() {
    return StreamBuilder<double>(
        stream: _progressController.stream,
        initialData: 0.0,
        builder: (context, snapshot) {
          final progresses = snapshot.data ?? 0.0;
          return SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        strokeWidth: 13.0,
                        value: progresses,
                        color: const Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                    Text('${(progresses * 100).toStringAsFixed(0)}%'),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Cargando inventario, por favor espere...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget circularUltimo(String texto) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(),
              ),
              Text(texto),
            ],
          ),
        ],
      ),
    );
  }

  Widget principal() {
    return buildCardSecundario();
  }

  Widget buildCardSecundario() {
    return FutureBuilder<Widget>(
      future: !validacionInicial ? inicio() : card(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<Widget> inicio() async {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: "Buscqueda manual",
                iconSize: 90.0,
                onPressed: () async {
                  alertaBusquedaManual(context, "Proceso manual");
                  //} else {}
                },
              ),
              const Text("Escanee un producto para continuar...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))
            ],
          ),
        ),
      ],
    );
  }

  Future<Widget> card() async {
    if (productoEncontrado == null) {
      // Si no se ha encontrado un producto, puedes mostrar un mensaje o un widget indicando que no se encontró el producto.
      return inicio();
    } else {
      final productos = productoEncontrado!;
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 60,
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: AssetImage('assets/images/medicamentos.png'),
                                                radius: 35,
                                              )
                                            ],
                                          ),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                //width: MediaQuery.of(context).size.width - 202,
                                                width: MediaQuery.of(context).size.width - 170,
                                                child: Text(
                                                  productos.producto,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colores.esquemaColor,
                                                  ),
                                                  maxLines: 2,
                                                  softWrap: true,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 70),
                                      child: Text(
                                        "Stock: ${productoEncontrado!.cantidad}F${productoEncontrado!.fraccion}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        //adicional(productos),
                        prueba(productos),
                        // promos(productos)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<void> alertaBusquedaManual(BuildContext context, String titulo) async {
    TextEditingController editingController = TextEditingController();
    List<Map<String, dynamic>> localFilteredValores = [];
    Future<void> updateSearchResults(String query) async {
      if (query.isNotEmpty) {
        List<Inventario> tempList = await dbHelper.buscarProductosPorNombre(query);
        localFilteredValores = tempList.map((item) => item.toMap()).toList();
      } else {
        localFilteredValores = [];
      }
    }

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(titulo),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: editingController,
                    decoration: const InputDecoration(
                      labelText: "Buscar",
                      hintText: "Ingrese nombre del producto",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    onSubmitted: (value) async {
                      await updateSearchResults(value);
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: localFilteredValores.isEmpty
                      ? const Center(child: Text(""))
                      : Scrollbar(
                          thickness: 10.0,
                          radius: const Radius.circular(8.0),
                          child: ListView.builder(
                            itemCount: localFilteredValores.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                elevation: 4,
                                child: InkWell(
                                  onTap: () async {
                                    //await fdwListener!.cancel();
                                    Navigator.pop(context);
                                    buscarProducto("na", localFilteredValores[index]["Cod_Producto"]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.check_box,
                                          color: localFilteredValores[index]["estado"] > 0 ? Colors.blue : Colors.grey,
                                          size: 24.0,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            localFilteredValores[index]['producto'] ?? localFilteredValores[index]['Descripcion'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.content_paste_go_outlined,
                                          color: Colores.esquemaColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
      },
    );
  }

  Future<void> alertaBusquedaManualBarras(BuildContext context, String titulo) async {
    TextEditingController editingController = TextEditingController();
    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(titulo),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: editingController,
                    decoration: const InputDecoration(
                      labelText: "Buscar código de barras",
                      hintText: "Ingrese el código de barras",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    onSubmitted: (value) async {
                      Navigator.of(context).pop();
                      await buscarProducto(value, 0);
                    },
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
      },
    );
  }

  /*Future<void> filterSearch2(String query, StateSetter setState) async {
    List<Map<String, dynamic>> tempList = [];

    if (query.isNotEmpty) {
      for (var item in filteredValores) {
        String descripcion = item['producto'] ?? item['Descripcion'];
        if (descripcion.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      }

      // Ordenando la lista alfabéticamente por descripción
      tempList.sort((a, b) => (a['producto'] ?? a['Descripcion']).toLowerCase().compareTo((b['producto'] ?? b['Descripcion']).toLowerCase()));

      setState(() {
        filteredValores = tempList;
      });
    } else {
      setState(() {
        filteredValores = List.from(valores); // Restaura la lista original si no hay filtro

        // Ordenar la lista original alfabéticamente si es necesario
        filteredValores
            .sort((a, b) => (a['producto'] ?? a['Descripcion']).toLowerCase().compareTo((b['producto'] ?? b['Descripcion']).toLowerCase()));
      });
    }
  }
*/
  Widget prueba(Inventario productos) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                    child: Text(
                  "Unidades: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    focusNode: cajasFocusNode,
                    onChanged: (f) async {
                      if (esEntero(f) && (int.tryParse(f) ?? 0) >= 0) {
                        int numCajasCorrectas = int.tryParse(f) ?? 0;
                        ref.read(cantidadCajasProvider.notifier).state = numCajasCorrectas;
                      } else {
                        await Fluttertoast.showToast(
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          msg:
                              "Por favor para continuar, verifique los valores ingresados, no deben ir valores menores que 0, ni con caracteres especiales",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: ctrlCajasEscaneadas,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      border: OutlineInputBorder(
                          // Añade este borde
                          borderRadius: BorderRadius.circular(10.0) // Define el radio del borde redondeado
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                    child: Text(
                  "Fracciones:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    focusNode: fraccionesFocusNode,
                    enabled: productos.fraccionDv > 1,
                    onChanged: (f) async {
                      if (esEntero(f) && (int.tryParse(f) ?? 0) >= 0) {
                      } else {
                        await Fluttertoast.showToast(
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          msg:
                              "Por favor para continuar, verifique los valores ingresados, no deben ir valores manores que 0, ni con caracteres especiales",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: ctrlFracciones,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      border: OutlineInputBorder(
                          // Añade este borde
                          borderRadius: BorderRadius.circular(10.0) // Define el radio del borde redondeado
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /*Future<void> buscarProducto(String codigoBarra, int codProductos) async {
    Inventario? productoEncontradoTemp = await dbHelper.buscarProductoPorCodigo(codigoBarra, codProductos);

    if (productoEncontrado != null && productoEncontrado!.codBarra != codigoBarra && !productoEncontrado!.codBarraAdicional.contains(codigoBarra)) {
      final productos = productoEncontrado!;
      bool usingNetworkTime = await PlatformService.verifyNetworkTimeAndTimeZone();

      if (!usingNetworkTime) {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error",
                confirmButtonText: "Aceptar",
                text:
                    "Por favor verifique que la configuración de la fecha y hora sean los proporcionados por la red y que la zona horaria sea Ecuador/Guayaquil",
                confirmButtonColor: Colores.esquemaColor));
      } else {
        final now = DateTime.now();
        final fechaEscaneo = inta.DateFormat('yyyy/MM/dd HH:mm:ss').format(now);

        int cajasEscaneadas = int.tryParse(ctrlCajasEscaneadas.text) ?? 0;
        int fraccionesEscaneadas = int.tryParse(ctrlFracciones.text) ?? 0;

        await dbHelper.actualizarDatosEnSQLite(productos.codProducto, cajasEscaneadas, fraccionesEscaneadas, 0, 0, 0, 1, 0, 0, fechaEscaneo);
        ref.read(codProductoProvider.notifier).state = productos.codProducto;
        /* setState(() {
          codProducto = productos.codProducto;
        });*/
        int inventarioValor = await dbHelper.countRecordsWithCajasOrFracciones();
        // if (inventarioValor >= 20) {
        var token = await readSecureData("token");
        var codUsuario = await readSecureData("cod_usuario");
        var codInventario = await readSecureData("codInventario");
        String codSesion = await readSecureData("codSesion");

        List<Map<String, dynamic>> inventarioTotal = await dbHelper.getRecordsWithCajasOrFracciones();
        print(inventarioTotal);
        if (inventarioTotal.isNotEmpty) {
          Fluttertoast.showToast(
            backgroundColor: Colors.yellow,
            textColor: Colors.white,
            msg: "Enviando datos automáticos, por favor espere....",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG,
          );
          var envioData = await enviarInventarioEspecial(
            token,
            await parseInt(codSesion, "Sesion"),
            await parseInt(codInventario, "codInventario"),
            await parseInt(codUsuario, "codUsuario"),
            inventarioTotal,
          );
          var prueba = await jsonDecode(envioData.body);

          if (prueba["msg"] == 'ok') {
            await dbHelper.limpiarDatosSqlite();
            Fluttertoast.showToast(
              backgroundColor: Colors.green,
              textColor: Colors.white,
              msg: "Datos automáticos enviados con éxito",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_LONG,
            );
          }
          //}
        }
        await setearvalores();
        await recargarDatos();
        await buscarProducto(codigoBarra, 0);
      }
      return; // Salir del método si es un producto diferente
    }

    if (productoEncontradoTemp != null) {
      productoEncontrado = null;
      producto.clear(); // Limpia la lista actual si solo necesitas el producto encontrado
      // Agrega el producto encontrado a la lista

      actualizarEstadoEscaneo(codigoBarra);
      ref.read(validacionInicialProvider.notifier).state = true;
      setState(() {
        producto.add(productoEncontradoTemp);
        productoEncontrado = productoEncontradoTemp;

        ctrlFracciones.text = '0';
      });
      /*if (productoEncontrado!.estado == 1) {
        ctrlCajasEscaneadas.text =
            ctrlCajasEscaneadas.text != "" ? (int.parse(ctrlCajasEscaneadas.text)).toString() : productoEncontrado!.cajasEscaneadas.toString();

        ctrlFracciones.text = productoEncontrado!.fraccionesEscaneadas.toString();
      }*/
      await procesarCodBarra(codigoBarra, codProductos); // Este llamado se hace independientemente del estado.
    } else /*if (productoEncontradoTemp == null)*/ {
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Este producto no fué encontrado",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }*/
  Future<void> buscarProducto(String codigoBarra, int codProductos) async {
    // Subir la información del producto anterior si existe y es diferente
    if (productoEncontrado != null && productoEncontrado!.codBarra != codigoBarra && !productoEncontrado!.codBarraAdicional.contains(codigoBarra)) {
      await subirInformacionProductoEnMemoria(productoEncontrado!,codigoBarra);

      // Reiniciar valores después de subir
      await setearvalores();
      await recargarDatos();
    }

    // Buscar el producto actual
    Inventario? productoEncontradoTemp = await dbHelper.buscarProductoPorCodigo(codigoBarra, codProductos);

    if (productoEncontradoTemp != null) {
      productoEncontrado = productoEncontradoTemp;
      producto.clear();
      producto.add(productoEncontradoTemp);
      actualizarEstadoEscaneo(codigoBarra);
      ref.read(validacionInicialProvider.notifier).state = true;
      // Actualizar los valores en la UI
      setState(() {
        ctrlCajasEscaneadas.text = '0';
        ctrlFracciones.text = '0';
      });

      // Procesar escaneo del nuevo producto
      await procesarCodBarra(codigoBarra, codProductos);
    } else {
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Este producto no fue encontrado",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> subirInformacionProductoEnMemoria(Inventario? productoEn,String codBarra) async {
    if (productoEn == null) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "No hay datos para subir.",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    // Crear el JSON con los valores actuales en memoria
    final now = DateTime.now();
    final fechaEscaneo = inta.DateFormat('yyyy/MM/dd HH:mm:ss').format(now);

    int cajasEscaneadas = int.tryParse(ctrlCajasEscaneadas.text) ?? 0;
    int fraccionesEscaneadas = int.tryParse(ctrlFracciones.text) ?? 0;

    List<Map<String, dynamic>> inventarioTotal = [
      {
        "Cod_Producto": productoEn.codProducto,
        "codLaboratorio": productoEn.codLaboratorio,
        "cantidad": productoEn.cantidad, // Puedes ajustar según tu lógica
        "fraccion": productoEn.fraccion,
        "cajas": cajasEscaneadas,
        "fracciones": fraccionesEscaneadas,
        "fechaEscaneo": fechaEscaneo,
      }
    ];

    // Enviar los datos
    var token = await readSecureData("token");
    var codUsuario = await readSecureData("cod_usuario");
    var codInventario = await readSecureData("codInventario");
    String codSesion = await readSecureData("codSesion");

    Fluttertoast.showToast(
      backgroundColor: Colors.yellow,
      textColor: Colors.white,
      msg: "Enviando datos, por favor espere....",
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );

    var envioData = await enviarInventarioEspecial(
      token,
      await parseInt(codSesion, "Sesion"),
      await parseInt(codInventario, "codInventario"),
      await parseInt(codUsuario, "codUsuario"),
      inventarioTotal,
    );

    var respuesta = jsonDecode(envioData.body);

    if (respuesta["msg"] == 'ok') {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: "Datos enviados con éxito",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );

      // Reiniciar valores después de enviar
      await setearvalores();
      await recargarDatos();
      await buscarProducto(codBarra, 0);
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Error al enviar datos: ${respuesta["msg"]}",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void actualizarEstadoEscaneo(String codigoBarra) {
    final anterior = ref.read(codigoBarraAnteriorProvider);

    if (codigoBarra != anterior) {
      ref.read(primerEscaneoProvider.notifier).state = true;
    } else {
      ref.read(primerEscaneoProvider.notifier).state = false;
    }

    // Siempre actualizamos el código de barra anterior al nuevo.
    ref.read(codigoBarraAnteriorProvider.notifier).state = codigoBarra;

    // Logs adicionales para depuración:
  }

  Future<void> datosIniciales() async {
    try {
      var codBodega = await storage.readSecureData("codBodega") ?? "";
      String tokens = await storage.readSecureData("token") ?? "";
      String codInventario = await storage.readSecureData("codInventario") ?? "";
      String validacionInventario = await storage.readSecureData("validacionInventario") ?? "";
      producto.clear();
      try {
        if (validacionInventario == "") {
          var datos = await obtenerOrdenesDatosInicialesInventarioTotal(tokens, int.parse(codBodega), int.parse(codInventario));

          await dbHelper.deleteTable();
          producto = parseOrdernes(datos.body);
          Map<String, dynamic> decodedData = jsonDecode(datos.body);

          List<Map<String, dynamic>> fetchedValores = List<Map<String, dynamic>>.from(decodedData["data"]);
          setState(() {
            valores = fetchedValores;
          });
          final totalItem = producto.length;
          for (int i = 0; i < producto.length; i++) {
            await dbHelper.insert(producto[i]);
            final progress = (i + 1) / totalItem;
            _progressController.sink.add(progress);
          }
          _progressController.sink.add(1.0);
          await storage.writeSecureData("validacionInventario", "deathbat");
          setState(() {
            activa = true;
            valida = true;
          });
          iniciarScanner();
        } else {
          setState(() {
            activa = true;
            valida = true;
          });
          iniciarScanner();
        }
      } catch (e) {
        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error: $e",
                confirmButtonText: "Aceptar",
                text: "Ocurrió un error ",
                onConfirm: () {
                  Navigator.of(context)
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

  void iniciarScanner() async {
    await setearvalores2();
    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {
        final codBarra = code.data.toString().trim();
        await buscarProducto(codBarra, 0);
      });
    }
  }

  Future<void> setearvalores() async {
    await fdwListener!.cancel();

    ref.read(primerEscaneoProvider.notifier).state = true;
    //ref.read(validacionInicialProvider.notifier).state = false;
    ref.read(codigoBarraAnteriorProvider.notifier).state = "";
    ref.read(cajasEscaneadasTextProvider.notifier).state.text = "";

    ref.read(cantidadCajasProvider.notifier).state = 0;
    setState(() {
      ctrlFracciones.text = "";
      productoEncontrado = null;
    });
  }

  Future<void> setearvalores2() async {
    ref.read(codigoBarraAnteriorProvider.notifier).state = "";

    ref.read(cajasEscaneadasTextProvider.notifier).state.text = "";

    ref.read(cantidadCajasProvider.notifier).state = 0;
    setState(() {
      ctrlFracciones.text = "";
    });
  }

  Future<void> procesarCodBarra(String codBarra, int codProductos) async {
    if (productoEncontrado!.codBarra.trim() == codBarra ||
        productoEncontrado!.codBarraAdicional.contains(codBarra) ||
        productoEncontrado!.codProducto == codProductos) {
      if (ref.read(primerEscaneoProvider) && productoEncontrado!.estado == 0) {
        // Solo actualiza el estado si es el primer escaneo
        ref.read(primerEscaneoProvider.notifier).state = false;

        ref.read(cajasEscaneadasTextProvider.notifier).state.text = "0";
        ref.read(cantidadCajasProvider.notifier).state = cantidadCajas + 1;
      } else if (ref.read(primerEscaneoProvider) && productoEncontrado!.estado == 1) {
        ref.read(primerEscaneoProvider.notifier).state = false;
      } else {
        if (productoEncontrado!.estado == 1) {
          int valor = int.parse(ctrlCajasEscaneadas.text) + 1;
          ref.read(cajasEscaneadasTextProvider.notifier).state.text = valor.toString();
          ref.read(cantidadCajasProvider.notifier).state = valor;
        } else {
          ref.read(cantidadCajasProvider.notifier).state = ref.watch(cantidadCajasProvider) + 1;
          ref.read(cajasEscaneadasTextProvider.notifier).state.text = cantidadCajas.toString();
        }
      }
    } else {
      sounidoErrorProducto();
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "El producto escaneado no es correcto",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  bool esEntero(String s) {
    final RegExp numeroEntero = RegExp(r'^-?\d+$');
    return numeroEntero.hasMatch(s);
  }

  @override
  Widget build(BuildContext context) {
    codProducto = ref.watch(codProductoProvider);
    primerEscaneo = ref.watch(primerEscaneoProvider);
    validacionInicial = ref.watch(validacionInicialProvider);
    codigoBarraAnterior = ref.watch(codigoBarraAnteriorProvider);
    ctrlCajasEscaneadas = ref.watch(cajasEscaneadasTextProvider);
    cantidadCajas = ref.watch(cantidadCajasProvider);

    if (top == null && left == null) {
      top = MediaQuery.of(context).size.height - 65; // 80 es un valor aproximado que puedes ajustar
      left = MediaQuery.of(context).size.width - 135; // 80 es un valor aproximado que puedes ajustar
    }
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Inventario",
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
            leading: IconButton(
                onPressed: () async {
                  await Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                },
                icon: const Icon(Icons.arrow_back)),
            actions: [
              processing
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            alertaBusquedaManualBarras(context, "Búsqueda");
                          },
                          icon: const Icon(Icons.search),
                          iconSize: 35,
                        ),
                        IconButton(
                          onPressed: /*producto.isEmpty
                              ? null
                              :*/
                              () async {
                            await ArtSweetAlert.show(
                                barrierDismissible: false,
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.warning,
                                    title: "¿Está seguro de guardar el inventario?",
                                    text: "Si acepta se registrará todo el inventario de los productos que haya hecho",
                                    confirmButtonText: "Aceptar",
                                    onCancel: () {
                                      Navigator.of(context).pop();
                                    },
                                    onConfirm: () async {
                                      setState(() {
                                        processing = true;
                                      });
                                      _progressController.close();
                                      //setearvalores();
                                      try {
                                        bool usingNetworkTime = await PlatformService.verifyNetworkTimeAndTimeZone();

                                        if (!usingNetworkTime) {
                                          await ArtSweetAlert.show(
                                              barrierDismissible: false,
                                              context: context,
                                              artDialogArgs: ArtDialogArgs(
                                                  type: ArtSweetAlertType.danger,
                                                  title: "Error",
                                                  confirmButtonText: "Aceptar",
                                                  text:
                                                      "Por favor verifique que la configuración de la fecha y hora sean los proporcionados por la red y que la zona horaria sea Ecuador/Guayaquil",
                                                  confirmButtonColor: Colores.esquemaColor));
                                        } else {
                                          if (producto.isNotEmpty) {
                                            final productos = productoEncontrado!;
                                            final now = DateTime.now();
                                            final fechaEscaneo = inta.DateFormat('yyyy/MM/dd HH:mm:ss').format(now);

                                            int cajasEscaneadas = int.tryParse(ctrlCajasEscaneadas.text) ?? 0;
                                            int fraccionesEscaneadas = int.tryParse(ctrlFracciones.text) ?? 0;

                                            await dbHelper.actualizarDatosEnSQLite(
                                                productos.codProducto, cajasEscaneadas, fraccionesEscaneadas, 0, 0, 0, 1, 0, 0, fechaEscaneo);
                                            ref.read(codProductoProvider.notifier).state = productos.codProducto;
                                          }
                                        }
                                        var token = await readSecureData("token");
                                        var codUsuario = await readSecureData("cod_usuario");
                                        var codInventario = await readSecureData("codInventario");
                                        String codSesion = await readSecureData("codSesion");

                                        List<Map<String, dynamic>> inventarioTotal = await dbHelper.getRecordsWithCajasOrFracciones();
                                        if (inventarioTotal.isNotEmpty) {
                                          Navigator.of(context).pop();
                                          Fluttertoast.showToast(
                                            backgroundColor: Colors.yellow,
                                            textColor: Colors.white,
                                            msg: "Procesando datos, por favor espere....",
                                            gravity: ToastGravity.BOTTOM,
                                            toastLength: Toast.LENGTH_LONG,
                                          );
                                          var envioData = await enviarInventarioEspecial(
                                            token,
                                            await parseInt(codSesion, "Sesion"),
                                            await parseInt(codInventario, "codInventario"),
                                            await parseInt(codUsuario, "codUsuario"),
                                            inventarioTotal,
                                          );
                                          var prueba = await jsonDecode(envioData.body);

                                          if (prueba["msg"] == 'ok') {
                                            setState(() {
                                              processing = false;
                                            });
                                            await dbHelper.limpiarDatosSqlite();

                                            await setearvalores();
                                            await recargarDatos();
                                            await ArtSweetAlert.show(
                                                barrierDismissible: true,
                                                context: context,
                                                artDialogArgs: ArtDialogArgs(
                                                    type: ArtSweetAlertType.success,
                                                    confirmButtonText: "Aceptar",
                                                    title: "Inventario enviado con éxito!",
                                                    onConfirm: () {
                                                      Navigator.pop(context);
                                                    },
                                                    // text: "Bienvenido",
                                                    confirmButtonColor: Colores.esquemaColor));
                                          } else {
                                            if (!mounted) return;
                                            setState(() {
                                              processing = false; // Asegurar que el botón siempre se habilite al inicio
                                            });
                                            await ArtSweetAlert.show(
                                                barrierDismissible: false,
                                                context: context,
                                                artDialogArgs: ArtDialogArgs(
                                                    type: ArtSweetAlertType.danger,
                                                    title: "Error $prueba",
                                                    confirmButtonText: "Aceptar",
                                                    text: "Comuníquese con el administrador",
                                                    confirmButtonColor: Colores.esquemaColor));
                                          }
                                        } else {
                                          setState(() {
                                            processing = false;
                                          });
                                          Navigator.of(context).pop();
                                          Fluttertoast.showToast(
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            msg: "No existen productos en el inventario a enviar....",
                                            gravity: ToastGravity.BOTTOM,
                                            toastLength: Toast.LENGTH_LONG,
                                          );
                                        }
                                      } on TimeoutException catch (e) {
                                        setState(() {
                                          processing = false; // Asegurar que el botón siempre se habilite al inicio
                                        });
                                        ArtSweetAlert.show(
                                            barrierDismissible: false,
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.danger,
                                                title: "Error: $e",
                                                confirmButtonText: "Aceptar",
                                                text: "Comuníquese con el administrador",
                                                confirmButtonColor: Colores.esquemaColor));
                                      } catch (e) {
                                        setState(() {
                                          processing = false;
                                        });
                                        ArtSweetAlert.show(
                                            barrierDismissible: false,
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.danger,
                                                title: "Ocurrió un error: $e",
                                                confirmButtonText: "Aceptar",
                                                text: "Comuníquese con el administrador",
                                                confirmButtonColor: Colores.esquemaColor));
                                      }
                                      //await guardarData(setState);
                                    },
                                    showCancelBtn: true,
                                    cancelButtonText: "Cancelar",
                                    cancelButtonColor: Colors.grey,
                                    confirmButtonColor: Colores.esquemaColor));
                          },
                          icon: const Icon(Icons.save),
                          iconSize: 35,
                        ),
                      ],
                    )
            ],
          ),
          body: datos(),
        ),
      ],
    );
  }
}
