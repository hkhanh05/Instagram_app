import '../models/user_model.dart';
import '../core/utils/helpers.dart';

class LoginController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<bool> register(User user) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );
    if (existing.isNotEmpty) {
      return false;
    }

    await db.insert('users', user.toMap());
    return true;
  }

  Future<User?> login(String email, String password) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isEmpty) {
      return null;
    }
    return User.fromMap(maps.first);
  }

  Future<bool> emailExists(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }
}
