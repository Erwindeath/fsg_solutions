class Mantenimientos {
  final int codSolicitud;
  final int codBodega;
  final String bodega;
  final String descripcionTipo;
  final String descripcionDetalle;
  final String detalle;
  final String fechaSolicitud;
  final String nombreSolicitante;
  List<dynamic> imagenes = [];
  final int codTipoMantenimiento;

  Mantenimientos(
      {required this.codSolicitud,
      required this.codBodega,
      required this.bodega,
      required this.descripcionTipo,
      required this.descripcionDetalle,
      required this.detalle,
      required this.fechaSolicitud,
      required this.nombreSolicitante,
      required this.imagenes,
      required this.codTipoMantenimiento
      });
}
class RutaConMantenimientos {
  final int codRuta;
  final String descripcionRuta;
  List<Mantenimientos> mantenimientos;

  RutaConMantenimientos({
    required this.codRuta,
    required this.descripcionRuta,
    required this.mantenimientos,
  });
}
