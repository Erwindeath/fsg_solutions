import 'package:flutter/material.dart';

class CircularPrimero extends StatelessWidget {
  final String texto;
  final double ancho;
  final double alto;

  const CircularPrimero({
    Key? key,
    required this.texto,
    this.ancho = 200.0, // Valor por defecto
    this.alto = 200.0, // Valor por defecto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: ancho,
                height: alto,
                child: const CircularProgressIndicator(),
              ),
              Text(texto),
            ],
          ),
        ],
      ),
    );
  }
}
