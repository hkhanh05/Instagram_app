import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../widgets/message/chat_item.dart';
import '../../widgets/message/note_item.dart';
=======
>>>>>>> 6327d897ed263bb7a2045b5003bf28aaa5c808f3

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),

      // 👇 DÙNG SafeArea để tránh lỗi Android
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== SEARCH BAR =====
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ===== NOTES =====
            SizedBox(
              height: 120, // 👈 giảm để tránh overflow
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  NoteItem(note: "Hello 👋", username: "user1"),
                  NoteItem(note: "Busy", username: "user2"),
                  NoteItem(note: "Call me", username: "user3"),
                ],
              ),
            ),

            const Divider(height: 1),

            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Tin nhắn",
                    style: TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Tin nhắn đang chờ",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),

            // ===== CHAT LIST =====
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero, // 👈 tránh lỗi layout
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const ChatItem();
                },
              ),
            ),
          ],
        ),
=======
    return const Scaffold(
      body: Center(
        child: Text('Message Screen'),
>>>>>>> 6327d897ed263bb7a2045b5003bf28aaa5c808f3
      ),
    );
  }
}
