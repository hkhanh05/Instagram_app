import 'package:flutter/material.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController controller = TextEditingController();

  // lưu comment + reply
  final List<Map<String, dynamic>> comments = [
    {
      "user": "user1",
      "text": "Nice post bro 🔥",
      "liked": false,
      "replies": []
    },
    {
      "user": "user2",
      "text": "Quá đẹp luôn 😍",
      "liked": false,
      "replies": []
    },
  ];

  int? replyingIndex; // đang reply comment nào

  void sendComment() {
    if (controller.text.isEmpty) return;

    setState(() {
      if (replyingIndex != null) {
        // 👉 thêm reply
        comments[replyingIndex!]["replies"].add({
          "user": "me",
          "text": controller.text,
          "liked": false,
        });
      } else {
        // 👉 comment thường
        comments.add({
          "user": "me",
          "text": controller.text,
          "liked": false,
          "replies": []
        });
      }
    });

    controller.clear();
    replyingIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
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
              // thanh kéo
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Comments",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const Divider(),

              // list comment
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (_, index) {
                    final item = comments[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // comment cha
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundImage:
                                NetworkImage('https://i.pravatar.cc/150'),
                          ),
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "${item['user']} ",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: item['text']),
                              ],
                            ),
                          ),
                          subtitle: GestureDetector(
                            onTap: () {
                              setState(() {
                                replyingIndex = index;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: const Text("Reply"),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              item['liked']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: item['liked']
                                  ? Colors.red
                                  : Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                item['liked'] = !item['liked'];
                              });
                            },
                          ),
                        ),

                        // reply con
                        if (item['replies'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 60),
                            child: Column(
                              children: List.generate(
                                item['replies'].length,
                                (i) {
                                  final reply = item['replies'][i];

                                  return ListTile(
                                    leading: const CircleAvatar(
                                      radius: 14,
                                      backgroundImage: NetworkImage(
                                          'https://i.pravatar.cc/150'),
                                    ),
                                    title: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "${reply['user']} ",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(text: reply['text']),
                                        ],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        reply['liked']
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 18,
                                        color: reply['liked']
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          reply['liked'] =
                                              !reply['liked'];
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // input + trạng thái reply
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    if (replyingIndex != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Replying to ${comments[replyingIndex!]['user']}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                replyingIndex = null;
                              });
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        ],
                      ),

                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/150'),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Add a comment...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: sendComment,
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}