import 'dart:convert';

import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/database/inventario_sqlite.dart';

class Inventario {
  final int codProducto;
  final String codBarra;
  final String producto;
  final int codLaboratorio;
  //final int cantidadUnidad;
  late int cantidad;
  //final int codCodigo;
  final int fraccion;

  var codBarraAdicional = [];
  final String politica;
  final int cajasEscaneadas;
  final int fraccionesEscaneadas;
  final int cajasCaducadas;
  final int fraccionesCaducadas;
  final int fraccionesMalPicadas;
  final int estado;
  final String observacion;
  final String bonificacion;
  final int fraccionDv;
  final double costo;
  final String iva;
  final int cajaPromo;
  final int fraccionPromo;
  final String fechaEscaneo;
  final String codTipo;

  Inventario(
      {required this.codBarra,
      required this.codProducto,
      required this.producto,
      required this.codLaboratorio,
      //required this.cantidadUnidad,
      required this.cantidad,
      //required this.codCodigo,
      required this.fraccion,
      required this.codBarraAdicional,
      required this.politica,
      required this.cajasEscaneadas,
      required this.fraccionesEscaneadas,
      required this.cajasCaducadas,
      required this.fraccionesCaducadas,
      required this.fraccionesMalPicadas,
      required this.estado,
      required this.observacion,
      required this.bonificacion,
      required this.fraccionDv,
      required this.costo,
      required this.iva,
      required this.cajaPromo,
      required this.fraccionPromo,
      required this.fechaEscaneo,
      required this.codTipo});
  Map<String, dynamic> toMap() {
    //
    //
    return {
      DatabaseHelper.columnCodProducto: codProducto,
      DatabaseHelper.columnProducto: producto,
      DatabaseHelper.columnCodBarra: codBarra,
      DatabaseHelper.columnCodLaboratorio: codLaboratorio,
      DatabaseHelper.columnCantidad: cantidad,
      DatabaseHelper.columnFraccion: fraccion,
      DatabaseHelper.columnCodBarraAdicional: jsonEncode(codBarraAdicional), // Convertir la lista en una cadena JSON
      DatabaseHelper.columnPolitica: politica,
      DatabaseHelper.columnCajasEscaneadas: cajasEscaneadas,
      DatabaseHelper.columnFraccionesEscaneadas: fraccionesEscaneadas,
      DatabaseHelper.columnaCajasCaduda: cajasCaducadas,
      DatabaseHelper.columnaFraccionesCaduca: fraccionesCaducadas,
      DatabaseHelper.columnFraccionesPicadas: fraccionesMalPicadas,
      DatabaseHelper.validacionProducto: 0,
      DatabaseHelper.columnObservacion: observacion,
      DatabaseHelper.columnBonificacion: bonificacion,
      DatabaseHelper.columFraccionDv: fraccionDv,
      DatabaseHelper.columCosto: costo,
      DatabaseHelper.columIva: iva,
      DatabaseHelper.columCajaPromo: cajaPromo,
      DatabaseHelper.columFraccionPromo: fraccionPromo,
      DatabaseHelper.columFechaEscaneo: fechaEscaneo,
      DatabaseHelper.columCodTipo: codTipo,
    };
  }

