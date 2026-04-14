import 'package:flutter/material.dart';
import '../../screens/story/story_view_screen.dart';

class StoryItem extends StatelessWidget {
  final int index;

  const StoryItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewScreen(initialUser: index),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150',
              ),
            ),
            const SizedBox(height: 6),
            const Text("user"),
          ],
        ),
      ),
    );
  }
}