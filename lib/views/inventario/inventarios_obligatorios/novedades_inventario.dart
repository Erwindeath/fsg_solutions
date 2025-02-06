// ignore_for_file: import_of_legacy_library_into_null_safe, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
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
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/reporte_ajuste.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/tarjeta.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'database/inventario_sqlite.dart';

class NovedadesInventario extends StatefulWidget {
  const NovedadesInventario({Key? key}) : super(key: key);

  @override
  State<NovedadesInventario> createState() => _NovedadesInventarioState();
}

class _NovedadesInventarioState extends State<NovedadesInventario> {
  bool load = false;
  List<Map<String, dynamic>> novedadesInventarios = [];
  List<Inventario> producto = [];
  double tama = 10;
  double tamanoTitulo = 18.0;
  double tamanoDescripcion = 15.0;
  String? errorCajas;
  String? errorFracciones;
  TextEditingController ctrCajas = TextEditingController();
  TextEditingController ctrFracciones = TextEditingController();
  TextEditingController ctrCajasCaducadas = TextEditingController();
  TextEditingController ctrFraccionesCaducadas = TextEditingController();
  TextEditingController ctrFraccionesMalPicadas = TextEditingController();
  TextEditingController ctrTotalCajas = TextEditingController();
  TextEditingController ctrTotalFracciones = TextEditingController();
  final SecureStorage _storage = SecureStorage();
  final dbHelper = DatabaseHelper();
  bool estadoBoton = true;
  double? top; // posición inicial top del botón
  double? left;

