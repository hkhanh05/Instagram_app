// Feed
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/fake_data_service.dart';

class PostProvider extends ChangeNotifier {
  final DatabaseHelper db = DatabaseHelper.instance;

  List<PostModel> posts = [];

  bool isLoading = false;

  // LOAD POSTS
  Future<void> loadPosts() async {
    isLoading = true;
    notifyListeners();

    final data = await db.getPostsByUserId(1);

    posts =
        data.map((e) {
          return PostModel.fromMap(e);
        }).toList();

    isLoading = false;
    notifyListeners();
  }

  // LIKE
  Future<void> likePost(PostModel post) async {
    final newLikes = post.likesCount + 1;

    await db.updatePostLikes(
      post.id!,
      newLikes,
    );

    await loadPosts();
  }

  // CREATE POST
  Future<void> createPost({
    required String imageUrl,
    required String caption,
  }) async {
    await db.insertPost(
      1,
      imageUrl,
      caption,
    );

    await loadPosts();
  }

  // DELETE POST
  Future<void> deletePost(int postId) async {
    await db.deletePost(postId);

    await loadPosts();
  }
}