import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/claseInventarioEspecial.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/descripcionProductoReconteo.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/inventarioEspeciales/providers.dart';

import '../../../../complementos/logica/storage.dart';
import '../laboratorios.dart';
import '../logica_inventario_general.dart';
import 'methodEspeciales.dart';

class ReconteoPrueba extends ConsumerStatefulWidget {
  final int codLaboratorio;
  final String laboratorio;
  const ReconteoPrueba({super.key, required this.codLaboratorio, required this.laboratorio});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReconteoPruebaState();
}

class _ReconteoPruebaState extends ConsumerState<ReconteoPrueba> {
  late List<bool> _isExpanded; // Asegurándonos de que sea una lista de booleanos.
  String token = "";
  bool load = false;
  late String codBodega;
  late String codInventario;

  bool enviando = false;
  SecureStorage storage = SecureStorage();

  List<InventarioEspecialClass> producto = [];
  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  Future<void> datosIniciales() async {
    try {
      token = await storage.readSecureData("token") ?? "";
      codBodega = await storage.readSecureData("codBodega") ?? "";
      codInventario = await storage.readSecureData("codInventario") ?? "";

      var codUsuario = await storage.readSecureData("cod_usuario");
      var compruebaProductoPendienteReconteos = await compruebaProductoPendienteReconteo(token, int.parse(codInventario), int.parse(codUsuario));
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
        producto.clear();
        var datos = await obtenerOrdenesDatosReconteoLaboratorio(token, int.parse(codBodega), int.parse(codInventario), widget.codLaboratorio);
        var decodifi = jsonDecode(datos.body);
        if (decodifi["msg"] != "err") {
          var valor = parseProductoReconteo(datos.body);
          setState(() {
            producto = valor;
            _isExpanded = List.filled(producto.length, false);
          });
          ref.watch(loadReconteo.notifier).state = true;
        } else {
          Fluttertoast.showToast(
            msg: "Ocurrió un error al obtener los datos: ${decodifi["msg"]}",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          ref.watch(loadReconteo.notifier).state = false;
          producto = [];
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Ocurrió un error: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      ref.watch(loadReconteo.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    load = ref.watch(loadReconteo);

    enviando = ref.watch(enviandoProductoReconteoPrincipal);
    return RefreshIndicator(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.laboratorio,
            style: const TextStyle(fontSize: 15.0),
          ),
          leading: IconButton(
              onPressed: () async {
                await Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (BuildContext context) => const LabotarotiosInventario()), (Route<dynamic> route) => false);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: !load
            ? circularPrimero()
            : CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return card(producto[index], index);
                      },
                      childCount: producto.length,
                    ),
                  ),
                ],
              ),
      ),
      onRefresh: () async {
        ref.watch(loadReconteo.notifier).state = false;
        datosIniciales();
      },
    );
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

  Widget card(InventarioEspecialClass producto, int index) {
    return Card(
      color: producto.codUsuario == 0 ? Colors.white : Colors.green.shade200,
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded[index] = !_isExpanded[index];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Envuelve tu Columna en un widget Expanded
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isExpanded[index] ? MediaQuery.of(context).size.width * 0.65 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        producto.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colores.esquemaColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text("Stock inicial: ${producto.unidad}F${producto.fraccion} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text("Stock encontrado: ${producto.cajasEscaneadas}F${producto.fraccionesEscaneadas}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      //Text("Fracciones encontradas: ${producto.fraccionesEscaneadas}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (producto.cantRealFinal > 0)
                        Text("Stock reconteo: ${producto.cantRealFinal}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              if (_isExpanded[index]) ...[
                // Estos iconos aparecen cuando _isExpanded[index] es true
                AnimatedOpacity(
                  opacity: _isExpanded[index] ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        iconSize: 40,
                        color: Colores.esquemaColor,
                        icon: const Icon(
                          Icons.note_alt,
                        ),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) => DescripcionProductosReconteo(
                                      cadNovedad: producto.cadNovedad,
                                      codProducto: producto.codProducto,
                                      codInventario: int.parse(codInventario),
                                      laboratorio: widget.codLaboratorio,
                                      nombreLaboratorio: widget.laboratorio,
                                      token: token,
                                    )),
                          );
                        },
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        iconSize: 40,
                        color: !enviando && producto.codUsuario == 0 ? Colores.esquemaColor : Colors.grey,
                        icon: const Icon(
                          Icons.check_circle_outline,
                        ),
                        onPressed: producto.codUsuario == 0
                            ? () async {
                                await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "¿Está seguro de confirmar el stock encontrado?",
                                        text: "Si acepta dará por finalizado el reconteo de este producto",
                                        confirmButtonText: "Aceptar",
                                        onCancel: () {
                                          Navigator.of(context).pop();
                                        },
                                        onConfirm: () async {
                                          var codUsuario = await storage.readSecureData("cod_usuario");
                                          Navigator.of(context).pop();
                                          try {
                                            ref.watch(enviandoProductoReconteoPrincipal.notifier).state = true;
                                            double cantReal =
                                                (producto.cajasEscaneadas + (producto.fraccionesEscaneadas / producto.fracciondv)).toDouble();

                                            var envio = await enviarDatosProductosReconteo(token, producto.cadNovedad, int.parse(codInventario),
                                                int.parse(codUsuario), cantReal, producto.cajasEscaneadas, producto.fraccionesEscaneadas);
                                            var decodeEnvio = jsonDecode(envio.body);
                    
                                            if (decodeEnvio["msg"] != 'err') {
                                              Fluttertoast.showToast(
                                                msg: "Datos guardados con éxito",
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                              );
                                              ref.watch(enviandoProductoReconteoPrincipal.notifier).state = false;
                                              ref.watch(loadReconteo.notifier).state = false;
                                              datosIniciales();
                                            } else {
                                              ref.watch(enviandoProductoReconteoPrincipal.notifier).state = false;
                                              Fluttertoast.showToast(
                                                msg: "Ocurrió un error al guardar ${decodeEnvio["msg"]}",
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                              );
                                            }
                                          } catch (e) {
                                            ref.watch(enviandoProductoReconteoPrincipal.notifier).state = false;
                                            Fluttertoast.showToast(
                                              msg: "Ocurrió un error al guardar $e",
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                          }
                                        },
                                        showCancelBtn: true,
                                        cancelButtonText: "Cancelar",
                                        cancelButtonColor: Colors.grey,
                                        confirmButtonColor: Colores.esquemaColor));
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
