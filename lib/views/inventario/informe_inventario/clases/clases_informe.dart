// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class Paso {
  final String titulo;
  final Widget contenido;

  Paso({required this.titulo, required this.contenido});
}

class LabelValue {
  final String label;
  final String value;

  LabelValue({required this.label, required this.value});
  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label};
  }

  @override
  String toString() {
    return '{"value": $value, "label": "$label"}';
  }
}

class Informe {
  final int codBodega;
  final String farmacia;
  final String fechaInicio;
  final String fechaFin;
  final double liquidacionInventario;
  final double liquidacionMedicinaCaducada;
  final List<Coordinador> coordinador;
  final List<EquipoInventario> equipoInventario;
  final List<Dependientes> dependientes;
  final List<CobroCaducado> cobroCaducado;
  final List<CobroInventario> cobroInventario;
  final List<DetalleInventario> detalleInventario;
  final List<Observacion> observacion;
  final List<Motivos> motivos;

  Informe({
    required this.codBodega,
    required this.farmacia,
    required this.fechaInicio,
    required this.fechaFin,
    required this.liquidacionInventario,
    required this.liquidacionMedicinaCaducada,
    required this.coordinador,
    required this.dependientes,
    required this.equipoInventario,
    required this.cobroCaducado,
    required this.cobroInventario,
    required this.detalleInventario,
    required this.observacion,
    required this.motivos,
  });
}

class Dependientes {
  final int value;
  final String label;
  final int tiempo_servicio;
  final double inventario;
  final double inventarioVal;
  final double medicina;
  final double medicinaVal;
  final double liquidacionMedicinaCaducada;
  final double liquidacionInventario;
  Dependientes(
      {required this.value,
      required this.label,
      required this.tiempo_servicio,
      required this.inventario,
      required this.inventarioVal,
      required this.medicina,
      required this.medicinaVal,
      required this.liquidacionMedicinaCaducada,
      required this.liquidacionInventario});
  factory Dependientes.fromJson(Map<String, dynamic> json) => Dependientes(
        value: json["value"],
        label: json["label"] as String,
        tiempo_servicio: json["tiempo_servicio"],
        inventario: json["inventario"],
        inventarioVal: json["inventarioVal"] ?? 0.0,
        medicina: json["medicina"],
        medicinaVal: json["medicinaVal"] ?? 0.0,
        liquidacionMedicinaCaducada: json["liquidacionMedicinaCaducada"] ?? 0.0,
        liquidacionInventario: json["liquidacionInventario"] ?? 0.0,
      );
  Map<String, dynamic> toJson() {
    //[{"value":5,"label":"MOREIRA DELGADO MARCO ANTONIO","tiempo_servicio":156,"inventario":"0","inventarioVal":"0","medicina":0,"medicinaVal":0}]
    return {
      'value': value,
      'label': label,
      'tiempo_servicio': tiempo_servicio,
      'inventario': inventario,
      'inventarioVal': inventarioVal,
      'medicina': medicina,
      'medicinaVal': medicinaVal,
      'liquidacionMedicinaCaducada': liquidacionMedicinaCaducada,
      'liquidacionInventario': liquidacionInventario,
    };
  }
  // Método factory desde JSON para NombreRol
}

class EquipoInventario {
  final int value;
  final String label;

  EquipoInventario({required this.value, required this.label});
  factory EquipoInventario.fromJson(Map<String, dynamic> json) => EquipoInventario(
        value: json["value"],
        label: json["label"] as String,
      );
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
  // Método factory desde JSON para NombreRol
}

class CobroCaducado {
  final String nombresRol;
  final double total;

  CobroCaducado({required this.nombresRol, required this.total});

  factory CobroCaducado.fromJson(Map<String, dynamic> json) => CobroCaducado(
        nombresRol: json["Nombres_Rol"] as String,
        total: (json["Total"] as num).toDouble(),
      );
}

class Coordinador {
  final int value;
  final String label;

  Coordinador({required this.value, required this.label});

  factory Coordinador.fromJson(Map<String, dynamic> json) {
    return Coordinador(
      value: json['value'],
      label: json['label'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}

class DetalleInventario {
  final String tipo;
  final double valor;
  DetalleInventario({required this.tipo, required this.valor});
  factory DetalleInventario.fromJson(Map<String, dynamic> json) {
    return DetalleInventario(
      tipo: json['tipo'],
      valor: json['valor'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'valor': valor,
    };
  }
}

class Motivos {
  final int value;
  final String label;

  Motivos({required this.value, required this.label});

  factory Motivos.fromJson(Map<String, dynamic> json) {
    return Motivos(
      value: json['value'],
      label: json['label'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}

class CobroInventario {
  final String nombresRol;
  final double valor;

  CobroInventario({required this.nombresRol, required this.valor});

  factory CobroInventario.fromJson(Map<String, dynamic> json) => CobroInventario(
        nombresRol: json["label"] as String,
        valor: (json["valor"] as num).toDouble(),
      );
  Map<String, dynamic> toJson() {
    return {
      'nombresRol': nombresRol,
      'valor': valor,
    };
  }
}

class Observacion {
  final int value;
  final String label;

  Observacion({required this.value, required this.label});

  factory Observacion.fromJson(Map<String, dynamic> json) => Observacion(
        value: json["value"] as int,
        label: json["label"] as String,
      );
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}
