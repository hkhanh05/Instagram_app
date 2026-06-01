import 'package:flutter/material.dart';

class InstagramFollowScreen extends StatelessWidget {
  final int initialIndex;
  final String username;
  final List<Map<String, dynamic>> followersList;
  final List<Map<String, dynamic>> followingList;

  const InstagramFollowScreen({
    super.key,
    this.initialIndex = 0,
    required this.username,
    required this.followersList,
    required this.followingList,
  });

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
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 18, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                username,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 1.5,
            tabs: [
              Tab(text: "${followersList.length} Người theo dõi"),
              Tab(text: "${followingList.length} Đang theo dõi"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FollowerTabContent(users: followersList, username: username),
            FollowingTabContent(users: followingList),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// FOLLOWER TAB
// =========================================================================
class FollowerTabContent extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final String username;

  const FollowerTabContent(
      {super.key, required this.users, required this.username});

  @override
  State<FollowerTabContent> createState() => _FollowerTabContentState();
}

class _FollowerTabContentState extends State<FollowerTabContent> {
  final Map<int, bool> _followStatusMap = {};

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return const Center(
        child: Text("Không có người theo dõi nào",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      children: [
        _buildSearchBar(),
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: Text("Hạng mục",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        _buildCategoryItem(
          "Người theo dõi mà bạn không theo dõi lại",
          "Các tài khoản chưa tương tác chéo với ${widget.username}",
          Icons.group_remove_outlined,
        ),
        _buildCategoryItem(
          "Ít tương tác nhất",
          "Danh sách tài khoản có tần suất tương tác thấp",
          Icons.unfold_less,
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: Text("Tất cả người theo dõi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.users.length,
          itemBuilder: (context, index) {
            final user = widget.users[index];
            int userId = user['id'] ?? index;

            bool isFollowingBack =
                _followStatusMap[userId] ?? (user['isFollowing'] == 1);

            return _buildUserTile(
              userData: user,
              isFollowerTab: true,
              isButtonActive: isFollowingBack,
              onButtonPressed: () {
                setState(() {
                  _followStatusMap[userId] = !isFollowingBack;
                });
                // To-Do: Bạn có thể gọi thêm Firebase Firestore để cập nhật trạng thái follow thực tế tại đây
              },
            );
          },
        ),
      ],
    );
  }
}

// =========================================================================
// FOLLOWING TAB
// =========================================================================
class FollowingTabContent extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  const FollowingTabContent({super.key, required this.users});

  @override
  State<FollowingTabContent> createState() => _FollowingTabContentState();
}

class _FollowingTabContentState extends State<FollowingTabContent> {
  final Map<int, bool> _unfollowStatusMap = {};

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return const Center(
        child:
            Text("Bạn chưa theo dõi ai", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      children: [
        _buildSearchBar(),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.contact_page_outlined, color: Colors.black),
          ),
          title: const Text("Kết nối người liên hệ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text("Tìm những người mà bạn biết"),
          trailing: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, elevation: 0),
            child: const Text("Kết nối", style: TextStyle(color: Colors.white)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Text("Sắp xếp theo Mặc định",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.users.length,
          itemBuilder: (context, index) {
            final user = widget.users[index];
            int userId = user['id'] ?? index;

            bool isUnfollowed = _unfollowStatusMap[userId] ?? false;

            return _buildUserTile(
              userData: user,
              isFollowerTab: false,
              isButtonActive: isUnfollowed,
              onButtonPressed: () {
                setState(() {
                  _unfollowStatusMap[userId] = !isUnfollowed;
                });
              },
            );
          },
        ),
      ],
    );
  }
}

// =========================================================================
// WIDGET THÀNH PHẦN
// =========================================================================
Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      height: 38,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
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
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    ),
    title: Text(title, style: const TextStyle(fontSize: 14)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
  );
}

Widget _buildUserTile({
  required Map<String, dynamic> userData,
  required bool isFollowerTab,
  required bool isButtonActive,
  required VoidCallback onButtonPressed,
}) {
  String buttonText = "";
  if (isFollowerTab) {
    buttonText = isButtonActive ? "Theo dõi lại" : "Nhắn tin";
  } else {
    buttonText = isButtonActive ? "Theo dõi" : "Nhắn tin";
  }

  String avatarUrl = userData['avatarUrl'] ?? '';
  String username = userData['username'] ?? '';
  String fullName = userData['fullName'] ?? '';

  return ListTile(
    leading: CircleAvatar(
      radius: 26,
      backgroundColor: Colors.grey[200],
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child: avatarUrl.isEmpty
          ? const Icon(Icons.person, color: Colors.grey)
          : null,
    ),
    title: Text(username,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    subtitle: Text(fullName,
        style: const TextStyle(color: Colors.grey, fontSize: 13)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: OutlinedButton(
            onPressed: onButtonPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: isButtonActive ? Colors.blue : Colors.grey[100],
              side: BorderSide(
                  color: isButtonActive ? Colors.blue : Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                  color: isButtonActive ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(isFollowerTab ? Icons.close : Icons.more_vert,
            color: Colors.grey, size: 20),
      ],
    ),
  );
}
