import 'dart:io';
import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📥 Nhận đường dẫn file ảnh (imagePath) truyền qua arguments từ CameraScreen
    final String imagePath =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 🖼️ ẢNH NỀN FULL MÀN HÌNH (Bo góc nhẹ giống ảnh mẫu)
          Positioned.fill(
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. ✖️ NÚT THOÁT (Góc trên cùng bên trái)
          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                radius: 20,
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),

          // 3. 📑 THANH ICON CHỨC NĂNG XẾP DỌC (Góc trên cùng bên phải)
          Positioned(
            top: 60,
            right: 20,
            child: Column(
              children: [
                _buildRightActionButton(Icons.text_fields, "Aa"),
                _buildRightActionButton(Icons.sticky_note_2_outlined, null),
                _buildRightActionButton(Icons.music_note, null),
                _buildRightActionButton(
                    Icons.auto_awesome, null), // Icon bộ lọc lấp lánh
                _buildRightActionButton(Icons.keyboard_arrow_down, null),
              ],
            ),
          ),

          // 4. ✍️ Ô NHẬP CHÚ THÍCH / CAPTION (Góc đáy bên trái)
          Positioned(
            bottom: 110,
            left: 24,
            right: 24,
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Thêm chú thích...',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),

          // 5. 🛠️ THANH CÔNG CỤ ĐĂNG BÀI Ở ĐÁY (Tin của bạn, Bạn thân, Gửi đi)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Nút "Tin của bạn"
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.person_pin,
                    label: 'Tin của bạn',
                    onPressed: () {
                      // Xử lý đăng bài...
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Nút "Bạn thân"
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.star,
                    label: 'Bạn thân',
                    iconColor: Colors.green,
                    onPressed: () {
                      // Xử lý đăng...
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Nút tròn mũi tên màu xanh dương để "Tiếp tục"
                GestureDetector(
                  onTap: () {
                    // Xử lý đăng bài trực tiếp...
                  },
                  child: const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.indigoAccent,
                    child: Icon(Icons.arrow_forward,
                        color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tạo nhanh các icon tròn nhỏ bên phải
  Widget _buildRightActionButton(IconData icon, String? customText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.black.withOpacity(0.4),
        child: customText != null
            ? Text(customText,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
            : Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // Hàm tạo nhanh nút dài dưới đáy
  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
