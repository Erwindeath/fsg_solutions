import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_data_inicial.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:soundpool/soundpool.dart';

List<Inventario> parseOrdernes(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Inventario>((json) {
    final codBarraAdicionalString = json["Cod_Barra_Adicional"];
    // Decodificar la cadena JSON en una lista de objetos
    final codBarraAdicionalList = jsonDecode(codBarraAdicionalString) as List<dynamic>;
    return Inventario(
        codBarra: json["Cod_Barra"],
        codProducto: json["Cod_Producto"],
        producto: json["Descripcion"].toString().trim(),
        codLaboratorio: json["Cod_Laboratorio"],
        cantidad: json["Unidad"]??0,
        fraccion: json["Fraccion"]??0,
        codBarraAdicional: codBarraAdicionalList.map((item) => item["Cod_Barra"]).toList(),
        politica: json["politica"].toString(),
        cajasEscaneadas: 0,
        fraccionesEscaneadas: 0,
        cajasCaducadas: 0,
        fraccionesCaducadas: 0,
        fraccionesMalPicadas: 0,
        estado: 0,
        observacion: json["observacion"],
        bonificacion: json["bonificacion"],
        fraccionDv: json["FraccionDv"],
        costo: double.parse(json["Costo_Promedio"].toString()),
        iva: json["Producto_Iva"],
        cajaPromo: 0,
        fraccionPromo: 0,
        fechaEscaneo: '',
        codTipo: json["Tipo"].toString()
        //echaEscaneo: json["Fecha_Inicio"].toString(),
        );
  }).toList();
}

List<Personal> parsePersonal(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Personal>((json) {
    return Personal(nombre: json["Nombres"], cedula: json["Cedula"], ciudad: json["Ciudad"], codUsuario: json["Cod_Usuario"]);
  }).toList();
}

List<ReportItem> parseReporteInicial(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<ReportItem>((json) {
    return ReportItem(
      laboratorio: json['Laboratorio'],
      descripcion: json['Descripcion'],
      cantidadCajas: json['cantidadCajas'],
      cantidadFracciones: json['cantidadFracciones'],
      precioCaja: json['precioCaja'].toDouble(),
      precioFraccion: json['precioFraccion'].toDouble(),
      total: json['total'].toDouble(),
      totalInventariar: json['totalSuma'].toDouble(),
    );
  }).toList();
}

List<Equipo> parseEquipo(String responseBody) {
  final parsed = json.decode(responseBody)["data"].cast<Map<String, dynamic>>();
  return parsed.map<Equipo>((json) {
    return Equipo(equipoNombre: json["Nombres"], equipoDetails: json["Cedula"]);
  }).toList();
}

Future<void> sounidoErrorProducto() async {
  Soundpool pool = Soundpool.fromOptions(options: const SoundpoolOptions(streamType: StreamType.notification));

  int soundId = await rootBundle.load("assets/sonidos/producto.mp3").then((ByteData soundData) {
    return pool.load(soundData);
  });
  await pool.play(soundId);
}

List<Ajuste> parsearAjustes(String responseBody) {
  final parsed = json.decode(responseBody)["datos"].cast<Map<String, dynamic>>();
  return parsed.map<Ajuste>((json) {
    return Ajuste(
        siglas: json["Siglas"],
        nombreLaboratorio: json["Nombres"],
        totalValor: double.parse(json["Total_Valor"].toString()),
        totalBase0: double.parse(json["Total_Base_0"].toString()),
        totalIva: double.parse(json["Total_IVA"].toString()));
  }).toList();
}

List<ProductosCobro> parsearCobros(String responseBody) {
  var datosDependientes = jsonDecode(responseBody)["data"];
  final parsed = json.decode(responseBody)["dataCobro"].cast<Map<String, dynamic>>();
  return parsed.map<ProductosCobro>((json) {
    return ProductosCobro(
        productoIva: json['Producto_Iva'],
        codProducto: json['Cod_Producto'],
        fraccion: json["Fraccion"],
        descripcion: json['Descripcion'],
        cantU: json['Cant_U'],
        cantF: json['Cant_F'],
        cantReal: (json['Cant_Real'] as num).toDouble(),
        precio: (json['Precio'] as num).toDouble(),
        iva: (json["iva"] as num).toDouble(),
        baseIva: (json['baseiva'] as num).toDouble(),
        baseCero: (json['basecero'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        descuento: (json['Descuento'] as num).toDouble(),
        costo: (json['Costo'] as num).toDouble(),
        precioPublico: (json['Precio_Publico'] as num).toDouble(),
        parcial: (json['Parcial'] as num).toDouble(),
        codUsuario: datosDependientes.length > 1 ? 0 : int.parse(datosDependientes[0]["Cod_Usuario"].toString()));
  }).toList();
}

List<ProductosAjustados> parsearProductosAjustados(String responseBody) {
  final parsed = json.decode(responseBody)["datos"].cast<Map<String, dynamic>>();
  return parsed.map<ProductosAjustados>((json) {
    return ProductosAjustados(
        codProducto: json['Cod_Producto'],
        descripcion: json['Descripcion'],
        unidad: json['Unidad'],
        fraccion: json['Fraccion'],
        cajasIngresadas: json['CajasIngresadas'],
        fraccionesIngresadas: json['FraccionesIngresadas'],
        cajasBuenas: json['Cajas_Buenas'],
        fraccionesBuenas: json['Fracciones_Buenas'],
        cajasCaducadas: json['Cajas_Caducadas'],
        fraccionesCaducadas: json['Fracciones_Caducadas'],
        stockActual: (json['stockActual'] as num).toDouble(),
        stockEncontrado: (json['stockIngresado'] as num).toDouble());
  }).toList();
}
