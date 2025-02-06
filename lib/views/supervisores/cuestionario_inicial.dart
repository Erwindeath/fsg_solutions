// ignore_for_file: import_of_legacy_library_into_null_safe, use_build_context_synchronously, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fsg_solutions/complementos/globals/api_routes.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/cuestionario/logica_cuestionario.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_user/home_user.dart';
import 'package:fsg_solutions/views/supervisores/providers.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CuestionarioInicial extends ConsumerStatefulWidget {
  const CuestionarioInicial({Key? key}) : super(key: key);

  @override
  ConsumerState<CuestionarioInicial> createState() => _CuestionarioInicialState();
}

class _CuestionarioInicialState extends ConsumerState<CuestionarioInicial> {
  bool cargando = false; // Variable para controlar la carga de datos
  double tamanoTitulo = 18.0; // Tamaño del título
  final SecureStorage _storage = SecureStorage();
  double tamanoDescripcion = 15.0; // Tamaño de la descripción
  List<dynamic> cuestionario = []; // Lista de preguntas del cuestionario
  bool respuesta1 = false; // Respuesta seleccionada 1
  bool respuesta2 = false; // Respuesta seleccionada 2
  //Map<String, bool> respuestas = {}; // Mapa de respuestas seleccionadas
  int indice = 0;
  TextEditingController textoOpcional = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Cuestionario inicial")),
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.save))],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          dataInicial();
        },
        child: datos(), // Widget que muestra los datos del cuestionario
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    dataInicial(); // Cargar los datos iniciales del cuestionario
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Función para obtener los datos iniciales del cuestionario desde el servidor
  Future<void> dataInicial() async {
    // await DatabaseHelper.instance.limpiarRespuestas();
    try {
      var token = await _storage.readSecureData("token");
      var response = await cuestionarioInicial(token, 10, ApiRoutes.obtenerCuestionarios);

      // Verificar si la respuesta del servidor no es un error
      if (jsonDecode(response.body)["msg"] != "err") {
        var jsonResponse = jsonDecode(response.body);
        var resultado = jsonResponse["data"][0]["resultado"];
        var cuestionarios = jsonDecode(resultado);

        setState(() {
          cuestionario = cuestionarios;
          cargando = true;
          // Actualizar la lista de preguntas del cuestionario
          // Establecer la variable cargando en true
        });
        // verificarRespuestasCompletas(cuestionario);
      }
    } on TimeoutException catch (e) {
      // Mostrar un mensaje de error si ocurre un tiempo de espera en la solicitud
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

  final Map<String, IconData> categoriaIconos = {
    'VENTAS': FontAwesomeIcons.chartBar,
    'CAJA': FontAwesomeIcons.moneyCheckDollar,
    'ATENCIÓN AL CLIENTE': FontAwesomeIcons.users,
    'DIRECCIÓN TÉCNICA': FontAwesomeIcons.gears,
    'INVENTARIOS': FontAwesomeIcons.clipboardCheck,
    'HORARIOS': FontAwesomeIcons.calendarCheck,
    'LIMPIEZA': FontAwesomeIcons.trash,
    'MARKETING': MdiIcons.star,
    'OPERACIONES': MdiIcons.briefcase,
    'VESTIMENTA': FontAwesomeIcons.peopleGroup
    // Agrega los demás nombres de categoría y sus respectivos íconos aquí
  };

  Widget datos() {
    if (!cargando) {
      return circularPrimero(); // Mostrar un indicador de carga si los datos no están disponibles
    } else {
      return _buildNotificaciones(cuestionario); // Mostrar los datos del cuestionario
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
              Text('Cargando datos....'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificaciones(List<dynamic> datos) {
    if (datos.isEmpty) {
      return const Center(
        child: Text("Vacío"), // Mostrar un mensaje si no hay preguntas disponibles
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: datos.length,
              itemBuilder: (BuildContext context, int indice) {
                var notificacion = datos[indice];
                var descripcion = notificacion['categoria'];
                var isExpanded = notificacion['isExpanded'] ?? false;
                var iconoCategoria = categoriaIconos[descripcion] ?? FontAwesomeIcons.file;

                return Card(
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
                        leading: Icon(
                          iconoCategoria,
                          color: Colores.esquemaColor,
                        ),
                        trailing: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colores.esquemaColor,
                        ),
                        onTap: () {
                          setState(() {
                            datos[indice]['isExpanded'] = !isExpanded;
                            if (!isExpanded) {
                              obtenerRespuestas(notificacion['cuestionario']);
                              _scrollToPanel(indice);
                            }
                          });
                        },
                      ),
                      if (isExpanded) tarjeta(cuestionarios: notificacion['cuestionario']),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  void _scrollToPanel(int panelIndex) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double panelHeight = renderBox.size.height; // Altura del ListTile
    final double scrollOffset = panelIndex * panelHeight;
    Scrollable.ensureVisible(
      context,
      alignment: 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

 

  Future<void> obtenerRespuestas(List<dynamic> cuestionarios) async {
    for (var cuestionario in cuestionarios) {
      var id = cuestionario['Cod_Supervision_General'].toString();
      var respuesta = await _getRespuesta(id);

      if (respuesta != null) {
        ref.read(respuestasProvider.notifier).actualizarRespuesta('${id}_respuesta1', respuesta[DatabaseHelper.columnRespuesta1] == 1);
        ref.read(respuestasProvider.notifier).actualizarRespuesta('${id}_respuesta2', respuesta[DatabaseHelper.columnRespuesta2] == 1);
        ref
            .read(respuestasProvider.notifier)
            .actualizarRespuesta('${id}_respuestaPersonalizada', respuesta[DatabaseHelper.columnRespuestaPersonalizada] != null);
        if (respuesta[DatabaseHelper.columnRespuestaPersonalizada] != null) {
          setState(() {
            textoOpcional.text = respuesta[DatabaseHelper.columnRespuestaPersonalizada].toString();
          });
        }
      }
    }
  }
  /* Future<void> obtenerRespuestas(List<dynamic> cuestionarios) async {
    //var prueba = await DatabaseHelper.instance.getAllOrders();

    for (var cuestionario in cuestionarios) {
      var id = cuestionario['Cod_Supervision_General'].toString();

      var respuesta = await _getRespuesta(id);

      if (respuesta != null) {
        setState(() {
          respuestas['${id}_respuesta1'] = respuesta[DatabaseHelper.columnRespuesta1] == 1;
          respuestas['${id}_respuesta2'] = respuesta[DatabaseHelper.columnRespuesta2] == 1;
          respuestas['${id}_respuestaPersonalizada'] = respuesta[DatabaseHelper.columnRespuestaPersonalizada] != null;
        });
        if (respuesta[DatabaseHelper.columnRespuestaPersonalizada] != null) {
          setState(() {
            textoOpcional.text = respuesta[DatabaseHelper.columnRespuestaPersonalizada].toString();
          });
        }
      }
    }
  }*/

  void guardarRespuesta(int respuesta, String preguntaId) async {
    Map<String, dynamic> row = {DatabaseHelper.columnPreguntaId: preguntaId, DatabaseHelper.columnRespuestaPersonalizada: respuesta};
    await DatabaseHelper.instance.insertRespuesta(row);
  }

  /*Widget tarjeta({required List<dynamic> cuestionarios}) {
    final respuestas = ref.watch(respuestasProvider); // Obtén el estado actual

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: cuestionarios.map((cuestionario) {
          var id = cuestionario['Cod_Supervision_General'].toString();
          var respuesta1 = respuestas['${id}_respuesta1'] ?? false;
          var respuesta2 = respuestas['${id}_respuesta2'] ?? false;
          var respuestaPersonal = respuestas['${id}_respuestaPersonalizada'] ?? false;
          //var respuestaBase =respuestas[DatabaseHelper.columnRespuestaPersonalizada] != null;
          bool isEditable = cuestionario['respuesta1'] == 'EDITABLE';
          bool isCardDisabled = respuesta1 || respuesta2 || respuestaPersonal;

          return SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              //color: isCardDisabled ? Colors.grey[300] : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(cuestionario['nm']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isEditable)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: textoOpcional,
                                    decoration: const InputDecoration(
                                      labelText: 'Ingrese un número',
                                    ),
                                    enabled: !respuestaPersonal,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (textoOpcional.text != "") {
                                      guardarRespuesta(int.parse(textoOpcional.text), id);
                                    } else {
                                      await Fluttertoast.showToast(
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        msg: "Debe agregar una cantidad",
                                        gravity: ToastGravity.BOTTOM,
                                        toastLength: Toast.LENGTH_SHORT,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    MdiIcons.safe,
                                    color: Colores.esquemaColor,
                                    size: 30.0,
                                  ),
                                ),
                              ],
                            ),
                          if (!isEditable)
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(cuestionario['respuesta1']),
                                    value: respuesta1,
                                    onChanged: /*isCardDisabled
                                        ? null
                                        : */
                                        (value) {
                                      setState(() {
                                        respuestas['${id}_respuesta1'] = value ?? false;

                                        respuestas['${id}_respuesta2'] = false;
                                        respuesta1 = true;
                                      });

                                      _saveRespuesta(id, respuesta1, respuesta2);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(cuestionario['respuesta2']),
                                    value: respuesta2,
                                    onChanged: /* isCardDisabled
                                        ? null
                                        : */
                                        (value) {
                                      setState(() {
                                        respuestas['${id}_respuesta2'] = value ?? false;
                                        respuestas['${id}_respuesta1'] = false;
                                        respuesta2 = true;
                                      });
                                      _saveRespuesta(id, respuesta1, respuesta2);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          if (cuestionario['foto'] == 'SI') _uploaderCard()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }*/
  Widget tarjeta({required List<dynamic> cuestionarios}) {
    final respuestas = ref.watch(respuestasProvider); // Obtén el estado actual

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: cuestionarios.map((cuestionario) {
          var id = cuestionario['Cod_Supervision_General'].toString();
          var respuesta1 = respuestas['${id}_respuesta1'] ?? false;
          var respuesta2 = respuestas['${id}_respuesta2'] ?? false;
          var respuestaPersonal = respuestas['${id}_respuestaPersonalizada'] ?? false;
          bool isEditable = cuestionario['respuesta1'] == 'EDITABLE';

          return SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(cuestionario['nm']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Aquí puedes añadir más lógica, como un botón para cargar una foto

                          if (isEditable)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: textoOpcional,
                                    decoration: const InputDecoration(
                                      labelText: 'Ingrese un número',
                                    ),
                                    //enabled: !respuestaPersonal,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (textoOpcional.text != "") {
                                      int respuestaNumerica = int.parse(textoOpcional.text);
                                      ref.read(respuestasProvider.notifier).actualizarRespuesta('${id}_respuestaPersonalizada', true);

                                      guardarRespuesta(int.parse(textoOpcional.text), id);
                                    } else {
                                      await Fluttertoast.showToast(
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        msg: "Debe agregar una cantidad",
                                        gravity: ToastGravity.BOTTOM,
                                        toastLength: Toast.LENGTH_SHORT,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    MdiIcons.safe,
                                    color: Colores.esquemaColor,
                                    size: 30.0,
                                  ),
                                ),
                              ],
                            ),
                          if (!isEditable)
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(cuestionario['respuesta1']),
                                    value: respuesta1,
                                    onChanged: (value) {
                                      ref.read(respuestasProvider.notifier).actualizarRespuesta('${id}_respuesta1', value ?? false);
                                      ref.read(respuestasProvider.notifier).actualizarRespuesta('${id}_respuesta2', false);
                                      _saveRespuesta(id, value ?? false, false);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(cuestionario['respuesta2']),
                                    value: respuesta2,
                                    onChanged: (value) {
                                      ref.read(respuestasProvider.notifier).actualizarRespuesta('${id}_respuesta2', value ?? false);
                                      ref.read(respuestasProvider.notifier).actualizarRespuesta('${id}_respuesta1', false);
                                      _saveRespuesta(id, false, value ?? false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          if (cuestionario['foto'] == 'SI')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                    onPressed: () {
                                     
                                    },
                                    child: const Row(children: [
                                      Text(
                                        "Añadir Anexo",
                                        style: TextStyle(color: Colores.esquemaColor),
                                      ),
                                      Icon(
                                        Icons.camera,
                                        color: Colores.esquemaColor,
                                        size: 30,
                                      )
                                    ])),
                                /* IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colores.esquemaColor,
                                      size: 30,
                                    )),*/
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void verificarRespuestasCompletas(List<dynamic> cuestionarioss) async {
    List<dynamic> preguntas = [];
    for (var categoria in cuestionario) {
      List<dynamic> preguntasCategoria = categoria['cuestionario'];
      preguntas.addAll(preguntasCategoria);
    }

    var prueba = await DatabaseHelper.instance.getAllOrders();

    bool todasContestadas = preguntas.every((pregunta) {
      var id = pregunta['Cod_Supervision_General'].toString();
      return prueba.any((item) => item['preguntaId'] == id);
    });

    if (preguntas.length == prueba.length && todasContestadas) {
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeUser()), (Route<dynamic> route) => false);
    } else {
      setState(() {
        cargando = true;
      });
    }
  }
/*Future getImage(bool gallery, int index, dynamic pregunta) async {
    ImagePicker picker = ImagePicker();
    var pickedFile;

    if (gallery) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    }

    if (pickedFile != null) {
      File sad = File(pickedFile!.path);
      final bytes = sad.readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;
      // Recorte de la imagen
      var cropper = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9
          ],
          compressQuality: mb <= 2 ? 100 : 100,
          compressFormat: ImageCompressFormat.jpg,
          uiSettings: [
            AndroidUiSettings(
                toolbarColor: Colores.esquemaColor,
                toolbarTitle: "Recorta la imagen",
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
                backgroundColor: Colors.white)
          ]);

      if (cropper != null) {
        final target = await path_provider.getTemporaryDirectory();
        final path = "/${target.absolute.path}/Y${index + 1}YX${pregunta["id_pregunta"]}X${DateTime.now().millisecondsSinceEpoch}.webp";
        await FlutterImageCompress.compressAndGetFile(
          cropper.path,
          path,
          format: CompressFormat.webp,
          minHeight: 800,
          minWidth: 800,
          quality: 30,
        );

       /* var tempImages = List.from(imagenes[pregunta["id_pregunta"]]);
        tempImages[index] = new XFile("${path}");
        setState(() {
          imagenes[pregunta["id_pregunta"]] = List.from(tempImages);
        });*/
      }
    }
  }*/

  // Guardar la respuesta en la base de datos
  void _saveRespuesta(String preguntaId, bool respuesta1, bool respuesta2) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnPreguntaId: preguntaId,
      DatabaseHelper.columnRespuesta1: respuesta1 ? 1 : 0,
      DatabaseHelper.columnRespuesta2: respuesta2 ? 1 : 0,
    };
    await DatabaseHelper.instance.insertRespuesta(row);
  }

  Future<Map<String, dynamic>?> _getRespuesta(String preguntaId) async {
    List<Map<String, dynamic>> respuestas = await DatabaseHelper.instance.getAllRespuestas();

    try {
      return respuestas.firstWhere(
        (respuesta) => respuesta[DatabaseHelper.columnPreguntaId] == preguntaId,
      );
    } catch (e) {
      return null; // Devuelve null si no se encuentra ninguna respuesta
    }
  }
}
