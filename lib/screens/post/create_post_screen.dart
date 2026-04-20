import 'package:flutter/material.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false; //  thêm loading state

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _submitPost(String imagePath) async {
    setState(() => _isLoading = true); //  bật loading

    // TODO: gọi API upload ảnh + caption ở đây
    await Future.delayed(const Duration(seconds: 1)); // giả lập gọi API

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đăng bài thành công!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context), // ✅ nút X để quay lại
        ),
        title: const Text(
          'Bài viết mới',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // hiện loading khi đang đăng
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: () => _submitPost(imagePath),
                  child: const Text(
                    'Chia sẻ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          //  Row ảnh + caption giống Instagram
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh thu nhỏ bên trái
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // Ô nhập caption bên phải
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: 4,
                    autofocus: true, //
                    decoration: const InputDecoration(
                      hintText: 'Viết chú thích...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          //
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.black,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
