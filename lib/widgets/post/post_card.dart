import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../screens/feed/comment_screen.dart';
import '../../services/fake_data_service.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;

  String username = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name =
        await FakeDataHelper.instance.getUsernameByUserId(
      widget.post.userId,
    );

    if (mounted) {
      setState(() {
        username = name;
      });
    }
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentScreen(
        postId: widget.post.id ?? 0,
      ),
    );
  }

  void _onShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SizedBox(
          height: 220,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Chia sẻ đến",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("user$index"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostImage() {
    final image = widget.post.imageUrl;

    if (image.startsWith('/')) {
      return Image.file(
        File(image),
        width: double.infinity,
        height: 450,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      image,
      width: double.infinity,
      height: 450,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          height: 450,
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 50,
            ),
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
        // HEADER
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=3',
            ),
          ),
          title: Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(
            Icons.more_vert,
          ),
        ),

        // IMAGE
        GestureDetector(
          onDoubleTap: _toggleLike,
          child: _buildPostImage(),
        ),

        // ACTIONS
        Row(
          children: [
            IconButton(
              icon: Icon(
                isLiked
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    isLiked ? Colors.red : Colors.black,
              ),
              onPressed: _toggleLike,
            ),
            IconButton(
              icon: const Icon(
                Icons.mode_comment_outlined,
              ),
              onPressed: () =>
                  _openComments(context),
            ),
            IconButton(
              icon: const Icon(
                Icons.send_outlined,
              ),
              onPressed: () =>
                  _onShare(context),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.bookmark_border,
              ),
              onPressed: () {},
            ),
          ],
        ),

        // LIKES
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Text(
            "${widget.post.likesCount} likes",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // CAPTION
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: "$username ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: widget.post.caption,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Text(
            "Vừa xong",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}