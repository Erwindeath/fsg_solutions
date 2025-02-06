// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:location/location.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'dart:math' show atan2, cos, pi, pow, sin, sqrt;

const int tiempoMinimoActualizacion = 300; // segundos (5 minutos)
const double distanciaMinimaActualizacion = 100; // metros

final GeoHasher geoHasher = GeoHasher();
final Location location = Location();
LocationData? _cachedLocationData;
LocationData? _lastKnownLocation;
Future<Map<String, String>> conseguirUbicacion({bool forzarActualizacion = false}) async {
  // Verificar si la actualización es forzada o si el caché es nulo
  if (!forzarActualizacion && _cachedLocationData != null) {
    // Obtener el tiempo actual
    var tiempoActual = DateTime.now().millisecondsSinceEpoch;
    // Calcular la diferencia de tiempo desde la última actualización
    var diferenciaTiempo = (tiempoActual - _cachedLocationData!.time!) ~/ 1000; // en segundos

    // Calcular la distancia recorrida desde la última ubicación guardada
    var distanciaRecorrida = calcularDistanciaEnKm(_cachedLocationData!.latitude!, _cachedLocationData!.longitude!,
            _lastKnownLocation?.latitude ?? _cachedLocationData!.latitude!, _lastKnownLocation?.longitude ?? _cachedLocationData!.longitude!) *
        1000; // Convertir a metros

    // Verificar si es necesario actualizar la ubicación
    if (diferenciaTiempo < tiempoMinimoActualizacion && distanciaRecorrida < distanciaMinimaActualizacion) {
      return {"estado": "true", "latitude": _cachedLocationData!.latitude.toString(), "longitude": _cachedLocationData!.longitude.toString()};
    }
  }

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return {"estado": "false", "error": "NO_ENABLED"};
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return {"estado": "false", "error": "NO_PERMISSION"};
    }
  }

  _lastKnownLocation = _cachedLocationData;
  _cachedLocationData = await location.getLocation();

  return {"estado": "true", "latitude": _cachedLocationData!.latitude.toString(), "longitude": _cachedLocationData!.longitude.toString()};
}

Future<String> conseguirGeoHash(_longitude, _latitude) async {
  var geohash = geoHasher.encode(_longitude!, _latitude!, precision: 9);
  return geohash;
}

double _toRadians(double grados) {
  return grados * pi / 180;
}

double calcularDistanciaEnKm(double lat1, double lon1, double lat2, double lon2) {
  const double radioTierraKm = 6371.0710; // Radio medio de la Tierra en kilómetros

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = pow(sin(dLat / 2), 2) + cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return radioTierraKm * c;
}
