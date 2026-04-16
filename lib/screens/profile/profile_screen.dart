import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'edit_profile_screen.dart';
import 'follow_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../story/story_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- 1. KHAI BÁO BIẾN & TRẠNG THÁI ---
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  String currentSong = "we fell in love in october • girl in red";
  String currentUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // --- 2. CÁC HÀM XỬ LÝ LOGIC ---

  // Hàm phát/tạm dừng nhạc
  void _playMusic() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(currentUrl));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Hàm hiển thị Menu chọn nhạc (BottomSheet)
  void _showMusicMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              ListTile(
                title: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.white),
                title: const Text("Thay đổi bài hát trên trang cá nhân", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _changeSong();
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: const Text("Xem trang âm thanh", style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Gỡ bài hát trên trang cá nhân", style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    currentSong = "Thêm nhạc vào trang cá nhân";
                    isPlaying = false;
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

  // Hàm đổi nhạc
  void _changeSong() {
    setState(() {
      currentSong = "Summertime Sadness • Lana Del Rey";
      currentUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3";
      isPlaying = false;
    });
    _player.stop();
  }

  // --- 3. GIAO DIỆN CHÍNH (BUILD) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(context),
      ),
      body: SingleChildScrollView(
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
    );
  }

  // --- 4. CÁC WIDGET THÀNH PHẦN (Giữ nguyên giao diện của bạn) ---

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.lock_outline, size: 18, color: Colors.black),
        SizedBox(width: 8),
        Text('username', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black),
      ],
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.add_box_outlined, color: Colors.black), onPressed: () {}),
      IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        },
      ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const _StatItem(count: '54', label: 'Bài viết'),
                    _StatItem(count: '66', label: 'Người theo dõi', onTap: () => _goToFollow(context, 0)),
                    _StatItem(count: '116', label: 'Đang theo dõi', onTap: () => _goToFollow(context, 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Your Name', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Bio của bạn ở đây...'),
          const SizedBox(height: 8),
          
          // WIDGET NHẠC
          GestureDetector(
            onTap: _playMusic,
            onLongPress: _showMusicMenu, // Nhấn giữ để hiện menu đổi nhạc như Instagram
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isPlaying ? Icons.pause : Icons.music_note, size: 16, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(currentSong, style: const TextStyle(fontSize: 13, color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToFollow(BuildContext context, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InstagramFollowScreen(initialIndex: index)));
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Chỉnh sửa', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Chia sẻ', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildStoryHighlights() {
    final List<Map<String, String>> highlights = [
      {'title': 'Mới', 'isAdd': 'true'},
      {'title': 'Du lịch', 'img': 'https://picsum.photos/200?random=10'},
      {'title': 'Thú cưng', 'img': 'https://picsum.photos/200?random=11'},
      {'title': 'Đồ ăn', 'img': 'https://picsum.photos/200?random=12'},
      {'title': 'Học tập', 'img': 'https://picsum.photos/200?random=13'},
    ];
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: highlights.length,
        itemBuilder: (context, index) {
          final item = highlights[index];
          bool isAddButton = item['isAdd'] == 'true';
          return GestureDetector(
            onTap: () {
              if (!isAddButton) Navigator.push(context, MaterialPageRoute(builder: (context) => StoryViewScreen(initialUser: (index - 1) % 3)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: isAddButton ? Colors.white : Colors.grey[200],
                      backgroundImage: isAddButton ? null : NetworkImage(item['img']!),
                      child: isAddButton ? const Icon(Icons.add, color: Colors.black, size: 30) : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(item['title']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() => const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Icon(Icons.grid_on), Icon(Icons.video_collection_outlined), Icon(Icons.person_pin_outlined)]));

  Widget _buildGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, 
      crossAxisSpacing: 2, 
      mainAxisSpacing: 2
    ),
    itemCount: 12,
    itemBuilder: (context, index) {
      String url = 'https://picsum.photos/400?random=$index';
      return GestureDetector(
        onTap: () {
          // 🔥 LỆNH CHUYỂN SANG TRANG CHI TIẾT
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(imageUrl: url),
            ),
          );
        },
        child: Image.network(url, fit: BoxFit.cover),
      );
    },
  );
}
// --- GIỮ NGUYÊN CÁC CLASS PHỤ TRỢ BÊN DƯỚI ---

class InstagramFollowScreen extends StatelessWidget {
  final int initialIndex;
  const InstagramFollowScreen({super.key, this.initialIndex = 0});

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
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: Row(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.lock_outline, size: 18, color: Colors.black),
            SizedBox(width: 8),
            Text('username', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ]),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 1.5,
            tabs: [Tab(text: "66 Người theo dõi"), Tab(text: "116 Đang theo dõi")],
          ),
        ),
        body: const TabBarView(children: [FollowListContent(isFollowerTab: true), FollowListContent(isFollowerTab: false)]),
      ),
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final String imageUrl;
  const PostDetailScreen({super.key, required this.imageUrl});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Giả lập danh sách bài viết để cuộn
  final List<String> posts = List.generate(10, (index) => 'https://picsum.photos/500?random=${index + 100}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Bài viết', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Dùng ListView để có thể cuộn xuống các bài tiếp theo
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildPostItem(index == 0 ? widget.imageUrl : posts[index]);
        },
      ),
    );
  }

  List<String> userComments = ["Đẹp quá 😍", "10 điểm ❤️"];
