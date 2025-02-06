// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/views/supervisores/ReportarManimiento/clases_reporte_mantenimiento.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' as cp;
import 'package:fsg_solutions/views/supervisores/menuSuper.dart';

import 'package:fsg_solutions/views/supervisores/ReportarManimiento/media/media_preview.dart';
import 'package:hl_image_picker_android/hl_image_picker_android.dart';
import '../../../complementos/logica/storage.dart';
import '../logica_supervisores.dart';
import 'methods.dart';

class ReportarMantenimiento extends StatefulWidget {
  const ReportarMantenimiento({Key? key}) : super(key: key);

  @override
  State<ReportarMantenimiento> createState() => _ReportarMantenimientoState();
}

class _ReportarMantenimientoState extends State<ReportarMantenimiento> {
  TextEditingController descipcion = TextEditingController();
  int numeroFarmacia = 0;
  int tipoMantenimiento = 0;
  String token = "";
  int compresion = 100;
  List<Bodegas> bodegas = [];
  List<Mantenimientos> tipoMantenimientos = [];
  List<DetalleMantenimiento> detallesSeleccionados = [];
  int detalleMantenimientoSeleccionado = 0;
  bool load = false;
  bool _isLoading = false;
  ValueNotifier<List<HLPickerItem>> _selectedImages = ValueNotifier([]);
  final _picker = HLImagePickerAndroid();
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
  bool guarda = true;
  final SecureStorage _storage = SecureStorage();
  List<DropdownMenuItem<int>>? generarFarmacias() {
    List<DropdownMenuItem<int>>? listadoFarmacias = [];
    listadoFarmacias.add(
      const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione una farmacia"),
      ),
    );
    for (var elemento in bodegas) {
      listadoFarmacias.add(
        DropdownMenuItem(
          value: elemento.codBodega,
          child: Text(elemento.nombreBodega),
        ),
      );
    }
    return listadoFarmacias;
  }

  List<DropdownMenuItem<int>>? generarTiposMantenimientos() {
    List<DropdownMenuItem<int>>? listadoTiposMantenimiento = [];
    listadoTiposMantenimiento.add(
      const DropdownMenuItem(
        value: 0,
        child: Text("Seleccione el tipo de mantenimiento"),
      ),
    );
    for (var elemento in tipoMantenimientos) {
      listadoTiposMantenimiento.add(
        DropdownMenuItem(
          value: elemento.tipoMantenimiento,
          child: Text(elemento.descripcioMantenimiento),
        ),
      );
    }
    return listadoTiposMantenimiento;
  }

  @override
  void initState() {
    super.initState();
    datosIniciales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de mantenimiento'),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            datosIniciales();
          },
          child: Stack(children: <Widget>[load ? datos() : segundo(), if (_isLoading) cargando()])),
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

  Widget datos() {
    return Card(
      elevation: 2,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: DropdownSearch<Bodegas>(
                            items: bodegas,
                            popupProps: PopupProps.menu(
                              showSearchBox: true, // Habilita el cuadro de búsqueda
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  title: Text(item.nombreBodega),
                                );
                              },
                            ),
                            dropdownDecoratorProps: const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Farmacias",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            itemAsString: (Bodegas? bodega) => bodega?.nombreBodega ?? '',
                            onChanged: (Bodegas? newValue) {
                              setState(() {
                                numeroFarmacia = newValue?.codBodega ?? 0;
                              });
                            },
                            selectedItem: bodegas.firstWhere(
                              (bodega) => bodega.codBodega == numeroFarmacia,
                              orElse: () => Bodegas(codBodega: 0, nombreBodega: 'Seleccione una farmacia'), // Asegúrate de manejar el caso null aquí
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Tipo mantenimiento",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  value: tipoMantenimiento,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: generarTiposMantenimientos(),
                                  isExpanded: true,
                                  onChanged: numeroFarmacia > 0
                                      ? (int? newValue) {
                                          setState(() {
                                            tipoMantenimiento = newValue!;
                                            detallesSeleccionados = tipoMantenimientos
                                                .firstWhere(
                                                  (mantenimiento) => mantenimiento.tipoMantenimiento == newValue,
                                                  orElse: () => Mantenimientos(
                                                      tipoMantenimiento: 0, descripcioMantenimiento: "Seleccione un detalle", detalles: []),
                                                )
                                                .detalles;
                                            detalleMantenimientoSeleccionado = 0;
                                          });
                                        }
                                      : null),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: generarDropdownDetalles(), // Llamar al método aquí
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            minLines: 3,
                            controller: descipcion,
                            decoration: const InputDecoration(hintText: "Describa la solicitud de mantenimiento"),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: _body()),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: pruebaCamaras()),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45.0,
                              child: ElevatedButton(
                                onPressed: _selectedImages.value.isNotEmpty &&
                                        tipoMantenimiento != 0 &&
                                        detalleMantenimientoSeleccionado != 0 &&
                                        numeroFarmacia != 0 &&
                                        guarda
                                    ? () async {
                                        setState(() {
                                          guarda = false;
                                          _isLoading = true;
                                        });

                                        try {
                                          var prueba = await enviarFotos(_selectedImages.value);
                                          if (prueba.statusCode != 200) {
                                            setState(() {
                                              guarda = true;
                                              _isLoading = false;
                                            });
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
                                              String codUsuario = await _storage.readSecureData("cod_usuario");

                                              var envio = await enviarMantenimiento(token, int.parse(codUsuario), numeroFarmacia, tipoMantenimiento,
                                                  detalleMantenimientoSeleccionado, descipcion.text, llaves);
                                              var mensaje = jsonDecode(envio.body)["msg"];

                                              if (mensaje != "err") {
                                                if (mounted) {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  await ArtSweetAlert.show(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      artDialogArgs: ArtDialogArgs(
                                                          type: ArtSweetAlertType.success,
                                                          title: "Correcto",
                                                          text: "Solicitud de mantenimiento enviada con éxito",
                                                          confirmButtonText: "Aceptar",
                                                          onConfirm: () async {
                                                            await Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (BuildContext context) => const MenuSuper(),
                                                              ),
                                                              (route) => false,
                                                            );
                                                          },
                                                          confirmButtonColor: Colores.esquemaColor));
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  msg: "Ocurrió un error: $mensaje",
                                                  gravity: ToastGravity.BOTTOM,
                                                  toastLength: Toast.LENGTH_LONG,
                                                );
                                                setState(() {
                                                  guarda = true;
                                                  _isLoading = false;
                                                });
                                                await eliminarFotos(llaves["llave"]);
                                              }
                                            }
                                          }
                                        } on TimeoutException catch (e) {
                                          setState(() {
                                            guarda = true;
                                            _isLoading = false;
                                          });
                                          Fluttertoast.showToast(
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            msg: e.toString(),
                                            gravity: ToastGravity.BOTTOM,
                                            toastLength: Toast.LENGTH_LONG,
                                          );
                                        } on SocketException catch (e) {
                                          setState(() {
                                            guarda = true;
                                            _isLoading = false;
                                          });
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
                                child: const Text("GUARDAR"),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget segundo() {
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

  Widget _body() {
    if (_selectedImages.value.isNotEmpty) {
      return _showImage();
    } else {
      return _uploaderCard();
    }
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
    if (_selectedImages.value.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [MediaPreview(items: _selectedImages.value)],
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
      setState(() {
        _selectedImages.value = List.from(_selectedImages.value)..add(finalImage);
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

  Widget generarDropdownDetalles() {
    List<DropdownMenuItem<int>> itemsDetalles = detallesSeleccionados.map((detalle) {
      return DropdownMenuItem<int>(
        value: detalle.tipoDescripcion, // Asume que cada detalle tiene un identificador único
        child: Text(detalle.tipoDetalle),
      );
    }).toList();

    itemsDetalles.insert(0, const DropdownMenuItem(value: 0, child: Text("Seleccione un detalle")));

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Detalle mantenimiento",
        // Aplica un borde al InputDecorator, que a su vez afecta visualmente al DropdownButton
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0), // Ajusta estos valores según necesites

        // Podrías aplicar más estilos aquí si lo deseas
      ),
      child: DropdownButtonHideUnderline(
        // Esto elimina la línea de subrayado
        child: DropdownButton<int>(
          value: detalleMantenimientoSeleccionado, // Asegúrate de que esta variable esté definida y gestionada adecuadamente
          icon: const Icon(Icons.keyboard_arrow_down),
          items: itemsDetalles,
          isExpanded: true,
          onChanged: detallesSeleccionados.isNotEmpty
              ? (int? newValue) {
                  setState(() {
                    detalleMantenimientoSeleccionado = newValue!;
                  });
                }
              : null,
          // Asegurando que el dropdown se muestre completamente en el InputDecorator
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> datosIniciales() async {
    bodegas.clear();
    token = await _storage.readSecureData("token");
    var datos = await obtenerBodegasYMantenimientos(token);
    //print(jsonDecode(datos.body)["dataMantenimientos"]);

    setState(() {
      bodegas = parseBodegas(datos.body);
      tipoMantenimientos = parseMantenimientos(datos.body);
      load = true;
    });
  }
}
