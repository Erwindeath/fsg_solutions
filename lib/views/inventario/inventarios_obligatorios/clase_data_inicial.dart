class Personal implements SignatureEntity {
  final String nombre;
  final String cedula;
  final String ciudad;
  final int codUsuario;

  Personal({required this.nombre, required this.cedula, required this.ciudad,required this.codUsuario});
  @override
  String getSignatureName() {
    return nombre;
  }

  @override
  String getSignatureDetails() {
    return cedula.toString();
  }

  @override
  String toString() {
    return 'Personal{'
        'nombre: $nombre, '
        'cedula: $cedula, '
        '}';
  }
}

class Equipo implements SignatureEntity {
  final String equipoNombre;
  final String equipoDetails;

  Equipo({required this.equipoNombre, required this.equipoDetails});

  @override
  String getSignatureName() {
    return equipoNombre;
  }

  @override
  String getSignatureDetails() {
    return equipoDetails;
  }

  @override
  String toString() {
    return 'Equipo{'
        'nombre: $equipoNombre, '
        'cedula: $equipoDetails, '
        '}';
  }
}

class ReportItem {
  final String laboratorio;
  final String descripcion;
  final int cantidadCajas;
  final int cantidadFracciones;
  final double precioCaja;
  final double precioFraccion;
  final double total;
  final double totalInventariar;

  ReportItem({
    required this.laboratorio,
    required this.descripcion,
    required this.cantidadCajas,
    required this.cantidadFracciones,
    required this.precioCaja,
    required this.precioFraccion,
    required this.total,
    required this.totalInventariar,
  });
}

abstract class SignatureEntity {
  String getSignatureName();
  String getSignatureDetails();
}
