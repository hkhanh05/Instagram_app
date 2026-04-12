// Cấu hình MaterialApp, theme, route
import 'package:flutter/material.dart';
import 'screens/main/main_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Instagram Clone',

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Màn hình đầu tiên
      home: const MainScreen(),
    );
  }
}
