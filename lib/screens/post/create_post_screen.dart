import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() =>
      _CreatePostScreenState();
}

class _CreatePostScreenState
    extends State<CreatePostScreen> {
  File? selectedImage;

  final TextEditingController captionController =
      TextEditingController();

  final ImagePicker picker = ImagePicker();

  bool showCaptionScreen = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pickImage();
    });
  }

  Future<void> pickImage() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> sharePost() async {
    if (selectedImage == null) return;

    await Provider.of<PostProvider>(
      context,
      listen: false,
    ).createPost(
      imageUrl: selectedImage!.path,
      caption: captionController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đăng bài thành công"),
      ),
    );

    captionController.clear();

    setState(() {
      showCaptionScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showCaptionScreen) {
      return buildCaptionScreen();
    }

    return buildSelectImageScreen();
  }

  Widget buildSelectImageScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          "New post",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: selectedImage == null
                ? null
                : () {
                    setState(() {
                      showCaptionScreen = true;
                    });
                  },
            child: const Text(
              "Next",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: selectedImage == null
                  ? const Center(
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.white,
                      ),
                    )
                  : Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text(
                    "Chọn ảnh khác",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCaptionScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New post"),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text(
              "Share",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedImage != null)
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Image.file(
                selectedImage!,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: captionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write a caption...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }
}