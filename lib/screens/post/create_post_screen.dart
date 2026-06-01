import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../services/fake_data_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() =>
      _CreatePostScreenState();
}

class _CreatePostScreenState
    extends State<CreatePostScreen> {
  final TextEditingController captionController =
      TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? imagePath =
        ModalRoute.of(context)?.settings.arguments
            as String?;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imagePath == null
                    ? Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),

          // Nút đóng
          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor:
                    Colors.black.withOpacity(0.4),
                radius: 20,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Menu bên phải
          Positioned(
            top: 60,
            right: 20,
            child: Column(
              children: [
                _buildRightActionButton(
                  Icons.text_fields,
                  "Aa",
                ),
                _buildRightActionButton(
                  Icons.sticky_note_2_outlined,
                  null,
                ),
                _buildRightActionButton(
                  Icons.music_note,
                  null,
                ),
                _buildRightActionButton(
                  Icons.auto_awesome,
                  null,
                ),
                _buildRightActionButton(
                  Icons.keyboard_arrow_down,
                  null,
                ),
              ],
            ),
          ),

          // Caption
          Positioned(
            bottom: 110,
            left: 24,
            right: 24,
            child: TextField(
              controller: captionController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Thêm chú thích...',
                hintStyle: TextStyle(
                  color:
                      Colors.white.withOpacity(0.8),
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          // Thanh dưới
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.person_pin,
                    label: 'Tin của bạn',
                    onPressed: () {},
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.star,
                    label: 'Bạn thân',
                    iconColor: Colors.green,
                    onPressed: () {},
                  ),
                ),

                const SizedBox(width: 12),

                GestureDetector(
                  onTap: () async {
                    if (imagePath == null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng chọn ảnh',
                          ),
                        ),
                      );
                      return;
                    }

                    await FakeDataHelper.instance.insertPost(
  1,
  imagePath,
  captionController.text.trim().isEmpty
      ? 'Bài viết mới'
      : captionController.text.trim(),
);

if (mounted) {
  Navigator.pop(context, true);
}
                  },
                  child: const CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        Colors.indigoAccent,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightActionButton(
    IconData icon,
    String? customText,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: CircleAvatar(
        radius: 22,
        backgroundColor:
            Colors.black.withOpacity(0.4),
        child: customText != null
            ? Text(
                customText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
      ),
    );
  }

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
          backgroundColor:
              Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}