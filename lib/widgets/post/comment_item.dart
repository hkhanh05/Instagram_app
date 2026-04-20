// Item comment
import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  final String user;
  final String text;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const CommentItem({
    super.key,
    required this.user,
    required this.text,
    required this.liked,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "$user ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
      subtitle: GestureDetector(
        onTap: onReply,
        child: const Text(
          "Reply",
          style: TextStyle(fontSize: 12),
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          color: liked ? Colors.red : Colors.black,
        ),
        onPressed: onLike,
      ),
    );
  }
}