import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/post_provider.dart';

void main() async {
  // Bắt buộc phải thêm dòng này khi chạy bất đồng bộ trong main
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo các dịch vụ Firebase
  await Firebase.initializeApp();

  runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => PostProvider(),
                ),
              ],
              child: const MyApp(),
            ),
          );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Chạy vào màn hình chào của bạn đầu tiên
    );
  }
}
