import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../widgets/post/post_card.dart';
import '../../widgets/story/story_list.dart';

import 'notification_screen.dart';
import '../message/message_screen.dart';
import '../post/camera_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(
        context,
        listen: false,
      ).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CameraScreen(),
              ),
            );
          },
        ),

        title: SizedBox(
          height: 50,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(
              'assets/images/instagram_logo.png',
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MessageScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const StoryList(),

          const Divider(
            height: 1,
            thickness: 0.3,
          ),

          Expanded(
            child: Consumer<PostProvider>(
              builder:
                  (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (provider.posts.isEmpty) {
                  return const Center(
                    child: Text(
                      "Chưa có bài viết",
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh:
                      provider.loadPosts,
                  child: ListView.builder(
                    itemCount:
                        provider.posts.length,
                    itemBuilder:
                        (context, index) {
                      return PostCard(
                        post:
                            provider.posts[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}