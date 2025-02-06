// ignore_for_file: prefer_final_fields, use_build_context_synchronously, file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/clase.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/encuesta_sqlite.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/methods.dart';
import 'package:fsg_solutions/views/inventario/informe_inventario/clases/methods.dart';
import 'package:fsg_solutions/views/inventario/informe_inventario/providers.dart';
import 'package:hl_image_picker_android/hl_image_picker_android.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' as cp;

import '../../../complementos/globals/cargando.dart';
import '../../../complementos/logica/storage.dart';
import '../../supervisores/ReportarManimiento/media/media_preview.dart';
import 'clases/clases_informe.dart';

class InformeInventario extends ConsumerStatefulWidget {
  const InformeInventario({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InformeInventariolState();
}

class _InformeInventariolState extends ConsumerState<InformeInventario> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Esto mantiene el estado

  final PageController _pageController = PageController();
  int _currentPage = 0; // Añade un campo para rastrear la página actual
  List<Paso> pasos = []; // Inicialmente vacía
  bool cargando = false;
  SecureStorage storage = SecureStorage();
  List<Informe> informe = [];

  final dbHelper = DatabaseHelperEncuesta();
  List<Categoria> preguntas = [];

  final _picker = HLImagePickerAndroid();

  ValueNotifier<List<HLPickerItem>> _selectedImages = ValueNotifier([]);
  List<ValueItem<String>> options = [];
  final bool _isCroppingEnabled = true;
  final MediaType _type = MediaType.all;
  final bool _isExportThumbnail = true;
  final bool _includePrevSelected = false;
  final int _count = 10;
  final bool _enablePreview = false;
  final bool _usedCameraButton = true;
  final int _numberOfColumn = 3;
  final double _compressQuality = 0.8;
  CropAspectRatio? _aspectRatio;
  List<CropAspectRatioPreset>? _aspectRatioPresets;
  ValueNotifier<bool> _sugiereDesvinculacion = ValueNotifier<bool>(false);
  ValueNotifier<bool> _sugiereLlamadoAtencion = ValueNotifier<bool>(false);
  String observacionInforme = "";
  TextEditingController conclusionesInforme = TextEditingController();
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (next != _currentPage) {
        setState(() {
          _currentPage = next;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        datosIniciales(ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLoading = ref.watch(enviando);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Informe inventario"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomeFarma(),
                ),
                (route) => false,
              );
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await datosIniciales(ref);
          },
          child: Stack(
            children: <Widget>[principal(), if (isLoading) cargandoEnvio()],
          ),
        ));
  }

  Future<void> datosIniciales(WidgetRef ref) async {
    // try {

    String codInventarios = await storage.readSecureData("codInventario");
    String tokens = await storage.readSecureData("token") ?? "";
    ref.read(enviando.notifier).state = false;
    var datos = await obtenerDatosInforme(int.parse(codInventarios), tokens);
    var mensaje = jsonDecode(datos.body)["msg"];
    //print(jsonDecode(datos.body));
    if (mensaje != "err") {
      setState(() {
        informe = parsearInforme(datos.body);

        preguntas = parsearEncuesta(datos.body, false);
        ref.read(respuestasProvider.notifier).cargarPreguntas(preguntas);
        cargando = true;
        List<LabelValue> currentSelections = ref.read(seleccionProvider.notifier).state;

        List<Paso> pasosTemporales = [];
        pasosTemporales.add(Paso(titulo: "Paso 1", contenido: datosEmpresa(informe.first)));
        pasosTemporales.add(Paso(titulo: "Paso 2", contenido: datosCobrosInventario(informe.first)));
        if (informe.first.cobroCaducado.isNotEmpty) {
          pasosTemporales.add(Paso(titulo: "Paso 3", contenido: datosCobrosCaducado(informe.first.cobroCaducado)));
        }
        pasosTemporales.add(Paso(titulo: "Paso 4", contenido: desarrolloPreguntas()));
        pasosTemporales.add(Paso(titulo: "Paso 5", contenido: desarrollo(informe.first.observacion, ref, currentSelections)));
        pasosTemporales.add(Paso(titulo: "Paso 6", contenido: conclusiones(informe.first, ref)));
        pasos = pasosTemporales;
      });
    } else {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Ocurrió un error al obtener los datos para el informe",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Widget principal() {
    if (!cargando) {
      return const CircularPrimero(texto: "Cargando datos informe....");
    } else {
      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pasos.length,
              itemBuilder: (context, index) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: pasos[index].contenido),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: buildIndicator(), // Muestra el indicador de progreso aquí
          ),
        ],
      );
    }
  }

  Widget cargandoEnvio() {
    return const Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                        // <-- Puedes cambiar el color aquí
                        ),
                  ),
                  Text(
                    'Enviando informe de inventario, por favor espere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // <-- Estiliza el texto para que se ajuste
                      fontSize: 14, // <-- Cambia el tamaño de fuente según tu necesidad
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < pasos.length; i++) {
      indicators.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators,
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget datosEmpresa(Informe primerInforme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.0),
                        child: Text("Farmacia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      Text(primerInforme.farmacia, style: TextStyle(fontSize: 16)),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Text("Fecha Inicio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                Text(primerInforme.fechaInicio, style: TextStyle(fontSize: 14))
                              ],
                            ),
                            Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Text("Fecha Fin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                Text(primerInforme.fechaFin, style: TextStyle(fontSize: 14))
                              ],
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text("Coordinador de punto de venta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ...primerInforme.coordinador
                          .map(
                            (coordinador) => Text(coordinador.label, style: const TextStyle(fontSize: 16)),
                          )
                          .toList(),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.group),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Text("Dependientes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  ],
                                ),
                                ...primerInforme.dependientes
                                    .map((dependiente) => Padding(
                                          padding: const EdgeInsets.only(top: 5.0),
                                          child: Text(dependiente.label, style: const TextStyle(fontSize: 14)),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget datosCobrosInventario(Informe primerInforme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.groups),
                          Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text("Equipo de inventario",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colores.esquemaColor)),
                          ),
                        ],
                      ),
                      ...primerInforme.equipoInventario
                          .map((equipoInventario) => Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(equipoInventario.label, style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      const Divider(),
                      primerInforme.cobroInventario.isNotEmpty
                          ? const Row(
                              children: [
                                Icon(Icons.monetization_on_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 5.0),
                                  child: Text("Valores por inventario",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colores.esquemaColor)),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      primerInforme.cobroInventario.isNotEmpty
                          ? DataTable(
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Valor')),
                              ],
                              rows: primerInforme.cobroInventario
                                  .map(
                                    (item) => DataRow(
                                      cells: [
                                        DataCell(Text(item.nombresRol)),
                                        DataCell(Text(item.valor.toString())),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget datosCobrosCaducado(List<CobroCaducado> primerInforme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.monetization_on_outlined),
                          Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text(
                              "Valores por productos caducados",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Valor')),
                        ],
                        rows: primerInforme
                            .map(
                              (item) => DataRow(
                                cells: [
                                  DataCell(Text(item.nombresRol)),
                                  DataCell(Text(item.total.toString())),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget desarrollo(List<Observacion> primerInforme, WidgetRef ref, List<LabelValue> currentSelections) {
    List<ValueItem<String>> opcionesObservacion = primerInforme.map((obs) => ValueItem(label: obs.label, value: obs.value.toString())).toList();

    List<ValueItem<String>> initialSelectedItems = opcionesObservacion
        .where((item) => currentSelections.any((selected) => selected.label == item.label && selected.value == item.value))
        .toList();

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: MultiSelectDropDown(
                    hint: "Observación",
                    onOptionSelected: (options) {
                      List<LabelValue> selectedOptions = options
                          .map((item) => LabelValue(label: item.label, value: item.value!)) // Crea un nuevo LabelValue
                          .toList();
                      ref.read(seleccionProvider.notifier).state = selectedOptions;
                    },

                    options: opcionesObservacion,
                    selectedOptions: initialSelectedItems, // set initial items
                    selectionType: SelectionType.multi,
                    chipConfig: const ChipConfig(
                      wrapType: WrapType.scroll,
                      spacing: 1.0,
                      runSpacing: 1.0,
                    ),
                    dropdownHeight: 250,
                    optionTextStyle: const TextStyle(fontSize: 16),
                    selectedOptionIcon: const Icon(Icons.check_circle),
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: _body()),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), child: pruebaCamaras()),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget desarrolloPreguntas() {
    return Consumer(
      builder: (context, ref, child) {
        final preguntas = ref.watch(respuestasProvider);
        print(preguntas); // Imprime para verificar los datos recibidos
        if (preguntas.isEmpty) {
          return Text("No hay datos disponibles");
        }
        return ListView.builder(
          itemCount: preguntas.length,
          itemBuilder: (context, indexCategoria) {
            final categoria = preguntas[indexCategoria];
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  for (int i = 0; i < categoria.preguntas.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoria.preguntas[i].nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Row(
                            children: [
                              for (int j = 0; j < categoria.preguntas[i].respuestas.length; j++)
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(categoria.preguntas[i].respuestas[j].dato),
                                    value: categoria.preguntas[i].respuestas[j].seleccionada,
                                    onChanged: (bool? value) {
                                      ref.read(respuestasProvider.notifier).actualizarRespuesta(
                                            indexCategoria,
                                            i,
                                            j,
                                            value ?? false,
                                          );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget conclusiones(Informe primerInforme, WidgetRef ref) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  controller: conclusionesInforme,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    labelText: 'Conclusiones',
                  ),
                ),
                // Checkbox para Sugiere desvinculación de personal
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  // Envuelve el CheckboxListTile en un ValueListenableBuilder para _sugiereDesvinculacion
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _sugiereDesvinculacion,
                    builder: (context, value, child) {
                      return CheckboxListTile(
                        title: const Text("Sugiere desvinculación de personal"),
                        value: value,
                        onChanged: (bool? newValue) {
                          _sugiereDesvinculacion.value = newValue!;
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _sugiereLlamadoAtencion,
                    builder: (context, value, child) {
                      return CheckboxListTile(
                        title: const Text("Sugiere llamado de atención"),
                        value: value,
                        onChanged: (bool? newValue) {
                          _sugiereLlamadoAtencion.value = newValue!;
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0), // Añadido padding horizontal para el espaciado
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _selectedImages.value.isNotEmpty &&
                              conclusionesInforme.text.trim() != "" &&
                              ref.watch(respuestasProvider.notifier).areAllQuestionsAnswered() &&
                              ref.watch(seleccionProvider).isNotEmpty &&
                              !ref.watch(enviando)
                          ? () async {
                              try {
                                ref.read(enviando.notifier).state = true;
                                var prueba = await enviarFotosMantenimientos(_selectedImages.value);
                                if (prueba.statusCode != 200) {
                                  ref.read(enviando.notifier).state = false;
                                  Fluttertoast.showToast(
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    msg: "Ocurrió un error al procesar las imágenes",
                                    gravity: ToastGravity.BOTTOM,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                } else {
                                  var data = await prueba.stream.bytesToString();
                                  Map<String, dynamic> llaves = await jsonDecode(data);
                                  if (llaves.isNotEmpty) {
                                    String descriptions = ref.watch(categoryDescriptionsProvider);
                                    String primeEncuesta = await dbHelper.getFirstEncuestaInicial() ?? "";
                                    List<String> listaImagenes = List<String>.from(llaves['llave']);
                                    List<Map<String, String>> nuevaLista = listaImagenes.map((llave) => {'llave': llave}).toList();

                                    String tokens = await storage.readSecureData("token") ?? "";
                                    final selecciones = ref.watch(seleccionProvider);

                                    DateTime now = DateTime.now();
                                    DateTime justDate = DateTime(now.year, now.month, now.day);
                                    String formattedDate = DateFormat('yyyy-MM-dd 00:00:00.000').format(justDate);

                                    var envio = await enviarDatosInforme(
                                      tokens,
                                      primerInforme.fechaInicio,
                                      primerInforme.fechaFin,
                                      formattedDate,
                                      primerInforme.codBodega,
                                      primerInforme.motivos.map((e) => e.toJson()).toList(),
                                      primerInforme.coordinador.map((e) => e.toJson()).toList(),
                                      primerInforme.equipoInventario.map((e) => e.toJson()).toList(),
                                      primerInforme.dependientes.map((e) => e.toJson()).toList(),
                                      primeEncuesta + descriptions,
                                      primerInforme.liquidacionInventario,
                                      primerInforme.liquidacionMedicinaCaducada,
                                      conclusionesInforme.text.trim(),
                                      _sugiereDesvinculacion.value,
                                      _sugiereLlamadoAtencion.value,
                                      false,
                                      selecciones.map((e) => e.toJson()).toList(),
                                      primerInforme.detalleInventario.map((e) => e.toJson()).toList(),
                                      nuevaLista,
                                    );
                                    var mensaje = jsonDecode(envio.body)["msg"];

                                    if (mensaje != "err") {
                                      await storage.deleteSecureData("informepasar");
                                      if (mounted) {
                                        ref.read(enviando.notifier).state = false;
                                        if (mounted) {
                                          Future.microtask(() async {
                                            await ArtSweetAlert.show(
                                              barrierDismissible: false,
                                              context: context,
                                              artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.success,
                                                title: "Correcto",
                                                text: "Informe de inventario enviado con éxito",
                                                confirmButtonText: "Aceptar",
                                                confirmButtonColor: Colores.esquemaColor,
                                                onConfirm: () async {
                                                  await storage.deleteSecureData("informepasar");
                                                  await Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (BuildContext context) => const HomeFarma(),
                                                    ),
                                                    (route) => false,
                                                  );
                                                },
                                              ),
                                            );
                                          });
                                        }
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        msg: "Ocurrió un error: $mensaje",
                                        gravity: ToastGravity.BOTTOM,
                                        toastLength: Toast.LENGTH_LONG,
                                      );

                                      await eliminarFotosInforme(llaves["llave"]);
                                      ref.read(enviando.notifier).state = false;
                                    }
                                  }
                                }
                              } on TimeoutException catch (e) {
                                ref.read(enviando.notifier).state = false;

                                Fluttertoast.showToast(
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  msg: e.toString(),
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              } on SocketException catch (e) {
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  msg: e.toString(),
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Hace que el botón ocupe todo el ancho y tenga una altura de 50
                        // Puedes ajustar la altura según necesites
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('ENVIAR'),
                          ),
                          Icon(Icons.send, size: 24), // Ícono de enviar al lado derecho del texto
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  bool areAllQuestionsAnswered() {
    // Verifica si cada categoría ha tenido todas sus preguntas respondidas.
    return preguntas.every((categoria) => areAllAnswersSelected(categoria));
  }

  bool areAllAnswersSelected(Categoria categoria) {
    return categoria.preguntas.every((pregunta) => pregunta.respuestas.any((respuesta) => respuesta.seleccionada));
  }

  Widget _body() {
    return ValueListenableBuilder<List<HLPickerItem>>(
      valueListenable: _selectedImages,
      builder: (context, value, child) {
        // Aquí 'value' contiene el valor actual de _selectedImages.value
        if (value.isNotEmpty) {
          return _showImage();
        } else {
          return _uploaderCard();
        }
      },
    );
  }

  Widget pruebaCamaras() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        imagenCamara(),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: imagenTelefono(),
        )
      ],
    );
  }

  final categoryDescriptionsProvider = Provider<String>((ref) {
    // Accede al notifier y llama al método para obtener las descripciones
    return ref.watch(respuestasProvider.notifier).getAllCategoryDescriptions();
  });
  /* Future<String> getAllCategoryDescriptions(List<Categoria> categorias) async {
    List<String> descriptions = []; // Lista para almacenar las descripciones

    for (var categoria in categorias) {
      descriptions.add(categoria.describe()); // Añade cada descripción a la lista
    }

    // Concatena todas las descripciones en un solo string con dos saltos de línea entre cada una
    return descriptions.toString();
  }*/

  Widget _showImage() {
    if (_selectedImages.value.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [MediaPreview(items: _selectedImages.value)], // Aquí pasas la lista de imágenes seleccionadas
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget imagenCamara() {
    return Flexible(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              getImage(false);
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(160, 50),
            ),
            child: const Flex(
              direction: Axis.horizontal,
              children: [
                Text('Tomar foto'),
                SizedBox(width: 10),
                Icon(Icons.camera),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imagenTelefono() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(true);
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(160, 50),
          ),
          child: const Flex(
            direction: Axis.horizontal,
            children: [
              Text('Elejir foto'),
              SizedBox(width: 10),
              Icon(Icons.image_search),
            ],
          ),
        ),
      ],
    );
  }

  Future getImage(bool gallery) async {
    if (!gallery) {
      openCamera();
    } else {
      openPhotos();
    }
  }

  Future<void> openPhotos() async {
    try {
      final List<HLPickerItem> images = await _picker.openPicker(
        cropping: _isCroppingEnabled,
        selectedIds: _includePrevSelected ? _selectedImages.value.map((e) => e.id).toList() : null,
        pickerOptions: HLPickerOptions(
          mediaType: _type,
          enablePreview: _enablePreview,
          isExportThumbnail: _isExportThumbnail,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: _compressQuality,
          maxSelectedAssets: _count,
          usedCameraButton: _usedCameraButton,
          numberOfColumn: _numberOfColumn,
          isGif: true,
        ),
        cropOptions: HLCropOptions(
          aspectRatio: _aspectRatio,
          aspectRatioPresets: _aspectRatioPresets,
          compressQuality: _compressQuality,
          compressFormat: CompressFormat.jpg,
        ),
        localized: const LocalizedImagePicker(doneText: "Aceptar", cancelText: "Cancelar"),
      );

      List<HLPickerItem> compressedImages = [];

      for (HLPickerItem image in images) {
        File originalFile = File(image.path);
        int originalSize = await originalFile.length();
        double sizeInMb = originalSize / (1024 * 1024);

        if (sizeInMb > 2) {
          final compressedImageFile = await cp.FlutterImageCompress.compressAndGetFile(
            originalFile.absolute.path,
            originalFile.absolute.path.replaceFirst(RegExp(r'\.(jpg|jpeg|png)$'), '_compressed.jpg'),
            quality: 85, // Este valor de calidad se aplica bien para JPEG.
          );

          if (compressedImageFile != null) {
            int fileSize = await compressedImageFile.length();
            HLPickerItem compressedImage = HLPickerItem(
              path: compressedImageFile.path,
              id: image.id,
              name: image.name,
              mimeType: 'image/png', // Asumiendo que la salida es PNG después de la compresión.
              size: fileSize,
              width: image.width, // Considera actualizar si es necesario.
              height: image.height, // Considera actualizar si es necesario.
              type: image.type,
              duration: image.duration,
              thumbnail: image.thumbnail,
            );
            compressedImages.add(compressedImage);
          } else {
            compressedImages.add(image); // Añade la imagen original si la compresión falla.
          }
        } else {
          compressedImages.add(image); // Añade la imagen original si no necesita compresión.
        }
      }

      setState(() {
        _selectedImages.value = compressedImages;
      });
    } catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: e.toString(),
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> openCamera() async {
    try {
      final HLPickerItem originalImage = await _picker.openCamera(
        cropping: _isCroppingEnabled,
        cameraOptions: HLCameraOptions(
          cameraType: _type == MediaType.video ? CameraType.video : CameraType.image,
          recordVideoMaxSecond: 40,
          isExportThumbnail: _isExportThumbnail,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: _compressQuality,
        ),
      );

      File originalFile = File(originalImage.path);
      int originalSize = await originalFile.length();
      double sizeInMb = originalSize / (1024 * 1024);

      HLPickerItem finalImage = originalImage; // Inicialmente, usa la imagen original.

      if (sizeInMb > 2) {
        final compressedImageFile = await cp.FlutterImageCompress.compressAndGetFile(
          originalFile.absolute.path,
          originalFile.absolute.path.replaceFirst(RegExp(r'\.jpg$'), '_compressed.jpg'),
          quality: 85,
        );

        if (compressedImageFile != null) {
          int fileSize = await compressedImageFile.length();
          finalImage = HLPickerItem(
            path: compressedImageFile.path,
            id: originalImage.id, // Reutiliza el ID original o genera uno nuevo si es necesario.
            name: originalImage.name, // Considera actualizar el nombre si lo prefieres.
            mimeType: originalImage.mimeType,
            size: fileSize,
            width: originalImage.width, // Actualiza si es necesario.
            height: originalImage.height, // Actualiza si es necesario.
            type: originalImage.type,
            duration: originalImage.duration, // Solo para videos.
            thumbnail: originalImage.thumbnail, // Considera generar un nuevo thumbnail si es necesario.
          );
        }
      }

      // Actualiza el ValueNotifier para añadir la nueva imagen a la lista existente.
      _selectedImages.value = List.from(_selectedImages.value)..add(finalImage);
    } catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: e.toString(),
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Widget _uploaderCard() {
    return DottedBorder(
      radius: const Radius.circular(12.0),
      borderType: BorderType.RRect,
      dashPattern: const [8, 4],
      color: Theme.of(context).highlightColor.withOpacity(0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              color: Theme.of(context).highlightColor,
              size: 80.0,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Subir una imagen',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).highlightColor),
            )
          ],
        ),
      ),
    );
  }
}
