import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'follow_screen.dart';
import '../settings/settings_screen.dart';
import '../story/story_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? firebaseUid;

  // 🔥 ĐÃ SỬA: Bỏ currentUserId của SQLite, chỉ giữ lại firebaseUid
  const ProfileScreen({super.key, this.firebaseUid});

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
  final List<Map<String, dynamic>> _highlights =
      []; // Tạm thời để trống hoặc nạp từ Firestore sau
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // 🔥 ĐÃ SỬA: Chạy thuần 100% bằng Firebase Firestore
  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (widget.firebaseUid != null && widget.firebaseUid!.isNotEmpty) {
        // 1. Tải thông tin User hồ sơ từ Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.firebaseUid)
            .get();

        if (doc.exists) {
          _userData = doc.data();
          _userData?['username'] = _userData?['username'] ?? 'instagram_user';
          _userData?['fullName'] =
              _userData?['name'] ?? _userData?['fullName'] ?? 'Thành viên mới';
          _userData?['bio'] =
              _userData?['bio'] ?? 'Chào mừng đến với Instagram clone! 🚀';
          _userData?['followersCount'] = _userData?['followersCount'] ?? 0;
          _userData?['followingCount'] = _userData?['followingCount'] ?? 0;
          _userData?['avatarUrl'] = _userData?['avatarUrl'] ?? '';

          currentSong =
              _userData?['currentSong'] ?? "Thêm nhạc vào trang cá nhân";
          currentUrl = _userData?['musicUrl'] ?? "";
        }

        // 2. Tải danh sách bài viết trực tuyến lọc theo uid từ Firestore
        final postsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.firebaseUid)
            .get();

        _userPosts = postsSnapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Lỗi load dữ liệu Firebase: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async => await _loadProfileData();

  @override
  void dispose() {
    _player.stop();
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
                title: const Text("Thay đổi bài hát",
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Gỡ bài hát",
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
                              trailing: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, elevation: 0),
                                child: const Text("Gửi",
                                    style: TextStyle(color: Colors.white)),
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
        onRefresh: _onRefresh,
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
    String titleText = _userData?['username']?.toString() ?? 'instagram_user';
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
          onPressed: () {
            // To-Do: Viết hàm tạo Post đẩy thẳng lên Firestore sau này tại đây
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
    String displayName = _userData?['fullName']?.toString() ?? 'Thành viên mới';

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
    List<Map<String, dynamic>> mockFollowersList = List.generate(
        followers,
        (i) => {
              'id': i,
              'username': 'follower_fb_$i',
              'fullName': 'Người theo dõi $i',
              'avatarUrl': '',
              'isFollowing': 0
            });
    List<Map<String, dynamic>> mockFollowingList = List.generate(
        following,
        (i) => {
              'id': i,
              'username': 'following_fb_$i',
              'fullName': 'Đang theo dõi $i',
              'avatarUrl': ''
            });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InstagramFollowScreen(
                initialIndex: index,
                username: _userData?['username'] ?? 'instagram_user',
                followersList: mockFollowersList,
                followingList: mockFollowingList)));
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
                      builder: (context) =>
                          EditProfileScreen(firebaseUid: widget.firebaseUid)));
              if (result == true) {
                _loadProfileData();
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              CircleAvatar(radius: 30, backgroundColor: Colors.grey[200]),
              Text(item['title'] ?? '')
            ]),
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
    if (_userPosts.isEmpty)
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
              child: Text("Chưa có bài viết nào",
                  style: TextStyle(color: Colors.grey))));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        String url = post['imageUrl'] ?? '';
        return url.isNotEmpty
            ? Image.network(url, fit: BoxFit.cover)
            : Container(
                color: Colors.grey[300],
                child:
                    const Icon(Icons.image_not_supported, color: Colors.grey));
      },
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
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 12))
        ]));
  }
}
