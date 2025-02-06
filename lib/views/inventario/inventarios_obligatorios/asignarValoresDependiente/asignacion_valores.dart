// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/views/home_farma/home_farma.dart';

import 'package:intl/intl.dart';

class AsignacionValores extends StatefulWidget {
  final String token;
  final String codBodega;
  const AsignacionValores({
    Key? key,
    required this.token,
    required this.codBodega,
  }) : super(key: key);

  @override
  State<AsignacionValores> createState() => _AsignacionValoresState();
}

class _AsignacionValoresState extends State<AsignacionValores> {
  @override
  void initState() {
    super.initState();
    datosIniciales();
  }
  String periodo = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async {
                await Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const HomeFarma()), (Route<dynamic> route) => false);
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text('Ajustes pendientes'),
        ),
        body: datos(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    scrollable: true,
                    title: const Text('¿Está seguro de procesar estos datos?'),
                    content: const Text('No podrá volver atrás'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          await Fluttertoast.showToast(
                            backgroundColor: Colors.yellow,
                            textColor: Colors.black,
                            msg: "Procesando datos, por favor espere...",
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                          );

                          Navigator.of(context).pop();
                          // var codUsuario = await storage.readSecureData("cod_usuario");
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  );
                });
              },
            );
          },
          label: const Row(
            children: [
              Icon(Icons.adjust), // Ícono que deseas mostrar
              SizedBox(width: 8), // Espacio entre el ícono y el texto
              Text("Ajustar"),
            ],
          ),
        ));
  }

  Widget datos() {
    return const Column(
      children: [
        //Expanded(child: listaAjuste()),
        Card(
          elevation: 1.0,
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Valor total:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('asdasdasdasdasdasd', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 70),
      ],
    );
  }

  /*Widget listaAjuste() {
    if (valoresAjustes.isEmpty) {
      return const Center(
        child: Text("Sin datos para ajustar."),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8.0),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: valoresAjustes.length,
          itemBuilder: (BuildContext context, int indice) {
            Ajuste ajuste = valoresAjustes[indice];

            return Card(
              elevation: 4.0,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ajuste.nombreLaboratorio.length > 30 ? ajuste.nombreLaboratorio.substring(0, 30) : ajuste.nombreLaboratorio,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              // color: Colores.esquemaColor, // Define el color adecuado
                            ),
                          ),
                          Text('${ajuste.totalValor}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }*/
  Future<void> datosIniciales() async {
    DateTime now = DateTime.now();

    // Formatea la fecha en el formato deseado (año y mes)
    String formattedDate = DateFormat('yyyyMM').format(now);

    periodo = formattedDate;

    //var datos= await obtenerValoresAsignacion(widget.token, int.parse(widget.codBodega));
  }
}
