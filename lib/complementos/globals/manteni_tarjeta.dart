// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/clase_mantenimientos.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/planificables/mantenimiento_detalle.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/urgentes/logica.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/logica_inventario_general.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;

class Tarjeta extends StatelessWidget {
  final RutaConMantenimientos rutaConMantenimientos;
  final VoidCallback onTap;
  final bool validacion;
  final VoidCallback onFechaSeleccionada; // Nuevo callback
  const Tarjeta({Key? key, required this.rutaConMantenimientos, required this.onTap, required this.validacion, required this.onFechaSeleccionada})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    String codUsuario = "";
    String token = "";
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 4,
        child: badges.Badge(
          position: badges.BadgePosition.topEnd(top: -10, end: 0),
          badgeAnimation: const badges.BadgeAnimation.slide(),
          showBadge: true, // Mostrar el badge solo si hay unidades o fracciones
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Color.fromRGBO(205, 62, 45, 1),
            padding: EdgeInsets.all(8),
          ),
          badgeContent: Text(
            rutaConMantenimientos.mantenimientos.length.toString(), // Mostrar la información en el formato deseado
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rutaConMantenimientos.descripcionRuta,
                    style: const TextStyle(color: Colores.esquemaColor, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    codUsuario = await storage.readSecureData("cod_usuario");
                    token = await storage.readSecureData("token");
                    mostrarDialogoConCalendario(
                        context, now, onFechaSeleccionada, rutaConMantenimientos.mantenimientos, int.parse(codUsuario), token);
                  },
                )
              ],
            ),
            children: rutaConMantenimientos.mantenimientos.map((mantenimiento) {
              return DetalleMantenimientoWidget(mantenimiento: mantenimiento, onFechaSeleccionada: onFechaSeleccionada);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> mostrarDialogoConCalendario(
      BuildContext context, DateTime now, VoidCallback onConfirm, List<Mantenimientos> mantenimientos, int codUsuario, String token) async {
    DateTime? fechaSeleccionada;

    final DateTime lastDate = DateTime(now.year, now.month + 1, now.day);
    final DateTime firstDate = DateTime(now.year, now.month, now.day);
    bool validar = true;
    // Muestra el diálogo personalizado
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AlertDialog(
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
                  onPressed: validar
                      ? () async {
                          // Aquí manejas la fecha seleccionada
                          try {
                            if (fechaSeleccionada != null) {
                              setState(() {
                                validar = false; // Deshabilita el botón Aceptar
                              });
                              Fluttertoast.showToast(
                                backgroundColor: Colors.yellow,
                                textColor: Colors.black,
                                msg: "Procesando datos, por favor espere...",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG,
                              );
                              final String formattedDate = DateFormat('dd/MM/yyyy').format(fechaSeleccionada!);
                              List<int> idsSolicitudes = mantenimientos.map((m) => m.codSolicitud).toList();

                              var envio = await aceptarMantenimientosMultiples(
                                  token, codUsuario, formattedDate, idsSolicitudes, "aceptar_mantenimientos_multiples");
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
                              Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                msg: "Debe elejir una fecha",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG,
                              );
                              onConfirm();
                            }
                            Navigator.of(context).pop();
                          } on TimeoutException catch (e) {
                            setState(() {
                              validar = true; // Deshabilita el botón Aceptar
                            });
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: "Tiempo de espera agotado: $e",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          } catch (e) {
                            setState(() {
                              validar = true; // Deshabilita el botón Aceptar
                            });
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: "Ocurrió un error: $e",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
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
}
