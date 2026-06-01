import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String? firebaseUid;

  const EditProfileScreen({super.key, this.firebaseUid});

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

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      if (widget.firebaseUid != null && widget.firebaseUid!.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.firebaseUid)
            .get();

        if (doc.exists) {
          final onlineData = doc.data();
          String genderFromFB = (onlineData?['gender'] ?? "").toString().trim();

          setState(() {
            nameCtrl.text = onlineData?['fullName'] ??
                onlineData?['name'] ??
                'Thành viên mới';
            usernameCtrl.text = onlineData?['username'] ?? 'instagram_user';
            bioCtrl.text = onlineData?['bio'] ?? '';
            currentAvatarUrl = onlineData?['avatarUrl'] ?? '';

            if (genderFromFB == "Nam" || genderFromFB == "Nữ") {
              selectedGender = genderFromFB;
            } else {
              selectedGender = null;
            }
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      print("❌ Lỗi nạp thông tin từ Firestore: $e");
      setState(() => _isLoading = false);
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
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Chỉnh sửa trang cá nhân",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            onPressed: () {},
            child: const Text("Chỉnh sửa ảnh hoặc avatar",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Tên"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: usernameCtrl,
            decoration: const InputDecoration(labelText: "Tên người dùng"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: bioCtrl,
            decoration: const InputDecoration(labelText: "Tiểu sử"),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedGender,
            hint: const Text("Chọn giới tính"),
            items: ["Nam", "Nữ"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => selectedGender = value),
            decoration: const InputDecoration(labelText: "Giới tính"),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              if (widget.firebaseUid == null || widget.firebaseUid!.isEmpty)
                return;
              setState(() => _isLoading = true);

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.firebaseUid)
                    .update({
                  'fullName': nameCtrl.text.trim(),
                  'name': nameCtrl.text.trim(),
                  'username': usernameCtrl.text.trim(),
                  'bio': bioCtrl.text.trim(),
                  'gender': selectedGender ?? "",
                  'avatarUrl': currentAvatarUrl,
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Đã cập nhật thành công! 🎉"),
                        backgroundColor: Colors.green),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                print("❌ Lỗi ghi Cloud: $e");
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text("Lưu thay đổi",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
