import 'package:flutter/material.dart';
import '../../widgets/message/chat_item.dart';
import '../../widgets/message/note_item.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ===== NOTES (AVATAR + TEXT) =====
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                NoteItem(note: "Hello 👋", username: "user1"),
                NoteItem(note: "Busy", username: "user2"),
                NoteItem(note: "Call me", username: "user3"),
              ],
            ),
          ),

          // ===== LINE =====
          const Divider(),

          // ===== HEADER =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Tin nhắn",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Tin nhắn đang chờ",
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // ===== CHAT LIST =====
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return const ChatItem();
              },
            ),
          ),
        ],
      ),
    );
  }
}