import 'dart:convert';
import 'dart:typed_data';

import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:fsg_solutions/complementos/logica/storage.dart';
import 'package:http/http.dart' as http;

SecureStorage storage = SecureStorage();
int valor = 30;
Future<http.Response> obtenerFarmaciasLaboratorios(int codUsuario, int codBodega, String token, String url, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codUsuario': codUsuario, 'codBodega': codBodega, 'codInventario': codInventario},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerFarmaciaEncuestaBodega(int codBodega, String token, String url, String fecha) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'fecha': fecha},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> comprobarTransferencias(int codBodega, String token, String url) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/$url'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerOrdenesDatosInicialesInventario(
    String token, int codBodega, int codLaboratorio, int codUsuario, int codInventario, String metodo) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_inventario_laboratatorios'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codLaboratorio': codLaboratorio, 'codUsuario': codUsuario, 'codInventario': codInventario, 'metodo': metodo},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerOrdenesDatosInicialesInventarioTotal(String token, int codBodega, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_inventario_laboratatorios_total'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codInventario': codInventario},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerOrdenesDatosReconteoLaboratorio(String token, int codBodega, int codInventario, int codLaboratorio) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_inventario_datos_reconteo_especial'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codInventario': codInventario, 'codLaboratorio': codLaboratorio},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerDescripcionProductoReconteo(
    String token, int cabNovedad, int codInventario, int codProducto, int codLaboratorio, int codUsuario) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_inventario_descripcion_reconteo_producto'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'cabNovedad': cabNovedad,
            'codInventario': codInventario,
            'codProducto': codProducto,
            'codLaboratorio': codLaboratorio,
            'codUsuario': codUsuario
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> enviarDatosProductosReconteo(
    String token, int cabNovedad, int codInventario, int codUsuario, double cantReal, int cajas, int fracciones) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/enviar_datos_inventario_reconteo'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'cabNovedad': cabNovedad,
            'codInventario': codInventario,
            'codUsuario': codUsuario,
            'cantReal': cantReal,
            'cajas':cajas,
            'fracciones':fracciones
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerOrdenesDatosInicialesLaboratoriosReconteo(
    String token, int codBodega, int codLaboratorio, int codInventario, String metodo) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_inventario_laboratatorios_reconteo'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codLaboratorio': codLaboratorio, 'codInventario': codInventario, 'metodo': metodo},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerPersonalBodega(String token, int codBodega) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_personal_por_bodega'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codBodega': codBodega,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> compruebaReconteoInventario(String token, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/comprueba_reconteo_inventario'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codInventario': codInventario,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> compruebaProductoPendienteReconteo(String token, int codInventario, int codUsuario) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/comprueba_producto_usuario_reconteo'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codInventario': codInventario,
            'codUsuario': codUsuario,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerPersonalBodegaNuevo(String token, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_personal_por_bodega_nuevo'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codInventario': codInventario,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerGrupo(String token, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_personal_inventario'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codInventario': codInventario,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerReporteInicial(String token, int codBodega, int codInventario, String metodo) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/obtener_reporte_inv_inicial'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codInventario': codInventario, 'metodo': metodo},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerEstadoImpresora(String token, int codInventario, String dato) {
  return http
      .post(
        Uri.parse('${URL}api/creedenciales/$dato'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codInventario': codInventario,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> enviarInventario(
    String token,
    int codSesion,
    int codInventario,
    int codInventarioDet,
    int codLaboratorio,
    int usuario,
    int codBodega,
    String fecha,
    List<dynamic> inventarioTotal,
    List<Map<String, String>> jsonTotales,
    int validaPromo,
    List<Map<String, dynamic>> obtenerProductosConPromocion,
    double baseCero,
    double baseIva,
    double ivas,
    double totales) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/enviar_datos_inventario'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codSesion': codSesion,
            'codInventario': codInventario,
            'codInventarioDet': codInventarioDet,
            'codLaboratorio': codLaboratorio,
            'codUsuario': usuario,
            'codBodega': codBodega,
            'fecha': fecha,
            'inventarioTotal': inventarioTotal,
            'jsonTotales': jsonTotales,
            'validaPromo': validaPromo,
            'jsonPromos': obtenerProductosConPromocion,
            'baseCero': baseCero,
            'baseIva': baseIva,
            'ivas': ivas,
            'totales': totales
          },
        ),
      )
      .timeout(const Duration(seconds: 40));
}

Future<http.Response> enviarInventarioEspecial(String token, int codSesion, int codInventario, int usuario, List<dynamic> inventarioTotal) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/enviar_datos_inventario_especial'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codSesion': codSesion,
            'codInventario': codInventario,
            'codUsuario': usuario,
            'inventarioTotal': inventarioTotal,
          },
        ),
      )
      .timeout(const Duration(seconds: 40));
}

Future<void> guardarData(String codLaboratorio, String nombreLaboratorio, String codInventario, String codInventarioDet) async {
  await storage.writeSecureData("codLaboratorio", codLaboratorio);
  await storage.writeSecureData("nombreLaboratorio", nombreLaboratorio);
  await storage.writeSecureData("codInventario", codInventario);
  await storage.writeSecureData("codInventarioDet", codInventarioDet);
}

