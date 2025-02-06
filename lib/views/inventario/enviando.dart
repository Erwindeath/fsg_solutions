import 'package:flutter/material.dart';

class CargandoEnvio extends StatelessWidget {
  final String texto;
  final Color colorTexto;
  final double width;
  final double height;
  final double tamanoTexto;

  const CargandoEnvio({
    Key? key,
    required this.texto,
    required this.colorTexto,
    this.width = 300.0, // Valor por defecto es 300
    this.height = 300.0, // Valor por defecto es 300
    required this.tamanoTexto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Opacity(
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
                    width: width,
                    height: height,
                    child: const CircularProgressIndicator(),
                  ),
                  Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: tamanoTexto,
                      color: colorTexto,
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
}
