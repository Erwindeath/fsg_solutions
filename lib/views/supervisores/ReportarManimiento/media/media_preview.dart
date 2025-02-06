import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hl_image_picker_android/hl_image_picker_android.dart';
import 'package:badges/badges.dart' as badges;

// Paso 1: Convertir en StatefulWidget
class MediaPreview extends StatefulWidget {
  final List<HLPickerItem> items;

  const MediaPreview({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return _uploaderCard();
    }

    return SizedBox(
      height: 240,
      width: double.infinity,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        itemBuilder: (_, index) {
          File? imageFile = File(widget.items[index].path);
          if (widget.items[index].type == "video") {
            imageFile = widget.items[index].thumbnail != null ? File(widget.items[index].thumbnail!) : null;
          }
          return imageFile != null
              ? InkWell(
                  onTap: () {/*openCortador(widget.items[index]);*/},
                  child: badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -20, end: -15),
                      badgeStyle: const badges.BadgeStyle(
                        elevation: 0,
                        badgeColor: Colors.transparent,
                      ),
                      badgeContent: Center(
                        child: IconButton(
                          onPressed: () {
                            // Paso 2: Eliminar elemento y actualizar UI
                            setState(() {
                              widget.items.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.remove_circle, size: 40.0),
                          color: Colors.red,
                        ),
                      ),
                      child: Image.file(imageFile)))
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  width: 320,
                  height: double.infinity,
                  child: const Text('No thumbnail'));
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8.0),
      ),
    );
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
/*void openCortador(HLPickerItem item) async {
    try {
      final croppedImage = await _picker.openCropper(
        item.path,
        cropOptions: HLCropOptions(
          aspectRatio: _aspectRatio,
          aspectRatioPresets: _aspectRatioPresets,
          compressQuality: _compressQuality,
          compressFormat: CompressFormat.jpg,
        ),
      );

      // Encuentra el índice del item que fue cortado
      int index = widget.items.indexOf(item);
      if (index != -1) {
        setState(() {
          // Reemplaza el item cortado con el nuevo en la misma posición
          widget.items[index] = croppedImage;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }*/
}
