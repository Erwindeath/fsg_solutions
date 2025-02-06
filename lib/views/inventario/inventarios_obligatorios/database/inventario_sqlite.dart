// ignore_for_file: depend_on_referenced_packages

//traer el det

import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_generar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "inventarios.db";
  // static const _databaseVersion = 3;

  static const table = 'productos';

  static const columnCodProducto = 'Cod_Producto'; // No change to column names
  static const columnCodBarra = 'codBarra';
  static const columnProducto = 'producto';
  static const columnCodLaboratorio = 'codLaboratorio';
  static const columnCantidad = 'cantidad';
  static const columnFraccion = 'fraccion';
  static const columnCodBarraAdicional = 'codBarraAdicional';
  static const columnPolitica = 'politica';
  static const columCodTipo = 'codTipo';
  static const columnCajasEscaneadas = 'cajas';
  static const columnFraccionesEscaneadas = 'fracciones';

  static const columnFraccionesPicadas = 'fraccionespicadas';
  static const columnaFraccionesCaduca = 'fraccionescaduca';
  static const columnaCajasCaduda = 'cajasCaduca';
  static const validacionProducto = 'estado';

  static const columnObservacion = 'observacion';
  static const columnBonificacion = 'bonificacion';

  static const columFraccionDv = 'fraccionDv';

  static const columCosto = 'costo';
  static const columIva = 'Producto_Iva';

  static const columCajaPromo = 'cajaPromo';
  static const columFraccionPromo = 'fraccionPromo';

  static const columFechaEscaneo = 'fechaEscaneo';

  // Make this class a singleton to avoid multiple instances of the database.
  static Database? _databaseOrdenes;

  Future<Database?> get database async {
    if (_databaseOrdenes != null) {
      return _databaseOrdenes;
    }

    _databaseOrdenes = await _initDatabase();
    return _databaseOrdenes;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, _databaseName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $table($columnCodProducto INTEGER PRIMARY KEY,$columnProducto TEXT,$columnCodBarra TEXT,$columnCodLaboratorio INTEGER, $columnCantidad INTEGER, $columnFraccion INTEGER, $columnCodBarraAdicional TEXT,$columnPolitica TEXT,$columnCajasEscaneadas INTEGER,$columnFraccionesEscaneadas INTEGER,$columnFraccionesPicadas INTEGER,$columnaFraccionesCaduca INTEGER,$columnaCajasCaduda INTEGER,$validacionProducto INTEGER,$columnObservacion TEXT,$columnBonificacion text,$columFraccionDv INTEGER,$columCosto REAL, $columIva TEXT, $columCajaPromo INTEGER, $columFraccionPromo INTEGER, $columFechaEscaneo TEXT,$columCodTipo TEXT)',
        );
      },
      version: 5,
    );
  }

  Future<void> insert(Inventario producto) async {
    final db = await database;

    await db!.insert(table, producto.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteTable() async {
    final db = await database;
    await db?.delete(table);
  }

  Future<List<Inventario>> getAllProductos(String valor) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      table,
      where: "$validacionProducto = ?",
      whereArgs: [valor],
    );
    return List.generate(maps.length, (i) {
      return Inventario.fromMap(maps[i]);
    });
  }

  Future<List<Inventario>> getAllProductos2() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      table,
    );
    return List.generate(maps.length, (i) {
      return Inventario.fromMap(maps[i]);
    });
  }

  Future<void> actualizarDatosEnSQLite(int codProducto, int cajasEscaneadas, int fraccionesEscaneadas, int cajasCaducadas, int fraccionesCaducadas,
      int fraccionesPicadas, int validacionProducto, int cajaPromo, int fraccionPromo, String fechaEscaneado) async {
    final db = await database;

    // Los campos que deseamos actualizar
    final Map<String, dynamic> datosActualizados = {
      DatabaseHelper.columnCajasEscaneadas: cajasEscaneadas,
      DatabaseHelper.columnFraccionesEscaneadas: fraccionesEscaneadas,
      DatabaseHelper.columnFraccionesPicadas: fraccionesPicadas,
      DatabaseHelper.columnaFraccionesCaduca: fraccionesCaducadas,
      DatabaseHelper.columnaCajasCaduda: cajasCaducadas,
      DatabaseHelper.validacionProducto: validacionProducto,
      DatabaseHelper.columCajaPromo: cajaPromo,
      DatabaseHelper.columFraccionPromo: fraccionPromo,
      DatabaseHelper.columFechaEscaneo: fechaEscaneado
    };
    await db?.update(
      table,
      datosActualizados,
      where: "$columnCodProducto = ?",
      //where: "$columnCodProducto = ? AND ${DatabaseHelper.validacionProducto} = 0", // Aquí agregamos la condición adicional
      whereArgs: [codProducto],
    );
  }

  Future<void> limpiarDatosSqlite() async {
    final db = await database;

    // Los campos que deseamos actualizar
    final Map<String, dynamic> datosActualizados = {
      DatabaseHelper.columnCajasEscaneadas: 0,
      DatabaseHelper.columnFraccionesEscaneadas: 0,
      DatabaseHelper.columnFraccionesPicadas: 0,
      DatabaseHelper.columnaFraccionesCaduca: 0,
      DatabaseHelper.columnaCajasCaduda: 0,
      DatabaseHelper.validacionProducto: 0,
      DatabaseHelper.columFechaEscaneo: ''
    };
    await db?.update(
      table,
      datosActualizados,
      where: "$validacionProducto = 1",
    );
  }

  Future<void> actualizarDatosEnSQLite2(int codProducto, int cajasEscaneadas, int fraccionesEscaneadas, int cajasCaducadas, int fraccionesCaducadas,
      int fraccionesPicadas, int validacionProducto /*,String fechaEscaneado*/) async {
    final db = await database;

    // Los campos que deseamos actualizar
    final Map<String, dynamic> datosActualizados = {
      DatabaseHelper.columnCajasEscaneadas: cajasEscaneadas,
      DatabaseHelper.columnFraccionesEscaneadas: fraccionesEscaneadas,
      DatabaseHelper.columnFraccionesPicadas: fraccionesPicadas,
      DatabaseHelper.columnaFraccionesCaduca: fraccionesCaducadas,
      DatabaseHelper.columnaCajasCaduda: cajasCaducadas,
      DatabaseHelper.validacionProducto: validacionProducto,
      //DatabaseHelper.columFechaEscaneo: fechaEscaneado
    };

    await db?.update(
      table,
      datosActualizados,
      //where: "$columnCodProducto = ?",
      where: "$columnCodProducto = ? AND ${DatabaseHelper.validacionProducto} = 0", // Aquí agregamos la condición adicional
      whereArgs: [codProducto],
    );
  }

  Future<List<Inventario>> obtenerNovedades(String valor) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.rawQuery(
      'SELECT * FROM $table WHERE $validacionProducto = ? AND ( $columnCantidad != ($columnCajasEscaneadas) OR $columnFraccion != ($columnFraccionesEscaneadas))',
      [valor],
    );

    return List.generate(maps.length, (i) {
      return Inventario.fromMap(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getAllRecordsAsMaps() async {
    final db = await database;

    const query = '''
    SELECT 
      $columnCodProducto,
      $columnCantidad,
      $columnFraccion,
      $columnCajasEscaneadas,
      $columnFraccionesEscaneadas,
      $columnaCajasCaduda,
      $columnaFraccionesCaduca,
      $columnFraccionesPicadas, 
      $columCosto,
      $columFraccionDv,
      ($columnCajasEscaneadas) as CajasTotales,
      ($columnFraccionesEscaneadas) as FraccionesTotales,
      ROUND((
        (($columnCajasEscaneadas) * $columFraccionDv + $columnFraccionesEscaneadas) 
        * $columCosto / $columFraccionDv
        ),4
      ) AS Parcial,
      ROUND((((($columnCajasEscaneadas) * $columFraccionDv + $columnFraccionesEscaneadas)* 1.0) / $columFraccionDv
      ),4) AS CantReal,
      ROUND((((($columnCantidad) * $columFraccionDv + $columnFraccion)* 1.0) / $columFraccionDv
      ),4) AS CantRealInicial,
      $columCajaPromo,
      $columFraccionPromo,
      $columFechaEscaneo,
      $columCodTipo
      FROM $table
    ''';
    List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    return maps;
  }

  Future<List<Map<String, dynamic>>> obtenerProductosConPromocion() async {
    final db = await database;
    const query = '''
    SELECT 
     Producto_Iva,
      Cod_Producto,
      producto as Producto,
      cajaPromo as Cant_U,
      fraccionPromo as Cant_F,
      costo as Costo,
      ROUND((cajaPromo + (fraccionPromo / CAST(fraccionDv AS REAL))) * costo, 4) as Parcial,
      fraccionDv as Fraccion,
      ROUND(cajaPromo + (fraccionPromo / CAST(fraccionDv AS REAL)), 2) as Cant_Real
    FROM $table
    WHERE ($columCajaPromo > 0 OR $columFraccionPromo > 0) and $validacionProducto>0
  ''';
    List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    return maps;
  }

  Future<List<Map<String, dynamic>>> getRecordsWithCajasOrFracciones() async {
    final db = await database;

    const query = '''
    SELECT 
      $columnCodProducto,
      $columnCodLaboratorio,
      $columnCantidad,
      $columnFraccion,
      $columnCajasEscaneadas,
      $columnFraccionesEscaneadas,
      $columFechaEscaneo
    FROM $table
    WHERE $columnCajasEscaneadas > 0 OR $columnFraccionesEscaneadas > 0
  ''';

    List<Map<String, dynamic>> maps = await db!.rawQuery(query);
    return maps;
  }

  Future<int> countRecordsWithCajasOrFracciones() async {
    final db = await database;

    const query = '''
  SELECT COUNT(*) as count
  FROM $table
  WHERE $columnCajasEscaneadas > 0 OR $columnFraccionesEscaneadas > 0
  ''';

    var result = await db!.rawQuery(query);
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<List<Map<String, dynamic>>> getRecordsWithFraccionesPicadasAndCaducas() async {
    final db = await database;
    final columnsToSelect = [
      columnCodProducto,
      columnCantidad,
      columnFraccion,
      columnCajasEscaneadas,
      columnFraccionesEscaneadas,
      columnFraccionesPicadas,
      columnaFraccionesCaduca,
      columnaCajasCaduda
    ];
    List<Map<String, dynamic>> maps = await db!.query(
      table,
      columns: columnsToSelect,
      where: '$columnFraccionesPicadas > 0 OR $columnaCajasCaduda > 0 OR $columnaFraccionesCaduca > 0 ',
    );
    return maps;
  }

  Future<Inventario?> buscarProductoPorCodigo(String codigoBarra, int codProductos) async {
    final db = await database; // Asegura que la base de datos está inicializada

    // Preparar la consulta SQL
    final List<Map<String, dynamic>> result = await db!.query(
      table,
      where: '$columnCodBarra = ? OR $columnCodBarraAdicional LIKE ? OR $columnCodProducto = ?',
      whereArgs: [codigoBarra, '%$codigoBarra%', codProductos],
    );

    // Verifica si se encontraron resultados y retorna un objeto Inventario si es así
    if (result.isNotEmpty) {
      return Inventario.fromMap(result.first); // Suponiendo que tienes un método fromMap en tu clase Inventario
    }
    return null; // Retorna null si no se encontró ningún resultado
  }

// En DatabaseHelper
  Future<List<Inventario>> buscarProductosPorNombre(String nombre) async {
    final db = await database;
    final result = await db!.query(
      table,
      where: '$columnProducto LIKE ?',
      whereArgs: ['%$nombre%'],
    );
    return List.generate(result.length, (i) {
      return Inventario.fromMap(result[i]);
    });
  }
}
