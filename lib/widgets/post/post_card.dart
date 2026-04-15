// // 

// import 'package:flutter/material.dart';

// class PostCard extends StatefulWidget {
//   const PostCard({super.key});

//   @override
//   State<PostCard> createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {
//   bool isLiked = false;

//   void _toggleLike() {
//     setState(() {
//       isLiked = !isLiked;
//     });
//   }

//   void _onShare(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Đã chia sẻ bài viết ✈️"),
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [

//         // 🔥 HEADER
//         ListTile(
//           leading: const CircleAvatar(
//             backgroundImage: NetworkImage(
//               'https://i.pravatar.cc/150?img=3',
//             ),
//           ),
//           title: const Text(
//             "username",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: const Text("Some music 🎵"),
//           trailing: const Icon(Icons.more_vert),
//         ),

//         // 🔥 IMAGE
//         GestureDetector(
//           onDoubleTap: _toggleLike,
//           child: Image.network(
//             'https://picsum.photos/500?random=1',
//             width: double.infinity,
//             height: 350,
//             fit: BoxFit.cover,
//           ),
//         ),

//         const SizedBox(height: 8),

//         // 🔥 ACTION BUTTONS
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Row(
//             children: [
//               IconButton(
//                 icon: Icon(
//                   isLiked ? Icons.favorite : Icons.favorite_border,
//                   color: isLiked ? Colors.red : Colors.black,
//                 ),
//                 onPressed: _toggleLike,
//               ),
//               IconButton(
//                 icon: const Icon(Icons.mode_comment_outlined),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.send_outlined),
//                 onPressed: () => _onShare(context),
//               ),

//               const Spacer(),

//               IconButton(
//                 icon: const Icon(Icons.bookmark_border),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),

//         // 🔥 LIKE COUNT
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             "Liked by user123 and others",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),

//         // 🔥 CAPTION
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           child: Text.rich(
//             TextSpan(
//               children: [
//                 TextSpan(
//                   text: "username ",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 TextSpan(text: "This is a caption"),
//               ],
//             ),
//           ),
//         ),

//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             "9 hours ago",
//             style: TextStyle(color: Colors.grey),
//           ),
//         ),

//         const SizedBox(height: 12),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../screens/feed/comment_screen.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int currentIndex = 0;

  final List<String> images = [
    'https://picsum.photos/500?random=1',
    'https://picsum.photos/500?random=2',
    'https://picsum.photos/500?random=3',
  ];

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void _onDoubleTap() {
    setState(() {
      isLiked = true;
    });
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CommentScreen(),
    );
  }

  void _onShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Chia sẻ đến",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  children: List.generate(8, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundImage:
                                NetworkImage('https://i.pravatar.cc/150'),
                          ),
                          const SizedBox(height: 6),
                          Text("user$index"),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🔥 HEADER (giống IG)
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: const CircleAvatar(
            radius: 18,
            backgroundImage:
                NetworkImage('https://i.pravatar.cc/150?img=3'),
          ),
          title: const Text(
            "username",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: const Row(
            children: [
              Icon(Icons.music_note, size: 12),
              SizedBox(width: 4),
              Text("Some music", style: TextStyle(fontSize: 12)),
            ],
          ),
          trailing: const Icon(Icons.more_vert, size: 18),
        ),

        // 🔥 IMAGE
        GestureDetector(
          onDoubleTap: _onDoubleTap,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 350,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return Image.network(
                      images[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),

              // 🔥 DOT (giống IG)
              Positioned(
                bottom: 10,
                child: Row(
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Colors.blue
                            : Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // 🔥 ACTION BAR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.black,
                ),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: const Icon(Icons.mode_comment_outlined),
                onPressed: () => _openComments(context),
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: () => _onShare(context),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // 🔥 TEXT
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Liked by user123 and others",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "username ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: "This is a caption"),
              ],
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "9 hours ago",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}