  factory Inventario.fromMap(Map<String, dynamic> map) {
    return Inventario(
      codBarra: map[DatabaseHelper.columnCodBarra],
      codProducto: map[DatabaseHelper.columnCodProducto],
      producto: map[DatabaseHelper.columnProducto],
      codLaboratorio: map[DatabaseHelper.columnCodLaboratorio],
      cantidad: map[DatabaseHelper.columnCantidad],
      fraccion: map[DatabaseHelper.columnFraccion],
      codBarraAdicional: jsonDecode(map[DatabaseHelper.columnCodBarraAdicional]),
      politica: map[DatabaseHelper.columnPolitica],
      cajasEscaneadas: map[DatabaseHelper.columnCajasEscaneadas],
      fraccionesEscaneadas: map[DatabaseHelper.columnFraccionesEscaneadas],
      cajasCaducadas: map[DatabaseHelper.columnaCajasCaduda],
      fraccionesCaducadas: map[DatabaseHelper.columnaFraccionesCaduca],
      fraccionesMalPicadas: map[DatabaseHelper.columnFraccionesPicadas],
      estado: map[DatabaseHelper.validacionProducto],
      observacion: map[DatabaseHelper.columnObservacion],
      bonificacion: map[DatabaseHelper.columnBonificacion],
      fraccionDv: map[DatabaseHelper.columFraccionDv],
      costo: map[DatabaseHelper.columCosto],
      iva: map[DatabaseHelper.columIva],
      cajaPromo: map[DatabaseHelper.columCajaPromo],
      fraccionPromo: map[DatabaseHelper.columFraccionPromo],
      fechaEscaneo: map[DatabaseHelper.columFechaEscaneo],
      codTipo: map[DatabaseHelper.columCodTipo],
    );
  }
  @override
  String toString() {
    return 'Ordenes{'
        'codProducto: $codProducto, '
        'cantidad: $cantidad, '
        'codigoBarra: $codBarra, '
        'observacion: $observacion, '
        'bonificacion: $bonificacion, '
        'producto:$producto, '
        'cajasEscaneadas:$cajasEscaneadas,'
        'fraccionesEscaneadas:$fraccionesEscaneadas,'
        'cajasCaducadas:$cajasCaducadas,'
        'fraccionesCaducadas:$fraccionesCaducadas,'
        'fraccionesMalPicadas:$fraccionesMalPicadas,'
        'estado:$estado,'
        'codTipo : $codTipo'
        '}';
  }

  static List<Map<String, dynamic>> convertirAListaMap(List<Inventario> productos) {
    List<Map<String, dynamic>> listaMapas = [];
    for (var producto in productos) {
      Map<String, dynamic> mapa = {
        'codProducto': producto.codProducto,
        'producto': producto.producto,
        'codLaboratorio': producto.codLaboratorio,
        'cantidad': producto.cantidad,
        'fraccion': producto.fraccion,
        'cajasEscaneadas': producto.cajasEscaneadas,
        'fraccionesEscaneadas': producto.fraccionesEscaneadas,
        'cajasCaducadas': producto.cajasCaducadas,
        'fraccionesCaducadas': producto.fraccionesCaducadas,
        'fraccionesMalPicadas': producto.fraccionesMalPicadas,
        'estado': producto.estado,
        'observacion': producto.observacion,
        'bonificacion': producto.bonificacion,
        'fraccionDv': producto.fraccionDv,
        'costo': producto.costo,
        'iva': producto.iva,
        'cajaPromo': producto.cajaPromo,
        'fraccionPromo': producto.fraccionPromo,
        'codTipo': producto.codTipo,
      };
      listaMapas.add(mapa);
    }
    listaMapas.sort((a, b) => a['producto'].compareTo(b['producto']));
    return listaMapas;
  }

  static List<Map<String, dynamic>> convertirAlistaEspecial(List<Inventario> productos) {
    List<Map<String, dynamic>> listaMapas = [];
    for (var producto in productos) {
      Map<String, dynamic> mapa = {
        'codProducto': producto.codProducto,
        'producto': producto.producto,
        'codLaboratorio': producto.codLaboratorio,
        'cantidad': producto.cantidad,
        'fraccion': producto.fraccion,
        'cajasEscaneadas': producto.cajasEscaneadas,
        'fraccionesEscaneadas': producto.fraccionesEscaneadas,
        'cajasCaducadas': producto.cajasCaducadas,
        'fraccionesCaducadas': producto.fraccionesCaducadas,
        'fraccionesMalPicadas': producto.fraccionesMalPicadas,
        'estado': producto.estado,
        'observacion': producto.observacion,
        'bonificacion': producto.bonificacion,
        'codBarra': producto.codBarra,
        'fraccionDv': producto.fraccionDv,
        'costo': producto.costo,
        'iva': producto.iva,
        'codTipo': producto.codTipo,
      };
      listaMapas.add(mapa);
    }
    return listaMapas;
  }
}

