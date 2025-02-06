import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/logica_inventario_general.dart';

import 'cobro_dependiente/pdf_factura.dart';

Future<bool> imprimeProcesa(List<dynamic> data, String token, int codBodega) async {
  List<Dato> datosList = [];

  List<int> secuenciales = data.map((venta) => int.parse(venta['Secuencial'].toString())).toList();

  for (int secuencial in secuenciales) {
    // Obtener datos adicionales con la llamada API
    var datosResponse = await obtenerDatosVenta(token, secuencial, codBodega);

    // Decodificar la respuesta JSON
    var datosJson = jsonDecode(datosResponse.body);

    if (datosJson["msg"] != "err") {
      // Verificar el tipo de 'datosJson' y crear instancias de 'Dato'
      if (datosJson['datos'] is List) {
        datosList.addAll((datosJson['datos'] as List).map((datoJson) => Dato.fromJson(Map<String, dynamic>.from(datoJson))).toList());
      }
    } else {
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Ocurrió un error al obtener los datos a cobrar.",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
  //Dato datosFactura = datosList[0];
  // Ahora 'datosList' contiene todas tus instancias de 'Dato' obtenidas de las llamadas API
  // Puedes procesar/imprimir/utilizar estos datos como desees.
  // ...

  // Ejemplo: Crear PDF
  PdfCreator pdfcreator = PdfCreator();
  bool valor = await pdfcreator.crearPdfFactura(datosList); // Asumiendo que crearPdfFactura() acepta un parámetro
  return valor;
  // Otro código según sea necesario
  // ...
}

class Respuesta {
  String msg;
  List<Dato> datos;

  Respuesta({required this.msg, required this.datos});

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(
      msg: json['msg'],
      datos: (json['datos'] as List).map((e) => Dato.fromJson(e)).toList(),
    );
  }
}

Future<List<Dato>> facturaDependienteActaConciliacion(Map<String, dynamic> data, String token, int codBodega, int codInventario) async {
  List<Dato> datosList = [];
  var compruebaDatos = await datosFactura(token, codBodega, codInventario);

  var datosDecode = jsonDecode(compruebaDatos.body);
  // Lista para almacenar los números internos
  List<int> numerosInternos = [];

  // Comprueba si la clave 'datos' existe y es una lista
  if (datosDecode['datos'] != null && datosDecode['datos'] is List) {
    // Itera sobre cada elemento en la lista 'datos'
    for (var item in datosDecode['datos']) {
      // Asegúrate de qsue el elemento tenga un campo 'N° Interno'
      if (item['N° Interno'] != null) {
        numerosInternos.add(int.parse(item['N° Interno']));
      }
    }
  }

  // Imprime los números internos
  for (var numero in numerosInternos) {
    var datosResponse = await obtenerDatosVenta(token, numero, codBodega);

    // Decodificar la respuesta JSON
    var datosJson = jsonDecode(datosResponse.body);

    if (datosJson["msg"] != "err") {
      // Verificar el tipo de 'datosJson' y crear instancias de 'Dato'
      if (datosJson['datos'] is List) {
        datosList.addAll((datosJson['datos'] as List).map((datoJson) => Dato.fromJson(Map<String, dynamic>.from(datoJson))).toList());
      }
    } else {
      await Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: "Ocurrió un error al obtener los datos a cobrar.",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
  return datosList;
}

class Dato {
  String ruc;
  String razonSocial;
  String dirMatriz;
  String documento;
  String claveAcceso;
  String rucCliente;
  String nombreCliente;
  String direccion;
  String telefono;
  String fecha;
  String infoAdicional;
  String formaPago;
  double monto;
  int plazo;
  String unidad;
  double baseIva;
  double base0;
  double iva;
  double total;
  bool tarifaIva;
  double compensacion;
  double descuentos;
  double recargo;
  List<Detail> details;

  Dato({
    required this.ruc,
    required this.razonSocial,
    required this.dirMatriz,
    required this.documento,
    required this.claveAcceso,
    required this.rucCliente,
    required this.nombreCliente,
    required this.direccion,
    required this.telefono,
    required this.fecha,
    required this.infoAdicional,
    required this.formaPago,
    required this.monto,
    required this.plazo,
    required this.unidad,
    required this.baseIva,
    required this.base0,
    required this.iva,
    required this.total,
    required this.tarifaIva,
    required this.compensacion,
    required this.descuentos,
    required this.recargo,
    required this.details,
  });

  factory Dato.fromJson(Map<String, dynamic> json) {
    return Dato(
      ruc: json['Ruc'] ?? "",
      razonSocial: json['Razon_Social'] ?? "",
      dirMatriz: json['Dir_Matriz'] ?? "",
      documento: json['Documento'] ?? "",
      claveAcceso: json['Clave_Acceso'] ?? "",
      rucCliente: json['Ruc_Cliente'] ?? "",
      nombreCliente: json['Nombre_Cliente'] ?? "",
      direccion: json['Direccion'] ?? "",
      telefono: json['Telefono'] ?? "",
      fecha: json['Fecha'] ?? "",
      infoAdicional: json['Info_Adicional'] ?? "",
      formaPago: json['Forma_Pago'] ?? "",
      monto: (json['Monto'] as num).toDouble(),
      plazo: json['Plazo'],
      unidad: json['unidad'],
      baseIva: double.parse(json['Base_iva'].toString()),
      base0: double.parse(json['Base_0'].toString()),
      iva: double.parse(json['Iva'].toString()),
      total: double.parse(json['Total'].toString()),
      tarifaIva: json['Tarifa_Iva'],
      compensacion: double.parse(json['Compensacion'].toString()),
      descuentos: double.parse(json['Descuentos'].toString()),
      recargo: double.parse(json['Recargo'].toString()),
      details: (jsonDecode(json['Details']) as List).map((e) => Detail.fromJson(e)).toList(),
    );
  }
}

class Detail {
  String descripcion;
  int codProducto;
  double cant;
  int cantUnidad;
  int cantFraccion;
  double total;
  double precioSinImpuesto;

  Detail({
    required this.descripcion,
    required this.codProducto,
    required this.cant,
    required this.cantUnidad,
    required this.cantFraccion,
    required this.total,
    required this.precioSinImpuesto,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      descripcion: json['Descripcion'],
      codProducto: json['Cod_Producto'],
      cant: json['Cant'],
      cantUnidad: json['Cant_Unidad'],
      cantFraccion: json['Cant_Fraccion'],
      total: json['Total'] ?? 0.0,
      precioSinImpuesto: json['Precio_Sin_Impuesto'],
    );
  }
}
