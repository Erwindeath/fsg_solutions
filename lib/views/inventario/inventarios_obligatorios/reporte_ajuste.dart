// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/database/inventario_sqlite.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/laboratorios.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/methods.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ReporteAjuste extends StatefulWidget {
  final String response;
  final String nombreLab;
  final String codInventarioDet;
  const ReporteAjuste({required this.response, required this.nombreLab, required this.codInventarioDet, Key? key}) : super(key: key);

  @override
  State<ReporteAjuste> createState() => _ReporteAjusteState();
}

class _ReporteAjusteState extends State<ReporteAjuste> {
  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  List<ProductosAjustados> produstosAjuste = [];
  List<ProductosAjustados> originalList = [];

  bool isSearching = false;
  final searchController = TextEditingController();
  SecureStorage storage = SecureStorage();
  File? imagenBarra;
  double cardWidth = 0.0;
  final dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    // 25% del ancho de la pantalla

    return Scaffold(
        appBar: AppBar(
          title: isSearching
              ? TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: TextStyle(color: Colors.white), // Cambia el color del texto de sugerencia
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      // Cambia el color del borde cuando el TextField está enfocado
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (value) {
                    filterSearchResults(value);

                    // Aquí puedes implementar el filtrado de tu lista en función del valor introducido
                  },
                )
              : Text('Stock-${widget.nombreLab}'),
          leading: IconButton(
              onPressed: () {
                if (isSearching) {
                  setState(() {
                    isSearching = false;
                    produstosAjuste = List.from(originalList);
                    searchController.clear();
                  });
                } else {
                  Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
                }
              },
              icon: Icon(isSearching ? Icons.close : Icons.arrow_back)),
          actions: [
            if (!isSearching)
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (isSearching) {
                        searchController.clear();
                        produstosAjuste = List.from(originalList);
                        isSearching = false;
                      } else {
                        isSearching = true;
                      }
                    });
                  },
                  icon: const Icon(Icons.search_rounded)),
            IconButton(
                onPressed: () async {
                  // await generarImagen("00a${widget.codInventarioDet}");
                  await generarImagen(widget.codInventarioDet);
                  await ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                          title: "Escanee el codigo de barras, o ingrese este número:(${widget.codInventarioDet})",
                          confirmButtonColor: Colores.esquemaColor,
                          customColumns: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: Image.file(
                                imagenBarra!,
                              ),
                            )
                          ]));
                  // Acción del ícono a la derecha
                },
                icon: const Icon(Icons.print_rounded) // Puedes cambiar este ícono por cualquier otro
                )
          ],
        ),
        body: datos(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await ArtSweetAlert.show(
                barrierDismissible: false,
                context: context,
                artDialogArgs: ArtDialogArgs(
                    type: ArtSweetAlertType.warning,
                    title: "¿Está seguro de finalizar?",
                    confirmButtonText: "Aceptar",
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () async {
                      await limpiarData();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (BuildContext context) => const LabotarotiosInventario()), (Route<dynamic> route) => false);
                    },
                    showCancelBtn: true,
                    cancelButtonText: "Cancelar",
                    cancelButtonColor: Colors.grey,
                    text: "Una vez finalizado este laboratorio no lo prodrá volver a visualizar esta data",
                    confirmButtonColor: Colores.esquemaColor));
          },
          label: const Text("Finalizar"),
        ));
  }

  Widget datos() {
    if (produstosAjuste.isEmpty) {
      return const Center(child: Text("Sin novedades"));
    }
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              ProductosAjustados producto = produstosAjuste[index];
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(producto.descripcion),
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //  const SizedBox(height: 5),
                            SizedBox(
                              width: cardWidth,
                              height: 80, // Puedes ajustar este valor según tus necesidades
                              child: Card(
                                elevation: 2,
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Icon(
                                    Icons.store,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text("Actual"),
                                  Text('${producto.unidad}F${producto.fraccion}'),
                                ]),
                              ),
                            ),
                            //const SizedBox(width: 10),
                            SizedBox(
                              width: cardWidth,
                              height: 80, // Ajusta este valor según tus necesidades
                              child: Card(
                                elevation: 2,
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.edit_document,
                                      size: 30, color: producto.stockActual > producto.stockEncontrado ? Colors.red : Colors.yellow),
                                  const SizedBox(width: 5),
                                  const Text("Ingresado"),
                                  Text('${producto.cajasBuenas}F${producto.fraccionesBuenas}'),
                                ]),
                              ),
                            ),
                            //const SizedBox(width: 10),
                            SizedBox(
                              width: cardWidth,
                              height: 80, // Ajusta este valor según tus necesidades
                              child: Card(
                                elevation: 2,
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Icon(FontAwesomeIcons.circleExclamation, size: 27, color: Colors.orange),
                                  const SizedBox(width: 5),
                                  const Text("Caducado"),
                                  producto.cajasCaducadas > 0 || producto.fraccionesCaducadas > 0
                                      ? Text(' ${producto.cajasCaducadas}F${producto.fraccionesCaducadas}')
                                      : const Icon(Icons.edit_off_outlined) // Reemplaza "some_icon" y "some_color" con el ícono y color que desees
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: produstosAjuste.length,
          ),
        )
      ],
    );
  }

  Future<void> limpiarData() async {
    await storage.deleteSecureData("validaajuste");
    await storage.deleteSecureData("codLaboratorio");
    await storage.deleteSecureData("codInventarioDet");
    await storage.deleteSecureData("nombreLaboratorio");
    await dbHelper.deleteTable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cardWidth = MediaQuery.of(context).size.width * 0.28;
    //datosIniciales();
  }

  Future<void> datosIniciales() async {
    setState(() {
      produstosAjuste = parsearProductosAjustados(widget.response);
      originalList = List.from(produstosAjuste);
      //cardWidth = MediaQuery.of(context).size.width * 0.28;
    });
  }

  Future<void> filterSearchResults(String query) async {
    List<ProductosAjustados> searchResults = [];
    if (query.isNotEmpty) {
      for (var item in originalList) {
        if (item.descripcion.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(item);
        }
      }
      setState(() {
        produstosAjuste = searchResults;
      });
    } else {
      setState(() {
        produstosAjuste = List.from(originalList);
      });
    }
  }

  Future<void> generarImagen(String datos) async {
    final image = img.Image(width: 400, height: 200);
    img.fill(image, color: img.ColorRgba8(255, 255, 255, 0));

    drawBarcode(image, Barcode.codabar(), datos);
    final png = img.encodePng(image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/barcode.jpg';
    final file = await File(filePath).writeAsBytes(png);
    setState(() {
      imagenBarra = file;
    });
  }
}
