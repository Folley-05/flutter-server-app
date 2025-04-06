import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


/// This class is used to manage the database
/// It will create a database and manage the logs 
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }
/// Initialize the database and create the logs table
  /// This method is used to initialize the database and create the logs table
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
// Insert a log entry into the database
  /// This method creates the database and the logs table if it doesn't exist
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
/// Retrieve all logs from the database
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    final db = await database;
    return await db.query('logs', orderBy: 'timestamp DESC');
  }
/// Retrieve logs by a specific message
  Future<void> clearLogs() async {
    final db = await database;
    await db.delete('logs');
  }
}
