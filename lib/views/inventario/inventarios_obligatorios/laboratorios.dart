// ignore_for_file: import_of_legacy_library_into_null_safe, use_build_context_synchronously, empty_catches, unnecessary_null_comparison, non_constant_identifier_names, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/encuesta.dart';
import 'package:fsg_solutions/views/inventario/informe_inventario/informeInventario.dart';

import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_data_inicial.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/cobro_dependiente/cobro_dependientes.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventario.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/inventarioEspecial.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/inventarioReconteo.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/logica_inventario_general.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/methods.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/novedades_inventario.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/pdf_creator.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/reporte_ajuste.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/utils.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:spelling_number/spelling_number.dart';

import '../../supervisores/logica_supervisores.dart';
import 'cobro_dependiente/pdf_factura.dart' as fact;

import 'database/inventario_sqlite.dart';
import 'inventarioEspeciales/descripcionProductoReconteo.dart';
import 'inventarioEspeciales/pruebaInventarioReconteo.dart';

class LabotarotiosInventario extends StatefulWidget {
  const LabotarotiosInventario({Key? key}) : super(key: key);

  @override
  State<LabotarotiosInventario> createState() => _LabotarotiosInventarioState();
}

class _LabotarotiosInventarioState extends State<LabotarotiosInventario> {
  List<Map<String, dynamic>> laboratoriosInventario = [];

  List<Map<String, dynamic>> valores = [];
  TextEditingController editingController = TextEditingController();
  bool _estaSeleccionando = false;
  bool valorInventarioEspecial = false;
  List<Inventario> producto = [];
  String token = "";
  List<Personal> personal = [];
  List<ReportItem> reportItems = [];
  List<int> seleccionados = [];
  List<Equipo> equipo = [];
  bool load = false;
  bool impreso = false;
  bool impresoActa = false;
  bool impresoFin = false;

