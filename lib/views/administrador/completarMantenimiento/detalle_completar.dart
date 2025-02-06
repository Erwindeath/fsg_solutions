// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart' as cp;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/clase_mantenimientos.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/urgentes/logica.dart';
import 'package:hl_image_picker_android/hl_image_picker_android.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../complementos/globals/imagen_carrusel.dart';
import '../../supervisores/ReportarManimiento/media/media_preview.dart';
import '../../supervisores/logica_supervisores.dart';

class DetalleCompletarWidget extends StatefulWidget {
  final Mantenimientos mantenimiento;
  final VoidCallback onFechaSeleccionada;

  const DetalleCompletarWidget({Key? key, required this.mantenimiento, required this.onFechaSeleccionada}) : super(key: key);
  @override
  State<DetalleCompletarWidget> createState() => _DetalleCompletarWidgetState();
}

class _DetalleCompletarWidgetState extends State<DetalleCompletarWidget> {
  double separacion = 2.0;
  TextEditingController descipcion = TextEditingController();
  String codUsuario = "";
  String token = "";
  SecureStorage storage = SecureStorage();
  final DateTime now = DateTime.now();
  double horizon = 5.0;
  double vertica = 5.0;
  double letradebajo = 14;
  bool validar = true;
  bool guarda = true;
  //List<HLPickerItem> selectedImages = [];
  ValueNotifier<List<HLPickerItem>> selectedImages = ValueNotifier([]);

  final picker = HLImagePickerAndroid();
  final bool isCroppingEnabled = true;
  final MediaType type = MediaType.all;
  final bool isExportThumbnail = true;
  final bool includePrevSelected = false;
  final int count = 10;
  final bool enablePreview = false;
  final bool usedCameraButton = true;
  final int numberOfColumn = 3;
  final double compressQuality = 0.8;
  CropAspectRatio? aspectRatio;

