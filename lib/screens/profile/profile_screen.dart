import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../story/story_view_screen.dart';
import '../../services/fake_data_service.dart';

class ProfileScreen extends StatefulWidget {
  final int currentUserId;
  // 🔥 ĐÃ SỬA: Thêm biến nhận Firebase UID từ MainScreen chuyển xuống
  final String? firebaseUid;

  const ProfileScreen({super.key, this.currentUserId = 1, this.firebaseUid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  String currentSong = "Thêm nhạc vào trang cá nhân";
  String currentUrl = "";

  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _highlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Đổi tên hàm cho đúng bản chất
  }

  // 🔥 ĐÃ SỬA: Hàm tải dữ liệu kết hợp linh hoạt Firebase và SQLite
  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic>? userMap;

      // 1. KIỂM TRA: Nếu có dữ liệu từ Firebase Auth truyền qua
      if (widget.firebaseUid != null && widget.firebaseUid!.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.firebaseUid)
            .get();

        if (doc.exists) {
          userMap = doc.data();
          // Đồng bộ một số trường dữ liệu cho khớp với UI cũ của bạn
          userMap?['username'] = userMap['username'] ?? 'instagram_user';
          userMap?['fullName'] = userMap['name'] ?? 'Thành viên mới';
          userMap?['bio'] =
              userMap['bio'] ?? 'Chào mừng đến với Instagram clone! 🚀';
        }
      }

      // 2. BACKUP LUỒNG CŨ: Nếu không chạy Firebase (hoặc lỗi), quay về đọc SQLite cũ
      if (userMap == null) {
        userMap =
            await DatabaseHelper.instance.getUserById(widget.currentUserId);
      }

      // Tải dữ liệu các bài đăng và tin nổi bật từ SQLite local dưới máy
      final posts =
          await DatabaseHelper.instance.getPostsByUserId(widget.currentUserId);
      final highlightsData =
          await DatabaseHelper.instance.getHighlights(widget.currentUserId);

      if (mounted) {
        setState(() {
          _userData = userMap;
          _userPosts = posts;
          _highlights = highlightsData;

          currentSong =
              userMap?['currentSong'] ?? "Thêm nhạc vào trang cá nhân";
          currentUrl = userMap?['musicUrl'] ?? "";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Lỗi load dữ liệu kết hợp: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Backwards-compatible wrapper: nhiều chỗ trong code cũ gọi `_loadSqliteData()`
  // nên giữ một wrapper để tránh lỗi tên không tìm thấy.
  Future<void> _loadSqliteData() async => await _loadProfileData();

  // Giữ nguyên các hàm bổ trợ khác ở phía bên dưới như _showMusicMenu, _buildGrid()...
  // Chỉ cần tìm chỗ nào gọi `_loadSqliteData()` thì đổi tên thành `_loadProfileData()` là được!
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
              await DatabaseHelper.instance.deleteHighlight(highlightId);
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
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _playMusic() async {
    if (currentUrl.isEmpty) return;
    try {
      if (isPlaying) {
        await _player.pause();
      } else {
        await _player.play(UrlSource(currentUrl));
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    } catch (e) {
      print("❌ Lỗi phát nhạc: $e");
    }
  }

  void _showMusicMenu() {
    if (currentUrl.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Theme(
                data: ThemeData(
                    iconTheme: const IconThemeData(color: Colors.white)),
                child: ListTile(
                    title: Text(currentSong,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.white),
                title: const Text("Thay đổi bài hát trên trang cá nhân",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _changeSong();
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: const Text("Xem trang âm thanh",
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Gỡ bài hát trên trang cá nhân",
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    currentSong = "Thêm nhạc vào trang cá nhân";
                    isPlaying = false;
                    currentUrl = "";
                  });
                  _player.stop();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeSong() {
    setState(() {
      currentSong = "Bài hát đã thay đổi";
      currentUrl = "";
      isPlaying = false;
    });
    _player.stop();
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
                                backgroundImage: _userData?['avatarUrl'] != null
                                    ? NetworkImage(_userData!['avatarUrl'])
                                    : null,
                                child: _userData?['avatarUrl'] == null
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline, size: 18, color: Colors.black),
        const SizedBox(width: 8),
        Text(_userData?['username'] ?? '',
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
            String currentAvatar = _userData?['avatarUrl'] ?? '';
            await DatabaseHelper.instance.insertPost(widget.currentUserId,
                currentAvatar, 'Bài viết mới cập nhật tự động từ SQLite! 🚀');
            _loadSqliteData();
          }),
      IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()))),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    int followers = _userData?['followersCount'] ?? 0;
    int following = _userData?['followingCount'] ?? 0;
    String avatar = _userData?['avatarUrl'] ?? '';

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
          Text(_userData?['fullName'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(_userData?['bio'] ?? ''),
          const SizedBox(height: 8),
          if (currentUrl.isNotEmpty)
            GestureDetector(
              onTap: _playMusic,
              onLongPress: _showMusicMenu,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isPlaying ? Icons.pause : Icons.music_note,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(currentSong,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.black)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _goToFollow(
      BuildContext context, int index, int followers, int following) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InstagramFollowScreen(
                  initialIndex: index,
                  username: _userData?['username'] ?? '',
                  followersCount: followers,
                  followingCount: following,
                )));
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
                          currentUserId: widget.currentUserId)));
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
    if (_highlights.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _highlights.length,
        itemBuilder: (context, index) {
          final item = _highlights[index];
          bool isAddButton = item['isAdd'] == 'true';
          String highlightImg = item['imageUrl']?.toString() ?? '';
          int highlightId = item['id'] ?? 0;
          String title = item['title'] ?? '';

          return GestureDetector(
            onTap: () {
              if (!isAddButton)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            StoryViewScreen(initialUser: (index - 1) % 3)));
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
                          ? NetworkImage(highlightImg)
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
          // 🔥 ĐÃ CHỈNH SỬA CHUẨN: Đưa Navigator mở PostDetailScreen vào đúng vị trí sự kiện click của ô lưới ảnh
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                  allPosts: _userPosts,
                  initialIndex: index,
                  username: _userData?['username'] ?? '',
                  avatarUrl: _userData?['avatarUrl'] ?? '',
                  onPostDeleted:
                      _loadSqliteData, // Khi xóa bài viết bên trong, tự động load lại danh sách trang chính
                ),
              ),
            );
          },
          child: url.isNotEmpty
              ? Image.network(url, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey)),
        );
      },
    );
  }
}

