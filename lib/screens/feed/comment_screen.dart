
// import 'package:flutter/material.dart';
// import '../../widgets/post/comment_item.dart';

// class CommentScreen extends StatefulWidget {
//   const CommentScreen({super.key});

//   @override
//   State<CommentScreen> createState() => _CommentScreenState();
// }

// class _CommentScreenState extends State<CommentScreen> {
//   final TextEditingController controller = TextEditingController();

//   final List<Map<String, dynamic>> comments = [
//     {
//       "user": "user1",
//       "text": "Nice post bro 🔥",
//       "liked": false,
//       "replies": []
//     },
//     {
//       "user": "user2",
//       "text": "Quá đẹp luôn 😍",
//       "liked": false,
//       "replies": []
//     },
//   ];

//   int? replyingIndex;

//   void sendComment() {
//     if (controller.text.isEmpty) return;

//     setState(() {
//       if (replyingIndex != null) {
//         comments[replyingIndex!]["replies"].add({
//           "user": "me",
//           "text": controller.text,
//           "liked": false,
//         });
//       } else {
//         comments.add({
//           "user": "me",
//           "text": controller.text,
//           "liked": false,
//           "replies": []
//         });
//       }
//     });

//     controller.clear();
//     replyingIndex = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.65,
//       minChildSize: 0.4,
//       maxChildSize: 0.95,
//       builder: (_, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             children: [
//               // 🔥 thanh kéo
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 10),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[400],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),

//               const Text(
//                 "Comments",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),

//               const Divider(),

//               // 🔥 LIST COMMENT
//               Expanded(
//                 child: ListView.builder(
//                   controller: scrollController,
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: comments.length,
//                   itemBuilder: (_, index) {
//                     final item = comments[index];

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 🔥 COMMENT CHA
//                         CommentItem(
//                           user: item['user'],
//                           text: item['text'],
//                           liked: item['liked'],
//                           onLike: () {
//                             setState(() {
//                               item['liked'] = !item['liked'];
//                             });
//                           },
//                           onReply: () {
//                             setState(() {
//                               replyingIndex = index;
//                             });
//                           },
//                         ),

//                         // 🔥 REPLY
//                         if (item['replies'].isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(left: 60),
//                             child: Column(
//                               children: List.generate(
//                                 item['replies'].length,
//                                 (i) {
//                                   final reply = item['replies'][i];

//                                   return ListTile(
//                                     leading: const CircleAvatar(
//                                       radius: 14,
//                                       backgroundImage:
//                                           NetworkImage('https://i.pravatar.cc/150'),
//                                     ),
//                                     title: Text.rich(
//                                       TextSpan(
//                                         children: [
//                                           TextSpan(
//                                             text: "${reply['user']} ",
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                           TextSpan(text: reply['text']),
//                                         ],
//                                       ),
//                                     ),
//                                     trailing: IconButton(
//                                       icon: Icon(
//                                         reply['liked']
//                                             ? Icons.favorite
//                                             : Icons.favorite_border,
//                                         size: 18,
//                                         color: reply['liked']
//                                             ? Colors.red
//                                             : Colors.black,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           reply['liked'] = !reply['liked'];
//                                         });
//                                       },
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//               ),

//               // 🔥 INPUT
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 child: Column(
//                   children: [
//                     if (replyingIndex != null)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Replying to ${comments[replyingIndex!]['user']}",
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 replyingIndex = null;
//                               });
//                             },
//                             child: const Text(
//                               "Cancel",
//                               style: TextStyle(color: Colors.red),
//                             ),
//                           )
//                         ],
//                       ),

//                     Row(
//                       children: [
//                         const CircleAvatar(
//                           radius: 16,
//                           backgroundImage:
//                               NetworkImage('https://i.pravatar.cc/150'),
//                         ),
//                         const SizedBox(width: 10),

//                         Expanded(
//                           child: TextField(
//                             controller: controller,
//                             decoration: const InputDecoration(
//                               hintText: "Add a comment...",
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),

//                         IconButton(
//                           icon: const Icon(Icons.send),
//                           onPressed: sendComment,
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../widgets/post/comment_item.dart';
import '../../services/fake_data_service.dart';

class CommentScreen extends StatefulWidget {
  final int postId;

  const CommentScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController controller = TextEditingController();

  final db = DatabaseHelper.instance;

  List<Map<String, dynamic>> comments = [];

  int? replyingIndex;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    comments =
        await db.getCommentsByPostId(widget.postId);

    setState(() {});
  }

  Future<void> sendComment() async {
    if (controller.text.trim().isEmpty) return;

    await db.insertComment(
      widget.postId,
      "me",
      controller.text,
    );

    controller.clear();

    await loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: comments.length,
                  itemBuilder: (_, index) {
                    final item = comments[index];

                    return CommentItem(
                      user: item['username'] ?? '',
                      text: item['content'] ?? '',
                      liked: false,
                      onLike: () {},
                      onReply: () {
                        setState(() {
                          replyingIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    if (replyingIndex != null)
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Replying to ${comments[replyingIndex!]['username']}",
                            style:
                                const TextStyle(fontSize: 12),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                replyingIndex = null;
                              });
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),

                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150',
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration:
                                const InputDecoration(
                              hintText:
                                  "Add a comment...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: sendComment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}