final TextEditingController _commentController = TextEditingController();

void _showCommentSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      // Dùng StatefulBuilder để cập nhật danh sách ngay trong bảng BottomSheet
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text('Bình luận', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  
                  // 2. Hiển thị danh sách bình luận thật
                  Expanded(
                    child: ListView.builder(
                      itemCount: userComments.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const CircleAvatar(radius: 15, backgroundColor: Colors.grey),
                        title: Text('user_$index', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(userComments[index]), // Hiện nội dung từ danh sách
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5')),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _commentController, // Gắn controller vào đây
                            decoration: const InputDecoration(hintText: 'Thêm bình luận...', border: InputBorder.none),
                          ),
                        ),
                        
                        // 3. Xử lý khi bấm nút Đăng
                        TextButton(
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              setSheetState(() {
                                // Thêm nội dung vào danh sách
                                userComments.add(_commentController.text);
                                // Xóa chữ trong ô nhập sau khi đăng
                                _commentController.clear(); 
                              });
                              // Nếu muốn cập nhật cả màn hình ngoài thì dùng setState(() {});
                            }
                          },
                          child: const Text('Đăng', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
    },
  );
}

  // Widget vẽ từng bài viết
 // Widget vẽ từng bài viết
  Widget _buildPostItem(String imgUrl) {
    bool isLiked = false; 

    return StatefulBuilder( 
      builder: (context, setStatePost) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header bài viết
            ListTile(
              leading: const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5')),
              title: const Text('username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Some music', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.more_vert),
            ),
            
            // 2. Ảnh bài viết
            Image.network(imgUrl, width: double.infinity, fit: BoxFit.cover),

            // 3. Thanh tương tác (Tim, Bình luận, Chia sẻ)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setStatePost(() => isLiked = !isLiked),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  
                  GestureDetector(
                    onTap: _showCommentSheet, // Gọi hàm hiển thị bảng bình luận
                    child: const Icon(Icons.chat_bubble_outline, size: 26),
                  ),
                  
                  const SizedBox(width: 16),
                  const Icon(Icons.send_outlined, size: 26),
                  const Spacer(),
                  const Icon(Icons.bookmark_border, size: 28),
                ],
              ),
            ),

            // 4. Lượt thích & Caption
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('15 lượt thích', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'username ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'Đẹp quá!'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // 🔥 THÊM GestureDetector: Cho phép bấm vào dòng chữ này để hiện bình luận
                  GestureDetector(
                    onTap: _showCommentSheet,
                    child: const Text('Xem tất cả 2 bình luận', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const Divider(), 
          ],
        );
      },
    );
  }
}

class FollowListContent extends StatelessWidget {
  final bool isFollowerTab;
  const FollowListContent({super.key, required this.isFollowerTab});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 38,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            child: const TextField(decoration: InputDecoration(hintText: "Tìm kiếm", prefixIcon: Icon(Icons.search, color: Colors.grey), border: InputBorder.none)),
          ),
        ),
        if (isFollowerTab) ...[
          const Padding(padding: EdgeInsets.only(left: 16, bottom: 8), child: Text("Hạng mục", style: TextStyle(fontWeight: FontWeight.bold))),
          _buildCategoryItem("Người không theo dõi lại", "tiem_cua_tui và 27 người khác", Icons.group_remove_outlined),
          _buildCategoryItem("Ít tương tác nhất", "_hoafen_ và 8 người khác", Icons.unfold_less),
          const Divider(),
        ],
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 15,
          itemBuilder: (context, index) => ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.grey),
            title: Text("user_insta_$index", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("Tên người dùng $index", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: _buildListTrailing(isFollowerTab, index),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String sub, IconData icon) => ListTile(
    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)), child: Icon(icon, color: Colors.black, size: 20)),
    title: Text(title, style: const TextStyle(fontSize: 14)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
  );

  Widget _buildListTrailing(bool isFollowerTab, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: (isFollowerTab && index % 3 == 0) ? Colors.blue : Colors.grey[200],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text((isFollowerTab && index % 3 == 0) ? "Theo dõi lại" : "Nhắn tin", 
            style: TextStyle(color: (isFollowerTab && index % 3 == 0) ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Icon(isFollowerTab ? Icons.close : Icons.more_vert, color: Colors.grey, size: 20),
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
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}