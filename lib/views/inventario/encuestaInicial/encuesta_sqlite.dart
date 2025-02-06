// ignore_for_file: depend_on_referenced_packages

//traer el det

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperEncuesta {
  static const _databaseName = "encuesta.db";
  // static const _databaseVersion = 3;

  static const table = 'datosEncuesta';
  static const columInventario = 'codInventario';
  static const columnEncuestaInicial = 'respuestas';

  // Make this class a singleton to avoid multiple instances of the database.
  static Database? _databaseEncuesta;

  Future<Database?> get database async {
    if (_databaseEncuesta != null) {
      return _databaseEncuesta;
    }

    _databaseEncuesta = await _initDatabase();
    return _databaseEncuesta;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, _databaseName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $table($columInventario INTEGER PRIMARY KEY,$columnEncuestaInicial TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insert(int codInventario, String datos) async {
    final db = await database;
    await db!.insert(
        table,
        {
          columInventario: codInventario, // Usar nombres de columnas como claves del mapa
          columnEncuestaInicial: datos
        },
        conflictAlgorithm: ConflictAlgorithm.ignore // Manejo de conflictos si hay claves duplicadas
        );
  }

  Future<String?> getFirstEncuestaInicial() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query(table, columns: [columnEncuestaInicial], limit: 1 // Limita la consulta al primer resultado
            );

    if (maps.isNotEmpty) {
      return maps.first[columnEncuestaInicial].toString();
    }
    return null; // Retorna null si no se encuentra el registro
  }

  Future<void> deleteTable() async {
    final db = await database;
    await db?.delete(table);
  }
}