class InstagramFollowScreen extends StatelessWidget {
  final int initialIndex;
  final String username;
  final int followersCount;
  final int followingCount;

  const InstagramFollowScreen(
      {super.key,
      this.initialIndex = 0,
      required this.username,
      required this.followersCount,
      required this.followingCount});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context)),
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, size: 18, color: Colors.black),
            const SizedBox(width: 8),
            Text(username,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ]),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 1.5,
            tabs: [
              Tab(text: "$followersCount Người theo dõi"),
              Tab(text: "$followingCount Đang theo dõi"),
            ],
          ),
        ),
        body: TabBarView(children: [
          FollowListContent(
              isFollowerTab: true,
              maxItems: followersCount,
              currentUsername: username),
          FollowListContent(
              isFollowerTab: false,
              maxItems: followingCount,
              currentUsername: username)
        ]),
      ),
    );
  }
}

// =========================================================================
// MÀN HÌNH CHI TIẾT BÀI VIẾT (Đã bọc logic mở BottomSheet tùy chọn Xóa khi bấm 3 chấm)
// =========================================================================
// =========================================================================
// MÀN HÌNH CHI TIẾT BÀI VIẾT (ĐÃ SỬA TRIỆT ĐỂ LỖI LATE INITIALIZATION)
// =========================================================================
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
  // 🔥 ĐÃ SỬA: Loại bỏ từ khóa 'late' nguy hiểm, khởi tạo trực tiếp danh sách rỗng để chống crash tuyệt đối
  List<Map<String, dynamic>> _currentPosts = [];
  Map<int, int> _likesMap = {};
  Map<int, List<Map<String, dynamic>>> _commentsMap = {};
  Map<int, bool> _isLikedByUser = {};

  @override
  void initState() {
    super.initState();
    // Khởi tạo bản sao dữ liệu bài viết ngay khi màn hình vừa được nạp
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
    final comments = await DatabaseHelper.instance.getCommentsByPostId(postId);
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
              await DatabaseHelper.instance.deletePost(postId);
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
                            await DatabaseHelper.instance.insertComment(postId,
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
          subtitle: const Text('Âm thanh gốc', style: TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showPostOptions(postId),
          ),
        ),
        postImg.isNotEmpty
            ? Image.network(postImg, width: double.infinity, fit: BoxFit.cover)
            : Container(
                height: 300,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image,
                    size: 50, color: Colors.grey)),
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
                  await DatabaseHelper.instance
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

class FollowListContent extends StatefulWidget {
  final bool isFollowerTab;
  final int maxItems;
  final String currentUsername;

  const FollowListContent(
      {super.key,
      required this.isFollowerTab,
      required this.maxItems,
      required this.currentUsername});

  @override
  State<FollowListContent> createState() => _FollowListContentState();
}

class _FollowListContentState extends State<FollowListContent> {
  final Map<int, bool> _followingMap = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)),
            child: const TextField(
                decoration: InputDecoration(
                    hintText: "Tìm kiếm",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none)),
          ),
        ),
        if (widget.isFollowerTab && widget.maxItems > 0) ...[
          const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text("Hạng mục",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          _buildCategoryItem(
              "Người không theo dõi lại",
              "Các tài khoản liên quan đến ${widget.currentUsername}",
              Icons.group_remove_outlined),
          _buildCategoryItem("Ít tương tác nhất",
              "Danh sách phân tích tương tác", Icons.unfold_less),
          const Divider(),
        ],
        widget.maxItems == 0
            ? const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                    child: Text("Danh sách trống",
                        style: TextStyle(color: Colors.grey))),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.maxItems,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.white)),
                  title: Text("user_insta_$index",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("Tên người dùng $index",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: _buildListTrailing(widget.isFollowerTab, index),
                ),
              ),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String sub, IconData icon) =>
      ListTile(
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300)),
            child: Icon(icon, color: Colors.black, size: 20)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      );

  Widget _buildListTrailing(bool isFollowerTab, int index) {
    bool isFollowedBack =
        _followingMap[index] ?? (isFollowerTab && index % 3 == 0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: () =>
                setState(() => _followingMap[index] = !isFollowedBack),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFollowedBack ? Colors.blue : Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text(isFollowedBack ? "Theo dõi lại" : "Nhắn tin",
                style: TextStyle(
                    color: isFollowedBack ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Icon(isFollowerTab ? Icons.close : Icons.more_vert,
            color: Colors.grey, size: 20),
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
