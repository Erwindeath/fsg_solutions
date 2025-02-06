// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/informe_inventario/informeInventario.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/logica_inventario_general.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/methods.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/utils.dart';

class CobroDependiente extends StatefulWidget {
  const CobroDependiente({Key? key}) : super(key: key);

  @override
  State<CobroDependiente> createState() => _CobroDependienteState();
}

class _CobroDependienteState extends State<CobroDependiente> {
  @override
  void initState() {
    super.initState();
    dataInicial();
  }

  int codInventario = 0;
  int codBodega = 0;
  int dependiente = 0;
  bool load = false;
  bool processing = false;
  String token = "";
  var datosDependientes = [];
  bool sinPro = false;
  List<dynamic> data = [];
  SecureStorage storage = SecureStorage();
  List<ProductosCobro> productosCobro = [];
  double? top; // posición inicial top del botón
  double? left;
  @override
  Widget build(BuildContext context) {
    if (top == null && left == null) {
      top = MediaQuery.of(context).size.height - 65; // 80 es un valor aproximado que puedes ajustar
      left = MediaQuery.of(context).size.width - 135; // 80 es un valor aproximado que puedes ajustar
    }
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Cobro a dependientes"),
          ),
          body: datos(),
        ),
        Positioned(
          top: top,
          left: left,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                top = (top! + details.delta.dy);
                left = (left! + details.delta.dx);
              });
            },
            child: processing
                ? const CircularProgressIndicator()
                : FloatingActionButton.extended(
                    onPressed: productosCobro.isEmpty && productosCobro.isEmpty && !sinPro
                        ? null
                        : () async {
                            bool hayProductoSinUsuario = productosCobro.any((producto) => producto.codUsuario == 0);
                            if (hayProductoSinUsuario) {
                              // Mostrar mensaje de error si hay algún producto con codUsuario igual a 0
                              await Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                msg: "Por favor, seleccione un dependiente para todos los productos.",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG,
                              );
                            } else {
                              if (data.isEmpty && productosCobro.isEmpty) {
                                await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "¿Terminar inventario?",
                                        text: "Pasar al informe de inventario?",
                                        confirmButtonText: "Aceptar",
                                        onCancel: () {
                                          Navigator.of(context).pop();
                                          dataInicial();
                                        },
                                        onConfirm: () async {
                                          setState(() {
                                            processing = true;
                                          });
                                          var dato = await finalizarInventario(token, codBodega, codInventario);
                                          await storage.deleteSecureData("cobrado");
                                          await storage.deleteSecureData("metodo");
                                          Navigator.pop(context);
                                          await Fluttertoast.showToast(
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            msg: "Finalizando inventario, por favor espere...",
                                            gravity: ToastGravity.BOTTOM,
                                            toastLength: Toast.LENGTH_SHORT,
                                          );
                                          await storage.writeSecureData("informepasar", "1");
                                          await Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) => const InformeInventario(),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                        showCancelBtn: true,
                                        cancelButtonText: "Cancelar",
                                        cancelButtonColor: Colors.grey,
                                        confirmButtonColor: Colores.esquemaColor));
                              } else {
                                await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "¿Está seguro de procesar estos cobros?",
                                        text: "Si acepta no podrá volver atrás",
                                        confirmButtonText: "Aceptar",
                                        onCancel: () {
                                          Navigator.of(context).pop();
                                        },
                                        onConfirm: () async {
                                          setState(() {
                                            processing = true;
                                          });
                                          Navigator.pop(context);
                                          await Fluttertoast.showToast(
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            msg: "Procesando datos, por favor espere...",
                                            gravity: ToastGravity.BOTTOM,
                                            toastLength: Toast.LENGTH_SHORT,
                                          );
                                          agruparProductosPorUsuario();
                                        },
                                        showCancelBtn: true,
                                        cancelButtonText: "Cancelar",
                                        cancelButtonColor: Colors.grey,
                                        confirmButtonColor: Colores.esquemaColor));
                              }
                            }
                          },
                    label: data.isEmpty && productosCobro.isEmpty ? const Text("Terminar") : const Text("Guardar"),
                    icon: const Icon(Icons.save),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> dataInicial() async {
    var codInventarios = await storage.readSecureData("codInventario");
    var bodega = await storage.readSecureData("codBodega");
    var tok = await storage.readSecureData("token");
    String a = await storage.readSecureData("cobrado") ?? "";

    if (a.isNotEmpty) {
      setState(() {
        data = jsonDecode(a);
        sinPro = true;
      });
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.black,
        msg: "Generando facturas, por favor espere...",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
      var dato = await imprimeProcesa(data, tok, int.parse(bodega));

      if (dato) {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "¿Reporte impreso con éxito?",
                text: "Si finaliza dará por terminado el proceso de este inventario",
                confirmButtonText: "Finalizar",
                onCancel: () {
                  Navigator.of(context).pop();
                  dataInicial();
                },
                onConfirm: () async {
                  setState(() {
                    processing = true;
                  });
                  await storage.deleteSecureData("cobrado");
                  Navigator.pop(context);
                  await Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "Finalizando inventario, por favor espere...",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  await Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const HomeFarma(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                showCancelBtn: true,
                cancelButtonText: "Cancelar",
                cancelButtonColor: Colors.grey,
                confirmButtonColor: Colores.esquemaColor));
      } else {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Error",
                text: "Error al generar el reporte",
                confirmButtonText: "Aceptar",
                confirmButtonColor: Colores.esquemaColor,
                onConfirm: () {}));
      }
    } else {
      /*ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "Error",
            text: "Error al generar el reporte",
            confirmButtonText: "Aceptar",
            confirmButtonColor: Colores.esquemaColor,
          ));
    }*/
      if (codInventarios == null && bodega == null) {
        load = true;
        productosCobro = [];
      } else {
        setState(() {
          codInventario = int.parse(codInventarios);
          codBodega = int.parse(bodega);
          token = tok;
        });
        var obtenerCobros = await obtenerPersonayProductosCobros(token, codBodega, codInventario);
        var decode = jsonDecode(obtenerCobros.body);
        if (decode["msg"] != "err") {
          if (decode["dataCobro"] != null) {
            productosCobro = parsearCobros(obtenerCobros.body);
            setState(() {
              datosDependientes = jsonDecode(obtenerCobros.body)["data"];
              load = true;
            });
          } else {
            setState(() {
              productosCobro = [];
              datosDependientes = [];
              sinPro = true;
              load = true;
            });
          }
        } else {
          setState(() {
            datosDependientes = [];
            load = true;
            productosCobro = [];
          });
          String errorMessage = jsonDecode(obtenerCobros.body)["mensaje"] ?? "Ocurrió un error desconocido";

          await Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: errorMessage,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      }
    }
  }

  Widget datos() {
    if (load == false) {
      return circularPrimero();
    } else {
      return listaProuctos();
    }
  }

  List<DropdownMenuItem<int>> generarTiposCuentas() {
    List<DropdownMenuItem<int>> listadoTiposMantenimiento = [];

    // Añadir la opción de "Seleccione un dependiente" sólo si hay más de un dependiente
    if (datosDependientes.length > 1) {
      listadoTiposMantenimiento.add(
        const DropdownMenuItem(
          value: 0,
          child: Text("Seleccione un dependiente"),
        ),
      );
    }

    // Añadir todos los elementos de datosDependientes
    for (var elemento in datosDependientes) {
      listadoTiposMantenimiento.add(
        DropdownMenuItem(
          value: int.parse(elemento["Cod_Usuario"].toString()),
          child: Text(elemento["Nombres"].toString().length > 20 ? elemento["Nombres"].toString().substring(0, 20) : elemento["Nombres"].toString()),
        ),
      );
    }
    return listadoTiposMantenimiento;
  }

  Widget listaProuctos() {
    if (productosCobro.isEmpty) {
      return const Center(
        child: Text("Sin datos para cobrar."),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: productosCobro.length,
          itemBuilder: (BuildContext context, int indice) {
            ProductosCobro ajuste = productosCobro[indice];

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
                          Flexible(
                            child: Text(
                              ajuste.descripcion.length > 30 ? ajuste.descripcion.substring(0, 30) : ajuste.descripcion,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                // color: Colores.esquemaColor, // Define el color adecuado
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Flexible(
                            child: DropdownButton<int>(
                              borderRadius: BorderRadius.circular(5.0),
                              underline: const SizedBox(),
                              elevation: 4,
                              value: ajuste.codUsuario, // Usa codUsuario del objeto ProductosCobro
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: generarTiposCuentas(),
                              isExpanded: true,
                              onChanged: (int? newValue) {
                                setState(() {
                                  ajuste.codUsuario = newValue!; // Actualiza codUsuario
                                });
                                // print(ajuste);
                              },
                            ),
                          ),
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

  Widget circularPrimero() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(),
              ),
              Text('Cargando datos...'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> agruparProductosPorUsuario() async {
    bool dato = false;
    // Crea un Map para almacenar los productos agrupados por codUsuario
    final Map<int, List<ProductosCobro>> productosAgrupados = {};

    // Itera sobre la lista de productos
    for (var producto in productosCobro) {
      // Si el codUsuario no está en el Map, añade una nueva entrada con una lista vacía
      productosAgrupados.putIfAbsent(producto.codUsuario, () => []);

      // Añade el producto a la lista correspondiente
      productosAgrupados[producto.codUsuario]!.add(producto);
    }

    // Crea una lista para almacenar los objetos finales
    List<Map<String, dynamic>> listaFinal = [];

    // Itera sobre el Map de productos agrupados y crea el objeto final
    productosAgrupados.forEach((codUsuario, productos) {
      // Calcula los totales para este usuario
      double total = 0;
      double base_0 = 0;
      double iva = 0;
      double baseIva = 0;

      for (var producto in productos) {
        // Aquí, suma los valores correspondientes a cada total
        // Ejemplo:
        total += producto.total;
        base_0 += producto.baseCero;
        iva += producto.iva;
        baseIva += producto.baseIva; // Ajusta según tus necesidades
      }

      // Añade el objeto a la lista final, incluyendo la llave "Totales"
      listaFinal.add({
        'codUsuario': codUsuario,
        'Productos': productos.map((producto) => producto.toJson()).toList(),
        'Totales': [
          {
            'Total': total,
            'Base_0': base_0,
            'Iva': iva,
            'Base_Iva': baseIva,
          }
        ],
      });
    });

    int codSesion = int.parse(await storage.readSecureData("codSesion"));
    int codUsuario = int.parse(await storage.readSecureData("cod_usuario"));
    var datos = await envioDatosCobro(token, jsonEncode(listaFinal), codBodega, codSesion, codUsuario, codInventario);

    var datosDecode = jsonDecode(datos.body);

    if (datosDecode["msg"] != "err" && datosDecode["datos"] != null) {
      await storage.writeSecureData("cobrado", jsonEncode(datosDecode["datos"]));

      List<dynamic> datos = jsonDecode(jsonEncode(datosDecode["datos"]));

      data = datos;
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.black,
        msg: "Generando facturas, por favor espere...",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
      dato = await imprimeProcesa(datos, token, codBodega);
      if (dato) {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "¿Reporte impreso con éxito?",
                text: "Pasar al informe de inventario?",
                confirmButtonText: "Aceptar",
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onConfirm: () async {
                  setState(() {
                    processing = true;
                  });
                  Navigator.pop(context);
                  await finalizarInventario(token, codBodega, codInventario);
                  await Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "Finalizando inventario, por favor espere...",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  await storage.deleteSecureData("cobrado");
                  await storage.writeSecureData("informepasar", "1");
                  await Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const InformeInventario(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                showCancelBtn: true,
                cancelButtonText: "Cancelar",
                cancelButtonColor: Colors.grey,
                confirmButtonColor: Colores.esquemaColor));
      } else {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Error",
                text: "Error al generar el reporte",
                confirmButtonText: "Aceptar",
                confirmButtonColor: Colores.esquemaColor,
                onConfirm: () {}));
      }
    } else {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "Error",
              text: "Error al procesar los cobros: ${datosDecode["msg"]}",
              confirmButtonText: "Aceptar",
              confirmButtonColor: Colores.esquemaColor,
              onConfirm: () {}));
      setState(() {
        processing = false;
      });
    }
  }
}
