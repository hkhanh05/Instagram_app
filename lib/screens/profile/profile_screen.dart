import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'follow_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

// --- MÀN HÌNH PROFILE CHÍNH ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock_outline, size: 18, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'username', 
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // 🔥 LỆNH CHUYỂN SANG TRANG CÀI ĐẶT
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
            },
          ),
        ],
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
                    _StatItem(
                      count: '66',
                      label: 'Người theo dõi',
                      onTap: () {
                        // Mở tab Followers (index 0)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InstagramFollowScreen(initialIndex: 0)),
                        );
                      },
                    ),
                    _StatItem(
                      count: '116',
                      label: 'Đang theo dõi',
                      onTap: () {
                        // Mở tab Following (index 1)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InstagramFollowScreen(initialIndex: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Your Name', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Bio của bạn ở đây...'),
        ],
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
              onPressed: () {
                // 🔥 ĐÂY LÀ LỆNH CHUYỂN TRANG
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,    
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Chỉnh sửa', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Chia sẻ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryHighlights() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            CircleAvatar(radius: 30, backgroundColor: Colors.grey[200], child: const Icon(Icons.add, color: Colors.black)),
            Text('Story $index', style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTabs() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Icon(Icons.grid_on), Icon(Icons.video_collection_outlined), Icon(Icons.person_pin_outlined)]),
      );

  Widget _buildGrid() => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
        itemCount: 12,
        itemBuilder: (context, index) => Image.network('https://picsum.photos/200?random=$index', fit: BoxFit.cover),
      );
}

// --- MÀN HÌNH FOLLOW (TAB VIEW) ---
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
            Text('username',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
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
        body: const TabBarView(
          children: [
            FollowListContent(isFollowerTab: true),
            FollowListContent(isFollowerTab: false),
          ],
        ),
      ),
    );
  }
}

// --- NỘI DUNG DANH SÁCH (DÙNG CHUNG CHO CẢ 2 TAB) ---
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
          _buildItem("Người không theo dõi lại", "tiem_cua_tui và 27 người khác", Icons.group_remove_outlined),
          _buildItem("Ít tương tác nhất", "_hoafen_ và 8 người khác", Icons.unfold_less),
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
            trailing: Row(
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String title, String sub, IconData icon) => ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)), child: Icon(icon, color: Colors.black, size: 20)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      );
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