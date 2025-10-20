import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  static const _dbName = 'vehicle_maintenance.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        make TEXT,
        model TEXT,
        year INTEGER,
        license_plate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        recommended_interval_days INTEGER,
        recommended_interval_miles INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER,
        maintenance_type_id INTEGER,
        date_performed TEXT,
        mileage INTEGER,
        notes TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
        FOREIGN KEY (maintenance_type_id) REFERENCES maintenance_types(id)
      )
    ''');
  }

  // ===== CRUD HELPERS =====

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  // ===== EXTRA UTILITIES =====

  // Get last maintenance date for a specific vehicle/type
  Future<Map<String, dynamic>?> getLastMaintenance(
    int vehicleId,
    int typeId,
  ) async {
    final db = await database;
    final result = await db.query(
      'maintenance_logs',
      where: 'vehicle_id = ? AND maintenance_type_id = ?',
      whereArgs: [vehicleId, typeId],
      orderBy: 'date_performed DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Preload some common maintenance types
  Future<void> seedMaintenanceTypes() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM maintenance_types'),
    );
    if (count == 0) {
      final maintenanceList = [
        {
          'name': 'Oil Change',
          'description': 'Replace engine oil and oil filter',
          'recommended_interval_days': 90,
          'recommended_interval_miles': 3000,
        },
        {
          'name': 'Tire Rotation',
          'description': 'Rotate tires for even wear',
          'recommended_interval_days': 180,
          'recommended_interval_miles': 6000,
        },
        {
          'name': 'Brake Inspection',
          'description': 'Check brake pads and fluid levels',
          'recommended_interval_days': 180,
          'recommended_interval_miles': 7000,
        },
      ];

      for (var item in maintenanceList) {
        await db.insert('maintenance_types', item);
      }
    }
  }
}