Future<http.Response> comprobarInventarioLaboratorioPendiente(String token, int codInventario, int codBodega, String fecha) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/comprobar_inventario_laboratorio_pendiente'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codInventario': codInventario, 'fecha': fecha, 'codBodega': codBodega},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> comprobarActaDisponible(String token, String periodo, int codBodega) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/comprobar_actas_disponiblesssss'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'periodo': periodo, 'codBodega': codBodega},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> compruebaCobros(String token, String periodo, int codBodega, String fechaInicio, String fechaFin) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/comprobar_cobros'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'periodo': periodo, 'codBodega': codBodega, 'fechaInicio': fechaInicio, 'fechaFin': fechaFin},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> comprobarActaDisponible2(String token, String periodo, int codBodega, String nombreBodega) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/comprobar_actas_disponibles'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'periodo': periodo, 'codBodega': codBodega, 'nombreBodega': nombreBodega},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> comprobarEstadoInventario(String token, int codBodega, String formatted, String nombreBodega) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/comprobar_laboratorios_disponibles'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'formatted': formatted, 'nombreBodega': nombreBodega},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> ajustarNovedadesPendientes(String token, int codUsuario, String fechaFinal, String periodo, double total, double totalBaseCero,
    double totalBaseIva, double iva, int codBodega, int codIventario) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/ajustar_novedades_pendientes'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codUsuario': codUsuario,
            'fechaFinal': fechaFinal,
            'periodo': periodo,
            'total': total,
            'totalBaseCero': totalBaseCero,
            'totalBaseIva': totalBaseIva,
            'iva': iva,
            'codBodega': codBodega,
            'codIventario': codIventario
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

/*Future<http.Response> obtenerValoresAsignacion(String token, int codBodega) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/obtener_valores_asignacion'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codBodega': codBodega,
          },
        ),
      )
      .timeout(const Duration(seconds: 20));
}*/
Future<http.Response> cambiaEstadoInicio(
    String token, String endpoint, int codBodega, int codInventario, List<int> seleccionados, int codUsuario, String llaves) {
  //sprint('${URL}api/creedenciales/${endpoint}');
  return http
      .post(
        Uri.parse('${URL}api/planificacion/$endpoint'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codInventario': codInventario, 'jsonPersonal': seleccionados, 'codUsuario': codUsuario, 'llave': llaves},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.StreamedResponse> enviarPdf(Uint8List pdfBytes, String carpeta) async {
  var request = http.MultipartRequest('POST', Uri.parse('${URL2}allku/mantenimientos'));
  request.fields["archivo"] = carpeta;

  // Agrega el PDF al request. 'pdf' es el nombre del campo en tu backend que recibe el archivo
  request.files.add(http.MultipartFile.fromBytes(
    'uploadfile', // Este es el nombre del campo esperado por el servidor para el archivo
    pdfBytes,
    filename: 'actaInicial.pdf', // El nombre del archivo que verá el servidor
  ));

  // Envía la solicitud
  var response = await request.send().timeout(Duration(seconds: valor));
  return response;
}

Future<http.Response> cambiaEstado(String token, String endpoint, int codBodega, int codInventario, String llaves) {
  //sprint('${URL}api/creedenciales/${endpoint}');
  return http
      .post(
        Uri.parse('${URL}api/planificacion/$endpoint'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codInventario': codInventario, 'llaves': llaves},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerPersonayProductosCobros(String token, int codBodega, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/obtener_personal_por_bodega_productos_cobros'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codBodega': codBodega,
            'codInventario': codInventario,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> envioDatosCobro(String token, String jsonCobro, int codBodega, int codSesion, int codUsuario, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/envio_datos_cobro'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codBodega': codBodega,
            'codSesion': codSesion,
            'codUsuario': codUsuario,
            'codInventario': codInventario,
            'jsonCobro': jsonCobro,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> finalizarInventario(String token, int codBodega, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/finalizar_inventario'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {
            'codBodega': codBodega,
            'codInventario': codInventario,
          },
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> obtenerDatosVenta(String token, int secuencial, int codBodega) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/obtener_datos_ventas'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'secuencial': secuencial, 'codBodega': codBodega},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> datosFactura(String token, int codBodega, int codInventario) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/obtener_facturas_ventas'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codBodega': codBodega, 'codInventario': codInventario},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> compruebaAjustes(String token, int codInventario, int codLaboratorio, int codBodega, int codInventarioDet) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/obtener_datos_ajustados'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codInventario': codInventario, 'codLaboratorio': codLaboratorio, 'codBodega': codBodega, 'codInventarioDet': codInventarioDet},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> verificarLaboratorio(int codLaboratorio, int codInventario, int codInventarioDet, String token) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/comprobar_laboratorio_disponibilidad'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codInventario': codInventario, 'codLaboratorio': codLaboratorio, 'codInventarioDet': codInventarioDet},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> verificarLaboratorioUsuario(int codLaboratorio, int codInventario, int codInventarioDet, int codUsuario, String token) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/comprobar_laboratorio_disponibilidad_usuario'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codInventario': codInventario, 'codLaboratorio': codLaboratorio, 'codInventarioDet': codInventarioDet, 'codUsuario': codUsuario},
        ),
      )
      .timeout(Duration(seconds: valor));
}

Future<http.Response> compruebaDatosAjustes(String token, codInventarioDet) {
  return http
      .post(
        Uri.parse('${URL}api/planificacion/obtener_reporte_datos_ajustados'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token},
        body: jsonEncode(
          {'codInventarioDet': codInventarioDet},
        ),
      )
      .timeout(Duration(seconds: valor));
}
