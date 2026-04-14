import 'package:flutter/material.dart';
import '../../screens/message/chat_screen.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(),
      title: const Text('Username'),
      subtitle: const Text('Last message...'),
      trailing: const Text('2h'),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      },
    );
  }
}
