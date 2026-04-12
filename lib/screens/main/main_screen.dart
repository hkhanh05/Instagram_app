// Chứa bottom bar (Home, Search,...)
import 'package:flutter/material.dart';

// IMPORT SCREENS (đảm bảo đúng path theo project của bạn)
import '../feed/feed_screen.dart';
import '../search/search_screen.dart';
import '../post/create_post_screen.dart';
import '../message/message_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const FeedScreen(),
    const SearchScreen(),
    const CreatePostScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/*
================= GIẢI THÍCH =================

1. IndexedStack:
- Giữ trạng thái các màn hình (giống Instagram thật)
- Không bị reload lại khi chuyển tab

2. _screens:
- Danh sách các trang chính của app
- Mỗi tab tương ứng 1 screen

3. BottomNavigationBar:
- Thanh điều hướng dưới cùng
- Đã tắt label để giống Instagram

4. IMPORT:
- Bạn phải tạo sẵn các file:
  + feed_screen.dart
  + search_screen.dart
  + create_post_screen.dart
  + message_screen.dart
  + profile_screen.dart

5. LƯU Ý:
- Nếu lỗi import → kiểm tra lại path
- Nếu chưa có screen → tạo file rỗng trước

================================================

TIP NÂNG CAO (làm sau):
- Thay icon bằng icon giống Instagram (SVG)
- Thêm animation khi chuyển tab
- Thêm badge (ví dụ: tin nhắn chưa đọc)

================================================
*/
