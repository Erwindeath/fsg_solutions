// ignore_for_file: non_constant_identifier_names

class Data {
  late int codInventario;
  late String Fecha_Inicio;
  late String Nombre;
  late int codBodega;
  late String Ciudad;
  late double? long;
  late double? lat;
  late String ubicacion;
  late String LlaveQR;
  late bool metodo;
  Data({
    required this.codInventario,
    required this.Fecha_Inicio,
    required this.Nombre,
    required this.codBodega,
    required this.Ciudad,
    required this.long,
    required this.lat,
    required this.ubicacion,
    required this.LlaveQR,
    required this.metodo
  });

  Data.fromJson(Map<String, dynamic> json) {
    codInventario = json['codInventario'];
    Fecha_Inicio = json['Fecha_Inicio'];
    Nombre = json['Nombre'];
    codBodega = json['codBodega'];
    Ciudad = json['Ciudad'];
    long = json['long'];
    lat = json['lat'];
    ubicacion = json['Ubicacion'];
    LlaveQR = json['LlaveQR'];
    metodo=json['metodo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['codInventario'] = codInventario;
    data['Fecha_Inicio'] = Fecha_Inicio;
    data['Nombre'] = Nombre;
    data['codBodega'] = codBodega;
    data['Ciudad'] = Ciudad;
    data['long'] = long;
    data['lat'] = lat;
    data['Ubicacion'] = ubicacion;
    data['LlaveQR'] = LlaveQR;
    data['metodo']= metodo;
    return data;
  }
  @override
  String toString() {
    return 'CargosPendientes{'
        'codInventario: $codInventario, '
        'Fecha_Inicio: $Fecha_Inicio, '
        'ubicacion: $ubicacion'
         '}';
  }
}