class Ajuste {
  final String siglas;
  final String nombreLaboratorio;
  final double totalValor;
  final double totalBase0;
  final double totalIva;

  Ajuste({required this.siglas, required this.nombreLaboratorio, required this.totalValor, required this.totalBase0, required this.totalIva});
}

class AsignarValores {
  final String siglas;
  final String nombreLaboratorio;
  final double totalValor;
  final double totalBase0;
  final double totalIva;

  AsignarValores({required this.siglas, required this.nombreLaboratorio, required this.totalValor, required this.totalBase0, required this.totalIva});
}

class ProductosCobro {
  String productoIva;
  int codProducto;
  int fraccion;
  String descripcion;
  int cantU;
  int cantF;
  double cantReal;
  double precio;
  double iva;
  double baseIva;
  double baseCero;
  double total;
  double descuento;
  double costo;
  double precioPublico;
  double parcial;
  int codUsuario;

  ProductosCobro(
      {required this.productoIva,
      required this.codProducto,
      required this.fraccion,
      required this.descripcion,
      required this.cantU,
      required this.cantF,
      required this.cantReal,
      required this.precio,
      required this.iva,
      required this.baseIva,
      required this.baseCero,
      required this.total,
      required this.descuento,
      required this.costo,
      required this.precioPublico,
      required this.parcial,
      required this.codUsuario});
  Map<String, dynamic> toJson() {
    return {
      'Producto_iva': productoIva,
      'Cod_Producto': codProducto,
      'Fraccion': fraccion,
      'Descripcion': descripcion,
      'Cant_U': cantU,
      'Cant_F': cantF,
      'Cant_Real': cantReal,
      'Precio': precio,
      'Descuento': 0,
      'Costo': costo,
      'PrecioPublico': precioPublico,
      'Parcial': parcial,
      'TipoMf': "",
      'Base': 0,
      'Bonificacion': 0,
      'id_broanet_invoicing': null,
    };
  }

  @override
  String toString() {
    return 'ProductosCobro(productoIva: $productoIva, codProducto: $codProducto, descripcion: $descripcion, cantU: $cantU, cantF: $cantF, cantReal: $cantReal, precio: $precio, descuento: $descuento, costo: $costo, precioPublico: $precioPublico, parcial: $parcial, codUsuario: $codUsuario)';
  }
}

class ProductosAjustados {
  final int codProducto;
  final String descripcion;
  final int unidad;
  final int fraccion;
  final int cajasIngresadas;
  final int fraccionesIngresadas;
  final int cajasBuenas;
  final int fraccionesBuenas;
  final int cajasCaducadas;
  final int fraccionesCaducadas;
  final double stockActual;
  final double stockEncontrado;

  ProductosAjustados(
      {required this.codProducto,
      required this.descripcion,
      required this.unidad,
      required this.fraccion,
      required this.cajasIngresadas,
      required this.fraccionesIngresadas,
      required this.cajasBuenas,
      required this.fraccionesBuenas,
      required this.cajasCaducadas,
      required this.fraccionesCaducadas,
      required this.stockActual,
      required this.stockEncontrado});

  factory ProductosAjustados.fromJson(Map<String, dynamic> json) {
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
        stockActual: json['stockActual'],
        stockEncontrado: json['stockIngresado']);
  }

  Map<String, dynamic> toJson() {
    return {
      'Cod_Producto': codProducto,
      'Descripcion': descripcion,
      'Unidad': unidad,
      'Fraccion': fraccion,
      'CajasIngresadas': cajasIngresadas,
      'FraccionesIngresadas': fraccionesIngresadas,
      'Cajas_Buenas': cajasBuenas,
      'Fracciones_Buenas': fraccionesBuenas,
      'Cajas_Caducadas': cajasCaducadas,
      'Fracciones_Caducadas': fraccionesCaducadas,
    };
  }
}
