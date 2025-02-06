// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, use_build_context_synchronously

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as inta;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:badges/badges.dart' as badges;
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/platform_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'database/inventario_sqlite.dart';

class TarjetaInventario extends StatefulWidget {
  final int codProducto;
  final String producto;
  final int cantidad;
  final int fraccion;
  final int cajasEscaneadas;
  final int fraccionesEscaneadas;
  final int fraccionesMalPicadas;
  final int cajasCaducadas;
  final int fraccionesCaducadas;
  final int estado;
  final int totalCajas;
  final int totalFracciones;
  final int fraccionDv;
  final int cajaPromo;
  final int fraccionPromo;
  final Function onDatosActualizados;
  final String codTipo;
  const TarjetaInventario({
    required this.codProducto,
    required this.producto,
    required this.cantidad,
    required this.fraccion,
    required this.cajasEscaneadas,
    required this.fraccionesEscaneadas,
    required this.fraccionesMalPicadas,
    required this.cajasCaducadas,
    required this.fraccionesCaducadas,
    required this.estado,
    required this.totalCajas,
    required this.totalFracciones,
    required this.fraccionDv,
    required this.cajaPromo,
    required this.fraccionPromo,
    required this.onDatosActualizados,
    required this.codTipo,
    Key? key,
  }) : super(key: key);

  @override
  _TarjetaInventarioState createState() => _TarjetaInventarioState();
}

class _TarjetaInventarioState extends State<TarjetaInventario> {
  //late TextEditingController ctrTotalCajas;
  TextEditingController ctrCajas = TextEditingController();
  TextEditingController ctrFracciones = TextEditingController();
  TextEditingController ctrCajasCaducadas = TextEditingController();
  TextEditingController ctrFraccionesCaducadas = TextEditingController();
  TextEditingController ctrFraccionesMalPicadas = TextEditingController();

  TextEditingController ctrlCajaPromo = TextEditingController();
  TextEditingController ctrlFraccionpromo = TextEditingController();
  // late TextEditingController ctrTotalFracciones;
  bool activaBotonPrincipal = false;
  bool activaBotonPrincipalFracciones = false;
  String? errorCajas;
  String? errorFracciones;
  double tama = 10;
  double tamanoTitulo = 18.0;
  double tamanoDescripcion = 15.0;
  Color alerta = Colors.yellow;
  FocusNode cajasFocusNode = FocusNode();
  FocusNode fraccionesFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();

    cajasFocusNode.addListener(() {
      if (cajasFocusNode.hasFocus) {
        ctrCajas.selection = TextSelection(baseOffset: 0, extentOffset: ctrCajas.text.length);
      }
    });

