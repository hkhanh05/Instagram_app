import 'package:flutter/material.dart';
import 'story_item.dart';

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110, // 👈 tăng nhẹ cho giống IG
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8), // 👈 QUAN TRỌNG
        itemCount: 10,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12), // 👈 khoảng cách giữa story
            child: StoryItem(index: index),
          );
        },
      ),
    );
  }
}