  List<CropAspectRatioPreset>? aspectRatioPresets;
  @override
  Widget build(BuildContext context) {
    String fechaFormateada = widget.mantenimiento.fechaSolicitud.replaceAll("/", "-");
    DateTime fechaMantenimiento = DateTime.parse(fechaFormateada);
    DateTime ahora = DateTime.now();
    // Asegurarse de que solo se compare la fecha, sin la hora
    DateTime fechaActual = DateTime(ahora.year, ahora.month, ahora.day);
    // Determinar el color basado en la comparación
    Color colorTexto;
    bool reprograma = false;
    if (fechaMantenimiento.isBefore(fechaActual)) {
      colorTexto = Colors.red; // La fecha de mantenimiento es anterior a la fecha actual
      reprograma = true;
    } else if (fechaMantenimiento.isAtSameMomentAs(fechaActual)) {
      colorTexto = Colors.yellow; // La fecha de mantenimiento es la misma que la fecha actual
      reprograma = true;
    } else {
      colorTexto = Colors.green; // La fecha de mantenimiento es posterior a la fecha actual
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(
          color: widget.mantenimiento.codTipoMantenimiento == 1 ? Colores.esquemaColor : Colors.transparent,
          width: 2.0, // Define el ancho del borde aquí
        ),
      ),
      elevation: 4,
      child: ExpansionTile(
        title: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /* Padding(
                    padding: EdgeInsets.symmetric(vertical: vertica),
                    child: Text("Requerimiento pendiente #${widget.mantenimiento.codSolicitud}",
                        style: const TextStyle(color: Colores.esquemaColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),*/
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
                      Text(widget.mantenimiento.bodega, style: TextStyle(fontSize: letradebajo))
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
                        widget.mantenimiento.descripcionTipo,
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
                      Text(widget.mantenimiento.fechaSolicitud, style: TextStyle(fontSize: letradebajo, color: colorTexto)),
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
                  widget.mantenimiento.descripcionDetalle,
                  style: TextStyle(fontSize: letradebajo),
                  maxLines: 3,
                  softWrap: true,
                )),
              ],
            ),
          ),
          if (widget.mantenimiento.detalle != "")
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizon + 15, vertical: separacion),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    widget.mantenimiento.detalle,
                    style: TextStyle(fontSize: letradebajo),
                    maxLines: 3,
                    softWrap: true,
                  )),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: ImagenesCarrusel(mantenimiento: widget.mantenimiento),
            ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: descipcion,
                decoration: const InputDecoration(label: Text("Observación"), helperText: "Añada una observación de ser necesaria"),
                maxLines: 2,
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: _body(),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: pruebaCamaras()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                onPressed: reprograma
                    ? () async {
                        codUsuario = await storage.readSecureData("cod_usuario");
                        token = await storage.readSecureData("token");
                        mostrarDialogoConCalendario(context, now, true, widget.onFechaSeleccionada, widget.mantenimiento.codSolicitud,
                            int.parse(codUsuario), token, fechaMantenimiento);
                      }
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Row(
                  children: [
                    Text("Reprogramar", style: TextStyle(color: Colors.black)),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.calendar_month,
                      color: Colores.esquemaColor,
                      size: 20,
                    )
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: selectedImages.value.isNotEmpty && validar
                      ? () async {
                          Map<String, dynamic> llaves = {};
                          codUsuario = await storage.readSecureData("cod_usuario");
                          token = await storage.readSecureData("token");

                          await showDialog(
                            context: context,
                            barrierDismissible: false, // Hace que el diálogo no se pueda cerrar tocando fuera de él
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                return WillPopScope(
                                  onWillPop: () async => Future.value(false),
                                  child: AlertDialog(
                                    title: const Text("Alerta"),
                                    content: const Text("¿Estás seguro de completar este mantenimiento?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("Cancelar"),
                                        onPressed: () {
                                          Navigator.pop(context); // Cierra el diálogo
                                        },
                                      ),
                                      TextButton(
                                        onPressed: selectedImages.value.isNotEmpty && guarda
                                            ? () async {
                                                Fluttertoast.showToast(
                                                  backgroundColor: Colors.yellow,
                                                  textColor: Colors.black,
                                                  msg: "Enviando datos, por favor espere..",
                                                  gravity: ToastGravity.BOTTOM,
                                                  toastLength: Toast.LENGTH_LONG,
                                                );
                                                setState(() {
                                                  guarda = false;
                                                });

                                                try {
                                                  var pruebas = await enviarFotosCompletadas(selectedImages.value);

                                                  if (pruebas.statusCode != 200) {
                                                    setState(() {
                                                      guarda = true;
                                                    });
                                                    Fluttertoast.showToast(
                                                      backgroundColor: Colors.red,
                                                      textColor: Colors.white,
                                                      msg: "Ocurrió un error al procesar las imágenes",
                                                      gravity: ToastGravity.BOTTOM,
                                                      toastLength: Toast.LENGTH_LONG,
                                                    );
                                                  } else {
                                                    var data = await pruebas.stream.bytesToString();
                                                    llaves = await jsonDecode(data);
                                                    if (llaves.isNotEmpty) {
                                                      codUsuario = await storage.readSecureData("cod_usuario");
                                                      token = await storage.readSecureData("token");

                                                      var controlador = await completarMantenimiento(
                                                          token,
                                                          int.parse(codUsuario),
                                                          widget.mantenimiento.codSolicitud,
                                                          descipcion.text.trim(),
                                                          "completar_mantenimiento",
                                                          llaves);
                                                      var decode = jsonDecode(controlador.body);

                                                      if (decode["msg"] != "err") {
                                                        if (mounted) {
                                                          Navigator.pop(context);
                                                          Fluttertoast.showToast(
                                                            backgroundColor: Colors.green,
                                                            textColor: Colors.white,
                                                            msg: "Mantenimiento completado con éxito",
                                                            gravity: ToastGravity.BOTTOM,
                                                            toastLength: Toast.LENGTH_LONG,
                                                          );
                                                        }
                                                        widget.onFechaSeleccionada();
                                                      } else {
                                                        setState(() {
                                                          guarda = true;
                                                        });
                                                        await eliminarFotos(llaves["llave"]);
                                                        Fluttertoast.showToast(
                                                          backgroundColor: Colors.red,
                                                          textColor: Colors.white,
                                                          msg: "Ocurrió un error al procesar: $decode",
                                                          gravity: ToastGravity.BOTTOM,
                                                          toastLength: Toast.LENGTH_LONG,
                                                        );
                                                      }
                                                    }
                                                  }
                                                } on TimeoutException catch (e) {
                                                  setState(() {
                                                    guarda = true;
                                                  });
                                                  Fluttertoast.showToast(
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    msg: "Tiempo de espera agotado: $e",
                                                    gravity: ToastGravity.BOTTOM,
                                                    toastLength: Toast.LENGTH_SHORT,
                                                  );
                                                  await eliminarFotos(llaves["llave"]);
                                                } catch (e) {
                                                  setState(() {
                                                    guarda = true;
                                                  });
                                                  Fluttertoast.showToast(
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    msg: "Ocurrió un error: $e",
                                                    gravity: ToastGravity.BOTTOM,
                                                    toastLength: Toast.LENGTH_SHORT,
                                                  );
                                                  await eliminarFotos(llaves["llave"]);
                                                }
                                              }
                                            : null,
                                        child: const Text("Aceptar"),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                          );
                        }
                      : null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Completar"),
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
    );
  }

  Widget cargando() {
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
                    'Enviando solicitud por favor espere.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // <-- Estiliza el texto para que se ajuste
                      fontSize: 14, // <-- Cambia el tamaño de fuente según tu necesidad
                      color: Colores.esquemaColor,
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

  Widget _uploaderCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
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
      ),
    );
  }

  Widget _body() {
    return ValueListenableBuilder<List<HLPickerItem>>(
      valueListenable: selectedImages,
      builder: (context, value, child) {
        // Aquí 'value' contiene el valor actual de _selectedImages.value
        if (value.isNotEmpty) {
          return _showImage();
        } else {
          return _uploaderCard(context);
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

  Widget _showImage() {
    if (selectedImages.value.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [MediaPreview(items: selectedImages.value)],
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

  Future getImage(
    bool gallery,
  ) async {
    if (!gallery) {
      openCamera();
    } else {
      openPhotos();
    }
  }

  Future<void> openPhotos() async {
    try {
      final List<HLPickerItem> images = await picker.openPicker(
        cropping: isCroppingEnabled,
        selectedIds: includePrevSelected ? selectedImages.value.map((e) => e.id).toList() : null,
        pickerOptions: HLPickerOptions(
          mediaType: type,
          enablePreview: enablePreview,
          isExportThumbnail: isExportThumbnail,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: compressQuality,
          maxSelectedAssets: count,
          usedCameraButton: usedCameraButton,
          numberOfColumn: numberOfColumn,
          isGif: true,
        ),
        cropOptions: HLCropOptions(
          aspectRatio: aspectRatio,
          aspectRatioPresets: aspectRatioPresets,
          compressQuality: compressQuality,
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
        selectedImages.value = compressedImages;
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

  /*Future<void> openCamera() async {
    try {
      final HLPickerItem originalImage = await picker.openCamera(
        cropping: isCroppingEnabled,
        cameraOptions: HLCameraOptions(
          cameraType: type == MediaType.video ? CameraType.video : CameraType.image,
          recordVideoMaxSecond: 40,
          isExportThumbnail: isExportThumbnail,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: compressQuality,
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
          quality: 85, // Ajusta este valor según la necesidad.
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

      setState(() {
        selectedImages = [finalImage];
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
  }*/
  Future<void> openCamera() async {
    try {
      final HLPickerItem originalImage = await picker.openCamera(
        cropping: isCroppingEnabled,
        cameraOptions: HLCameraOptions(
          cameraType: type == MediaType.video ? CameraType.video : CameraType.image,
          recordVideoMaxSecond: 40,
          isExportThumbnail: isExportThumbnail,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: compressQuality,
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
      setState(() {
        selectedImages.value = List.from(selectedImages.value)..add(finalImage);
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

  Future<void> mostrarDialogoConCalendario(BuildContext context, DateTime now, bool valida, VoidCallback onConfirm, int codSolicitud, int codUsuario,
      String token, DateTime fechaMantenimiento) async {
    TextEditingController descripcion = TextEditingController();
    DateTime? fechaSeleccionada;

    final DateTime lastDate = DateTime(now.year, valida ? now.month : now.month + 1, valida ? now.day + 7 : now.day);

    // Muestra el diálogo personalizado
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Seleccione una fecha de reprogramación"),
          content: SizedBox(
            // Ajusta el tamaño según necesites
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  child: CalendarDatePicker(
                    initialDate: fechaMantenimiento,
                    firstDate: fechaMantenimiento,
                    lastDate: lastDate,
                    onDateChanged: (DateTime newDate) {
                      fechaSeleccionada = newDate;
                    },
                  ),
                ),
                TextField(
                  controller: descripcion,
                  decoration: const InputDecoration(label: Text("Descripción"), helperText: "Añada una descripción"),
                  maxLines: 2,
                ),
              ],
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
              onPressed:
                  fechaSeleccionada != null && fechaSeleccionada?.isAtSameMomentAs(fechaMantenimiento) == false && descripcion.text.trim() != ""
                      ? () async {
                          // Aquí manejas la fecha seleccionada
                          try {
                            if (fechaSeleccionada != null && fechaSeleccionada?.isAtSameMomentAs(fechaMantenimiento) == false) {
                              if (descripcion.text.trim() != "") {
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.yellow,
                                  textColor: Colors.black,
                                  msg: "Guardando reprogramación, por favor espere...",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_LONG,
                                );
                                final String formattedDate = DateFormat('dd/MM/yyyy').format(fechaSeleccionada!);
                                var envio = await reprogramaMantenimiento(
                                    token, codUsuario, formattedDate, codSolicitud, descripcion.text.trim(), "reprograma_mantenimiento");
                                var decode = jsonDecode(envio.body);
                                if (decode["msg"] != "err") {
                                  Fluttertoast.showToast(
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    msg: "Mantenimiento reprogramado correctamente",
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
                                  msg: "Agregue una descripción",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              }
                              // Realiza acciones con la fecha seleccionada
                            } else {
                              Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                msg: "Seleccione una fecha superior a la planificada",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG,
                              );
                              // onConfirm();
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
                        }
                      : null,
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
