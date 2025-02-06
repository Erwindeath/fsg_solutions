import 'dart:convert';

class Categoria {
  final int codCategoria;
  final String nombre;
  final List<Pregunta> preguntas;

  Categoria({required this.codCategoria, required this.nombre, required this.preguntas});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    // Decodificar la cadena 'preguntas' si es necesario
    var preguntasJson = jsonDecode(json['preguntas'] as String);

    List<Pregunta> preguntasList = (preguntasJson as List).map((i) => Pregunta.fromJson(i as Map<String, dynamic>)).toList();
    return Categoria(
      codCategoria: json['Cod_Categoria'],
      nombre: json['Nombre'],
      preguntas: preguntasList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codCategoria': codCategoria,
      'preguntas': preguntas.map((p) => p.toJson()).toList(),
    };
  }

  String describe() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln("$nombre:"); // Agrega el nombre de la categoría

    for (var pregunta in preguntas) {
      buffer.write("${pregunta.codPreguntas}. ${pregunta.nombre}: "); // Pregunta número y nombre
      var selectedRespuestas = pregunta.respuestas.where((r) => r.seleccionada);
      if (selectedRespuestas.isNotEmpty) {
        // Asume que solo puede haber una respuesta seleccionada por pregunta para este formato
        var respuesta = selectedRespuestas.first;
        buffer.writeln("${respuesta.dato}${respuesta.observacion.isNotEmpty ? ' - ${respuesta.observacion}' : ''}");
      } else {
        buffer.writeln("No respondida");
      }
    }

    return buffer.toString();
  }
}

class Pregunta {
  final int codPreguntas;
  final String nombre;
  final bool llevaObservacion;
  final List<Respuesta> respuestas;

  Pregunta({required this.codPreguntas, required this.nombre, required this.llevaObservacion, required this.respuestas});

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    var list = json['datos'] as List;

    List<Respuesta> respuestasList = list.map((i) => Respuesta.fromJson(i)).toList();

    return Pregunta(
      codPreguntas: json['Cod_Preguntas'], // Asegúrate que el nombre de la clave coincide exactamente
      nombre: json['Nombre'],
      llevaObservacion: json["llevaObservacion"],
      respuestas: respuestasList,
    );
  }
  Map<String, dynamic> toJson() {
    // Obtiene solo las respuestas seleccionadas
    List<Map<String, dynamic>> selectedRespuestas =
        respuestas.where((respuesta) => respuesta.seleccionada).map((respuesta) => respuesta.toJson()).toList();

    return {
      'codPreguntas': codPreguntas,
      'respuestas': selectedRespuestas,
    };
  }
}

class Respuesta {
  final int codRespuesta;
  final String dato;
  bool seleccionada;
  String observacion;
  Respuesta({required this.codRespuesta, required this.dato, this.seleccionada = false, this.observacion = ""});

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(
      codRespuesta: json['CodRespuesta'],
      dato: json['dato'],
      seleccionada: false,
      observacion: "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'codRespuesta': codRespuesta,
      'observacion': observacion,
    };
  }
}
