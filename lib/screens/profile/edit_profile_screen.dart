import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import '../../models/profile_model.dart';
import '../../services/fake_data_service.dart';

class EditProfileScreen extends StatefulWidget {
  final int currentUserId;

  const EditProfileScreen({
    super.key,
    this.currentUserId = 1,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController profileController = ProfileController();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();

  String? selectedGender; // 🔥 Chuyển thành nullable để tránh gán cứng dữ liệu tĩnh ban đầu
  String currentAvatarUrl = ""; // 🔥 Xóa chuỗi URL ảnh tĩnh pravatar
  int? profileId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // =========================================================================
  // LOAD PROFILE FROM CONTROLLER / DATABASE
  // =========================================================================
  Future<void> loadProfile() async {
    final profile = await profileController.getProfile(widget.currentUserId);

    if (profile != null) {
      setState(() {
        profileId = profile.id;
        nameCtrl.text = profile.fullName;
        usernameCtrl.text = profile.username;
        bioCtrl.text = profile.bio;
        selectedGender = profile.gender;
        currentAvatarUrl = profile.avatarUrl;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Chỉnh sửa trang cá nhân",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AVATAR ĐỘNG - KHÔNG CÒN ẢNH TĨNH
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: currentAvatarUrl.isNotEmpty 
                  ? NetworkImage(currentAvatarUrl) 
                  : null,
              child: currentAvatarUrl.isEmpty 
                  ? const Icon(Icons.person, size: 40, color: Colors.grey) 
                  : null,
            ),
          ),

          TextButton(
            onPressed: () {
              // To-Do: Xử lý chức năng chọn ảnh từ thư viện thiết bị tại đây
            },
            child: const Text(
              "Chỉnh sửa ảnh hoặc avatar",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),

          // NAME
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: "Tên",
            ),
          ),

          const SizedBox(height: 10),

          // USERNAME
          TextField(
            controller: usernameCtrl,
            decoration: const InputDecoration(
              labelText: "Tên người dùng",
            ),
          ),

          const SizedBox(height: 10),

          // BIO
          TextField(
            controller: bioCtrl,
            decoration: const InputDecoration(
              labelText: "Tiểu sử",
            ),
          ),

          const SizedBox(height: 10),

          // GENDER DROPDOWN
          DropdownButtonFormField<String>(
            value: selectedGender,
            hint: const Text("Chọn giới tính"), // Hiển thị hint nếu DB chưa có dữ liệu giới tính
            items: ["Nam", "Nữ"]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            decoration: const InputDecoration(
              labelText: "Giới tính",
            ),
          ),

          const SizedBox(height: 30),

          // SAVE BUTTON
          ElevatedButton(
            onPressed: () async {
              final updatedProfile = ProfileModel(
                id: profileId ?? widget.currentUserId,
                fullName: nameCtrl.text,
                username: usernameCtrl.text,
                bio: bioCtrl.text,
                gender: selectedGender ?? "", // Nếu chưa chọn thì truyền chuỗi rỗng
                avatarUrl: currentAvatarUrl,
              );

              // INSERT / UPDATE XUỐNG CƠ SỞ DỮ LIỆU THỰC TẾ
              if (profileId == null) {
                await profileController.insertProfile(updatedProfile);
              } else {
                await profileController.updateProfile(updatedProfile);
              }

              // THÔNG BÁO VÀ PHẢN HỒI LẠI MÀN HÌNH TRƯỚC
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã cập nhật thông tin cá nhân thành công!"),
                  ),
                );
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Lưu",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}