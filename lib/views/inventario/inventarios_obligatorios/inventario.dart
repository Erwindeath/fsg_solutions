// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_final_fields, sized_box_for_whitespace, use_build_context_synchronously, depend_on_referenced_packages, unused_field, unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:badges/badges.dart' as badges;

import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/database/inventario_sqlite.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/laboratorios.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/logica_inventario_general.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/methods.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/novedades_inventario.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/platform_service.dart';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart' as inta;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InventarioObligatorio extends StatefulWidget {
  final bool envio;
  final bool alerta;
  const InventarioObligatorio({Key? key, required this.envio, required this.alerta}) : super(key: key);

  @override
  State<InventarioObligatorio> createState() => _InventarioObligatorioState();
}

class _InventarioObligatorioState extends State<InventarioObligatorio> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> valores = [];
  List<Map<String, dynamic>> filteredValores = [];
  String tituloLaboratorio = "";
  String codigoBarraAnterior = "";
  String unidadesss = '0';
  String fraccionesss = '0';
  String fraccionessspica = '0';

  String cajaPromo = '0';
  String fraccionPromo = '0';
  int codProducto = 0;
  bool politica = false;
  bool activaBotonPrincipal = false;
  bool activaBotonPrincipalFracciones = false;
  bool validaButton = false;
  String token = "";
  bool validacionInicial = false;
  Inventario? productoEncontrado;
  bool nuevaVerificacion = false;
  bool primerEscaneo = true;
  bool activa = false;
  bool valida = false;
  double alto = 210;
  double ancho = 350;
  double tama = 10;
  double tamanoTitulo = 18.0;
  double tamanoDescripcion = 15.0;
  int cantidadCajas = 0;
  int cantidadFracciones = 0;
  int contador = 0;
  bool comprobarNuevoValor = false;

  int fraccionesMalPicadas = 0;
  int cajasCaducadas = 0;
  int fraccionesCaducadas = 0;

  int tipoNovedad = 0;

  List<Inventario> producto = [];

  TextEditingController ctrlCajaCaducada = TextEditingController();
  TextEditingController ctrlFraccionCaducada = TextEditingController();

  TextEditingController ctrlCajaPromo = TextEditingController();
  TextEditingController ctrlFraccionpromo = TextEditingController();

  TextEditingController ctrlFraccionCortada = TextEditingController();
  TextEditingController ctrlFracciones = TextEditingController();
  TextEditingController ctrlCajasEscaneadas = TextEditingController();
  TextEditingController ctrlTotalCajas = TextEditingController();
  TextEditingController ctrlTotalFracciones = TextEditingController();

  ScrollController _scrollController = ScrollController();

  var fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');
  StreamSubscription<dynamic>? fdwListener;

  bool boton = false;
  SecureStorage storage = SecureStorage();

  FocusNode cajasFocusNode = FocusNode();
  FocusNode fraccionesFocusNode = FocusNode();

  bool isCardOnTop = false;
  bool isKeyboardOpen = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final StreamController<double> _progressController = StreamController();
  bool processing = false;
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
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              tituloLaboratorio,
              style: const TextStyle(color: Colors.white, fontSize: 15.0),
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
                  : IconButton(
                      onPressed: /* producto.isEmpty
                          ? nulls
                          :*/
                          () async {
                        await ArtSweetAlert.show(
                            barrierDismissible: false,
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.warning,
                                title: "¿Está seguro de guardar el inventario de este laboratorio?",
                                text: "Si acepta dará por finalizado el inventario de este laboratorio",
                                confirmButtonText: "Aceptar",
                                onCancel: () {
                                  Navigator.of(context).pop();
                                },
                                onConfirm: () async {
                                  setState(() {
                                    processing = true;
                                  });
                                  final dbHelper = DatabaseHelper();
                                  for (int i = 0; i < producto.length; i++) {
                                    await dbHelper.actualizarDatosEnSQLite2(producto[i].codProducto, 0, 0, 0, 0, 0, 1);
                                  }
                                  _progressController.close();
                                  fdwListener?.cancel();

                                  setearvalores();

                                  await ArtSweetAlert.show(
                                      barrierDismissible: false,
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.warning,
                                          title: "Inventario finalizado",
                                          confirmButtonText: "Aceptar",
                                          text: "El inventario de este laboratorio ha terminado, compruebe las novedades",
                                          confirmButtonColor: Colores.esquemaColor,
                                          onConfirm: () {
                                            setState(() {
                                              processing = false;
                                            });
                                            Navigator.pop(context);
                                          }));

                                  setState(() {
                                    processing = false;
                                  });
                                  await recargarDatos();
                                },
                                showCancelBtn: true,
                                cancelButtonText: "Cancelar",
                                cancelButtonColor: Colors.grey,
                                confirmButtonColor: Colores.esquemaColor));
                      },
                      icon: const Icon(Icons.save),
                      iconSize: 35,
                    )
            ],
          ),
          body: datos(),
          floatingActionButton: validaButton && activaBotonPrincipal && activaBotonPrincipalFracciones
              ? FloatingActionButton.extended(
                  onPressed: producto.isEmpty
                      ? null
                      : () async {
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
                            final dbHelper = DatabaseHelper();

                            int cajasEscaneadas = int.tryParse(ctrlCajasEscaneadas.text) ?? 0;
                            int fraccionesEscaneadas = int.tryParse(ctrlFracciones.text) ?? 0;
                            int cajasCaducadas = int.tryParse(ctrlCajaCaducada.text) ?? 0;
                            int fraccionesCaducadas = int.tryParse(ctrlFraccionCaducada.text) ?? 0;
                            int fraccionesMalPicadas = int.tryParse(ctrlFraccionCortada.text) ?? 0;

                            int cajasPromoc = int.tryParse(ctrlCajaPromo.text) ?? 0;
                            int fraccionesPromo = int.tryParse(ctrlFraccionpromo.text) ?? 0;

                            await dbHelper.actualizarDatosEnSQLite(productos.codProducto, cajasEscaneadas, fraccionesEscaneadas, cajasCaducadas,
                                fraccionesCaducadas, fraccionesMalPicadas, 1, cajasPromoc, fraccionesPromo, fechaEscaneo);
                            setState(() {
                              codProducto = productos.codProducto;
                            });
                            setearvalores();
                            await recargarDatos();
                          }
                        },
                  label: const Text("Siguiente producto"),
                  icon: const Icon(Icons.fast_forward_sharp),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

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

  @override
  void dispose() {
    _progressController.close();
    fdwListener?.cancel();
    cajasFocusNode.dispose();
    fraccionesFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> recargarDatos() async {
    producto.clear();
    final dbHelper = DatabaseHelper();
    var dato = await dbHelper.getAllProductos("0");
    if (dato.isEmpty) {
      await Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const NovedadesInventario()), (Route<dynamic> route) => false);
    }
    producto = await dbHelper.getAllProductos2();
    iniciarScanner();
  }

  Future<void> limpiar() async {
    await storage.deleteSecureData("codLaboratorio");
    await storage.deleteSecureData("nombreLaboratorio");
  }

  Future<void> datosIniciales() async {
    bool datoInicial = widget.envio;
    final dbHelper = DatabaseHelper();
    try {
      String nombreLab = await storage.readSecureData("nombreLaboratorio") ?? "";
      var codBodega = await storage.readSecureData("codBodega") ?? "";
      String codLaboratorio = await storage.readSecureData("codLaboratorio") ?? "";
      String tokens = await storage.readSecureData("token") ?? "";
      String codUsuario = await storage.readSecureData("cod_usuario") ?? "";
      String codInventario = await storage.readSecureData("codInventario") ?? "";
      String codInventarioDet = await storage.readSecureData("codInventarioDet") ?? "";
      if (datoInicial) {
        var dato = await dbHelper.getAllProductos("0");
        //si no hay datos en sqlite se va por este if
        if (dato.isEmpty) {
          await Navigator.of(context)
              .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const NovedadesInventario()), (Route<dynamic> route) => false);
        }
        producto.clear();
        producto = await dbHelper.getAllProductos2();

        setState(() {
          tituloLaboratorio = nombreLab;
          activa = true;
          valida = true;
          comprobarNuevoValor = true;
          valores = Inventario.convertirAListaMap(producto);
        });

        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "Inventario pendiente",
                confirmButtonText: "Aceptar",
                text: "Usted tiene un inventario pendiente",
                confirmButtonColor: Colores.esquemaColor));

        //}
        iniciarScanner();
      } else {
        producto.clear();
        try {
          final SecureStorage storage = SecureStorage();
          String metodo = await storage.readSecureData("metodo");
          var datos = await obtenerOrdenesDatosInicialesInventario(
              tokens, int.parse(codBodega), int.parse(codLaboratorio), int.parse(codUsuario), int.parse(codInventario), metodo);

          var fecha = jsonDecode(datos.body)["data"][0]["Fecha_Inicio"];

          await storage.writeSecureData("fechaInventario", fecha.toString());
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
          var verificarLaboratorios = await verificarLaboratorioUsuario(
              int.parse(codLaboratorio), int.parse(codInventario), int.parse(codInventarioDet), int.parse(codUsuario), tokens);
          var valorDecode = jsonDecode(verificarLaboratorios.body);

          if (valorDecode["msg"] != "err") {
            setState(() {
              tituloLaboratorio = nombreLab;
              activa = true;
              valida = true;
              comprobarNuevoValor = true;
            });
            iniciarScanner();
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: "Ocurrió un error, este laboratorio se encuentra asignado a otro usuario",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
            );
            await limpiar();
            Navigator.of(context)
                .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
          }
        } catch (e) {
          ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.danger,
                  title: "Error: $e",
                  confirmButtonText: "Aceptar",
                  text: "No hay productos a inventariar para este laboratorio ",
                  onConfirm: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (BuildContext context) => const LabotarotiosInventario()), (Route<dynamic> route) => false);
                  },
                  confirmButtonColor: Colores.esquemaColor));
        }
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
    if (!activa) {
      return circularPrimero();
    } else if (!valida) {
      return circularSegundo();
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
                    "Generando inventario, por favor espere...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget circularSegundo() {
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
              Text('Generando inventario....'),
            ],
          ),
        ],
      ),
    );
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

  Widget principal() {
    return buildCardSecundario();
  }

  Future<Widget> inicio() async {
    final dbHelper = DatabaseHelper();
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
                  producto = await dbHelper.getAllProductos2();

                  setState(() {
                    filteredValores = Inventario.convertirAlistaEspecial(producto);
                    // Lógica de ordenamiento combinada
                    filteredValores.sort((a, b) {
                      // Primero, la lógica para priorizar elementos con cantidad o fracción > 0
                      int cantidadA = a['cantidad'] ?? 0;
                      int cantidadB = b['cantidad'] ?? 0;
                      int fraccionA = a['fraccion'] ?? 0;
                      int fraccionB = b['fraccion'] ?? 0;
                      bool ambosCeroA = cantidadA == 0 && fraccionA == 0;
                      bool ambosCeroB = cantidadB == 0 && fraccionB == 0;
                      if (ambosCeroA && !ambosCeroB) return 1;
                      if (!ambosCeroA && ambosCeroB) return -1;

                      // Luego, la lógica de orden alfabético
                      return (a['producto'] ?? a['Descripcion']).toLowerCase().compareTo((b['producto'] ?? b['Descripcion']).toLowerCase());
                    });
                  });
                  if (filteredValores.isNotEmpty) {
                    alertaBusquedaManual(context, "Proceso manual");
                  } else {}
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
                                    IconButton(
                                        onPressed: () async {
                                          await ArtSweetAlert.show(
                                              barrierDismissible: false,
                                              context: context,
                                              artDialogArgs: ArtDialogArgs(
                                                  type: ArtSweetAlertType.info,
                                                  title: "Política de devolución",
                                                  confirmButtonText: "Aceptar",
                                                  text:
                                                      "El producto ${productoEncontrado!.producto} tiene la política de devolución de ${productoEncontrado!.politica}",
                                                  confirmButtonColor: Colores.esquemaColor));
                                        },
                                        icon: Icon(MdiIcons.commentAlert, size: 40.0, color: Colores.esquemaColor)),
                                    //IconButton(onPressed: () async {}, icon: Icon(MdiIcons.clipboardPulse, size: 40.0, color: Colores.esquemaColor))
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

  Future<void> activaBotones() async {
    setState(() {
      activaBotonPrincipal = true;
    });
  }

  Future<void> desactivaBotones() async {
    setState(() {
      activaBotonPrincipal = false;
    });
  }

  Future<void> activaBotonesFra(int acti) async {
    setState(() {
      activaBotonPrincipalFracciones = true;
    });
  }

  Future<void> desactivaBotonesFra() async {
    setState(() {
      activaBotonPrincipalFracciones = false;
    });
  }

  bool esEntero(String s) {
    final RegExp numeroEntero = RegExp(r'^-?\d+$');
    return numeroEntero.hasMatch(s);
  }

  Widget prueba(Inventario productos) {
    if (productos.fraccionDv <= 1) {
      setState(() {
        activaBotonPrincipalFracciones = true;
      });
    }
    if (productos.fraccion == 0 && ctrlFracciones.text.isEmpty) {
      ctrlFracciones.text = "0";
      setState(() {
        activaBotonPrincipalFracciones = true;
      });
    } else if (productos.cantidad == 0 && ctrlCajasEscaneadas.text.isEmpty) {
      ctrlCajasEscaneadas.text = "0";

      setState(() {
        activaBotonPrincipal = true;
      });
    }
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
                        int numCajasCaducadas = int.tryParse(ctrlCajaCaducada.text) ?? 0;
                        ctrlTotalCajas.text = (numCajasCorrectas + numCajasCaducadas).toString();
                        await activaBotones();
                      } else {
                        await desactivaBotones();
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
                    onSubmitted: (String value) {
                      if (productos.fraccionDv > 1) {
                        FocusScope.of(context).requestFocus(fraccionesFocusNode);
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
                        await activaBotonesFra(productos.fraccionDv);
                      } else {
                        await desactivaBotonesFra();
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
            const SizedBox(
              height: 20,
            ),
            if (productos.codTipo != '02')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [buttonCadBadge(), productos.fraccionDv > 1 ? picados() : const SizedBox.shrink(), promociones()],
              ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget picados() {
    final productos = productoEncontrado;
    //print('Unidades: $unidadesss, Fracciones: $fraccionesss');
    return badges.Badge(
        position: badges.BadgePosition.topEnd(top: -15, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        showBadge: ctrlFraccionCortada.text != "", // Mostrar el badge solo si hay unidades o fracciones
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color.fromRGBO(205, 62, 45, 1),
          padding: EdgeInsets.all(8),
        ),
        badgeContent: Text(
          'F$fraccionessspica', // Mostrar la información en el formato deseado
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: SizedBox(
          width: 110, // Ancho del botón
          height: 40, // Altura del botón
          child: FloatingActionButton.extended(
            onPressed: () {
              alertaPicados(context, "Producto mal cortado", productos!);
            },
            label: const Text("Mal cortado"),
          ),
        ));
  }

  Widget promociones() {
    final productos = productoEncontrado;

    return badges.Badge(
        position: badges.BadgePosition.topEnd(top: -15, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        showBadge: ctrlCajaPromo.text != "" || ctrlFraccionpromo.text != "", // Mostrar el badge solo si hay unidades o fracciones
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color.fromRGBO(205, 62, 45, 1),
          padding: EdgeInsets.all(8),
        ),
        badgeContent: Text(
          '${cajaPromo}F$fraccionPromo', // Mostrar la información en el formato deseado
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: SizedBox(
          width: 110, // Ancho del botón
          height: 40, // Altura del botón
          child: FloatingActionButton.extended(
            onPressed: () {
              alertaPromos(context, "Promociones no entregadas", productos!);
            },
            label: const Text("Cargos"),
          ),
        ));
  }

  Widget buttonCadBadge() {
    final productos = productoEncontrado;

    return badges.Badge(
        position: badges.BadgePosition.topEnd(top: -15, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        showBadge: ctrlCajaCaducada.text != "" || ctrlFraccionCaducada.text != "", // Mostrar el badge solo si hay unidades o fracciones
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color.fromRGBO(205, 62, 45, 1),
          padding: EdgeInsets.all(8),
        ),
        badgeContent: Text(
          '${unidadesss}F$fraccionesss', // Mostrar la información en el formato deseado
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: SizedBox(
          width: 100, // Ancho del botón
          height: 40, // Altura del botón
          child: FloatingActionButton.extended(
            onPressed: () {
              alertaEspecial(context, "Producto caducado", productos!);
            },
            label: const Text("Caducado"),
          ),
        ));
  }

  Future<void> alertaPicados(
    BuildContext context,
    String titulo,
    Inventario producto,
  ) async {
    bool botonComprueba = false;

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          botonComprueba = esValidoFraccionCortada();
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              scrollable: true,
              title: Text(titulo),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 230,
                        child: Text(
                          producto.producto,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 16.0),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("Ingrese el número de fracciones"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: ctrlFraccionCortada,
                      onChanged: (f) async {
                        if (esEntero(f)) {
                          int numFraccionesPicadas = int.tryParse(f) ?? 0;
                          setState(() {
                            fraccionessspica = numFraccionesPicadas.toString();
                            botonComprueba = true;
                          });
                        } else {
                          setState(() {
                            botonComprueba = false;
                          });
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg:
                                "Por favor para continuar, verifique los valores ingresados, la cantidad de caducados no debe ser mayor a la cantidad encontrada, ni con caracteres especiales",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          MdiIcons.pill,
                          size: 24,
                          color: Colores.esquemaColor,
                        ),
                        labelText: "Cantidad de francciones",
                        hintText: "Cantidad de francciones",
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    setState(() {
                      ctrlFraccionCortada.text = "";
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: botonComprueba
                      ? () async {
                          setState(() {
                            fraccionessspica = ctrlFraccionCortada.text;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  bool esValido() {
    bool esValidoCaja =
        esEntero(ctrlCajaCaducada.text) && (int.tryParse(ctrlCajaCaducada.text) ?? 0) <= (int.tryParse(ctrlCajasEscaneadas.text) ?? 0);
    bool esValidoFraccion =
        esEntero(ctrlFraccionCaducada.text) && (int.tryParse(ctrlFraccionCaducada.text) ?? 0) <= (int.tryParse(ctrlFracciones.text) ?? 0);
    return esValidoCaja && esValidoFraccion;
  }

  bool esValidoPromos() {
    bool esValidoCaja = esEntero(ctrlCajaPromo.text);
    bool esValidoFraccion = esEntero(ctrlFraccionpromo.text);
    return esValidoCaja && esValidoFraccion;
  }

  bool esValidoFraccionCortada() {
    return esEntero(ctrlFraccionCortada.text);
  }

  Future<void> alertaEspecial(
    BuildContext context,
    String titulo,
    Inventario producto,
  ) async {
    bool botonComprueba = false;
    bool botonCompruebaF = false;
    if (esValido()) {
      botonComprueba = true;
      botonCompruebaF = true;
    }
    if (producto.fraccionDv <= 1) {
      setState(() {
        botonCompruebaF = true;
      });
    }
    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              scrollable: true,
              title: Text(titulo),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 230,
                        child: Text(
                          producto.producto,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 16.0),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("Ingrese el número de unidades"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: ctrlCajaCaducada,
                      onChanged: (f) async {
                        if (esEntero(f) && ((int.tryParse(f) ?? 0) <= (int.tryParse(ctrlCajasEscaneadas.text) ?? 0))) {
                          int numFraccionesCorrectas = int.tryParse(f) ?? 0;
                          setState(() {
                            unidadesss = numFraccionesCorrectas.toString();
                            botonComprueba = true;
                          });
                        } else {
                          setState(() {
                            botonComprueba = false;
                          });
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg:
                                "Por favor para continuar, verifique los valores ingresados, la cantidad de caducados no debe ser mayor a la cantidad encontrada, ni con caracteres especiales",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          MdiIcons.package,
                          size: 24,
                          color: Colores.esquemaColor,
                        ),
                        labelText: "Número de unidades",
                        hintText: "Número de unidades",
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("Ingrese el número de fracciones"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: ctrlFraccionCaducada,
                      enabled: producto.fraccionDv > 1,
                      onChanged: (f) async {
                        if (esEntero(f) /*&& ((int.tryParse(f) ?? 0) <= (int.tryParse(ctrlFracciones.text) ?? 0))*/) {
                          int numFraccionesCaducadas = int.tryParse(f) ?? 0;
                          setState(() {
                            fraccionesss = numFraccionesCaducadas.toString();
                            botonCompruebaF = true;
                            //fraccionesss = "0";
                          });
                        } else {
                          setState(() {
                            botonCompruebaF = false;
                          });
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg:
                                "Por favor para continuar, verifique los valores ingresados, la cantidad de caducados no debe ser mayor a la cantidad encontrada, ni con caracteres especiales",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          MdiIcons.pill,
                          size: 24,
                          color: Colores.esquemaColor,
                        ),
                        labelText: "Cantidad de fracciones",
                        hintText: "Cantidad de fracciones",
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    setState(() {
                      ctrlCajaCaducada.text = "";
                      ctrlFraccionCaducada.text = "";
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: botonComprueba && botonCompruebaF
                      ? () async {
                          setState(() {
                            unidadesss = ctrlCajaCaducada.text;
                            fraccionesss = ctrlFraccionCaducada.text;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> alertaPromos(
    BuildContext context,
    String titulo,
    Inventario producto,
  ) async {
    bool botonCompruebaPromo = false;
    bool botonCompruebaFPromo = false;
    if (esValidoPromos()) {
      botonCompruebaPromo = true;
      botonCompruebaFPromo = true;
    }
    if (producto.fraccionDv <= 1) {
      setState(() {
        botonCompruebaFPromo = true;
      });
    }

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              scrollable: true,
              title: Text(titulo),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 230,
                        child: Text(
                          producto.producto,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 16.0),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("Ingrese el número de unidades"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: ctrlCajaPromo,
                      onChanged: (f) async {
                        if (esEntero(f)) {
                          int numFraccionesCorrectas = int.tryParse(f) ?? 0;
                          setState(() {
                            cajaPromo = numFraccionesCorrectas.toString();
                            botonCompruebaPromo = true;
                            //fraccionesss = "0";
                          });
                        } else {
                          setState(() {
                            botonCompruebaPromo = false;
                          });
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg: "Por favor para continuar, verifique los valores ingresados, la cantidad no debe contener caracteres especiales",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          MdiIcons.package,
                          size: 24,
                          color: Colores.esquemaColor,
                        ),
                        labelText: "Numero de unidades",
                        hintText: "Numero de unidades",
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("Ingrese el número de fracciones"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      enabled: producto.fraccionDv > 1,
                      controller: ctrlFraccionpromo,
                      onChanged: (f) async {
                        if (esEntero(f)) {
                          int numFraccionesCaducadas = int.tryParse(f) ?? 0;
                          setState(() {
                            fraccionPromo = numFraccionesCaducadas.toString();
                            botonCompruebaFPromo = true;
                            //fraccionesss = "0";
                          });
                        } else {
                          setState(() {
                            botonCompruebaFPromo = false;
                          });
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg: "Por favor para continuar, verifique los valores ingresados, la cantidad no debe contener caracteres especiales",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          MdiIcons.pill,
                          size: 24,
                          color: Colores.esquemaColor,
                        ),
                        labelText: "Cantidad de fracciones",
                        hintText: "Cantidad de fracciones",
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    setState(() {
                      ctrlCajaPromo.text = "";
                      ctrlFraccionpromo.text = "";
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: botonCompruebaPromo && botonCompruebaFPromo
                      ? () async {
                          setState(() {
                            cajaPromo = ctrlCajaPromo.text;
                            fraccionPromo = ctrlFraccionpromo.text;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> setearvalores() async {
    await fdwListener!.cancel();
    setState(() {
      primerEscaneo = true;
      codigoBarraAnterior = "";
      ctrlCajaCaducada.text = "";
      ctrlFraccionCaducada.text = "";
      ctrlFraccionCortada.text = "";
      ctrlFracciones.text = "";
      ctrlCajasEscaneadas.text = "";
      ctrlTotalCajas.text = "";
      ctrlTotalFracciones.text = "";
      ctrlCajaPromo.text = "";
      ctrlFraccionpromo.text = "";
      cajaPromo = '0';
      fraccionPromo = '0';
      cantidadCajas = 0;
      validacionInicial = false;
      nuevaVerificacion = false;
      politica = false;
      activaBotonPrincipal = false;
      activaBotonPrincipalFracciones = false;
      unidadesss = "0";
      fraccionesss = "0";
      fraccionessspica = "0";
      productoEncontrado = null;
    });
  }

  Future<void> setearvalores2() async {
    setState(() {
      codigoBarraAnterior = "";
      ctrlCajaCaducada.text = "";
      ctrlFraccionCaducada.text = "";
      ctrlFraccionCortada.text = "";
      ctrlFracciones.text = "";
      ctrlCajasEscaneadas.text = "";
      ctrlTotalCajas.text = "";
      ctrlTotalFracciones.text = "";
      ctrlCajaPromo.text = "";
      ctrlFraccionpromo.text = "";
      cajaPromo = "0";
      fraccionPromo = "0";
      cantidadCajas = 0;
      unidadesss = "0";
      fraccionesss = "0";
      fraccionessspica = "0";
    });
  }

  Future<void> filterSearch(String query, StateSetter setState) async {
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

  Future<void> alertaBusquedaManual(
    BuildContext context,
    String titulo,
  ) async {
    TextEditingController editingController = TextEditingController();

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          int indexToScroll = filteredValores.indexWhere((element) => element["codProducto"] == codProducto);

          double alturaDeCadaElementoDouble = 51.0;

          if (indexToScroll != -1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              double scrollPosition = indexToScroll * alturaDeCadaElementoDouble;
              _scrollController.animateTo(
                scrollPosition,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          }

          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              title: Text(titulo),
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editingController,
                      decoration: const InputDecoration(
                        labelText: "Buscar",
                        hintText: "Buscar",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) async {
                        await filterSearch(value, setState);
                      },
                    ),
                  ),
                  // Aquí está el CustomScrollView
                  Expanded(
                    child: filteredValores.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Scrollbar(
                            thickness: 10.0,
                            radius: const Radius.circular(8.0),
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: <Widget>[
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return badges.Badge(
                                        position: badges.BadgePosition.topEnd(top: 5, end: 3),
                                        badgeStyle: badges.BadgeStyle(
                                          badgeColor: filteredValores[index]["cantidad"] == 0 &&
                                                  filteredValores[index]["fraccion"] == 0 &&
                                                  filteredValores[index]["cajasEscaneadas"] == 0 &&
                                                  filteredValores[index]["fraccionesEscaneadas"] == 0
                                              ? Colors.red
                                              : Colors.green,
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        child: Card(
                                          elevation: 4,
                                          child: InkWell(
                                            onTap: () async {
                                              await fdwListener!.cancel();
                                              Navigator.pop(context);
                                              buscarProducto("na", filteredValores[index]["codProducto"]);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check_box,
                                                    color: filteredValores[index]["estado"] > 0 ? Colors.blue : Colors.grey,
                                                    size: 24.0,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      filteredValores[index]['producto'] ?? filteredValores[index]['Descripcion'],
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
                                        ),
                                      );
                                    },
                                    childCount: filteredValores.length,
                                  ),
                                ),
                              ],
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
            ),
          );
        });
      },
    );
  }

  void iniciarScanner() async {
    setearvalores2();
    if (Platform.isAndroid) {
      fdwListener = fdw.onScanResult.listen((code) async {
        final codBarra = code.data.toString().trim();

        await buscarProducto(codBarra, 0);
      });
    }
  }

  Future<void> procesarCodBarra(String codBarra, int codProductos) async {
    if (productoEncontrado!.codBarra.trim() == codBarra ||
        productoEncontrado!.codBarraAdicional.contains(codBarra) ||
        productoEncontrado!.codProducto == codProductos) {
      if (primerEscaneo) {
        setState(() {
          primerEscaneo = false;
        });
      } else {
        if (productoEncontrado!.estado == 1) {
          setState(() {
            // Incrementamos directamente desde el valor actual en ctrlCajasEscaneadas

            int valor = int.parse(ctrlCajasEscaneadas.text) + 1;
            ctrlCajasEscaneadas.text = valor.toString();
            // Actualizamos ctrlTotalCajas basado en su valor actual
            /* int valorTotal = int.parse(ctrlTotalCajas.text) + 1;
            ctrlTotalCajas.text = valorTotal.toString();*/
          });
        } else {
          activaBotones();
          setState(() {
            cantidadCajas++;
            ctrlCajasEscaneadas.text = cantidadCajas.toString();
            //ctrlTotalCajas.text = cantidadCajas.toString();
          });
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

  Future<void> buscarProducto(String codigoBarra, int codProductos) async {
    //setearvalores2();
    Inventario? productoEncontradoTemp = producto.firstWhereOrNull(
      (inventario) =>
          //(inventario.estado == 0) &&
          inventario.codBarra == codigoBarra || inventario.codBarraAdicional.contains(codigoBarra) || inventario.codProducto == codProductos,
    );
    if (productoEncontrado != null && productoEncontrado!.codBarra != codigoBarra && !productoEncontrado!.codBarraAdicional.contains(codigoBarra)) {
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Está intentando escanear un producto diferente al actual",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      return; // Salir del método si es un producto diferente
    }

    if (productoEncontradoTemp != null) {
      if (productoEncontradoTemp.observacion != "0" && productoEncontradoTemp.bonificacion != "0" && primerEscaneo) {
        ArtSweetAlert.show(
            barrierDismissible: true,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Producto en promoción",
                confirmButtonText: "Aceptar",
                text:
                    "El producto ${productoEncontradoTemp.producto} está en: ${productoEncontradoTemp.observacion} es decir: ${productoEncontradoTemp.bonificacion}",
                confirmButtonColor: Colores.esquemaColor));
      }
      productoEncontrado = null;
      setState(() {
        if (codigoBarra != codigoBarraAnterior) {
          primerEscaneo = true; // Indicar que es el primer escaneo si el código de barras cambia
        }
        productoEncontrado = productoEncontradoTemp;
        isKeyboardOpen = true;
        validaButton = true;
        politica = true;
        validacionInicial = true;
        nuevaVerificacion = true;
      });

      if (productoEncontrado!.estado == 1) {
        ctrlCajaCaducada.text = (productoEncontrado!.cajasCaducadas.toString()) == "0" ? "" : productoEncontrado!.cajasCaducadas.toString();
        ctrlCajasEscaneadas.text =
            ctrlCajasEscaneadas.text != "" ? (int.parse(ctrlCajasEscaneadas.text)).toString() : productoEncontrado!.cajasEscaneadas.toString();
        /* ctrlTotalCajas.text = ctrlCajasEscaneadas.text != ""
            ? (productoEncontrado!.cajasCaducadas + int.parse(ctrlCajasEscaneadas.text)).toString()
            : (productoEncontrado!.cajasCaducadas + productoEncontrado!.cajasEscaneadas).toString();*/

        ctrlFracciones.text = productoEncontrado!.fraccionesEscaneadas.toString();
        ctrlFraccionCaducada.text =
            productoEncontrado!.fraccionesCaducadas.toString() == "0" ? "" : productoEncontrado!.fraccionesCaducadas.toString();
        ctrlFraccionCortada.text =
            productoEncontrado!.fraccionesMalPicadas.toString() == "0" ? "" : productoEncontrado!.fraccionesMalPicadas.toString();

        ctrlCajaPromo.text = productoEncontrado!.cajaPromo.toString() == "0" ? "" : productoEncontrado!.cajaPromo.toString();
        ctrlFraccionpromo.text = productoEncontrado!.fraccionPromo.toString() == "0" ? "" : productoEncontrado!.fraccionPromo.toString();

        unidadesss = productoEncontrado!.cajasCaducadas.toString();
        fraccionesss = productoEncontrado!.fraccionesCaducadas.toString();
        fraccionessspica = productoEncontrado!.fraccionesMalPicadas.toString();
        cajaPromo = productoEncontrado!.cajaPromo.toString();
        fraccionPromo = productoEncontrado!.fraccionPromo.toString();

        setState(() {
          activaBotonPrincipal = true;
          activaBotonPrincipalFracciones = true;
        });
      }
      await procesarCodBarra(codigoBarra, codProductos); // Este llamado se hace independientemente del estado.
      codigoBarraAnterior = codigoBarra; // Actualizar el código de barras anterior.
    } else /*if (productoEncontradoTemp == null)*/ {
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Este producto no perternece a este laboratorio",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
