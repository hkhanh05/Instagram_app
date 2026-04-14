import 'package:flutter/material.dart';
import '../../screens/feed/comment_screen.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool showHeart = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnim = Tween(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnim = Tween(begin: 1.0, end: 0.0).animate(_controller);
  }

  void _onDoubleTap() {
    setState(() {
      isLiked = true;
      showHeart = true;
    });

    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  void _openComment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CommentScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
          title: const Text("username"),
          trailing: const Icon(Icons.more_vert),
        ),

        GestureDetector(
          onDoubleTap: _onDoubleTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network('https://picsum.photos/500/500'),
              if (showHeart)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => Opacity(
                    opacity: _opacityAnim.value,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        Row(
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.black,
              ),
              onPressed: () => setState(() => isLiked = !isLiked),
            ),
            IconButton(
              icon: const Icon(Icons.comment_outlined),
              onPressed: () => _openComment(context),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {},
            ),
          ],
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("Liked by user123 and others"),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("username This is a caption"),
        ),
      ],
    );
  }
}