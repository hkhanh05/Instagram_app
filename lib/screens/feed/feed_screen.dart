import 'package:flutter/material.dart';
import '../../widgets/post/post_item.dart';
import '../../widgets/story/story_item.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: const [
          Icon(Icons.favorite_border),
          SizedBox(width: 15),
          Icon(Icons.send),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // STORY LIST
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: StoryItem(),
                );
              },
            ),
          ),

          const Divider(),

          // POST LIST
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return const PostItem();
              },
            ),
          ),
        ],
      ),
    );
  }
}