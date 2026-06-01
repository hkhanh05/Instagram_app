// lib/providers/post_provider.dart

import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/fake_data_service.dart';
import '../core/constants/current_user.dart';

class PostProvider extends ChangeNotifier {
  final FakeDataHelper db = FakeDataHelper.instance;

  List<PostModel> posts = [];

  bool isLoading = false;

  // ==========================
  // LOAD FEED (TẤT CẢ BÀI VIẾT)
  // ==========================
  Future<void> loadPosts() async {
    isLoading = true;
    notifyListeners();

    final data = await db.getAllPosts();

    posts = data
        .map(
          (e) => PostModel.fromMap(e),
        )
        .toList();

    isLoading = false;
    notifyListeners();
  }

  // ==========================
  // LOAD PROFILE POSTS
  // ==========================
  Future<List<PostModel>> getPostsByUser(
    int userId,
  ) async {
    final data = await db.getPostsByUserId(
      userId,
    );

    return data
        .map(
          (e) => PostModel.fromMap(e),
        )
        .toList();
  }

  // ==========================
  // LIKE POST
  // ==========================
  Future<void> likePost(
    PostModel post,
  ) async {
    final newLikes =
        post.likesCount + 1;

    await db.updatePostLikes(
      post.id!,
      newLikes,
    );

    await loadPosts();
  }

  // ==========================
  // CREATE POST
  // ==========================
  Future<void> createPost({
    required String imageUrl,
    required String caption,
  }) async {
    await db.insertPost(
      CurrentUser.id ?? 1,
      imageUrl,
      caption,
    );

    await loadPosts();
  }

  // ==========================
  // DELETE POST
  // ==========================
  Future<void> deletePost(
    int postId,
  ) async {
    await db.deletePost(
      postId,
    );

    await loadPosts();
  }
}