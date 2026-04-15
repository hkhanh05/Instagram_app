// Following
import 'package:flutter/material.dart';

class InstagramFollowScreen extends StatelessWidget {
  const InstagramFollowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tab: Người theo dõi & Đang theo dõi
      initialIndex: 1, // Mặc định mở tab "Đang theo dõi" giống hình 1
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {},
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lock_outline, size: 18, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'username',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.black),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 1.5,
            tabs: [
              Tab(text: "66 Người theo dõi"),
              Tab(text: "116 Đang theo dõi"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FollowerTabContent(), // Nội dung tab Người theo dõi
            FollowingTabContent(), // Nội dung tab Đang theo dõi
          ],
        ),
      ),
    );
  }
}

// --- TAB NGƯỜI THEO DÕI ---
class FollowerTabContent extends StatelessWidget {
  const FollowerTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSearchBar(),
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: Text("Hạng mục", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        _buildCategoryItem("Người theo dõi mà bạn không theo dõi lại", "tiem_cua_doris và 27 người khác", Icons.group_remove_outlined),
        _buildCategoryItem("Ít tương tác nhất", "_dimha_ và 8 người khác", Icons.unfold_less),
        const Divider(),
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: Text("Tất cả người theo dõi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) => _buildUserTile(index, isFollowerTab: true),
        ),
      ],
    );
  }
}

// --- TAB ĐANG THEO DÕI ---
class FollowingTabContent extends StatelessWidget {
  const FollowingTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSearchBar(),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.contact_page_outlined, color: Colors.black),
          ),
          title: const Text("Kết nối người liên hệ", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text("Tìm những người mà bạn biết"),
          trailing: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, elevation: 0),
            child: const Text("Kết nối", style: TextStyle(color: Colors.white)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Text("Sắp xếp theo Mặc định", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 15,
          itemBuilder: (context, index) => _buildUserTile(index, isFollowerTab: false),
        ),
      ],
    );
  }
}

// --- CÁC WIDGET DÙNG CHUNG ---

Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      height: 38,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Tìm kiếm",
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 4),
        ),
      ),
    ),
  );
}

Widget _buildCategoryItem(String title, String sub, IconData icon) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    ),
    title: Text(title, style: const TextStyle(fontSize: 14)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
  );
}

Widget _buildUserTile(int index, {required bool isFollowerTab}) {
  return ListTile(
    leading: const CircleAvatar(radius: 26, backgroundColor: Colors.grey),
    title: Text("user_insta_$index", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    subtitle: Text("Tên người dùng $index", style: const TextStyle(color: Colors.grey)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: (isFollowerTab && index % 3 == 0) ? Colors.blue : Colors.grey[100],
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              (isFollowerTab && index % 3 == 0) ? "Theo dõi lại" : "Nhắn tin",
              style: TextStyle(color: (isFollowerTab && index % 3 == 0) ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(isFollowerTab ? Icons.close : Icons.more_vert, color: Colors.grey, size: 20),
      ],
    ),
  );
}