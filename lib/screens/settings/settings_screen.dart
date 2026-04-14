import 'package:flutter/material.dart';
import '../profile/edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget buildItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt và hoạt động")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("Tài khoản của bạn",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          buildItem("Trung tâm tài khoản", Icons.person, () {}),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("Cách bạn dùng Instagram",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          buildItem("Đã lưu", Icons.bookmark, () {}),
          buildItem("Kho lưu trữ", Icons.archive, () {}),
          buildItem("Hoạt động của bạn", Icons.history, () {}),
          buildItem("Thông báo", Icons.notifications, () {}),
          buildItem("Quản lý thời gian", Icons.access_time, () {}),

          const Divider(),

          buildItem("Chỉnh sửa trang cá nhân", Icons.edit, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const EditProfileScreen()),
            );
          }),

          const Divider(),

          ListTile(
            title: const Text("Đăng xuất",
                style: TextStyle(color: Colors.red)),
            onTap: () {},
          )
        ],
      ),
    );
  }
}