import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../widgets/post/post_item.dart';
import '../../widgets/story/story_item.dart';
=======
>>>>>>> 6327d897ed263bb7a2045b5003bf28aaa5c808f3

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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

      // ❗ DÙNG ListView thay vì Column
      body: ListView(
        children: [

          // STORY
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

          // POSTS
          ListView.builder(
            shrinkWrap: true, // 👈 QUAN TRỌNG
            physics: const NeverScrollableScrollPhysics(), // 👈 QUAN TRỌNG
            itemCount: 5,
            itemBuilder: (context, index) {
              return const PostItem();
            },
          ),
        ],
      ),
    );
  }
}
=======
    return const Scaffold(
      body: Center(
        child: Text('Feed Screen'),
      ),
    );
  }
}
>>>>>>> 6327d897ed263bb7a2045b5003bf28aaa5c808f3
