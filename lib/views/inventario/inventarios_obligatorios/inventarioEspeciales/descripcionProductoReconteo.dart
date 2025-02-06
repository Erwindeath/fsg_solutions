// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/providers.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/pruebaInventarioReconteo.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../complementos/globals/colors.dart';
import '../logica_inventario_general.dart';

class DescripcionProductosReconteo extends ConsumerStatefulWidget {
  final int codProducto;
  final int codInventario;
  final int cadNovedad;
  final int laboratorio;
  final String nombreLaboratorio;
  final String token;
  const DescripcionProductosReconteo(
      {super.key,
      required this.codProducto,
      required this.codInventario,
      required this.cadNovedad,
      required this.laboratorio,
      required this.nombreLaboratorio,
      required this.token});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DescripcionProductosReconteoState();
}

class _DescripcionProductosReconteoState extends ConsumerState<DescripcionProductosReconteo> {
  List<Map<String, dynamic>> novedadesInventariosEspecial = [];
  List<Map<String, dynamic>> datosUsuario = [];

  bool load = false;
  bool isExpanded = false;
  bool enviando = false;
  TextEditingController ctrlCajasReconteo = TextEditingController();
  TextEditingController ctrlFraccionesReconteo = TextEditingController();
  int cantidadCajas = 0;
  int cantidadFracciones = 0;
  @override
  Widget build(BuildContext context) {
    load = ref.watch(loadReconteoProducto);
    enviando = ref.watch(enviandoProductoReconteo);
    cantidadCajas = ref.watch(cantidadCajasReconteo);
    cantidadFracciones = ref.watch(cantidadFraccionesReconteo);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Reconteo"),
            leading: IconButton(
                onPressed: () async {
                  await Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ReconteoPrueba(codLaboratorio: widget.laboratorio, laboratorio: widget.nombreLaboratorio)),
                      (Route<dynamic> route) => false);
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          body: buildCardSecundario(),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> datosIniciales() async {
    var codUsuario = await readSecureData("cod_usuario");
    var datos = await obtenerDescripcionProductoReconteo(
        widget.token, widget.cadNovedad, widget.codInventario, widget.codProducto, widget.laboratorio, int.parse(codUsuario));
    var decode = jsonDecode(datos.body);
    if (decode["msg"] != "err") {
      List<Map<String, dynamic>> productos = (decode["data"] as List).map((e) => e as Map<String, dynamic>).toList();

      setState(() {
        novedadesInventariosEspecial = productos;
        datosUsuario = (productos[0]["datosUsuarios"] as List).map((e) => e as Map<String, dynamic>).toList();
      });
      if (novedadesInventariosEspecial[0]["Fecha_Reconteo"] != 'null') {
        if (novedadesInventariosEspecial[0]["Cant_Real_Final"] > 0) {
          double numero = double.parse(novedadesInventariosEspecial[0]["Cant_Real_Final"].toString());
          int parteEntera = numero.toInt();

          double parteDecimal = numero - parteEntera;
          int valorFraccion = (parteDecimal * novedadesInventariosEspecial[0]["productoDv"]).toInt();
          setState(() {
            ctrlCajasReconteo.text = parteEntera.toString();
            ctrlFraccionesReconteo.text = valorFraccion.toString();
          });
        }
        ref.watch(enviandoProductoReconteo.notifier).state = true;
        /*ref.read(cantidadCajasReconteo.notifier).state = parteEntera;
        ref.read(cantidadFraccionesReconteo.notifier).state = valorFraccion;*/
      }
      ref.watch(loadReconteoProducto.notifier).state = true;
    } else {
      //ref.watch(loadReconteoProducto.notifier).state = false;
    }
  }

  Future<Widget> circularPrimero() async {
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

  Widget buildCardSecundario() {
    return FutureBuilder<Widget>(
      future: !load ? circularPrimero() : card(novedadesInventariosEspecial, datosUsuario),
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

  Future<Widget> card(List<Map<String, dynamic>> novedades, List<Map<String, dynamic>> datosUsuario) async {
    print(novedades);
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
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width - 120,
                                          child: Text(
                                            novedades[0]["Descripcion"],
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
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Stock: ${novedades[0]["Unidad"]}F${novedades[0]["Fraccion"]}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: novedades[0]["cantRealInicial"] < novedades[0]["cantRealEscaneada"] ? Colors.yellow : Colors.red),
                                  ),
                                  Text(
                                    "Encontrado: ${novedades[0]["Cajas_Buenas"]}F${novedades[0]["Fracciones_Buenas"]}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: novedades[0]["cantRealInicial"] < novedades[0]["cantRealEscaneada"] ? Colors.yellow : Colors.red),
                                  ),
                                ],
                              ),
                              if (novedades[0]["FechaRegistroInicial"].substring(6, 10) != "1900")
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Fecha: ",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      novedades[0]["FechaRegistroInicial"].substring(6, 10) == "1900" ? '' : novedades[0]["FechaRegistroInicial"],
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              if (novedades[0]["Fecha_Reconteo"].toString() != 'null')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Fecha reconteo: ",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      novedades[0]["Fecha_Reconteo"],
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            textAlign: TextAlign.right,
                                            controller: ctrlCajasReconteo,
                                            keyboardType: TextInputType.number,
                                            enabled: novedades[0]["Fecha_Reconteo"].toString() == 'null' || !enviando,
                                            cursorHeight: 25.0,
                                            /* decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),*/
                                            onChanged: (f) async {
                                              if (esEntero(f) && (int.tryParse(f) ?? 0) >= 0) {
                                                int numCajasCorrectas = int.tryParse(f) ?? 0;
                                                ref.read(cantidadCajasReconteo.notifier).state = numCajasCorrectas;
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
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text("/${novedades[0]["Cajas_Buenas"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            textAlign: TextAlign.right,
                                            controller: ctrlFraccionesReconteo,
                                            keyboardType: TextInputType.number,
                                            enabled:
                                                (novedades[0]["productoDv"] > 1 || novedades[0]["Fecha_Reconteo"].toString() == 'null') && enviando,
                                            cursorHeight: 25.0,
                                            /*decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),*/
                                            onChanged: (f) async {
                                              if (esEntero(f) && (int.tryParse(f) ?? 0) >= 0) {
                                                int numFraccionesCorrectas = int.tryParse(f) ?? 0;
                                                ref.read(cantidadFraccionesReconteo.notifier).state = numFraccionesCorrectas;
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
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text("/${novedades[0]["Fracciones_Buenas"]}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(
                                            novedades[0]["Fecha_Reconteo"].toString() == 'null' ? Colors.white : Colors.grey.shade100),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colores.esquemaColor)),
                                    onPressed: novedades[0]["Fecha_Reconteo"].toString() == 'null' || !enviando
                                        ? () async {
                                            ref.watch(enviandoProductoReconteo.notifier).state = true;
                                            await enviarReconteoProducto(cantidadCajas, cantidadFracciones, novedades[0]["productoDv"]);
                                          }
                                        : null,
                                    child: const Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.save),
                                          SizedBox(width: 10),
                                          Text("Guardar"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (datosUsuario.isNotEmpty)
                                Card(
                                  elevation: 2,
                                  child: ListTile(
                                      title: const Text("Usuarios"),
                                      trailing: Icon(
                                        !isExpanded ? MdiIcons.chevronDownCircle : MdiIcons.chevronUpCircle,
                                        color: Colores.esquemaColor,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          // print(cantidadReal);
                                          isExpanded = !isExpanded;
                                        });
                                      }),
                                ),
                              if (isExpanded)
                                Card(
                                  elevation: 2,
                                  child: SizedBox(
                                    height: 200, // Define una altura fija o ajusta según sea necesario
                                    child: CustomScrollView(
                                      slivers: [
                                        SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    datosUsuario[index]["Nombres_Rol"],
                                                  ),
                                                  Text(datosUsuario[index]["Cant_Real_UsuarioDes"]),
                                                ],
                                              );
                                            },
                                            childCount: datosUsuario.length,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
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

  Future<void> enviarReconteoProducto(int unidades, int fracciones, int productDv) async {
    var codUsuario = await readSecureData("cod_usuario");
    double cantReal = (unidades + (fracciones / productDv)).toDouble();

    // ROUND(((cinre.Cajas_Buenas+(CAST(iif(cinre.Fracciones_Buenas is null,0.0,cinre.Fracciones_Buenas) as float))/p.Fraccion)),2)
    try {
      var envio = await enviarDatosProductosReconteo(
          widget.token, widget.cadNovedad, widget.codInventario, int.parse(codUsuario), cantReal, unidades, fracciones);
      var decodeEnvio = jsonDecode(envio.body);
      if (decodeEnvio["msg"] != 'err') {
        Fluttertoast.showToast(
          msg: "Datos guardados con éxito",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => ReconteoPrueba(codLaboratorio: widget.laboratorio, laboratorio: widget.nombreLaboratorio)),
            (Route<dynamic> route) => false);
      } else {
        ref.watch(enviandoProductoReconteo.notifier).state = false;
        Fluttertoast.showToast(
          msg: "Ocurrió un error al guardar ${decodeEnvio["msg"]}",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      ref.watch(enviandoProductoReconteo.notifier).state = false;
      Fluttertoast.showToast(
        msg: "Ocurrió un error al guardar $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  bool esEntero(String s) {
    final RegExp numeroEntero = RegExp(r'^-?\d+$');
    return numeroEntero.hasMatch(s);
  }
}
