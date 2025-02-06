// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/globals/imagen_carrusel.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/clase_mantenimientos.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/urgentes/logica.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TarjetaNueva extends StatelessWidget {
  final Mantenimientos mantenimiento;
  final VoidCallback onTap;
  final bool validacion;
  final VoidCallback onFechaSeleccionada; // Nuevo callback
  const TarjetaNueva({Key? key, required this.mantenimiento, required this.onTap, required this.validacion, required this.onFechaSeleccionada})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController descipcion = TextEditingController();
    String codUsuario = "";
    String token = "";
    SecureStorage storage = SecureStorage();
    final DateTime now = DateTime.now();
    double horizon = 5.0;
    double vertica = 5.0;
    double letradebajo = 14;
    double separacion = 2.0;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 4,
        child: ExpansionTile(
          title: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: vertica),
                    child: Text("Requerimiento #${mantenimiento.codSolicitud}",
                        style: const TextStyle(color: Colores.esquemaColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizon, vertical: separacion),
                      child: Row(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Icon(
                            MdiIcons.storeCog,
                            color: Colores.esquemaColor,
                          ),
                        ),
                        Text(mantenimiento.bodega, style: TextStyle(fontSize: letradebajo))
                      ])),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizon, vertical: separacion),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Icon(
                            MdiIcons.bookCog,
                            color: Colores.esquemaColor,
                          ),
                        ),
                        Expanded(
                            child: Text(
                          mantenimiento.descripcionTipo,
                          style: TextStyle(fontSize: letradebajo),
                          maxLines: 3,
                          softWrap: true,
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizon, vertical: separacion),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Icon(
                            MdiIcons.calendar,
                            color: Colores.esquemaColor,
                          ),
                        ),
                        Text(mantenimiento.fechaSolicitud, style: TextStyle(fontSize: letradebajo)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizon + 11, vertical: separacion),
              child: Row(
                children: [
                  Text("Detalles: ", style: TextStyle(fontSize: letradebajo + 5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizon + 15, vertical: separacion),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    mantenimiento.descripcionDetalle,
                    style: TextStyle(fontSize: letradebajo),
                    maxLines: 3,
                    softWrap: true,
                  )),
                ],
              ),
            ),
            if (mantenimiento.detalle != "")
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizon + 15, vertical: separacion),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      mantenimiento.detalle,
                      style: TextStyle(fontSize: letradebajo),
                      maxLines: 3,
                      softWrap: true,
                    )),
                  ],
                ),
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: ImagenesCarrusel(mantenimiento: mantenimiento),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: () async {
                    /**ArtDialogResponse response =*/ await ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            confirmButtonText: "Aceptar",
                            cancelButtonText: "Cancelar",
                            showCancelBtn: true,
                            title: "Alerta",
                            text: "¿Estás seguro de rechazar este mantenimiento?",
                            type: ArtSweetAlertType.warning,
                            confirmButtonColor: Colores.esquemaColor,
                            denyButtonColor: Colors.white,
                            customColumns: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  minLines: 2,
                                  controller: descipcion,
                                  decoration: const InputDecoration(hintText: "Describa el motivo de rechazo"),
                                ),
                              )
                            ],
                            onConfirm: () async {
                              codUsuario = await storage.readSecureData("cod_usuario");
                              token = await storage.readSecureData("token");
                              try {
                                if (descipcion.text != "") {
                                  var controlador = await rechazarMantenimiento(
                                      token, int.parse(codUsuario), mantenimiento.codSolicitud, descipcion.text.trim(), "rechazar_mantenimiento");
                                  var decode = jsonDecode(controlador.body);

                                  if (decode["msg"] != "err") {
                                    Fluttertoast.showToast(
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      msg: "Mantenimiento rechazado correctamente",
                                      gravity: ToastGravity.BOTTOM,
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                    onFechaSeleccionada();
                                    Navigator.pop(context);
                                  } else {
                                    Fluttertoast.showToast(
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      msg: "Ocurrió un error al procesar: $decode",
                                      gravity: ToastGravity.BOTTOM,
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      backgroundColor: Colors.red, textColor: Colors.white, msg: "Ingrese un motivo", gravity: ToastGravity.BOTTOM);
                                }
                              } on TimeoutException catch (e) {
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  msg: "Tiempo de espera agotado: $e",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              } catch (e) {
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  msg: "Ocurrió un error: $e",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              }
                            },
                            onCancel: () {
                              Navigator.pop(context);
                            }));

                
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Row(
                    children: [
                      Text("Rechazar", style: TextStyle(color: Colors.black)),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.cancel,
                        color: Colores.esquemaColor,
                        size: 20,
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      codUsuario = await storage.readSecureData("cod_usuario");
                      token = await storage.readSecureData("token");
                      mostrarDialogoConCalendario(
                          context, now, validacion, onFechaSeleccionada, mantenimiento.codSolicitud, int.parse(codUsuario), token);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Aceptar"),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.check, size: 20)
                      ],
                    )),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Future<void> mostrarDialogoConCalendario(
      BuildContext context, DateTime now, bool valida, VoidCallback onConfirm, int codSolicitud, int codUsuario, String token) async {
    DateTime? fechaSeleccionada;

    final DateTime lastDate = DateTime(now.year, valida ? now.month : now.month + 1, valida ? now.day + 5 : now.day);
    final DateTime firstDate = DateTime(now.year, now.month, now.day);
    // Muestra el diálogo personalizado
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Seleccione una fecha"),
          content: SizedBox(
            // Ajusta el tamaño según necesites
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.height,
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: (DateTime newDate) {
                fechaSeleccionada = newDate;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                // Aquí manejas la fecha seleccionada
                try {
                  if (fechaSeleccionada != null) {
                    final String formattedDate = DateFormat('dd/MM/yyyy').format(fechaSeleccionada!);
                    Fluttertoast.showToast(
                      backgroundColor: Colors.yellow,
                      textColor: Colors.black,
                      msg: "Guardando planificación por favor espere..",
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_LONG,
                    );
                    var envio = await aceptarMantenimiento(token, codUsuario, formattedDate, codSolicitud, "aceptar_urgente");
                    var decode = jsonDecode(envio.body);
                    if (decode["msg"] != "err") {
                      Fluttertoast.showToast(
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        msg: "Planificación registrada correctamente",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_LONG,
                      );
                      onConfirm();
                    } else {
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: "Ocurrió un error al procesar: $decode",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_LONG,
                      );
                    }
                  } else {
                    onConfirm();
                  }
                  Navigator.of(context).pop();
                } on TimeoutException catch (e) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "Tiempo de espera agotado: $e",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: "Ocurrió un error: $e",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
