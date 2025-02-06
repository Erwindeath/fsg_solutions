import 'package:flutter/services.dart';

class Globales {
  static final Globales _globales = Globales._internal();

  var token = "";
  var nombre = "";
  var cargo = "";

  var tempDir = "";

  var platform = const MethodChannel('app.channel.shared.data');

  factory Globales() {
    return _globales;
  }

  Globales._internal();
}
