// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';
import 'package:fsg_solutions/views/administrador/completarMantenimiento/detalle_completar.dart';
import 'package:fsg_solutions/views/administrador/validarMantenimiento/clase_mantenimientos.dart';

import 'package:badges/badges.dart' as badges;

class CompletarTarjeta extends StatelessWidget {
  final RutaConMantenimientos rutaConMantenimientos;
  final VoidCallback onTap;
  final bool validacion;
  final VoidCallback onFechaSeleccionada;

  CompletarTarjeta({
    Key? key,
    required this.rutaConMantenimientos,
    required this.onTap,
    required this.validacion,
    required this.onFechaSeleccionada,
  }) : super(key: key);

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //onTap: widget.onTap,
      child: Card(
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
              ],
            ),
            children: rutaConMantenimientos.mantenimientos.map((mantenimiento) {
              return DetalleCompletarWidget(mantenimiento: mantenimiento, onFechaSeleccionada: onFechaSeleccionada);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
