// Format, validate,...import 'package:sqflite/sqflite.dart';
// // Nên thêm thư viện này để xử lý đường dẫn chuyên nghiệp hơn
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Sử dụng join từ thư viện path để tạo đường dẫn an toàn hơn
    final databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // 3. Tạo bảng users
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE,
              password TEXT
            );
          ''');
        }
      },
    );
  }
}
