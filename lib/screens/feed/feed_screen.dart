// import 'package:flutter/material.dart';
// import '../../widgets/story/story_list.dart';
// import '../../widgets/post/post_card.dart';
// import 'notification_screen.dart';
// import '../message/message_screen.dart';

// class FeedScreen extends StatelessWidget {
//   const FeedScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Instagram"),
//         actions: [
//           // ❤️ Notification
//           IconButton(
//             icon: const Icon(Icons.favorite_border),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const NotificationScreen(),
//                 ),
//               );
//             },
//           ),

//           // 💬 Message
//           IconButton(
//             icon: const Icon(Icons.chat_bubble_outline),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const MessageScreen(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         children: const [
//           StoryList(),
//           Divider(),
//           PostCard(),
//           PostCard(),
//           PostCard(),
//         ],
//       ),
//     );
//   }
// }

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
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        // 🔥 ICON TRÁI (GIỐNG IG)
        leading: IconButton(
          icon: const Icon(Icons.add, color: Colors.black, size: 28),
          onPressed: () {},
        ),

        // 🔥 LOGO GIỮA
        title: SizedBox(
          height: 50,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(
              'assets/images/instagram_logo.png',
            ),
          ),
        ),

        // 🔥 ICON PHẢI
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
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

      body: Column(
        children: [

          // 🔥 STORY (KHÔNG PADDING)
          const StoryList(),

          // 🔥 LINE NGĂN CÁCH
          const Divider(height: 1, thickness: 0.3),

          // 🔥 FEED LIST
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero, // 👈 QUAN TRỌNG
              itemCount: 5,
              itemBuilder: (context, index) {
                return const PostCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}