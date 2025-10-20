import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  // Database name and version
  static const _dbName = 'vehicle_app.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Initialize DB
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create all tables here
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

  // Optional: handle DB version upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Example: add a new column or create new tables
      await db.execute('ALTER TABLE users ADD COLUMN age INTEGER');
    }
  }

  // ===== CRUD HELPERS =====

  // Insert record
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  // Query all
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  // Query with condition
  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  // Update
  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  // Delete
  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Close DB
  Future close() async {
    final db = await database;
    db.close();
  }
}
