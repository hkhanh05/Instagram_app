import '../../services/fake_data_service.dart';
import '../models/profile_model.dart';

class ProfileController {
  final dbHelper = DatabaseHelper.instance;

  // =========================================================================
  // 1. CHỨC NĂNG THÊM MỚI (INSERT)
  // =========================================================================
  Future<int> insertProfile(ProfileModel profile) async {
    try {
      final db = await dbHelper.database;

      return await db.insert(
        'user_profile',
        profile.toMap(),
      );
    } catch (e) {
      print("❌ Lỗi insertProfile: $e");
      return -1;
    }
  }

  // =========================================================================
  // 2. CHỨC NĂNG ĐỌC DỮ LIỆU (GET)
  // =========================================================================
  Future<ProfileModel?> getProfile(int userId) async {
    try {
      final db = await dbHelper.database;

      final maps = await db.query(
        'user_profile',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        // 🔥 Tạo bản sao an toàn tránh lỗi null
        final Map<String, dynamic> safeMap =
            Map<String, dynamic>.from(maps.first);

        // 🔥 Gán dữ liệu mặc định nếu SQLite bị null
        safeMap['name'] =
            safeMap['name'] ?? 'Chưa đặt tên';

        safeMap['username'] =
            safeMap['username'] ?? 'username';

        safeMap['bio'] =
            safeMap['bio'] ?? '';

        safeMap['gender'] =
            safeMap['gender'] ?? 'Nữ';

        safeMap['avatar'] =
            safeMap['avatar'] ??
                'https://i.pravatar.cc/150?img=3';

        // 🔥 Trả dữ liệu về model
        return ProfileModel.fromMap(safeMap);
      }
    } catch (e) {
      print("❌ Lỗi getProfile tại Controller: $e");
    }

    return null;
  }

  // =========================================================================
  // 3. CHỨC NĂNG CẬP NHẬT (UPDATE)
  // =========================================================================
  Future<int> updateProfile(ProfileModel profile) async {
    try {
      final db = await dbHelper.database;

      print(
          "=== ĐANG TIẾN HÀNH CẬP NHẬT SQLITE VIA CONTROLLER ===");

      print("ID người dùng cần sửa: ${profile.id}");

      final dataToUpdate = profile.toMap();

      print(
          "Dữ liệu dạng Map đẩy xuống DB: $dataToUpdate");

      return await db.update(
        'user_profile',
        dataToUpdate,
        where: 'id = ?',
        whereArgs: [profile.id],
      );
    } catch (e) {
      print(
          "❌ Lỗi updateProfile tại Controller: $e");
      return -1;
    }
  }
}
