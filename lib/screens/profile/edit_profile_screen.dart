import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();

  String? selectedGender;
  String currentAvatarUrl = "";
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;

        final gender = data['gender']?.toString();

        setState(() {
          nameCtrl.text =
              data['fullName']?.toString() ?? data['name']?.toString() ?? '';
          usernameCtrl.text = data['username']?.toString() ?? '';
          bioCtrl.text = data['bio']?.toString() ?? '';
          selectedGender = (gender == 'Nam' || gender == 'Nữ') ? gender : null;
          currentAvatarUrl = data['avatarUrl']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          nameCtrl.text = user.displayName ?? '';
          usernameCtrl.text = user.email?.split('@').first ?? '';
          bioCtrl.text = '';
          selectedGender = null;
          currentAvatarUrl = user.photoURL ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Load profile error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': nameCtrl.text.trim(),
        'fullName': nameCtrl.text.trim(),
        'username': usernameCtrl.text.trim(),
        'bio': bioCtrl.text.trim(),
        'gender': selectedGender ?? '',
        'avatarUrl': currentAvatarUrl,
        'followersCount': 0,
        'followingCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã cập nhật thông tin cá nhân thành công!"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Save profile error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi lưu thông tin: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              backgroundImage:
                  currentAvatarUrl.isNotEmpty ? NetworkImage(currentAvatarUrl) : null,
              child: currentAvatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
          ),

          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Chức năng đổi avatar sẽ làm sau"),
                ),
              );
            },
            child: const Text(
              "Chỉnh sửa ảnh hoặc avatar",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),

          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: "Tên",
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: usernameCtrl,
            decoration: const InputDecoration(
              labelText: "Tên người dùng",
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: bioCtrl,
            decoration: const InputDecoration(
              labelText: "Tiểu sử",
            ),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: selectedGender,
            hint: const Text("Chọn giới tính"),
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

          ElevatedButton(
            onPressed: _isSaving ? null : saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Lưu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}