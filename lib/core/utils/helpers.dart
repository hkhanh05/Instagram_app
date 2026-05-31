// helpers/helpers.dart
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
    final databasesPath = await getDatabasesPath();
    // Lưu ý: Tên file có 2 dấu chấm 'instagram..db', bạn có thể sửa thành 'instagram.db' nếu muốn sạch sẽ hơn.
    final String path = join(databasesPath, 'instagram..db');

    return await openDatabase(
      path,
      version:
          3, // Nâng version lên 3 để cập nhật cấu trúc bảng đầy đủ cho người dùng cài mới
      onCreate: (db, version) async {
        // Đối với người dùng cài đặt ứng dụng lần đầu tiên, họ sẽ nhận ngay schema mới nhất này
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            name TEXT,
            username TEXT,
            birthday TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Áp dụng chiến lược kiểm tra từng nấc phiên bản để nâng cấp an toàn

        // Nếu người dùng đang ở version 1 (chưa có cột username), thêm cột username vào
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN username TEXT');
        }

        // Nếu người dùng đang ở version 1 hoặc 2 (chưa có cột birthday), thêm cột birthday vào
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE users ADD COLUMN birthday TEXT');
        }
      },
    );
  }
}
