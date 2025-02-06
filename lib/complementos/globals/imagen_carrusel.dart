// ignore_for_file: prefer_final_fields, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../views/administrador/validarMantenimiento/clase_mantenimientos.dart';

class ImagenesCarrusel extends StatefulWidget {
  final Mantenimientos mantenimiento;

  const ImagenesCarrusel({Key? key, required this.mantenimiento}) : super(key: key);

  @override
  _ImagenesCarruselState createState() => _ImagenesCarruselState();
}

class _ImagenesCarruselState extends State<ImagenesCarrusel> {
  bool _imagenesCargadas = false;
  List<String> _imagenesUrls = [];
  Map<int, bool> _erroresDeCarga = {}; // Rastrea qué imágenes tuvieron errores al cargar

  @override
  void initState() {
    super.initState();
    _cargarImagenes();
  }

  void _cargarImagenes() {
    if (!_imagenesCargadas) {
      _imagenesUrls = widget.mantenimiento.imagenes.map<String>((imagen) {
        return "$URL3$imagen";
      }).toList();

      setState(() => _imagenesCargadas = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _imagenesCargadas && _imagenesUrls.isNotEmpty
        ? CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              viewportFraction: 0.4,
              initialPage: 0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            items: List.generate(_imagenesUrls.length, (index) {
              String imageUrl = _imagenesUrls[index];
              return GestureDetector(
                onTap: () {
                  if (_erroresDeCarga[index] != true) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(10),
                          child: PhotoViewGallery.builder(
                            itemCount: _imagenesUrls.length,
                            builder: (context, index) {
                              return PhotoViewGalleryPageOptions(
                                imageProvider: NetworkImage(_imagenesUrls[index]),
                                minScale: PhotoViewComputedScale.contained * 0.8,
                                maxScale: PhotoViewComputedScale.covered * 2,
                              );
                            },
                            backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                            pageController: PageController(initialPage: _imagenesUrls.indexOf(imageUrl)),
                            scrollPhysics: const BouncingScrollPhysics(),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey, // Color de fondo del contenedor
                        borderRadius: BorderRadius.circular(8.0), // Borde redondeado
                        border: Border.all(
                          color: Colors.white, // Color del borde
                          width: 3, // Ancho del borde
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0), // Asegúrate de que coincide con el borde del contenedor
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            _erroresDeCarga[index] = true; // Marca esta imagen como error
                            return const Center(child: Icon(Icons.error, color: Colors.red));
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