  double baseCero = 0.0;
  double baseIvas = 0.0;
  double ivas = 0.0;
  double totales = 0.0;
  @override
  Widget build(BuildContext context) {
    // Si es la primera vez que se construye el widget, establece las posiciones iniciales
    if (top == null && left == null) {
      top = MediaQuery.of(context).size.height - 65; // 80 es un valor aproximado que puedes ajustar
      left = producto.isEmpty
          ? MediaQuery.of(context).size.width - 120
          : MediaQuery.of(context).size.width - 50; // 80 es un valor aproximado que puedes ajustar
    }
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Novedades del inventario",
              style: TextStyle(fontSize: 19.0),
            ),
            leading: IconButton(
                onPressed: () async {
                  await Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                },
                icon: const Icon(Icons.arrow_back)),
            actions: [
              IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                          return WillPopScope(
                            child: AlertDialog(
                              title: const Text("¿Está seguro de continuar?"),
                              content: const Text("¿Una vez finalizado este laboratorio no lo podrá volver a editar?"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Cancelar"),
                                  onPressed: () {
                                    Navigator.pop(context); // Cierra el diálogo
                                  },
                                ),
                                TextButton(
                                  onPressed: estadoBoton
                                      ? () async {
                                          setState(() {
                                            estadoBoton = false;
                                          });
                                          await guardarData(setState);
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
                },
                icon: const Icon(Icons.save),
                iconSize: 35,
              )
            ],
          ),
          body: datos(),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    dataInicial();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> guardarData(StateSetter setState) async {
    try {
      Fluttertoast.showToast(
        backgroundColor: Colors.yellow,
        textColor: Colors.white,
        msg: "Procesando datos, por favor espere....",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );

      var fecha = await readSecureData("fechaInventario");
      var token = await readSecureData("token");
      var codUsuario = await readSecureData("cod_usuario");
      var codInventario = await readSecureData("codInventario");
      var nombreLaboratorio = await readSecureData("nombreLaboratorio");
      var codLaboratorio = await readSecureData("codLaboratorio");
      var codBodega = await readSecureData("codBodega");
      String codInventarioDet = await readSecureData("codInventarioDet");
      String codSesion = await readSecureData("codSesion");
      List<Map<String, dynamic>> inventarioTotal = await dbHelper.getAllRecordsAsMaps();

      List<Map<String, dynamic>> obtenerProductosConPromocion = await dbHelper.obtenerProductosConPromocion();

      int dato = 0;
      if (obtenerProductosConPromocion.isNotEmpty) {
        dato = 1;
      }
      var totalesa = await calcularTotales(obtenerProductosConPromocion);

      var envioData = await enviarInventario(
          token,
          await parseInt(codSesion, "Sesion"),
          await parseInt(codInventario, "codInventario"),
          await parseInt(codInventarioDet, "codInventarioDet"),
          await parseInt(codLaboratorio, "codLaboratorio"),
          await parseInt(codUsuario, "codUsuario"),
          await parseInt(codBodega, "codBodega"),
          fecha,
          inventarioTotal,
          totalesa,
          dato,
          obtenerProductosConPromocion,
          baseCero,
          baseIvas,
          ivas,
          totales);
      var prueba = await jsonDecode(envioData.body);

      if (prueba["msg"] == 'ok') {
        final dbHelper = DatabaseHelper();
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                confirmButtonText: "Aceptar",
                title: "Inventario guardado con éxito!",
                // text: "Bienvenido",
                confirmButtonColor: Colores.esquemaColor));
        var consultaAjuste = await compruebaDatosAjustes(token, int.parse(codInventarioDet));
        var decodifica = jsonDecode(consultaAjuste.body);

        if (decodifica["msg"] == "ok") {
          await _storage.writeSecureData("validaajuste", "1");
          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContextcontext) =>
                      ReporteAjuste(response: consultaAjuste.body, nombreLab: nombreLaboratorio, codInventarioDet: codInventarioDet)),
              (Route<dynamic> route) => false);
        } else {
          await dbHelper.deleteTable();
          await storage.deleteSecureData("codLaboratorio");
          await storage.deleteSecureData("nombreLaboratorio");
          await storage.deleteSecureData("codInventarioDet");
          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContextcontext) => const LabotarotiosInventario()), (Route<dynamic> route) => false);
        }

        /**/
      } else {
        if (!mounted) return;
        setState(() {
          estadoBoton = true; // Asegurar que el botón siempre se habilite al inicio
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
    } on TimeoutException catch (e) {
      setState(() {
        estadoBoton = true; // Asegurar que el botón siempre se habilite al inicio
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
        estadoBoton = true;
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

  Future<String> readSecureData(String key, {String defaultValue = ''}) async {
    try {
      String? value = await _storage.readSecureData(key);
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

  Future<void> dataInicial() async {
    producto = await dbHelper.obtenerNovedades("1");
    if (producto.isNotEmpty) {
      setState(() {
        novedadesInventarios = Inventario.convertirAListaMap(producto);
        load = true;
      });
    } else {
      novedadesInventarios = [];
      setState(() {
        load = true;
      });
    }
  }

  Widget datos() {
    if (load == false) {
      return circularPrimero();
    } else {
      return _buildNotificaciones(novedadesInventarios);
    }
  }

  Future<void> actualizarDatos() async {
    Navigator.of(context).pop();
    await dataInicial();
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

  Widget _buildNotificaciones(List<Map<String, dynamic>> novedades) {
    if (novedades.isEmpty) {
      return const Center(child: Text("Sin novedades"));
    }
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              var laboratorioss = novedades[index];
              var isExpanded = laboratorioss['isExpanded'] ?? false;
              var codTipo = laboratorioss['codTipo'] ?? "";
              print(codTipo);
              var descripcion = laboratorioss['producto'];
              var cajas = laboratorioss['cantidad'];
              var fracciones = laboratorioss['fraccion'];
              var cajasEscaneadas = laboratorioss['cajasEscaneadas'];
              var fraccionesEscaneadas = laboratorioss["fraccionesEscaneadas"];
              double cantidadReal = laboratorioss['cantidad'] + (double.parse(laboratorioss["fraccion"].toString()) / laboratorioss["fraccionDv"]);
              double cantidadRealEscaneada =
                  laboratorioss['cajasEscaneadas'] + (double.parse(laboratorioss["fraccionesEscaneadas"].toString()) / laboratorioss["fraccionDv"]);
              //var laboratorioId = notificacion['id'];
              return Card(
                child: Column(
                  children: [
                    ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              descripcion,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: codTipo != "02" ? Colores.esquemaColor : Colors.blue,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Stock: ${cajas}F$fracciones",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: cantidadReal < cantidadRealEscaneada ? Colors.yellow : Colors.red),
                                ),
                                Text(
                                  "Ingresado: ${cajasEscaneadas}F$fraccionesEscaneadas",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: cantidadReal < cantidadRealEscaneada ? Colors.yellow : Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          !isExpanded ? MdiIcons.chevronDownCircle : MdiIcons.chevronUpCircle,
                          color: Colores.esquemaColor,
                        ),
                        onTap: () {
                          setState(() {
                            // print(cantidadReal);
                            laboratorioss['isExpanded'] = !isExpanded;
                          });
                        }),
                    if (laboratorioss['isExpanded'] ?? false)
                      TarjetaInventario(
                        codProducto: laboratorioss["codProducto"],
                        producto: laboratorioss["producto"],
                        cantidad: laboratorioss["cantidad"],
                        fraccion: laboratorioss["fraccion"],
                        cajasEscaneadas: laboratorioss["cajasEscaneadas"],
                        fraccionesEscaneadas: laboratorioss["fraccionesEscaneadas"],
                        fraccionesMalPicadas: laboratorioss["fraccionesMalPicadas"],
                        cajasCaducadas: laboratorioss["cajasCaducadas"],
                        fraccionesCaducadas: laboratorioss["fraccionesCaducadas"],
                        estado: laboratorioss["estado"],
                        totalCajas: laboratorioss["cajasEscaneadas"] + laboratorioss["cajasCaducadas"],
                        totalFracciones:
                            laboratorioss["fraccionesEscaneadas"] + laboratorioss["fraccionesMalPicadas"] + laboratorioss["fraccionesCaducadas"],
                        fraccionDv: laboratorioss["fraccionDv"],
                        cajaPromo: laboratorioss["cajaPromo"],
                        fraccionPromo: laboratorioss["fraccionPromo"],
                        onDatosActualizados: actualizarDatos,
                        codTipo: laboratorioss["codTipo"],
                      ),
                  ],
                ),
              );
            },
            childCount: novedades.length,
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, String>>> calcularTotales(List<Map<String, dynamic>> productos) async {
    double base0 = 0.0;
    double baseIva = 0.0;
    double iva = 0.0;
    String valorIva = await storage.readSecureData("valorIva");
    int valor = int.parse(valorIva);
    for (var producto in productos) {
      String prodIvaTrimmed = producto['Producto_Iva'].toString().trim();
      double costoVenta = double.parse(producto['Costo'].toString());
      int cajaPromo = int.parse(producto['Cant_U'].toString());
      int fraccionPromo = int.parse(producto['Cant_F'].toString());
      int fraccionDv = int.parse(producto['Fraccion'].toString());

      double cantUnidad = cajaPromo + (fraccionPromo / fraccionDv.toDouble());

      if (prodIvaTrimmed.isEmpty) {
        base0 += costoVenta * cantUnidad;
      } else if (prodIvaTrimmed == '*') {
        double base = (costoVenta / ((valor / 100) + 1)) * cantUnidad;
        baseIva += base;
        iva += (base * (valor / 100));
      }
    }

    double total = base0 + baseIva + iva;

    setState(() {
      baseCero = double.parse(base0.toStringAsFixed(2).toString());
      baseIvas = double.parse(baseIva.toStringAsFixed(2));

      ivas = double.parse(iva.toStringAsFixed(2));
      totales = double.parse(total.toStringAsFixed(2));
    });
    return [
      {
        "Total": total.toStringAsFixed(2),
        "Base_0": base0.toStringAsFixed(2),
        "Iva": iva.toStringAsFixed(2),
        "Base_Iva": baseIva.toStringAsFixed(2),
      }
    ];
  }
}
