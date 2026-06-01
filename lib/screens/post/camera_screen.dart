// import 'dart:io'; // 🔥 BẮT BUỘC NHÉT THÊM DÒNG NÀY Ở ĐẦU FILE để dùng được lớp File
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:camera/camera.dart';
// import 'create_post_screen.dart';

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen>
//     with WidgetsBindingObserver {
//   final ImagePicker _picker = ImagePicker();

//   CameraController? _cameraController;
//   List<CameraDescription>? _cameras;
//   bool _isCameraInitialized = false;
//   int _selectedCameraIndex = 0;

//   // 🔥 NHÉT THÊM BIẾN NÀY: Để lưu đường dẫn ảnh hiển thị góc trái
//   File? _previewImage;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeCamera(_selectedCameraIndex);
//   }

//   Future<void> _initializeCamera(int cameraIndex) async {
//     var status = await Permission.camera.request();
//     if (status.isGranted) {
//       _cameras = await availableCameras();
//       if (_cameras != null && _cameras!.isNotEmpty) {
//         if (_cameraController != null) {
//           await _cameraController!.dispose();
//         }

//         _cameraController = CameraController(
//           _cameras![cameraIndex],
//           ResolutionPreset.medium,
//           enableAudio: false,
//         );

//         try {
//           await _cameraController!.initialize();
//           if (mounted) {
//             setState(() {
//               _isCameraInitialized = true;
//             });
//           }
//         } catch (e) {
//           print("❌ Lỗi khởi tạo ống kính: $e");
//         }
//       }
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final CameraController? cameraController = _cameraController;
//     if (state == AppLifecycleState.resumed) {
//       if (cameraController != null && !cameraController.value.isInitialized) {
//         _initializeCamera(_selectedCameraIndex);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   Future<void> _capturePhoto() async {
//     var status = await Permission.camera.status;
//     if (status.isDenied) {
//       status = await Permission.camera.request();
//     }

//     if (status.isGranted) {
//       try {
//         final XFile? image = await _picker.pickImage(
//           source: ImageSource.camera,
//           imageQuality: 85,
//           maxWidth: 1080,
//           maxHeight: 1080,
//         );

//         if (image != null && mounted) {
//           // 🔥 ĐÃ SỬA: Lưu lại ảnh để hiển thị góc trái nếu muốn
//           setState(() {
//             _previewImage = File(image.path);
//           });
//           // Nếu bạn muốn bấm nút chụp xong nhảy màn hình luôn thì giữ dòng dưới:
//           Navigator.pushNamed(context, '/create-post', arguments: image.path);
//         }
//       } catch (e) {
//         print("❌ Lỗi khi chụp ảnh: $e");
//       }
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Vui lòng cấp quyền camera trong cài đặt')),
//         );
//       }
//     }
//   }

//   Future<void> _pickFromGallery() async {
//     final XFile? image = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//       maxWidth: 1080,
//       maxHeight: 1080,
//     );
//     if (image != null && mounted) {
//       // 🔥 ĐÃ SỬA: Cập nhật ảnh thu nhỏ vào ô vuông
//       setState(() {
//         _previewImage = File(image.path);
//       });
//       // Bấm chọn ảnh xong nhảy màn hình edit:
//       Navigator.pushNamed(context, '/create-post', arguments: image.path);
//     }
//   }

//   void _toggleCamera() {
//     if (_cameras == null || _cameras!.isEmpty) return;
//     setState(() {
//       _isCameraInitialized = false;
//       _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
//     });
//     _initializeCamera(_selectedCameraIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: const Text('Bài viết mới',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               color: Colors.black,
//               child: _isCameraInitialized && _cameraController != null
//                   ? Center(child: CameraPreview(_cameraController!))
//                   : const Center(
//                       child: CircularProgressIndicator(color: Colors.white)),
//             ),
//           ),
//           Container(
//             color: Colors.black,
//             padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // 🔥 ĐÃ SỬA Ô GÓC TRÁI: Nhét logic hiển thị hình ảnh thu nhỏ vào đây
//                 GestureDetector(
//                   onTap: _pickFromGallery,
//                   child: Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[800],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                     // Kiểm tra nếu biến _previewImage có ảnh thì hiển thị ảnh bo góc, ngược lại hiện Icon mặc định
//                     child: _previewImage != null
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child:
//                                 Image.file(_previewImage!, fit: BoxFit.cover),
//                           )
//                         : const Icon(Icons.photo_library_outlined,
//                             color: Colors.white, size: 24),
//                   ),
//                 ),

//                 GestureDetector(
//                   onTap: _capturePhoto,
//                   child: Container(
//                     width: 76,
//                     height: 76,
//                     decoration: const BoxDecoration(
//                         color: Colors.white, shape: BoxShape.circle),
//                     padding: const EdgeInsets.all(4),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.black, width: 2),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.flip_camera_android,
//                       color: Colors.white, size: 26),
//                   onPressed: _toggleCamera,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

import 'create_post_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;

  File? _previewImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    var status = await Permission.camera.request();

    if (!status.isGranted) return;

    _cameras = await availableCameras();

    if (_cameras == null || _cameras!.isEmpty) return;

    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    final controller = _cameraController;

    if (controller == null) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(_selectedCameraIndex);
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (image == null) return;

      setState(() {
        _previewImage = File(image.path);
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreatePostScreen(),
          settings: RouteSettings(
            arguments: image.path,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _previewImage = File(image.path);
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreatePostScreen(),
          settings: RouteSettings(
            arguments: image.path,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Gallery Error: $e");
    }
  }

  void _toggleCamera() {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }

    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex =
          _selectedCameraIndex == 0 ? 1 : 0;
    });

    _initializeCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Bài viết mới",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: _isCameraInitialized &&
                      _cameraController != null
                  ? CameraPreview(_cameraController!)
                  : const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
            ),
          ),

          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: _previewImage != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                                    6),
                            child: Image.file(
                              _previewImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                          ),
                  ),
                ),

                GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration:
                        const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Container(
                      margin:
                          const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _toggleCamera,
                  icon: const Icon(
                    Icons.flip_camera_android,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

