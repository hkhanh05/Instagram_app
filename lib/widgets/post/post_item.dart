import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        const ListTile(
          leading: CircleAvatar(),
          title: Text('username'),
          subtitle: Text('Location'),
          trailing: Icon(Icons.more_vert),
        ),

        // IMAGE
        Container(
          height: 250,
          color: Colors.grey[300],
          child: const Center(child: Text('Image')),
        ),

        // ACTION BUTTONS
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            children: [
              Icon(Icons.favorite_border),
              SizedBox(width: 10),
              Icon(Icons.comment_outlined),
              SizedBox(width: 10),
              Icon(Icons.send),
              Spacer(),
              Icon(Icons.bookmark_border),
            ],
          ),
        ),

        // LIKES
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Liked by user1 and others',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // CAPTION
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text('username Caption here...'),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}