  double totalInventario = 0.00;
  int codigoInventario = 0;
  SecureStorage storage = SecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const HomeFarma(),
              ),
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Laboratorios a inventariar'),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            datoInicial();
          },
          child: datos()),
    );
  }

  @override
  void initState() {
    super.initState();
    datoInicial();
  }

  Widget datos() {
    if (load == false) {
      return circularPrimero();
    } else {
      return laboratoriosInventario.isEmpty && !load
          ? const Center(
              child: Text("Laboratorios no dispobibles..."),
            )
          : _buildNotificaciones(laboratoriosInventario);
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

  Widget _buildNotificaciones(List<Map<String, dynamic>> laboratorios) {
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
                    var validaLab = laboratorioss['valida'] ?? 0;
                    //var laboratorioId = notificacion['id'];
                    return Card(
                      color: valorInventarioEspecial && validaLab == 0 ? Colors.white : Colors.green.shade200,
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
                              // Verifica si ya hay una selección en curso
                              if (_estaSeleccionando) return;
                              // Indica que la selección ha comenzado
                              _estaSeleccionando = true;

                              // Aquí continúa tu lógica de selección...
                              //String token = await storage.readSecureData("token");
                              if (!valorInventarioEspecial) {
                                var verificarLaboratorios = await verificarLaboratorio(
                                  laboratorioss["Cod_Laboratorio"],
                                  laboratorioss["codIventario"],
                                  laboratorioss["C_Inventario_Det"],
                                  token,
                                );
                                var valorDecode = jsonDecode(verificarLaboratorios.body);
                                if (valorDecode["msg"] != "err") {
                                  final dbHelper = DatabaseHelper();
                                  await dbHelper.deleteTable();
                                  await storage.deleteSecureData("codLaboratorio");
                                  await storage.deleteSecureData("nombreLaboratorio");
                                  await storage.deleteSecureData("codInventarioDet");
                                  await storage.deleteSecureData("fechaInventario");
                                  await guardarData(laboratorioss["Cod_Laboratorio"].toString(), descripcion,
                                      laboratorioss["codIventario"].toString(), laboratorioss["C_Inventario_Det"].toString());

                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => const InventarioObligatorio(
                                                envio: false,
                                                alerta: false,
                                              )),
                                      (Route<dynamic> route) => false);
                                } else {
                                  await ArtSweetAlert.show(
                                      barrierDismissible: false,
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          type: ArtSweetAlertType.danger,
                                          title: "Error",
                                          text: "Este laboratorio ya se encuentra escogido",
                                          confirmButtonText: "Aceptar",
                                          showCancelBtn: true,
                                          cancelButtonText: "Cancelar",
                                          confirmButtonColor: Colores.esquemaColor));
                                  // Navigator.pop(context);
                                  datoInicial();
                                }

                                // Después de manejar la selección, restablece el estado de selección
                                _estaSeleccionando = false;
                              } else {
                                // Indica que la selección ha comenzado

                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => ReconteoPrueba(
                                              codLaboratorio: laboratorioss["Cod_Laboratorio"],
                                              laboratorio: descripcion,
                                            )),
                                    (Route<dynamic> route) => false);
                              }
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

  Future<void> mostrarSelectMultiple(BuildContext context, List<Personal> personal) async {
    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
              title: const Text("Seleccione el personal"),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5, // Altura máxima
                child: SingleChildScrollView(
                  child: ListBody(
                    children: personal.map((persona) {
                      return CheckboxListTile(
                        title: Text(persona.nombre),
                        value: seleccionados.contains(persona.codUsuario),
                        onChanged: (bool? valor) {
                          setState(() {
                            if (valor == true) {
                              seleccionados.add(persona.codUsuario);
                            } else {
                              seleccionados.remove(persona.codUsuario);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    // Aquí puedes manejar los valores seleccionados
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> datoInicial() async {
    limpiarvariables();
    // await storage.writeSecureData("informepasar", "1");
    //await storage.writeSecureData("cod_usuario", "68");
    String codInventarios = await storage.readSecureData("codInventario");
    var codUsuario = await storage.readSecureData("cod_usuario");

    var codBodega = await storage.readSecureData("codBodega");
    String nombreBodega = await storage.readSecureData("nombreBodega");

    token = await storage.readSecureData("token");

    var validaReporte = await storage.readSecureData("validaajuste");
    String cobrado = await storage.readSecureData("cobrado") ?? "";
    String pasarInforme = await storage.readSecureData("informepasar") ?? "";
    if (codBodega == "2000" || codBodega == "0" || codBodega == "3000") {
      var compruebaReconteo = await compruebaReconteoInventario(token, int.parse(codInventarios));
      var deco = jsonDecode(compruebaReconteo.body);

      if (deco["msg"] != "err") {
        if (deco["data"][0]["Cod_Estado"] == 1 && !deco["data"][0]["Estado_Reconteo"]) {
          Navigator.of(context)
              .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const InventarioEspecial()), (Route<dynamic> route) => false);
        } else if (deco["data"][0]["Cod_Estado"] == 1 && deco["data"][0]["Estado_Reconteo"]) {
          var compruebaProductoPendienteReconteos = await compruebaProductoPendienteReconteo(token, int.parse(codInventarios), int.parse(codUsuario));
          var decode = jsonDecode(compruebaProductoPendienteReconteos.body);
          if (decode["msg"] != "err") {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => DescripcionProductosReconteo(
                        cadNovedad: decode["data"][0]["cadNovedad"],
                        codProducto: decode["data"][0]["Cod_Producto"],
                        codInventario: decode["data"][0]["C_Inventario_Cab"],
                        laboratorio: decode["data"][0]["Cod_Laboratorio"],
                        nombreLaboratorio: decode["data"][0]["Laboratorio"],
                        token: token,
                      )),
            );
          } else {
            String codigoInv = await storage.readSecureData("codInventario") ?? "";
            String codigoInvDet = await storage.readSecureData("codInventarioDet") ?? "";

            var datos = await obtenerFarmaciasLaboratorios(
                int.parse(codUsuario), int.parse(codBodega), token, "obtener_laboratorios_inventario_especial", int.parse(codigoInv));

            if (jsonDecode(datos.body)["msg"] != "err") {
              List<Map<String, dynamic>> laboratorios = (jsonDecode(datos.body)["data"] as List).map((e) => e as Map<String, dynamic>).toList();

              setState(() {
                laboratoriosInventario = laboratorios;
                valores = laboratorios;
                load = true;
                valorInventarioEspecial = true;
              });
            } else if (codigoInvDet.isEmpty && codigoInv.isEmpty) {
              await ArtSweetAlert.show(
                  barrierDismissible: false,
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.warning,
                      title: "No tiene inventarios disponibles",
                      confirmButtonText: "Aceptar",
                      onConfirm: () async {
                        await Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                      },
                      confirmButtonColor: Colores.esquemaColor));
            }
          }
        } else {
          await ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: "No tiene inventarios disponibles",
                  confirmButtonText: "Aceptar",
                  onConfirm: () async {
                    await Navigator.of(context)
                        .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                  },
                  confirmButtonColor: Colores.esquemaColor));
        }
      } else if (deco["msg"] == "err") {
        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "Error: ${deco["msg"]} ",
                confirmButtonText: "Aceptar",
                text: "Comuníquese con el administrador",
                confirmButtonColor: Colores.esquemaColor));
      }
    } else {
      var comprubaFin = await obtenerFarmaciasLaboratorios(
          int.parse(codUsuario), int.parse(codBodega), token, "comprobar_estado_inventario", int.parse(codInventarios));
      var compruebaDecode = jsonDecode(comprubaFin.body);
      final dbHelper = DatabaseHelper();
      try {
        if (cobrado.isEmpty && pasarInforme.isEmpty) {
          if (compruebaDecode["msg"] == "err") {
            await ArtSweetAlert.show(
                barrierDismissible: false,
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.warning,
                    title: "No tiene inventarios disponibles",
                    confirmButtonText: "Aceptar",
                    onConfirm: () async {
                      await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                    },
                    confirmButtonColor: Colores.esquemaColor));
          } else {
            if (compruebaDecode["datos"][0]["Encuesta"] == null) {
              await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => EncuestaInicial(
                            codInventario: int.parse(codInventarios),
                            codUsuario: int.parse(codUsuario),
                            codBodega: int.parse(codBodega),
                            valida: true,
                          )),
                  (Route<dynamic> route) => false);
            } else {
              if (validaReporte == null) {
                var verificarUsuario = await obtenerFarmaciasLaboratorios(
                    int.parse(codUsuario), int.parse(codBodega), token, "comprobar_usuario_laboratorio", int.parse(codInventarios));

                if (jsonDecode(verificarUsuario.body)["msg"] == "ok") {
                  producto = await dbHelper.getAllProductos("0");

                  if (producto.isEmpty) {
                    await Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (BuildContext context) => const NovedadesInventario()), (Route<dynamic> route) => false);
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) => const InventarioObligatorio(
                                  envio: true,
                                  alerta: false,
                                )),
                        (Route<dynamic> route) => false);
                  }
                } else {
                  await storage.deleteSecureData("codLaboratorio");
                  await storage.deleteSecureData("nombreLaboratorio");
                  String metodo = await storage.readSecureData("metodo");
                  String codInventarios = await storage.readSecureData("codInventario");
                  await dbHelper.deleteTable();
                  var data = await fetchData(codUsuario, codBodega, token, codInventarios, metodo);

                  if (data.isNotEmpty && impreso) {
                    await mostrarSelectMultiple(context, data['personal']).then((_) async {
                      if (seleccionados.isNotEmpty) {
                        Fluttertoast.showToast(
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          msg: "Generando acta inicial, por favor espere...",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_LONG,
                        );
                        /****************ACTA DE INICIO DEINVENTARIO******** */
                        var personal = data['personal'];
                        var listaFiltrada = personal.where((persona) => seleccionados.contains(persona.codUsuario)).toList();

                        var equipoini = data['equipo'];
                        var reportItems = data['reportItems'];
                        List<SignatureEntity> combinedListPersonal = [...listaFiltrada];
                        List<SignatureEntity> combinedListEquipo = [...equipoini];
                        PdfCreator pdfcreator = PdfCreator();
                        DateTime now = DateTime.now();
                        String mes = DateFormat('MMMM', 'es_ES').format(now); // 'MMMM' para el nombre completo del mes
                        String dia = DateFormat('d').format(now); // 'd' para el día del mes
                        String anio = DateFormat('y').format(now); // 'y' para el año
                        int codbodegaNuevo = int.parse(codBodega) < 17 ? int.parse(codBodega) - 1 : int.parse(codBodega);
                        String farmacia = codbodegaNuevo.toString();
                        String content =
                            '''En la ciudad de ${personal[0].ciudad}. a los $dia día(s) del mes de $mes del $anio, en cumplimiento del Procedimiento Control de Inventario en Puntos de Venta PRO-INV-001, de la Sociedad Civil de Hecho Denominada Grupo Uscocovich, "Farmacias San Gregorio", respaldado en su reglamento interno de trabajo, procede a dar inicio al conteo de inventario del punto de venta Nro. $farmacia, dicho proceso será realizado por el personal designado por el área de control de Inventarios, bajo el cargo de Auxiliares de Inventario, y en presencia de los responsables del punto de venta que desempeñan su trabajo en calidad de Auxiliares de Mostrador.

Este inventario determinará las responsabilidades correspondientes a los excedentes y déficits detectados en dicho proceso, de acuerdo con las políticas de inventario establecidas, los ajustes serán realizados en el Punto de Venta (PDV). En situaciones donde los déficits superen a los excedentes, los ajustes por déficits serán asumidos por el (la/los/las) Auxiliar(es) de Mostrador. Quienes asumen la responsabilidad de las diferencias de inventario encontradas y autorizan el descuento correspondiente en sus roles de pagos conforme a la ley.
    
La Sociedad Civil de Hecho denominada Grupo Uscocovich, operadora de "Farmacias San Gregorio", basada en sus reglamentos internos, considera las mencionadas irregularidades como faltas graves, conforme al Artículo 58 y 69 de esta norma, en concordancia con el Artículo 46 y 172 del Código de Trabajo.
Por encontrarse inmerso en una o más de las prohibiciones del trabajador al ser una falta grave dichas circunstancias podrán dar lugar al inicio de un proceso de visto bueno, involucrando a las partes pertinentes en el proceso de toma física de inventarios. 
     
Se deja en constancia de todas las partes, que el ejercicio y ejecución del Proceso de Control de Inventarios en Puntos de Venta PRO-INV-001, será realizado con criterios de cumplimiento al control de activos asignados a cada punto de venta y bajo responsabilidad de cada Auxiliar de Mostrador asignado, siendo estos últimos responsables y custodios de todos los productos del punto de venta.
Los suscritos se comprometen a estar presentes en todo el desarrollo del proceso de toma física de inventarios, como constancia y legitimidad de la ejecución del mismo.

Para constancia de lo anterior, se firma la presente acta por quienes en ella intervienen.''';

                        Uint8List valor = await pdfcreator.crearPdf("ACTA DE INICIO DE INVENTARIO", "F01-PRO-INV-001", content,
                            firmaGrupo: "Representante del equipo de Auxiliares de Inventario:",
                            firmaDep: "Consentimiento mediante firmas del personal de farmacia:",
                            personal: combinedListPersonal,
                            equipo: combinedListEquipo,
                            reporte: reportItems,
                            textoFinal: "Total de laboratorios a inventariar inicial",
                            textoFin: "Total del inventario general inicial",
                            valorTotal: totalInventario);

                        if (valor.isEmpty) {
                          datoInicial();
                        } else {
                          await ArtSweetAlert.show(
                              barrierDismissible: false,
                              context: context,
                              artDialogArgs: ArtDialogArgs(
                                  type: ArtSweetAlertType.warning,
                                  title: "Acta de inicio",
                                  text: "Por favor confirme si imprimió o guardó correctamente el acta de inicio",
                                  confirmButtonText: "Aceptar",
                                  showCancelBtn: true,
                                  cancelButtonText: "Cancelar",
                                  onConfirm: () async {
                                    Fluttertoast.showToast(
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      msg: "Procesando, espere un momento por favor...",
                                      gravity: ToastGravity.BOTTOM,
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                    try {
                                      var prueba = await enviarPdf(valor, "inventarios-actas-inicio");
                                      if (prueba.statusCode != 200) {
                                        Fluttertoast.showToast(
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          msg: "Ocurrió un error al procesar el archivo",
                                          gravity: ToastGravity.BOTTOM,
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                        Navigator.pop(context);
                                        setState(() {
                                          impreso = false;
                                        });
                                        datoInicial();
                                      } else {
                                        var data = await prueba.stream.bytesToString();
                                        var decode = await jsonDecode(data);
                                        String llaves = decode["llave"][0];
                                        Map<String, dynamic> llavese = await jsonDecode(data);
                                        if (llaves.isNotEmpty) {
                                          var envio = await cambiaEstadoInicio(token, "actualiza_estado_acta_inicio", int.parse(codBodega),
                                              codigoInventario, seleccionados, int.parse(codUsuario), llaves);

                                          var decodi = await jsonDecode(envio.body);
                                          if (decodi["msg"] != "err") {
                                            Navigator.pop(context);
                                            setState(() {
                                              impreso = true;
                                            });
                                            datoInicial();
                                          } else {
                                            Fluttertoast.showToast(
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              msg: "Ocurrió un error al guardar estado",
                                              gravity: ToastGravity.BOTTOM,
                                              toastLength: Toast.LENGTH_LONG,
                                            );
                                            Navigator.pop(context);
                                            setState(() {
                                              impreso = false;
                                            });
                                            await eliminarFotosNuevo(llavese["llave"]);
                                            datoInicial();
                                          }
                                        } else {
                                          Navigator.pop(context);
                                          setState(() {
                                            impreso = false;
                                          });
                                          await eliminarFotosNuevo(llavese["llave"]);
                                          datoInicial();
                                        }
                                      }
                                    } on TimeoutException catch (e) {
                                      ArtSweetAlert.show(
                                          barrierDismissible: false,
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.danger,
                                              title: "Error al procesar archivos: $e",
                                              confirmButtonText: "Aceptar",
                                              text: "Comuníquese con el administrador",
                                              confirmButtonColor: Colores.esquemaColor));
                                    } catch (e) {
                                      await ArtSweetAlert.show(
                                          barrierDismissible: false,
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              type: ArtSweetAlertType.danger,
                                              title: "Error al generar al acta inicial",
                                              confirmButtonText: "Aceptar",
                                              text: "Comuníquese con el administrador",
                                              confirmButtonColor: Colores.esquemaColor));
                                    }
                                  },
                                  onCancel: () {
                                    Navigator.pop(context);
                                    datoInicial();
                                  },
                                  confirmButtonColor: Colores.esquemaColor));
                        }
                      } else {
                        await ArtSweetAlert.show(
                            barrierDismissible: false,
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.danger,
                                title: "Error al generar al acta inicial",
                                confirmButtonText: "Aceptar",
                                text: "Debe seleccionar al personal del punto de venta",
                                confirmButtonColor: Colores.esquemaColor));
                        datoInicial();
                      }
                    });
                  } else {
                    if (data.isEmpty) {
                      await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                    }
                    alertaDatos(codBodega, token, true, codUsuario, nombreBodega);
                  }
                }
              } else {
                String codInventarioDet = await storage.readSecureData("codInventarioDet");
                var nombreLaboratorio = await storage.readSecureData("nombreLaboratorio");

                var consultaAjuste = await compruebaDatosAjustes(token, int.parse(codInventarioDet));
                var decodifica = jsonDecode(consultaAjuste.body);
                if (decodifica["msg"] == "ok") {
                  await Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContextcontext) =>
                              ReporteAjuste(response: consultaAjuste.body, nombreLab: nombreLaboratorio, codInventarioDet: codInventarioDet)),
                      (Route<dynamic> route) => false);
                } else {
                  await ArtSweetAlert.show(
                      barrierDismissible: false,
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                          type: ArtSweetAlertType.danger,
                          title: "Error al comprobar ajustes",
                          confirmButtonText: "Aceptar",
                          text: "Comuníquese con el administrador",
                          confirmButtonColor: Colores.esquemaColor));
                  datoInicial();
                }
              }
            }
          }
        } else if (pasarInforme.isNotEmpty && cobrado.isEmpty) {
          await Navigator.of(context)
              .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const InformeInventario()), (Route<dynamic> route) => false);
        } else {
          await Navigator.of(context)
              .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const CobroDependiente()), (Route<dynamic> route) => false);
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
  }

  Future<bool> alertaDatos(String codBodega, String token, bool result, String codUsuario, String nombreBodega) async {
    String codigoInv = await storage.readSecureData("codInventario") ?? "";
    String codigoInvDet = await storage.readSecureData("codInventarioDet") ?? "";
    var verificarTransferencias = await comprobarTransferencias(int.parse(codBodega), token, "comprobar_transferencias");

    //print(jsonDecode(verificarTransferencias.body));

    if (jsonDecode(verificarTransferencias.body)["msg"] == "ok") {
      var decodificado = jsonDecode(verificarTransferencias.body);

      String dateString = decodificado["data"][0]["Fecha"];
      DateTime? dateTime;
      try {
        dateTime = DateTime.parse(dateString);
      } catch (e) {}

      if (dateTime != null && result) {
        await initializeDateFormatting('es_ES', null);
        final DateFormat formatter = DateFormat.yMMMMEEEEd('es_ES');
        String formatted = formatter.format(dateTime);

        ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Transferencia en proceso",
                onConfirm: () async {
                  partefinal(codBodega, codUsuario, codigoInvDet, codigoInv, nombreBodega);
                  Navigator.pop(context);
                },
                confirmButtonText: "Aceptar",
                text:
                    "La farmacia tiene una transferencia pendiente, Descripción: ${decodificado["data"][0]["Observacion"]}, con fecha de: $formatted, por un valor de: \$${decodificado["data"][0]["Total"].toString()}",
                confirmButtonColor: Colores.esquemaColor));
      }
    } else {
      partefinal(codBodega, codUsuario, codigoInvDet, codigoInv, nombreBodega);
    }
    return true;
  }

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> partefinal(String codBodega, String codUsuario, String codigoInvDet, String codigoInv, String nombreBodega) async {
    var datos = await obtenerFarmaciasLaboratorios(
        int.parse(codUsuario), int.parse(codBodega), token, "obtener_laboratorios_inventario", int.parse(codigoInv));

    if (jsonDecode(datos.body)["msg"] != "err") {
      List<Map<String, dynamic>> laboratorios = (jsonDecode(datos.body)["data"] as List).map((e) => e as Map<String, dynamic>).toList();

      setState(() {
        laboratoriosInventario = laboratorios;
        valores = laboratorios;
        load = true;
      });
    } else if (codigoInvDet.isEmpty && codigoInv.isEmpty) {
      await ArtSweetAlert.show(
          barrierDismissible: false,
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.warning,
              title: "No tiene inventarios disponibles",
              confirmButtonText: "Aceptar",
              onConfirm: () async {
                await Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
              },
              confirmButtonColor: Colores.esquemaColor));
    } else {
      DateTime dateTime = DateTime.now();
      await initializeDateFormatting('es_ES', null);
      final DateFormat formatter = DateFormat("yyyy-MM-dd");
      String formatted = formatter.format(dateTime);

      var comprobarInventario = await comprobarInventarioLaboratorioPendiente(token, int.parse(codigoInv), int.parse(codBodega), formatted);

      var valorDecodificado = jsonDecode(comprobarInventario.body);

      if (valorDecodificado["msg"] == "ok" && valorDecodificado["data"] != null) {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Alerta",
                text: "No hay laboratorios para realizar, pero tiene que esperar a que finalicen el inventario de los laboratorios en proceso",
                confirmButtonText: "Aceptar",
                onConfirm: () async {
                  await Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                },
                confirmButtonColor: Colores.esquemaColor));
      } else if (valorDecodificado["msg"] == "ok" && valorDecodificado["data"] == null) {
        var comprobarAjustes = await comprobarEstadoInventario(token, int.parse(codBodega), formatted, nombreBodega);
        var decodeComprueba = jsonDecode(comprobarAjustes.body);
        if (decodeComprueba["msg"] == "ok" && decodeComprueba["respuesta"] != null) {
          await ArtSweetAlert.show(
              barrierDismissible: false,
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: "Alerta",
                  text:
                      "Por favor espere a que se realicen los ajustes correspondientes, se acaba de notificar al responsable mediante un correo automático",
                  confirmButtonText: "Aceptar",
                  onConfirm: () async {
                    await Navigator.of(context)
                        .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                  },
                  confirmButtonColor: Colores.esquemaColor));
        } else if (decodeComprueba["msg"] == "ok" && decodeComprueba["respuesta"] == null) {
          String periodo = "";
          String fechaInicio = "";
          String fechaFin = "";
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyyMM').format(now);
          periodo = formattedDate;

          // Restar dos días a la fecha actual para la fecha de inicio
          DateTime inicio = now.subtract(const Duration(days: 2));
          String formattedInicio = DateFormat("yyyy-MM-dd").format(inicio);
          fechaInicio = formattedInicio;

          String formattedFinal = DateFormat("yyyy-MM-dd").format(now);
          fechaFin = formattedFinal;
          var comprobacion = await comprobarActaDisponible2(token, periodo, int.parse(codBodega), nombreBodega);
          var valordeco = jsonDecode(comprobacion.body);

          if (valordeco["respuesta"] != null && valordeco["respuesta"][0]["Valor"] < 0) {
            await ArtSweetAlert.show(
                barrierDismissible: false,
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.warning,
                    title: "Alerta",
                    text:
                        "Por favor espere a que se realicen los cobros correspondientes, se acaba de notificar al responsable mediante un correo automático",
                    confirmButtonText: "Aceptar",
                    onConfirm: () async {
                      await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                    },
                    confirmButtonColor: Colores.esquemaColor));
          } else if (valordeco["msg"] != "err" && valordeco["respuesta"][0]["Valor"] >= 0) {
            actaFinal(codUsuario, codBodega, token);
          } else {
            var compruebaCobro = await compruebaCobros(token, periodo, int.parse(codBodega), fechaInicio, fechaFin);
            var cobroDecode = await jsonDecode(compruebaCobro.body);
            String codInventarios = await storage.readSecureData("codInventario");
            var data = await fetchData2(codUsuario, codBodega, token, codInventarios);

            if (data.isNotEmpty && impresoActa) {
              double numero = (cobroDecode["respuesta"][0]["totalCobro"] ?? 0.0).toDouble();
              String numeroFormateado = numero.toStringAsFixed(2); // Formatea a dos decimales

              Fluttertoast.showToast(
                backgroundColor: Colors.green,
                textColor: Colors.white,
                msg: "Generando acta conciliatoria, por favor espere...",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_LONG,
              );
              List<Dato> prueba = await facturaDependienteActaConciliacion(data, token, int.parse(codBodega), int.parse(codigoInv));

              fact.PdfCreator pdfcreator2 = fact.PdfCreator();
              bool valores = await pdfcreator2.crearPdfFactura(prueba); // Asumiendo que crearPdfFactura() acepta un parámetro

              /****************ACTA DE CONCILIACION DEINVENTARIO******** */
              var equipo = data['equipo'];
              var personal = data['personal'];

              String enLetras = SpellingNumber(lang: 'es').convert(numero.floor());

              // Convertir la parte decimal del número a texto
              int parteDecimal = ((numero - numero.floor()) * 100).round();
              String centavos = SpellingNumber(lang: 'es').convert(parteDecimal);

              // Construir la cadena final
              enLetras = capitalize(enLetras);
              String resultado = '$enLetras dólares con $centavos centavos dólares americanos';

              List<SignatureEntity> combinedListPersonal = [...personal];
              List<SignatureEntity> combinedListEquipo = [...equipo];
              PdfCreator pdfcreator = PdfCreator();
              String mes = DateFormat('MMMM', 'es_ES').format(now); // 'MMMM' para el nombre completo del mes
              String dia = DateFormat('d').format(now); // 'd' para el día del mes
              String anio = DateFormat('y').format(now); // 'y' para el año
              int codbodegaNuevo = int.parse(codBodega) < 17 ? int.parse(codBodega) - 1 : int.parse(codBodega);
              String farmacia = codbodegaNuevo.toString();
              List<dynamic> personalStrings = personal.map((p) => "${p.nombre} con C.C: ${p.cedula}").toList();

              // Paso 2: Une la lista con ', ' como separador.
              String allPersonal = personalStrings.join(', ');
              String content =
                  '''En la ciudad de ${personal[0].ciudad}. a los $dia día(s) del mes de $mes del $anio, en cumplimiento del Procedimiento Control de Inventario en Puntos de Venta PRO-INV-001, de la Sociedad Civil de Hecho Denominada Grupo Uscocovich, "Farmacias San Gregorio", ubicada en el KM 4 ½ vía Portoviejo Manta, en conjunto de los trabajadores del Punto de venta Nro. $farmacia, a los colaborador(es): CON C.C: , con el cargo de Auxiliar de mostrador se analizaron las novedades encontradas, las cuales concluyen en:
     
  1.  Los trabajadores con el cargo de Auxiliares de Mostrador reconocen haberse encontrado presentes durante el todo el proceso de desarrollo y elaboración del conteo de Inventario a la farmacia Nro.$farmacia, en la ciudad de ${personal[0].ciudad}, en la que se ha detectado un faltante de mercadería por $numeroFormateado, valor en letras: $resultado.

  2.	Los valores antes mencionados serán cancelados por descuento vía rol de pagos o mediante descuento de su liquidación al término de su relación de laboral con la Sociedad Civil de Hecho Denominada Grupo Uscocovich, "Farmacias San Gregorio", esto en atención al artículo 58 del reglamento interno de trabajo.

  3.	Las partes intervinientes son consecuentes y bajo su propia responsabilidad acceden al acuerdo de pago de los valores antes detallados, también reconocen la falta de gestión y control en sus funciones para las cuales fueron contratados para la idónea administración del punto de venta, que son considerados un acto negligente de su parte; la Sociedad Civil de Hecho Denominada Grupo Uscocovich, "Farmacias San Gregorio", se reserva el derecho de iniciar acciones disciplinarias, administrativas o judiciales conforme al resultado del presente inventario.

Para constancia y aceptación de lo expresado en este documento, previa lectura firma todas las partes intervinientes en el proceso de toma física de inventario, dejando en constancia que lo expuesto anteriormente goza de total veracidad.''';
              content = content.replaceFirst('CON C.C:', allPersonal);

              Uint8List valor = await pdfcreator.crearPdf("ACTA CONCILIATORIA DE INVENTARIO", "F02-PRO-INV-001", content,
                  firmaGrupo: "Representante del equipo de Auxiliares de Inventario:",
                  firmaDep: "Consentimiento mediante firmas del personal de farmacia:",
                  personal: combinedListPersonal,
                  equipo: combinedListEquipo);

              if (valor.isEmpty) {
                datoInicial();
              } else {
                await ArtSweetAlert.show(
                    barrierDismissible: false,
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.warning,
                        title: "Acta conciliatoria",
                        text: "Por favor confirme si imprimió o guardó correctamente el acta conciliatoria",
                        confirmButtonText: "Aceptar",
                        showCancelBtn: true,
                        cancelButtonText: "Cancelar",
                        onConfirm: () async {
                          Fluttertoast.showToast(
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            msg: "Procesando, espere un momento por favor...",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_LONG,
                          );
                          try {
                            var prueba = await enviarPdf(valor, "inventarios-actas-conciliatoria");
                            if (prueba.statusCode != 200) {
                              Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                msg: "Ocurrió un error al procesar el archivo",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG,
                              );
                              Navigator.pop(context);
                              setState(() {
                                impreso = false;
                              });
                              datoInicial();
                            } else {
                              var data = await prueba.stream.bytesToString();
                              var decode = await jsonDecode(data);
                              String llaves = decode["llave"][0];
                              Map<String, dynamic> llavese = await jsonDecode(data);
                              if (llaves.isNotEmpty) {
                                var envio =
                                    await cambiaEstado(token, "actualiza_estado_acta_conciliacion", int.parse(codBodega), codigoInventario, llaves);

                                var decodi = await jsonDecode(envio.body);
                                if (decodi["msg"] != "err") {
                                  Navigator.pop(context);
                                  datoInicial();
                                } else {
                                  Fluttertoast.showToast(
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    msg: "Ocurrió un error al guardar estado",
                                    gravity: ToastGravity.BOTTOM,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  Navigator.pop(context);
                                  await eliminarFotosNuevo(llavese["llave"]);
                                  datoInicial();
                                }
                              } else {
                                Navigator.pop(context);
                                await eliminarFotosNuevo(llavese["llave"]);
                                datoInicial();
                              }
                            }
                          } on TimeoutException catch (e) {
                            ArtSweetAlert.show(
                                barrierDismissible: false,
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.danger,
                                    title: "Error al procesar los archivos: $e",
                                    confirmButtonText: "Aceptar",
                                    text: "Comuníquese con el administrador",
                                    confirmButtonColor: Colores.esquemaColor));
                          } catch (e) {
                            await ArtSweetAlert.show(
                                barrierDismissible: false,
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.danger,
                                    title: "Error al generar al acta conciliatoria",
                                    confirmButtonText: "Aceptar",
                                    text: "Comuníquese con el administrador",
                                    confirmButtonColor: Colores.esquemaColor));
                          }
                        },
                        onCancel: () {
                          Navigator.pop(context);
                          datoInicial();
                        },
                        confirmButtonColor: Colores.esquemaColor));
              }
            } else {
              actaFinal(codUsuario, codBodega, token);
            }
          }
        }
      }
    }
  }

  Future<Map<String, dynamic>> fetchData(String codUsuario, String codBodega, String token, String codInventarios, String metodo) async {
    try {
      setState(() {
        codigoInventario = int.parse(codInventarios);
      });
      var obtenerGrupos = await obtenerGrupo(token, int.parse(codInventarios));

      if (obtenerGrupos == null || !obtenerGrupos.body.contains("msg")) {
        throw Exception('Error obteniendo grupos.');
      }

      var gruposDecode = jsonDecode(obtenerGrupos.body);

      var reporte = await obtenerReporteInicial(token, int.parse(codBodega), int.parse(codInventarios), metodo);

      if (reporte == null || !reporte.body.contains("msg")) {
        throw Exception('Error obteniendo reporte inicial.');
      }

      var reporteDecode = jsonDecode(reporte.body);
      totalInventario = (reporteDecode["data2"][0]["TOTAL_PVPX"] as num).toDouble();

      var obtenerData = await obtenerPersonalBodega(token, int.parse(codBodega));
      if (obtenerData == null || !obtenerData.body.contains("msg")) {
        throw Exception('Error obteniendo datos personales.');
      }

      var dataDecode = jsonDecode(obtenerData.body);

      var obtenerImpresion = await obtenerEstadoImpresora(token, int.parse(codInventarios), "obtener_estado_impresion");

      if (jsonDecode(obtenerImpresion.body)["msg"] == "ok") {
        setState(() {
          impreso = true;
        });
      }

      if (dataDecode["msg"] == "ok" && gruposDecode["msg"] == "ok" && reporteDecode["msg"] == "ok") {
        return {
          'equipo': parseEquipo(obtenerGrupos.body),
          'personal': parsePersonal(obtenerData.body),
          'reportItems': parseReporteInicial(reporte.body),
        };
      } else {
        throw Exception('Error al generar el acta inicial.');
      }
    } catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Erroreeeeee $e",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
      return {}; // Retorna un objeto vacío en caso de error
    }
  }

  Future<Map<String, dynamic>> fetchData2(String codUsuario, String codBodega, String token, String codInventarios) async {
    try {
      // Llamada a obtenerFarmaciasLaboratorios

      setState(() {
        codigoInventario = int.parse(codInventarios);
      });
      var obtenerGrupos = await obtenerGrupo(token, int.parse(codInventarios));
      if (obtenerGrupos == null || !obtenerGrupos.body.contains("msg")) {
        throw Exception('Error obteniendo grupos.');
      }

      var gruposDecode = jsonDecode(obtenerGrupos.body);

      var obtenerData = await obtenerPersonalBodegaNuevo(token, int.parse(codInventarios));
      if (obtenerData == null || !obtenerData.body.contains("msg")) {
        throw Exception('Error obteniendo datos personales.');
      }

      var dataDecode = jsonDecode(obtenerData.body);

      var obtenerImpresion = await obtenerEstadoImpresora(token, int.parse(codInventarios), "obtener_estado_impresion_acta");

      if (jsonDecode(obtenerImpresion.body)["msg"] == "ok") {
        setState(() {
          impresoActa = true;
        });
      }

      if (dataDecode["msg"] == "ok" && gruposDecode["msg"] == "ok" /*&& reporteDecode["msg"] == "ok"*/) {
        return {
          'equipo': parseEquipo(obtenerGrupos.body),
          'personal': parsePersonal(obtenerData.body),
          // 'reportItems': parseReporteInicial(reporte.body),
        };
      } else {
        throw Exception('Algunos datos no tienen el formato esperado.');
      }
    } catch (e) {
      print(e);
      // print('Error: $e');
      return {}; // Retorna un objeto vacío en caso de error
    }
  }

  void limpiarvariables() {
    setState(() {
      impreso = false;
      impresoActa = false;
      impresoFin = false;
    });
  }

  Future<Map<String, dynamic>> fetchData3(String codUsuario, String codBodega, String token, String codInventarios, String metodo) async {
    try {
      setState(() {
        codigoInventario = int.parse(codInventarios);
      });

      var obtenerGrupos = await obtenerGrupo(token, int.parse(codInventarios));
      if (obtenerGrupos == null || !obtenerGrupos.body.contains("msg")) {
        throw Exception('Error obteniendo grupos.');
      }

      var gruposDecode = jsonDecode(obtenerGrupos.body);

      var reporte = await obtenerReporteInicial(token, int.parse(codBodega), int.parse(codInventarios), metodo);
      if (reporte == null || !reporte.body.contains("msg")) {
        throw Exception('Error obteniendo reporte inicial.');
      }
      var reporteDecode = jsonDecode(reporte.body);

      totalInventario = (reporteDecode["data2"][0]["TOTAL_PVPX"] as num).toDouble();
      var obtenerData = await obtenerPersonalBodegaNuevo(token, int.parse(codInventarios));
      if (obtenerData == null || !obtenerData.body.contains("msg")) {
        throw Exception('Error obteniendo datos personales.');
      }

      var dataDecode = jsonDecode(obtenerData.body);

      var obtenerImpresion = await obtenerEstadoImpresora(token, int.parse(codInventarios), "obtener_estado_impresion_actafinal");

      if (jsonDecode(obtenerImpresion.body)["msg"] == "ok") {
        setState(() {
          impresoFin = true;
        });
      }

      if (dataDecode["msg"] == "ok" && gruposDecode["msg"] == "ok" && reporteDecode["msg"] == "ok") {
        return {
          'equipo': parseEquipo(obtenerGrupos.body),
          'personal': parsePersonal(obtenerData.body),
          'reportItems': parseReporteInicial(reporte.body),
        };
      } else {
        throw Exception('Algunos datos no tienen el formato esperado.');
      }
    } catch (e) {
      // print('Error: $e');
      return {}; // Retorna un objeto vacío en caso de error
    }
  }

  Future<void> actaFinal(String codUsuario, String codBodega, String token) async {
    String codInventarios = await storage.readSecureData("codInventario");
    String metodo = await storage.readSecureData("metodo");
    var datas = await fetchData3(codUsuario, codBodega, token, codInventarios, metodo);
    if (datas.isNotEmpty && impresoFin) {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: "Generando acta de entrega de inventario, por favor espere...",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
      var equipos = datas['equipo'];
      var personals = datas['personal'];
      /*   for (var a in personal) {
            print(a);
          }*/

      var reportItemsz = datas['reportItems'];
      List<SignatureEntity> combinedListPersonals = [...personals];
      List<SignatureEntity> combinedListEquipos = [...equipos];
      PdfCreator pdfcreator = PdfCreator();
      DateTime nows = DateTime.now();
      String mess = DateFormat('MMMM', 'es_ES').format(nows); // 'MMMM' para el nombre completo del mes
      String dias = DateFormat('d').format(nows); // 'd' para el día del mes
      String anios = DateFormat('y').format(nows); // 'y' para el año
      int codbodegaNuevo = int.parse(codBodega) < 17 ? int.parse(codBodega) - 1 : int.parse(codBodega);
      String farmacia = codbodegaNuevo.toString();
      // Paso 1: Genera la lista de cadenas con nombres y cédulas.
      List<dynamic> personalStrings = personals.map((p) => "${p.nombre} con C.C: ${p.cedula}").toList();

      String allPersonal = personalStrings.join(', ');
      String content =
          '''En la ciudad de ${personals[0].ciudad}. a los $dias día(s) del mes de $mess del $anios, en cumplimiento del Procedimiento Control de Inventario en Puntos de Venta PRO-INV-001, de la Sociedad Civil de Hecho Denominada Grupo Uscocovich, "Farmacias San Gregorio", respaldado en su reglamento interno de trabajo, se procede a entregar la totalidad del inventario del punto de venta Nro. $farmacia., para su respectivo control y custodia de activos, para ello se citan a los colaboradores(oras):  CON C.C:  ,como responsables directos, quienes cosienten la recepción del punto de venta.   
     
Todo esto enmarcado en lo dispuesto en el Reglamento Interno de Trabajo de la Sociedad Civil de Hecho Denominada Grupo Uscocovich, "Farmacias San Gregorio", se cita el Art.- 56, numeral 22. De los deberes del trabajador:

"Informar inmediatamente a sus superiores, los hechos o circunstancias que causen o puedan causar daño a la empresa..."

Se deja constancia de todas las partes, que el ejercicio y ejecución del Procedimiento Control de Inventario en Puntos de Venta PRO-INV-001, fue realizado con criterios de cumplimiento al control de activos asignados a cada punto de venta y bajo responsabilidad de cada dependiente asignado, siendo estos últimos responsables y custodios de todos los productos del punto de venta que se detallan en el anexo 1 de este documento.

Para constancia de lo anterior, se firma la presente acta por quienes en ella intervienen.''';
      content = content.replaceFirst('CON C.C:', allPersonal);
      Uint8List valor = await pdfcreator.crearPdf("ACTA DE ENTREGA DE INVENTARIO", "F01-PRO-INV-001", content,
          firmaGrupo: "Representante del equipo de Auxiliares de Inventario:",
          firmaDep: "Consentimiento mediante firmas del personal de farmacia quien(es) recibe(n) el inventario:",
          personal: combinedListPersonals,
          equipo: combinedListEquipos,
          reporte: reportItemsz,
          textoFinal: "Total del inventario final por laboratorio",
          textoFin: "Total del inventario general",
          valorTotal: totalInventario);

      if (valor.isEmpty) {
        datoInicial();
      } else {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Entrega de inventario",
                text: "Por favor confirme si imprimió o guardó correctamente el acta de entrega de inventario",
                confirmButtonText: "Aceptar",
                showCancelBtn: true,
                cancelButtonText: "Cancelar",
                onConfirm: () async {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    msg: "Procesando, espere un momento por favor...",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_LONG,
                  );
                  try {
                    var prueba = await enviarPdf(valor, "inventarios-actas-final");
                    if (prueba.statusCode != 200) {
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: "Ocurrió un error al procesar el archivo",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_LONG,
                      );
                      Navigator.pop(context);
                      setState(() {
                        impreso = false;
                      });
                      datoInicial();
                    } else {
                      var data = await prueba.stream.bytesToString();
                      var decode = await jsonDecode(data);
                      String llaves = decode["llave"][0];
                      Map<String, dynamic> llavese = await jsonDecode(data);
                      if (llaves.isNotEmpty) {
                        var envio = await cambiaEstado(token, "actualiza_estado_acta_final", int.parse(codBodega), codigoInventario, llaves);

                        var decodi = await jsonDecode(envio.body);
                        if (decodi["msg"] != "err") {
                          Navigator.pop(context);
                          datoInicial();
                        } else {
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg: "Ocurrió un error al guardar estado",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_LONG,
                          );
                          Navigator.pop(context);
                          await eliminarFotosNuevo(llavese["llave"]);
                          datoInicial();
                        }
                      } else {
                        Navigator.pop(context);
                        await eliminarFotosNuevo(llavese["llave"]);
                        datoInicial();
                      }
                    }
                  } on TimeoutException catch (e) {
                    ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Error al procesar los archivos: $e",
                            confirmButtonText: "Aceptar",
                            text: "Comuníquese con el administrador",
                            confirmButtonColor: Colores.esquemaColor));
                  } catch (e) {
                    await ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Error al generar al acta final",
                            confirmButtonText: "Aceptar",
                            text: "Comuníquese con el administrador",
                            confirmButtonColor: Colores.esquemaColor));
                  }
                },
                onCancel: () {
                  Navigator.pop(context);
                  datoInicial();
                },
                confirmButtonColor: Colores.esquemaColor));
      }
      /*bool valores = await pdfcreator.crearPdf("ACTA DE ENTREGA DE INVENTARIO", "F01-PRO-INV-001", content,
          firmaGrupo: "Representante del equipo de Auxiliares de Inventario:",
          firmaDep: "Consentimiento mediante firmas del personal de farmacia quien(es) recibe(n) el inventario:",
          personal: combinedListPersonals,
          equipo: combinedListEquipos,
          reporte: reportItemsz,
          textoFinal: "Total del inventario final por laboratorio",
          textoFin: "Total del inventario general",
          valorTotal: totalInventario);

      if (valores) {
        await ArtSweetAlert.show(
            barrierDismissible: false,
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.warning,
                title: "Entrega de inventario",
                text: "Por favor confirme si imprimió correctamente el acta de entrega de inventario",
                confirmButtonText: "Aceptar",
                showCancelBtn: true,
                cancelButtonText: "Cancelar",
                onConfirm: () async {
                  await cambiaEstado(token, "actualiza_estado_acta_final", int.parse(codBodega), codigoInventario);

                  Navigator.pop(context);
                  datoInicial();
                },
                onCancel: () {
                  Navigator.pop(context);
                  datoInicial();
                },
                confirmButtonColor: Colores.esquemaColor));
      } else {
        datoInicial();
      }*/
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => const CobroDependiente()),
      );
    }
  }
}