    fraccionesFocusNode.addListener(() {
      if (fraccionesFocusNode.hasFocus) {
        ctrFracciones.selection = TextSelection(baseOffset: 0, extentOffset: ctrFracciones.text.length);
      }
    });
    inicial();
    /*ctrTotalCajas.text = (widget.cajasEscaneadas + widget.cajasCaducadas).toString();
    ctrTotalFracciones.text = (widget.fraccionesEscaneadas + widget.fraccionesMalPicadas + widget.fraccion).toString();
    ctrTotalCajas.addListener(() {
      if ((int.tryParse(ctrTotalCajas.text) ?? 0) > widget.cantidad) {
        setState(() {
          errorCajas = "Soprepasa stock";
        });
      } else if ((int.tryParse(ctrTotalCajas.text) ?? 0) < widget.cantidad) {
        setState(() {
          errorCajas = "Falta stock";
        });
      } else if ((int.tryParse(ctrTotalCajas.text) ?? 0) == widget.cantidad) {
        setState(() {
          errorCajas = "OK";
        });
      }
    });
    ctrTotalFracciones.addListener(() {
      if ((int.tryParse(ctrTotalFracciones.text) ?? 0) > widget.fraccion) {
        setState(() {
          errorFracciones = "Soprepasa stock";
        });
      } else if ((int.tryParse(ctrTotalFracciones.text) ?? 0) < widget.fraccion) {
        setState(() {
          errorCajas = "Falta stock";
        });
      } else if ((int.tryParse(ctrTotalFracciones.text) ?? 0) == widget.fraccion) {
        setState(() {
          errorCajas = "OK";
        });
      }
    });*/
  }

  Future<void> inicial() async {
    setState(() {
      ctrCajas.text = widget.cajasEscaneadas.toString();
      ctrFracciones.text = widget.fraccionesEscaneadas.toString();
      ctrFraccionesCaducadas.text = widget.fraccionesCaducadas.toString();
      ctrCajasCaducadas.text = widget.cajasCaducadas.toString();
      ctrFraccionesMalPicadas.text = widget.fraccionesMalPicadas.toString();
      ctrlCajaPromo.text = widget.cajaPromo.toString();
      ctrlFraccionpromo.text = widget.fraccionPromo.toString();
      activaBotonPrincipal = true;
      activaBotonPrincipalFracciones = true;
    });
  }

  bool isValidNumber(String value) {
    if (value.isEmpty) {
      return true; // Acepta valores vacíos
    }

    final n = num.tryParse(value);

    if (n == null) {
      return false;
    }

    return n is int; // Acepta solo enteros positivos
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: prueba(),
      ),
    );
  }

  Widget prueba() {
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
                        if (numCajasCorrectas < (int.tryParse(ctrCajasCaducadas.text) ?? 0)) {
                          ctrCajasCaducadas.text = "0";
                        }
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
                    keyboardType: TextInputType.number,
                    controller: ctrCajas,
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
                    enabled: widget.fraccionDv > 1 || int.parse(ctrFracciones.text) > 0,
                    onChanged: (f) async {
                      if (esEntero(f) && (int.tryParse(f) ?? 0) >= 0) {
                        int numFraccionesCorrectas = int.tryParse(f) ?? 0;
                        if (numFraccionesCorrectas <
                            ((int.tryParse(ctrFraccionesMalPicadas.text) ?? 0)) + (int.tryParse(ctrFraccionesCaducadas.text) ?? 0)) {
                          ctrFraccionesMalPicadas.text = "0";
                          ctrFraccionesCaducadas.text = "0";
                        }
                        await activaBotonesFra(widget.fraccionDv);
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
                    controller: ctrFracciones,
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
            if (widget.codTipo != "02")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buttonCadBadge(), widget.fraccionDv > 1 ? picados() : const SizedBox.shrink(), promociones()],
              ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: activaBotonPrincipalFracciones && activaBotonPrincipal
                        ? () async {
                            if (isValidNumber(ctrCajasCaducadas.text) &&
                                isValidNumber(ctrCajas.text) &&
                                //isValidNumber(ctrTotalCajas.text) &&
                                isValidNumber(ctrFracciones.text) &&
                                isValidNumber(ctrFraccionesCaducadas.text) &&
                                isValidNumber(ctrFraccionesMalPicadas.text)) {
                              await ArtSweetAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.warning,
                                      title: "¿Está seguro de continuar?",
                                      confirmButtonText: "Aceptar",
                                      onCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                      onConfirm: () async {
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
                                          int cajasInput = int.tryParse(ctrCajas.text) ?? 0;
                                          int fraccionesInput = int.tryParse(ctrFracciones.text) ?? 0;
                                          int fraccionesMalPicadasInput = int.tryParse(ctrFraccionesMalPicadas.text) ?? 0;
                                          int fraccionesCaducadasInput = int.tryParse(ctrFraccionesCaducadas.text) ?? 0;
                                          int cajasCaducadasInput = int.tryParse(ctrCajasCaducadas.text) ?? 0;
                                          int cajasPromo = int.tryParse(ctrlCajaPromo.text) ?? 0;
                                          int fraccionPromo = int.tryParse(ctrlFraccionpromo.text) ?? 0;

                                          int cajasFinal = cajasInput;
                                          int fraccionesFinal = fraccionesInput;
                                          int fraccionesMalPicadasFinal = fraccionesMalPicadasInput;
                                          int fraccionesCaducadasFinal = fraccionesCaducadasInput;
                                          int cajasCaducadasFinal = cajasCaducadasInput;

                                          DatabaseHelper dbHelper = DatabaseHelper();
                                          await dbHelper.actualizarDatosEnSQLite(
                                              widget.codProducto,
                                              cajasFinal,
                                              fraccionesFinal,
                                              cajasCaducadasFinal,
                                              fraccionesCaducadasFinal,
                                              fraccionesMalPicadasFinal,
                                              1,
                                              cajasPromo,
                                              fraccionPromo,
                                              fechaEscaneo.toString());

                                          widget.onDatosActualizados();
                                        }
                                      },
                                      showCancelBtn: true,
                                      cancelButtonText: "Cancelar",
                                      cancelButtonColor: Colors.grey,
                                      text: "Una vez guardado este producto no lo podrá volver a editar",
                                      confirmButtonColor: Colores.esquemaColor));
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
                          }
                        : null,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget picados() {
    return badges.Badge(
        position: badges.BadgePosition.topEnd(top: -15, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        showBadge: ctrFraccionesMalPicadas.text != "", // Mostrar el badge solo si hay unidades o fracciones
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color.fromRGBO(205, 62, 45, 1),
          padding: EdgeInsets.all(8),
        ),
        badgeContent: Text(
          'F${ctrFraccionesMalPicadas.text}', // Mostrar la información en el formato deseado
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: SizedBox(
          width: 100, // Ancho del botón
          height: 40,
          child: FloatingActionButton.extended(
            onPressed: () {
              alertaPicados(context, "Producto mal cortado", widget.producto);
            },
            label: const Text("Mal cortado"),
          ),
        ));
  }

  Widget buttonCadBadge() {
    //print('Unidades: $unidadesss, Fracciones: $fraccionesss');
    return badges.Badge(
        position: badges.BadgePosition.topEnd(top: -15, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        showBadge: ctrCajasCaducadas.text != "" || ctrFraccionesCaducadas.text != "", // Mostrar el badge solo si hay unidades o fracciones
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color.fromRGBO(205, 62, 45, 1),
          padding: EdgeInsets.all(8),
        ),
        badgeContent: Text(
          '${ctrCajasCaducadas.text}F${ctrFraccionesCaducadas.text}', // Mostrar la información en el formato deseado
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: SizedBox(
          width: 100, // Ancho del botón
          height: 40,
          child: FloatingActionButton.extended(
            onPressed: () {
              alertaEspecial(context, "Producto caducado", widget.producto);
            },
            label: const Text("Caducado"),
          ),
        ));
  }

  Widget promociones() {
    //print('Unidades: $unidadesss, Fracciones: $fraccionesss');
    return badges.Badge(
        position: badges.BadgePosition.topEnd(top: -15, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        showBadge: ctrlCajaPromo.text != "" || ctrlFraccionpromo.text != "", // Mostrar el badge solo si hay unidades o fracciones
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color.fromRGBO(205, 62, 45, 1),
          padding: EdgeInsets.all(8),
        ),
        badgeContent: Text(
          '${ctrlCajaPromo.text}F${ctrlFraccionpromo.text}', // Mostrar la información en el formato deseado
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: SizedBox(
          width: 100, // Ancho del botón
          height: 40, // Altura del botón
          child: FloatingActionButton.extended(
            onPressed: () {
              alertaPromos(context, "Promociones no entregadas", widget.producto);
            },
            label: const Text("Cargos"),
          ),
        ));
  }

  Future<void> alertaPicados(
    BuildContext context,
    String titulo,
    String producto,
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
                          producto,
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
                      controller: ctrFraccionesMalPicadas,
                      onChanged: (f) async {
                        if (esEntero(f) && ((int.tryParse(f) ?? 0) <= (int.tryParse(ctrFracciones.text) ?? 0))) {
                          //int numFraccionesPicadas = int.tryParse(f) ?? 0;
                          setState(() {
                            //fraccionessspica = numFraccionesPicadas.toString();
                            botonComprueba = true;
                            //fraccionesss = "0";
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
                      ctrFraccionesMalPicadas.text = "";
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: botonComprueba
                      ? () async {
                          /*setState(() {
                            fraccionessspica = ctrlFraccionCortada.text;
                          });*/
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
    bool esValidoCaja = esEntero(ctrCajasCaducadas.text) && (int.tryParse(ctrCajasCaducadas.text) ?? 0) <= (int.tryParse(ctrCajas.text) ?? 0);
    bool esValidoFraccion =
        esEntero(ctrFraccionesCaducadas.text) && (int.tryParse(ctrFraccionesCaducadas.text) ?? 0) <= (int.tryParse(ctrFracciones.text) ?? 0);
    return esValidoCaja && esValidoFraccion;
  }

  bool esValidoFraccionCortada() {
    return esEntero(ctrFraccionesMalPicadas.text) && (int.tryParse(ctrFraccionesMalPicadas.text) ?? 0) <= (int.tryParse(ctrFracciones.text) ?? 0);
  }

  bool esValidoPromos() {
    bool esValidoCaja = esEntero(ctrlCajaPromo.text);
    bool esValidoFraccion = esEntero(ctrlFraccionpromo.text);
    return esValidoCaja && esValidoFraccion;
  }

  Future<void> alertaPromos(
    BuildContext context,
    String titulo,
    String producto,
  ) async {
    bool botonCompruebaPromo = false;
    bool botonCompruebaFPromo = false;
    if (esValidoPromos()) {
      botonCompruebaPromo = true;
      botonCompruebaFPromo = true;
    }
    if (widget.fraccionDv <= 1) {
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
                          producto,
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
                          setState(() {
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
                      controller: ctrlFraccionpromo,
                      onChanged: (f) async {
                        if (esEntero(f)) {
                          setState(() {
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

  Future<void> alertaEspecial(
    BuildContext context,
    String titulo,
    String producto,
  ) async {
    bool botonComprueba = false;
    bool botonCompruebaF = false;
    if (esValido()) {
      botonComprueba = true;
      botonCompruebaF = true;
    }
    if (widget.fraccionDv <= 1) {
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
                          producto,
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
                      controller: ctrCajasCaducadas,
                      onChanged: (f) async {
                        if (esEntero(f) /*&& ((int.tryParse(f) ?? 0) <= (int.tryParse(ctrCajas.text) ?? 0))*/) {
                          // int numFraccionesCorrectas = int.tryParse(f) ?? 0;
                          setState(() {
                            //unidadesss = numFraccionesCorrectas.toString();
                            botonComprueba = true;
                            //fraccionesss = "0";
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
                      controller: ctrFraccionesCaducadas,
                      enabled: widget.fraccionDv > 1,
                      onChanged: (f) async {
                        if (esEntero(f) && ((int.tryParse(f) ?? 0) <= (int.tryParse(ctrFracciones.text) ?? 0))) {
                          //   int numFraccionesCaducadas = int.tryParse(f) ?? 0;
                          setState(() {
                            //  fraccionesss = numFraccionesCaducadas.toString();
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
                      ctrCajasCaducadas.text = "";
                      ctrFraccionesCaducadas.text = "";
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: botonComprueba && botonCompruebaF
                      ? () async {
                          /*setState(() {
                            unidadesss = ctrlCajaCaducada.text;
                            fraccionesss = ctrlFraccionCaducada.text;
                          });*/
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

  @override
  void dispose() {
    super.dispose();
    cajasFocusNode.dispose();
    fraccionesFocusNode.dispose();
  }
}
