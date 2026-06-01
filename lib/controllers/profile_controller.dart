import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class ProfileController {
  // 🔥 KHÔNG SỬ DỤNG DATABASEHELPER NỮA
  // Tham chiếu trực tiếp tới Collection 'users' trên Cloud Firestore
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // =========================================================================
  // 1. CHỨC NĂNG THÊM MỚI / KHỞI TẠO TÀI KHOẢN (SET/INSERT)
  // =========================================================================
  Future<bool> insertProfile(String firebaseUid, ProfileModel profile) async {
    try {
      // Sử dụng .doc(firebaseUid).set() để ID Document trùng khớp với Firebase Auth UID
      await _usersCollection.doc(firebaseUid).set({
        'uid': firebaseUid,
        //  'email': profile.email ?? '', // Phòng hờ model của bạn có trường email
        'name': profile.fullName,
        'fullName': profile.fullName,
        'username': profile.username,
        'bio': profile.bio.isEmpty
            ? 'Chào mừng đến với Instagram clone! 🚀'
            : profile.bio,
        'gender': profile.gender,
        'avatarUrl': profile.avatarUrl,
        'followersCount': 0,
        'followingCount': 0,
        'currentSong': "Thêm nhạc vào trang cá nhân",
        'musicUrl': "",
        'createdAt':
            FieldValue.serverTimestamp(), // Lưu thời gian tạo trực tuyến
      });
      return true;
    } catch (e) {
      print("❌ Lỗi insertProfile lên Firestore: $e");
      return false;
    }
  }

  // =========================================================================
  // 2. CHỨC NĂNG ĐỌC DỮ LIỆU HỒ SƠ (GET)
  // =========================================================================
  Future<ProfileModel?> getProfile(String firebaseUid) async {
    try {
      if (firebaseUid.isEmpty) return null;

      final docSnapshot = await _usersCollection.doc(firebaseUid).get();

      if (docSnapshot.exists) {
        final Map<String, dynamic> data =
            docSnapshot.data() as Map<String, dynamic>;

        // Chuẩn hóa dữ liệu động tránh lỗi null tương tự logic cũ của bạn
        final Map<String, dynamic> safeMap = {
          'id': firebaseUid, // Dùng UID chuỗi làm ID định danh
          'fullName': data['fullName'] ?? data['name'] ?? 'Thành viên mới',
          'username': data['username'] ?? 'instagram_user',
          'bio': data['bio'] ?? '',
          'gender': data['gender'] ?? '',
          'avatarUrl': data['avatarUrl'] ?? '',
        };

        // Trả dữ liệu về mapping Model từ dữ liệu Cloud
        return ProfileModel.fromMap(safeMap);
      }
    } catch (e) {
      print("❌ Lỗi getProfile tại Firestore Controller: $e");
    }
    return null;
  }

  // =========================================================================
  // 3. CHỨC NĂNG CẬP NHẬT (UPDATE)
  // =========================================================================
  Future<bool> updateProfile(String firebaseUid, ProfileModel profile) async {
    try {
      print("=== ĐANG TIẾN HÀNH CẬP NHẬT CLOUD FIRESTORE VIA CONTROLLER ===");
      print("UID người dùng cần sửa: $firebaseUid");

      await _usersCollection.doc(firebaseUid).update({
        'fullName': profile.fullName.trim(),
        'name': profile.fullName.trim(),
        'username': profile.username.trim(),
        'bio': profile.bio.trim(),
        'gender': profile.gender,
        'avatarUrl': profile.avatarUrl,
      });

      print("🚀 Đã cập nhật dữ liệu trực tuyến thành công!");
      return true;
    } catch (e) {
      print("❌ Lỗi updateProfile tại Firestore Controller: $e");
      return false;
    }
  }
}
