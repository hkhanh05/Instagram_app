import 'dart:io';
import '../../services/fake_data_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_profile_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../story/story_view_screen.dart';
import '../../core/utils/helpers.dart';
import '../story/hightlight_view_screen.dart';
import '../post/camera_screen.dart';
import '../profile/follow_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/follow_service.dart';
import '../../core/constants/current_user.dart';

bool _isAssetImagePath(String path) => path.startsWith('assets/');
bool _isNetworkImagePath(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

ImageProvider _imageProviderFromPath(String path) {
  if (_isAssetImagePath(path)) {
    return AssetImage(path);
  }
  if (_isNetworkImagePath(path)) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}

Widget _postImageFromPath(String path,
    {BoxFit fit = BoxFit.cover, double? height}) {
  if (path.isEmpty) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }

  if (_isAssetImagePath(path)) {
    return Image.asset(path, width: double.infinity, height: height, fit: fit);
  }
  if (_isNetworkImagePath(path)) {
    return Image.network(path,
        width: double.infinity, height: height, fit: fit);
  }
  return Image.file(File(path),
      width: double.infinity, height: height, fit: fit);
}

class ProfileScreen extends StatefulWidget {
  final int currentUserId;
  final String? firebaseUid;

  const ProfileScreen({super.key, this.currentUserId = 1, this.firebaseUid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _highlights = [];
  List<Map<String, dynamic>> followersFromFirebase = [];
List<Map<String, dynamic>> followingFromFirebase = [];
  bool _isLoading = true;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // 🔥 ĐÃ SỬA TRIỆT ĐỂ: Chỉ giữ lại 1 hàm duy nhất, ưu tiên dữ liệu từ Firebase trước
 Future<void> _loadProfileData() async {
  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  try {
    Map<String, dynamic>? userMap;

    final currentUser = FirebaseAuth.instance.currentUser;

    final profileUid =
    widget.firebaseUid ??
    FirebaseAuth.instance.currentUser?.uid;

if (profileUid != null) {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(profileUid)
      .get();

      if (doc.exists) {
        userMap = doc.data();

        userMap?['username'] =
            userMap?['username'] ?? 'instagram_user';

        userMap?['fullName'] =
            userMap?['fullName'] ??
            userMap?['name'] ??
            'Thành viên mới';

        userMap?['bio'] =
            userMap?['bio'] ??
            'Chào mừng đến với Instagram clone! 🚀';

        userMap?['followersCount'] =
            userMap?['followersCount'] ?? 0;

        userMap?['followingCount'] =
            userMap?['followingCount'] ?? 0;

        userMap?['avatarUrl'] =
            userMap?['avatarUrl'] ?? '';
      }
    }

    // Nếu Firebase chưa có thì lấy SQLite
    if (userMap == null) {
      userMap = await FakeDataHelper.instance.getUserById(
        CurrentUser.id ?? widget.currentUserId,
      );
    }

    final posts = await FakeDataHelper.instance.getPostsByUserId(
      CurrentUser.id ?? widget.currentUserId,
    );

    final highlightsData =
        await FakeDataHelper.instance.getHighlights(
      CurrentUser.id ?? widget.currentUserId,
    );

    if (mounted) {
      setState(() {
        _userData = userMap;
        _userPosts = posts;
        _highlights = highlightsData;
        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('❌ Lỗi load dữ liệu: $e');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  // Cầu nối đồng bộ để lệnh Kéo để Refresh (onRefresh) không bị lỗi biên dịch

  Future<void> _loadSqliteData() async {
  await _loadProfileData();
}

  void _showInstagramShareSheet(BuildContext context) {
    int followers = _userData?['followersCount'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10))),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text('Chia sẻ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10)),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm...",
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: followers == 0
                      ? const Center(
                          child: Text("Không có người theo dõi nào để chia sẻ",
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: followers,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    _userData?['avatarUrl'] != null &&
                                            _userData!['avatarUrl']
                                                .toString()
                                                .isNotEmpty
                                        ? NetworkImage(_userData!['avatarUrl'])
                                        : null,
                                child: _userData?['avatarUrl'] == null ||
                                        _userData!['avatarUrl']
                                            .toString()
                                            .isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.grey)
                                    : null,
                              ),
                              title: Text("friend_insta_$index",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              subtitle: Text("Người theo dõi thứ $index",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              trailing: SizedBox(
                                height: 32,
                                width: 80,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Đã gửi trang cá nhân đến friend_insta_$index thành công!"),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Gửi",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteHighlight(int highlightId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa tin nổi bật?"),
        content: Text(
            "Bạn có chắc chắn muốn xóa '$title' khỏi trang cá nhân không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.black))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FakeDataHelper.instance.deleteHighlight(highlightId);
              _loadSqliteData();
            },
            child: const Text("Xóa",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: _buildAppBarTitle(),
          actions: _buildAppBarActions(context)),
      body: RefreshIndicator(
        onRefresh: _loadSqliteData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              _buildButtons(context),
              _buildStoryHighlights(),
              const Divider(),
              _buildTabs(),
              _buildGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    // 🔥 ĐÃ SỬA: Đọc chuẩn dữ liệu từ map Firebase/SQLite tránh lỗi trống tiêu đề
    String titleText = _userData?['username']?.toString() ?? 'instagram_user';
    if (titleText.isEmpty) titleText = 'instagram_user';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline, size: 18, color: Colors.black),
        const SizedBox(width: 8),
        Text(titleText,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black),
      ],
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
  icon: const Icon(Icons.add_box_outlined, color: Colors.black),
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraScreen(),
      ),
    );

    if (result == true) {
      await _loadSqliteData();
    }
  },
),
      IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()))),
    ];
  }

Future<void> _showCreateHighlightSheet() async {
  final XFile? pickedImage = await _imagePicker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );

  if (pickedImage == null || !mounted) return;

  final titleController = TextEditingController();
  final selectedImagePath = pickedImage.path;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (sheetContext) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tạo tin nổi bật',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _postImageFromPath(selectedImagePath),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Tên highlight',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final title =
                          titleController.text.trim();

                      await FakeDataHelper.instance.insertHighlight(
                        CurrentUser.id ?? widget.currentUserId,
                        title.isEmpty ? 'Mới' : title,
                        selectedImagePath,
                      );

                      if (!mounted) return;

                      Navigator.pop(sheetContext);

                      Future.delayed(
                        const Duration(milliseconds: 300),
                        () {
                          if (mounted) {
                            _loadProfileData();
                          }
                        },
                      );
                    } catch (e) {
                      debugPrint(
                        'Lỗi lưu highlight: $e',
                      );
                    }
                  },
                  child: const Text('Lưu highlight'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

}

  Widget _buildHeader(BuildContext context) {
    int followers = _userData?['followersCount'] ?? 0;
    int following = _userData?['followingCount'] ?? 0;
    String avatar = _userData?['avatarUrl'] ?? '';

    // 🔥 ĐÃ SỬA: Ép giá trị hiển thị Tên đầy đủ từ Firebase
    String displayName = _userData?['fullName']?.toString() ?? 'Thành viên mới';
    if (displayName.isEmpty) displayName = 'Thành viên mới';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    avatar.isNotEmpty ? NetworkImage(avatar) : null,
                child: avatar.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(count: '${_userPosts.length}', label: 'Bài viết'),
                    _StatItem(
                        count: '$followers',
                        label: 'Người theo dõi',
                        onTap: () =>
                            _goToFollow(context, 0, followers, following)),
                    _StatItem(
                        count: '$following',
                        label: 'Đang theo dõi',
                        onTap: () =>
                            _goToFollow(context, 1, followers, following)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(displayName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(_userData?['bio'] ?? 'Chào mừng đến với Instagram clone! 🚀'),
          const SizedBox(height: 8),
          
        ],
      ),
    );
  }

  void _goToFollow(
    BuildContext context,
    int index,
    int followers,
    int following,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => InstagramFollowScreen(
        initialIndex: index,
        username: _userData?['username'] ?? 'instagram_user',
        followersList: followersFromFirebase,
        followingList: followingFromFirebase,
      ),
    ),
  );
}
  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
              child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                                currentUserId:
                                    CurrentUser.id ?? widget.currentUserId,
                              )));
              if (result == true) {
                _loadSqliteData();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Chỉnh sửa',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )),
          const SizedBox(width: 10),
          Expanded(
              child: OutlinedButton(
            onPressed: () => _showInstagramShareSheet(context),
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Chia sẻ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildStoryHighlights() {
    final visibleHighlights = [
      {'isAdd': 'true', 'title': 'Mới', 'imageUrl': '', 'id': 0},
      ..._highlights.where((item) => item['isAdd'] != 'true'),
    ];

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: visibleHighlights.length,
        itemBuilder: (context, index) {
          final item = visibleHighlights[index];
          bool isAddButton = item['isAdd'] == 'true';
          String highlightImg = item['imageUrl']?.toString() ?? '';
          int highlightId = item['id'] ?? 0;
          String title = item['title'] ?? '';

          return GestureDetector(
            onTap: () {
              if (isAddButton) {
                _showCreateHighlightSheet();
              } else {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HighlightViewerScreen(
        imagePath: highlightImg,
        title: title,
      ),
    ),
  );
}
            },
            onLongPress: () {
              if (!isAddButton && highlightId != 0) {
                _confirmDeleteHighlight(highlightId, title);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300)),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          isAddButton ? Colors.white : Colors.grey[200],
                      backgroundImage: (!isAddButton && highlightImg.isNotEmpty)
                          ? _imageProviderFromPath(highlightImg)
                          : null,
                      child: isAddButton
                          ? const Icon(Icons.add, color: Colors.black, size: 30)
                          : (highlightImg.isEmpty
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Icon(Icons.grid_on),
        Icon(Icons.video_collection_outlined),
        Icon(Icons.person_pin_outlined)
      ]));

  Widget _buildGrid() {
    if (_userPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child:
            Text("Chưa có bài viết nào", style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        String url = post['imageUrl'] ?? '';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                  allPosts: _userPosts,
                  initialIndex: index,
                  username: _userData?['username'] ?? 'instagram_user',
                  avatarUrl: _userData?['avatarUrl'] ?? '',
                  onPostDeleted: _loadSqliteData,
                ),
              ),
            );
          },
          child: url.isNotEmpty
              ? _postImageFromPath(url)
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey)),
        );
      },
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  final int initialIndex;
  final String username;
  final String avatarUrl;
  final VoidCallback? onPostDeleted;

  const PostDetailScreen({
    super.key,
    required this.allPosts,
    required this.initialIndex,
    required this.username,
    required this.avatarUrl,
    this.onPostDeleted,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  List<Map<String, dynamic>> _currentPosts = [];
  Map<int, int> _likesMap = {};
  Map<int, List<Map<String, dynamic>>> _commentsMap = {};
  Map<int, bool> _isLikedByUser = {};

  @override
  void initState() {
    super.initState();
    _currentPosts = List.from(widget.allPosts);
    _initData();
  }

  void _initData() {
    for (int i = 0; i < _currentPosts.length; i++) {
      int postId = _currentPosts[i]['id'];
      _likesMap[postId] = _currentPosts[i]['likesCount'] ?? 0;
      _loadComments(postId);
    }
  }

  Future<void> _loadComments(int postId) async {
    final comments = await FakeDataHelper.instance.getCommentsByPostId(postId);
    if (mounted) {
      setState(() {
        _commentsMap[postId] = comments;
      });
    }
  }

  void _showPostOptions(int postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Xóa bài viết',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePost(postId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('Lưu bài viết'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeletePost(int postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa bài viết?"),
        content:
            const Text("Bài viết này sẽ bị xóa vĩnh viễn khỏi SQLite của bạn."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.black))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FakeDataHelper.instance.deletePost(postId);
              setState(() {
                _currentPosts.removeWhere((post) => post['id'] == postId);
              });
              if (widget.onPostDeleted != null) {
                widget.onPostDeleted!();
              }
              if (_currentPosts.isEmpty && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Xóa",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCommentSheet(int postId) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text('Bình luận',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: (_commentsMap[postId] ?? []).isEmpty
                      ? const Center(
                          child: Text("Chưa có bình luận nào.",
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: (_commentsMap[postId] ?? []).length,
                          itemBuilder: (context, index) {
                            final comment = _commentsMap[postId]![index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 15,
                                backgroundImage: widget.avatarUrl.isNotEmpty
                                    ? NetworkImage(widget.avatarUrl)
                                    : null,
                                child: widget.avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 15)
                                    : null,
                              ),
                              title: Text(comment['username'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              subtitle: Text(comment['content'] ?? ''),
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: widget.avatarUrl.isNotEmpty
                            ? NetworkImage(widget.avatarUrl)
                            : null,
                        child: widget.avatarUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                              hintText: 'Thêm bình luận...',
                              border: InputBorder.none),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (commentController.text.isNotEmpty) {
                            await FakeDataHelper.instance.insertComment(postId,
                                widget.username, commentController.text);
                            commentController.clear();
                            await _loadComments(postId);
                            setState(() {});
                            Navigator.pop(context);
                            _showCommentSheet(postId);
                          }
                        },
                        child: const Text('Đăng',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Bài viết',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _currentPosts.isEmpty
          ? const Center(
              child: Text("Không có bài viết nào",
                  style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: _currentPosts.length,
              itemBuilder: (context, index) {
                int actualIndex =
                    (index + widget.initialIndex) % _currentPosts.length;
                return _buildPostItem(_currentPosts[actualIndex]);
              },
            ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> postData) {
    int postId = postData['id'];
    int currentLikes = _likesMap[postId] ?? 0;
    bool isLiked = _isLikedByUser[postId] ?? false;
    int commentLength = _commentsMap[postId]?.length ?? 0;
    String postImg = postData['imageUrl'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundImage: widget.avatarUrl.isNotEmpty
                ? NetworkImage(widget.avatarUrl)
                : null,
            child: widget.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(widget.username,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showPostOptions(postId),
          ),
        ),
        _postImageFromPath(postImg, height: 300),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isLiked = !isLiked;
                    _isLikedByUser[postId] = isLiked;
                    _likesMap[postId] =
                        isLiked ? currentLikes + 1 : currentLikes - 1;
                  });
                  await FakeDataHelper.instance
                      .updatePostLikes(postId, _likesMap[postId]!);
                },
                child: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black, size: 28),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showCommentSheet(postId),
                child: const Icon(Icons.chat_bubble_outline, size: 26),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.send_outlined, size: 26),
              const Spacer(),
              const Icon(Icons.bookmark_border, size: 28),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$currentLikes lượt thích',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: '${widget.username} ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: postData['caption'] ?? ''),
              ])),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _showCommentSheet(postId),
                child: Text('Xem tất cả $commentLength bình luận',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback? onTap;
  const _StatItem({required this.count, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Text(count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
