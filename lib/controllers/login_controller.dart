// controllers/login_controller.dart
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import '../core/utils/helpers.dart';

import 'package:sqflite/sqflite.dart';

class LoginController {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// 1. XỬ LÝ ĐĂNG KÝ (Firebase Auth + SQLite)
  Future<bool> register(User user) async {
    try {
      // BƯỚC A: Tạo tài khoản trên Cloud Firebase Authentication
      fb.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      fb.User? firebaseUser = userCredential.user;

      // Nếu Firebase tạo thành công và trả về thông tin User
      if (firebaseUser != null) {
        // BƯỚC B: Đồng bộ dữ liệu xuống Local SQLite
        final Database db = await _dbHelper.database;

        Map<String, dynamic> userData = {
          'email': user.email,
          'password': user
              .password, // Thường đồ án nộp bài lưu text, thực tế nên mã hóa
          'name': user.name,
          'username': user.username,
          'birthday': user.birthday,
        };

        // Tiến hành chèn (insert) vào bảng users trong SQLite
        await db.insert(
          'users',
          userData,
          conflictAlgorithm:
              ConflictAlgorithm.replace, // Nếu trùng dữ liệu thì đè lên
        );

        return true; // Đăng ký thành công cả 2 bên
      }
      return false;
    } on fb.FirebaseAuthException catch (e) {
      // Ép kiểu tường minh thông tin lỗi để an toàn trên môi trường Web
      print("Lỗi Firebase Register: ${e.code} - ${e.message.toString()}");
      return false;
    } catch (e) {
      // FIX TẠI ĐÂY: Sử dụng e.toString() thay vì gọi $e trực tiếp để tránh lỗi JavaScriptObject trên Web
      print("Lỗi hệ thống Register: ${e.toString()}");
      return false;
    }
  }

  /// 2. XỬ LÝ ĐĂNG NHẬP (Firebase Auth + Kiểm tra SQLite)
  Future<User?> login(String email, String password) async {
    try {
      // BƯỚC A: Xác thực tài khoản thông qua Firebase Auth trước
      fb.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      fb.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // BƯỚC B: Lấy thông tin chi tiết (Name, Username, Birthday) từ SQLite lên để dùng trong App
        final Database db = await _dbHelper.database;

        List<Map<String, dynamic>> maps = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
        );

        if (maps.isNotEmpty) {
          // Trả về Object User đầy đủ thông tin từ SQL
          return User.fromMap(maps.first);
        } else {
          // Trường hợp hiếm: Có trên Firebase nhưng SQLite local chưa có (ví dụ đổi máy ảo khác)
          return User(email: email, password: password, name: "Instagram User");
        }
      }
      return null;
    } on fb.FirebaseAuthException catch (e) {
      // Ép kiểu tường minh thông tin lỗi để an toàn trên môi trường Web
      print("Lỗi Firebase Login: ${e.code} - ${e.message.toString()}");
      return null;
    } catch (e) {
      // FIX TẠI ĐÂY: Sử dụng e.toString() để bọc lỗi ngoại lệ an toàn trên Web
      print("Lỗi hệ thống Login: ${e.toString()}");
      return null;
    }
  }

  /// 3. XỬ LÝ ĐĂNG XUẤT
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Lỗi hệ thống Logout: ${e.toString()}");
    }
  }
}
