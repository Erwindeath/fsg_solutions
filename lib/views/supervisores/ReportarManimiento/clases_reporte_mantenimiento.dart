import 'dart:convert';

class Bodegas {
  final int codBodega;
  final String nombreBodega;

  Bodegas({required this.codBodega, required this.nombreBodega});
}

class Mantenimientos {
  final int tipoMantenimiento;
  final String descripcioMantenimiento;
   final List<DetalleMantenimiento> detalles;
  Mantenimientos({required this.tipoMantenimiento, required this.descripcioMantenimiento,required this.detalles});
  factory Mantenimientos.fromJson(Map<String, dynamic> json) {
    List<DetalleMantenimiento> detallesList = (jsonDecode(json['detalles']) as List)
        .map((detalle) => DetalleMantenimiento.fromJson(detalle))
        .toList();

    return Mantenimientos(
      tipoMantenimiento: json['tipoMantenimiento'],
      descripcioMantenimiento: json['descripcionManteniemiento'], // Corregir la clave según tu JSON
      detalles: detallesList,
    );
  }
  @override
  String toString() {
    String detallesStr = detalles.map((detalle) => detalle.toString()).join(', ');
    return 'Mantenimientos(tipoMantenimiento: $tipoMantenimiento, descripcioMantenimiento: $descripcioMantenimiento, detalles: [$detallesStr])';
  }
}

class DetalleMantenimiento {
  final int tipoDescripcion;
  final String tipoDetalle;

  DetalleMantenimiento({required this.tipoDescripcion, required this.tipoDetalle});

  // Método para crear una instancia de DetalleMantenimiento desde un map.
  factory DetalleMantenimiento.fromJson(Map<String, dynamic> json) {
    return DetalleMantenimiento(
      tipoDescripcion: json['tipoDescripcion'],
      tipoDetalle: json['tipoDetalle'],
    );
  }
   @override
  String toString() {
    return 'DetalleMantenimiento(tipoDescripcion: $tipoDescripcion, tipoDetalle: $tipoDetalle)';
  }
}