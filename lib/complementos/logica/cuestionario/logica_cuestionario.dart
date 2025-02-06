// ignore_for_file: depend_on_referenced_packages

import 'package:fsg_solutions/complementos/globals/url.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<http.Response> cuestionarioInicial(String token, int segundos, String llamado) {
  return http.post(Uri.parse(URL + llamado),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'access-token': token}).timeout(Duration(seconds: segundos));
}

class DatabaseHelper {
  static const _databaseName = "cuestionario.db";
  static const _databaseVersion = 1;

  static const tableRespuestas = 'respuestas';
  static const columnId = 'id';
  static const columnPreguntaId = 'preguntaId';
  static const columnRespuesta1 = 'respuesta1';
  static const columnRespuesta2 = 'respuesta2';
  static const columnRespuestaPersonalizada = 'respuestaPersonalizada';
  // Instancia única de la base de datos
  static Database? _database;

  // Constructor privado para prevenir instancias directas de la clase
  DatabaseHelper._privateConstructor();

  // Instancia única de la clase
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Obtener referencia a la base de datos
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // Si la base de datos no existe, la crea
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  _initDatabase() async {
    final path = await getDatabasesPath();
    String paths = join(path, _databaseName);
    return await openDatabase(paths, version: _databaseVersion, onCreate: _onCreate);
  }

  // Crear la tabla de respuestas
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableRespuestas (
        $columnId INTEGER PRIMARY KEY,
        $columnPreguntaId TEXT NOT NULL,
        $columnRespuesta1 INTEGER,
        $columnRespuesta2 INTEGER,
        $columnRespuestaPersonalizada INTEGER)
      ''');
  }

  // Insertar una respuesta en la base de datos
  Future<int> insertRespuesta(Map<String, dynamic> row) async {
  
    Database db = await instance.database;
    var result = await db.query(
      tableRespuestas,
      where: '$columnPreguntaId = ?',
      whereArgs: [row[columnPreguntaId]],
    );

    if (result.isNotEmpty) {
      // Actualizar si ya existe
      return await db.update(tableRespuestas, row, where: '$columnPreguntaId = ?', whereArgs: [row[columnPreguntaId]]);
    } else {
      // Insertar si no existe
      return await db.insert(tableRespuestas, row);
    }
  }

  // Obtener todas las respuestas de la base de datos
  Future<List<Map<String, dynamic>>> getAllRespuestas() async {
    Database db = await instance.database;
    return await db.query(tableRespuestas);
  }

  Future<void> limpiarRespuestas() async {
    Database db = await instance.database;
    await db.delete(tableRespuestas);
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return db.query(tableRespuestas);
  }

  void actualizarDatosEnSQLite(int codProducto, int cajasFinal, int fraccionesFinal, int cajasCaducadasFinal, int fraccionesCaducadasFinal,
      int fraccionesMalPicadasFinal, int i) {}
}
