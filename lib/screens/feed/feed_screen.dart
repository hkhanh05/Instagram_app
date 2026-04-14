import 'package:flutter/material.dart';
import '../../widgets/story/story_list.dart';
import '../../widgets/post/post_card.dart';
import 'notification_screen.dart';
import '../message/message_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instagram"),
        actions: [
          // ❤️ Notification
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
          ),

          // 💬 Message
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MessageScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: const [
          StoryList(),
          Divider(),
          PostCard(),
          PostCard(),
          PostCard(),
        ],
      ),
    );
  }
}