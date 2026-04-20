// Chụp ảnh
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  // Chụp ảnh bằng camera
  Future<void> _capturePhoto() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, //
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      // ✅ thêm navigate sau khi chụp xong
      if (image != null && mounted) {
        Navigator.pushNamed(context, '/create-post', arguments: image.path);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cấp quyền camera')),
        );
      }
    }
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery, //
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (image != null && mounted) {
      Navigator.pushNamed(context, '/create-post', arguments: image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text('Bài viết mới', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn từ thư viện'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
