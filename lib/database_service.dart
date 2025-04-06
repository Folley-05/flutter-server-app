import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertLog(String message) async {
    final db = await database;
    await db.insert(
      'logs',
      {
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllLogs() async {
    final db = await database;
    return await db.query('logs', orderBy: 'timestamp DESC');
  }

  Future<void> clearLogs() async {
    final db = await database;
    await db.delete('logs');
  }
}
