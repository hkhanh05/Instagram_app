import 'package:flutter/material.dart';

// IMPORT SCREENS (Đảm bảo đúng path của project bạn nhé)
import '../feed/feed_screen.dart';
import '../search/search_screen.dart';
import '../post/create_post_screen.dart';
import '../message/message_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String? firebaseUid;

  // Sửa chính xác hàm khởi tạo nhận biến dynamic
  MainScreen({super.key, this.firebaseUid});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Khai báo danh sách các màn hình
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các màn hình một lần duy nhất tại đây khi khởi chạy widget
    _screens = [
      const FeedScreen(),
      const SearchScreen(),
      const CreatePostScreen(),
      const MessageScreen(),
      // Truyền an toàn Firebase UID vào ProfileScreen
      ProfileScreen(firebaseUid: widget.firebaseUid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children:
            _screens, // Truyền trực tiếp danh sách biến tĩnh tĩnh đã lưu trong bộ nhớ
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
