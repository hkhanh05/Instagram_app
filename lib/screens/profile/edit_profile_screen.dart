import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameCtrl =
      TextEditingController(text: "Hòa Phan");
  final TextEditingController usernameCtrl =
      TextEditingController(text: "aoh.fen");
  final TextEditingController bioCtrl =
      TextEditingController(text: "Come quiet, stay curious.");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa trang cá nhân")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Chỉnh sửa ảnh hoặc avatar"),
          ),

          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Tên"),
          ),

          TextField(
            controller: usernameCtrl,
            decoration: const InputDecoration(labelText: "Tên người dùng"),
          ),

          TextField(
            controller: bioCtrl,
            decoration: const InputDecoration(labelText: "Tiểu sử"),
          ),

          DropdownButtonFormField(
            value: "Nữ",
            items: ["Nam", "Nữ"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(labelText: "Giới tính"),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {},
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }
}