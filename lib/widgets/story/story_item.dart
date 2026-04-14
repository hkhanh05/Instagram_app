import 'package:flutter/material.dart';

class StoryItem extends StatelessWidget {
  const StoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orange, Colors.purple],
            ),
          ),
          child: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'User',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}