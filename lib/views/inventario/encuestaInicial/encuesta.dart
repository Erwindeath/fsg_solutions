// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/esqueleto.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';
import 'package:fsg_solutions/views/inventario/ajuste_inventario/home_ajuste_inventario.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/clase.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/encuesta_sqlite.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/methods.dart';
import 'package:fsg_solutions/views/inventario/encuestaInicial/provider.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/laboratorios.dart';

import '../../../complementos/globals/colors.dart';
import '../enviando.dart';

class EncuestaInicial extends ConsumerStatefulWidget {
  final int codInventario;
  final int codBodega;
  final int codUsuario;
  final bool valida;
  const EncuestaInicial({required this.codInventario, required this.codUsuario, required this.codBodega, required this.valida, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EncuestaInicialState();
}

class _EncuestaInicialState extends ConsumerState<EncuestaInicial> {
  SecureStorage storage = SecureStorage();

  final dbHelper = DatabaseHelperEncuesta();
  List<Categoria> encuesta = [];
  @override
  Widget build(BuildContext context) {
    final isLoading = !ref.watch(enviando);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Encuesta"),
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
              icon: const Icon(Icons.arrow_back)),
          actions: [
            IconButton(
                onPressed: areAllQuestionsAnswered() && ref.watch(enviando)
                    ? () async {
                        try {
                          String token = await storage.readSecureData("token");
                          // Lista para almacenar las descripciones

                          if (widget.valida) {
                            ref.read(enviando.notifier).state = false;
                            await dbHelper.deleteTable();
                            String allDescriptions = await getAllCategoryDescriptions(encuesta);
                            await dbHelper.insert(widget.codInventario, allDescriptions);

                            var enviandos = await enviarEncuesta(
                                token, widget.codBodega, encuesta.map((e) => e.toJson()).toList(), widget.codInventario, widget.codUsuario);
                            var decodi = jsonDecode(enviandos.body);
                            if (decodi["msg"] != "err") {
                              ref.read(enviando.notifier).state = true;
                              if (mounted) {
                                Future.microtask(() async {
                                  await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.success,
                                      title: "Correcto",
                                      text: "Encuesta enviada con éxito",
                                      confirmButtonText: "Aceptar",
                                      confirmButtonColor: Colores.esquemaColor,
                                      onConfirm: () async {
                                        await Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) => const LabotarotiosInventario(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  );
                                });
                              }
                            } else {
                              await dbHelper.deleteTable();
                              ArtSweetAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.danger,
                                      title: "Error: $decodi",
                                      confirmButtonText: "Aceptar",
                                      text: "Comuníquese con el administrador",
                                      confirmButtonColor: Colores.esquemaColor));

                              ref.read(enviando.notifier).state = true;
                            }
                          } else {
                            var enviandos =
                                await enviarEncuesta(token, widget.codBodega, encuesta.map((e) => e.toJson()).toList(), 0, widget.codUsuario);
                            var decodi = jsonDecode(enviandos.body);
                            if (decodi["msg"] != "err") {
                              await storage.writeSecureData("encuesta", "encuestaenviada");
                              ref.read(enviando.notifier).state = true;
                              if (mounted) {
                                Future.microtask(() async {
                                  await ArtSweetAlert.show(
                                    barrierDismissible: false,
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.success,
                                      title: "Correcto",
                                      text: "Encuesta enviada con éxito",
                                      confirmButtonText: "Aceptar",
                                      confirmButtonColor: Colores.esquemaColor,
                                      onConfirm: () async {
                                        await Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) => const AjusteInventario(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  );
                                });
                              }
                            } else {
                              ArtSweetAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.danger,
                                      title: "Error: $decodi",
                                      confirmButtonText: "Aceptar",
                                      text: "Comuníquese con el administrador",
                                      confirmButtonColor: Colores.esquemaColor));
                              ref.read(enviando.notifier).state = true;
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
                          await dbHelper.deleteTable();
                          ref.read(enviando.notifier).state = true;
                        } on SocketException catch (e) {
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg: e.toString(),
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_LONG,
                          );
                          await dbHelper.deleteTable();

                          ref.read(enviando.notifier).state = true;
                        }
                      }
                    : null,
                icon: const Icon(Icons.save))
          ],
        ),
        body: Stack(
          children: <Widget>[
            principal(),
            if (isLoading)
              const CargandoEnvio(
                texto: 'Procesando datos, por favor espere.',
                colorTexto: Colores.esquemaColor,
                width: 300.0,
                height: 300.0,
                tamanoTexto: 14,
              )
          ],
        )); //principal());
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  bool areAllQuestionsAnswered() {
    // Verifica si cada categoría ha tenido todas sus preguntas respondidas.
    return encuesta.every((categoria) => areAllAnswersSelected(categoria));
  }

  Future<String> getAllCategoryDescriptions(List<Categoria> categorias) async {
    List<String> descriptions = []; // Lista para almacenar las descripciones

    for (var categoria in categorias) {
      descriptions.add(categoria.describe()); // Añade cada descripción a la lista
    }

    // Concatena todas las descripciones en un solo string con dos saltos de línea entre cada una
    return descriptions.toString();
  }

  Future<void> datosIniciales() async {
    String token = await storage.readSecureData("token");
    ref.read(obteniendoDatos.notifier).state = false;
    try {
      var obtenerData = await obtenerEncuesta(widget.codInventario, token);
      var decodificado = jsonDecode(obtenerData.body);
      if (decodificado["msg"] != "err") {
        ref.read(obteniendoDatos.notifier).state = true;
        setState(() {
          encuesta = parsearEncuesta(obtenerData.body, true);
        });
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: "Ocurrió un error al obtener los datos ",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );

        ref.read(obteniendoDatos.notifier).state = false;
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

      ref.read(obteniendoDatos.notifier).state = false;
    }
  }

  Widget principal() {
    if (!ref.watch(obteniendoDatos)) {
      return const MenuSkeleton();
    } else {
      return startQuestions();
    }
  }

  Widget startQuestions() {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= encuesta.length) return null;
              final categoria = encuesta[index];
              bool allAnswered = areAllAnswersSelected(categoria);
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(8.0),
                color: allAnswered ? Colors.green.shade200 : Colors.white, // Cambiar color de fondo basado en el estado

                child: ExpansionTile(
                  leading: allAnswered ? const Icon(Icons.check_circle_outline, color: Colors.white) : null, // Ícono de completado

                  title: Text(categoria.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  children: categoria.preguntas.map((pregunta) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            pregunta.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            children: [
                              Row(
                                children: pregunta.respuestas.map((respuesta) {
                                  return Expanded(
                                    child: CheckboxListTile(
                                      title: Text(respuesta.dato),
                                      value: respuesta.seleccionada,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          for (var r in pregunta.respuestas) {
                                            r.seleccionada = false;
                                            r.observacion = "";
                                          }
                                          respuesta.seleccionada = value!;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (pregunta.llevaObservacion && pregunta.respuestas.any((r) => r.dato == "NO" && r.seleccionada))
                                TextField(
                                  onSubmitted: (text) {
                                    // Encuentra la respuesta "NO" y actualiza su observación
                                    var noRespuesta = pregunta.respuestas.firstWhere((r) => r.dato == "NO" && r.seleccionada);
                                    setState(() {
                                      noRespuesta.observacion = text;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Añada una observación de ser necesaria"',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            childCount: encuesta.length,
          ),
        )
      ],
    );
  }

  bool areAllAnswersSelected(Categoria categoria) {
    return categoria.preguntas.every((pregunta) => pregunta.respuestas.any((respuesta) => respuesta.seleccionada));
  }
}
