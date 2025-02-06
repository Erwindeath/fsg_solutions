import 'package:flutter/material.dart';
import 'package:fsg_solutions/complementos/globals/colors.dart';

import 'package:badges/badges.dart' as badges;

// ignore: non_constant_identifier_names
Widget MenuAcciones({children, int itemPorLinea = 1}) {
  List<Widget> newChildren = [];

  int dividir = itemPorLinea;
  int factor = (dividir < children.length) ? dividir : children.length;
  int factorCrecimiento = (children.length / dividir).ceil();
  for (var i = 0; i < factorCrecimiento; i++) {
    List<Widget> botones = [];
    for (var child in children.sublist(0, factor)) {
      botones.add(child);
    }
    children.removeRange(0, factor);
    factor = (dividir < children.length) ? dividir : children.length;
    newChildren.add(LineaMenu(children: botones, itemPorLinea: itemPorLinea));
  }

  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    child: Column(
      children: newChildren,
    ),
  );
}

// ignore: non_constant_identifier_names
Widget LineaMenu({children, itemPorLinea}) {
  var vacios = itemPorLinea - children.length;

  for (var i = 0; i < vacios; i++) {
    children.add(BotonVacio());
  }

  return Row(
    children: children,
  );
}

// ignore: non_constant_identifier_names
Widget Principal({children}) {
  return Row(children: [
    Expanded(
      child: Column(
        children: children,
      ),
    ),
  ]);
}

// ignore: non_constant_identifier_names
Widget BotonMenu({
  String? nombre,
  IconData icono = Icons.token,
  IconData? secondaryIcon, // Nuevo parámetro opcional
  callback,
  bool? habilitado,
  required bool valida,
  int? valorValidar,
  int? valorCompletar,
  color,
}) {
  String badgeText = '';
  if (nombre == "Validar Mantenimiento" && valorValidar != null && valorValidar > 0) {
    badgeText = valorValidar.toString();
  } else if (nombre == "Completar mantenimiento" && valorCompletar != null && valorCompletar > 0) {
    badgeText = valorCompletar.toString();
  }
  return Expanded(
    child: GestureDetector(
      onTap: habilitado! ? () => callback() : null,
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: 0, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        showBadge: valida && badgeText.isNotEmpty,
        // Mostrar el badge solo si hay unidades o fracciones
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color.fromRGBO(205, 62, 45, 1),
          padding: EdgeInsets.all(8),
        ),
        badgeContent: Text(
          badgeText,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: Card(
          color: habilitado ? null : Colors.grey[200],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Stack(
                    children: [
                      Icon(icono, color: habilitado ? color : Colors.grey, size: 50),
                      if (secondaryIcon != null)
                        Positioned.directional(
                          textDirection: TextDirection.ltr,
                          end: 0,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 54.0),
                              child: Icon(
                                secondaryIcon,
                                size: 25.0,
                                color: Colores.esquemaColor, // Cambia esto al color que desees
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    nombre!,
                    style: TextStyle(
                      color: habilitado ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget BotonVacio() {
  return const Expanded(
    child: SizedBox.shrink(),
  );
}
