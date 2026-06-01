import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../profile/profile_screen.dart';

/// Model cho bài đăng
class PostModel {
  final String id;
  final String imageUrl;
  final String userId;
  final String caption;
  final List<String> hashtags;

  PostModel({
    required this.id,
    required this.imageUrl,
    required this.userId,
    required this.caption,
    required this.hashtags,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      caption: data['caption'] ?? '',
      hashtags: List<String>.from(data['hashtags'] ?? []),
    );
  }
}

/// Model cho người dùng
class UserModel {
  final String uid;
  final String username;
  final String avatarUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.avatarUrl,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Debounce timer để tránh gọi Firestore liên tục khi gõ
  Timer? _debounce;

  String _query = '';
  bool _isLoading = false;

  // Kết quả tìm kiếm
  List<UserModel> _userResults = [];
  List<PostModel> _postResults = [];

  // Tab controller cho User / Post
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDefaultPosts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── Load ảnh mặc định (trước khi tìm kiếm) ───────────────────────────────
  Future<void> _loadDefaultPosts() async {
    setState(() => _isLoading = true);
    try {
      final snap = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      setState(() {
        _postResults = snap.docs.map(PostModel.fromDoc).toList();
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Xử lý khi người dùng gõ ──────────────────────────────────────────────
void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final q = value.trim();
      setState(() => _query = q);
      if (q.isEmpty) {
        _loadDefaultPosts();
      } else {
        _performSearch(q);
      }
    });
  }

  // ─── Tìm kiếm đồng thời users và posts ────────────────────────────────────
  Future<void> _performSearch(String q) async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _searchUsers(q),
        _searchPosts(q),
      ]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tìm user theo username (prefix search)
  /// Firestore trick: dùng >= query và <= query\uf8ff
  Future<void> _searchUsers(String q) async {
    final lower = q.toLowerCase();
    final snap = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: lower)
        .where('username', isLessThanOrEqualTo: '$lower\uf8ff')
        .limit(20)
        .get();

    setState(() {
      _userResults = snap.docs.map(UserModel.fromDoc).toList();
    });
  }

  /// Tìm post theo caption hoặc hashtags
  Future<void> _searchPosts(String q) async {
    final lower = q.toLowerCase();

    // Tìm theo caption (prefix search)
    final captionSnap = await _firestore
        .collection('posts')
        .where('caption', isGreaterThanOrEqualTo: lower)
        .where('caption', isLessThanOrEqualTo: '$lower\uf8ff')
        .limit(20)
        .get();

    // Tìm theo hashtag (array-contains)
    final hashtagSnap = await _firestore
        .collection('posts')
        .where('hashtags', arrayContains: lower)
        .limit(20)
        .get();

    // Gộp và loại trùng theo id
    final combined = <String, PostModel>{};
    for (final doc in captionSnap.docs) {
      final post = PostModel.fromDoc(doc);
      combined[post.id] = post;
    }
    for (final doc in hashtagSnap.docs) {
      final post = PostModel.fromDoc(doc);
      combined[post.id] = post;
    }

    setState(() {
      _postResults = combined.values.toList();
    });
  }

  // ─── Build UI ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _query.isEmpty ? _buildDefaultGrid() : _buildSearchResults(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
onChanged: _onSearchChanged,
          autofocus: false,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm người dùng, #hashtag...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
            suffixIcon: _query.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: Icon(Icons.close, color: Colors.grey[400], size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          ),
        ),
      ),
      bottom: _query.isNotEmpty
          ? TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(
                  text: 'Người dùng'
                      '${_userResults.isNotEmpty ? ' (${_userResults.length})' : ''}',
                ),
                Tab(
                  text: 'Bài đăng'
                      '${_postResults.isNotEmpty ? ' (${_postResults.length})' : ''}',
                ),
              ],
            )
          : null,
    );
  }

  // Grid ảnh mặc định (khi chưa tìm kiếm)
  Widget _buildDefaultGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_postResults.isEmpty) {
      return const Center(
        child: Text('Chưa có bài đăng nào', style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _postResults.length,
      itemBuilder: (_, i) => _buildPostTile(_postResults[i]),
    );
  }

  // Kết quả tìm kiếm chia 2 tab
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUserList(),
        _buildPostGrid(),
      ],
    );
  }

  // Danh sách người dùng
  Widget _buildUserList() {
    if (_userResults.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _userResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (_, i) {
        final user = _userResults[i];
return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? const Icon(Icons.person, size: 24)
                : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            user.uid,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfileScreen(
        firebaseUid: user.uid,
      ),
    ),
  );
},
        );
      },
    );
  }

  // Grid ảnh từ posts
  Widget _buildPostGrid() {
    if (_postResults.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy bài đăng', style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _postResults.length,
      itemBuilder: (_, i) => _buildPostTile(_postResults[i]),
    );
  }

  Widget _buildPostTile(PostModel post) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to post detail
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => PostDetailScreen(postId: post.id),
        // ));
      },
      child: post.imageUrl.isNotEmpty
          ? Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          : Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
    );
  }
}