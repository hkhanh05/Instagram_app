import 'package:flutter/material.dart';
import '../../widgets/message/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Hello!", "isMe": false},
    {"text": "Hi!", "isMe": true},
  ];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": _controller.text,
        "isMe": true,
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          // DANH SÁCH TIN NHẮN
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  text: messages[index]["text"],
                  isMe: messages[index]["isMe"],
                );
              },
            ),
          ),

          // Ô NHẬP + NÚT GỬI
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}