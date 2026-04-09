<<<<<<< HEAD
# instagram

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# Instagram_app
Môi trường: VSCode, flutter project,  ngôn ngữ dart, Máy ảo Android Studio
>>>>>>> 891229a7f2d5c8850cbb4c5ef4ad68e5a21be4d7

 ## Phần mềm: Mạng xã hội Instagram
Thành viên: 
1.	Nguyễn Hữu Khánh
2.	Nguyễn Vũ Phương Uyên
3.	Phan Thị Hồng Hòa
4.	Võ Tuấn Kiệt
Môi trường: VSCode, flutter project,  ngôn ngữ dart, Máy ảo Android Studio
CÂY THƯ MỤC (TẠM THỜI)

 
## GIẢI THÍCH NGẮN GỌN
•	core/
→ chứa config chung → đổi 1 lần ảnh hưởng toàn app
•	models/
→ thực thể
•	widgets/
→ tái sử dụng → tránh code lặp 
•	screens/
→ mỗi file = 1 màn hình
•	main_screen.dart
→ giống Instagram: có bottom navigation
LUỒNG DỮ LIỆU
Login → MainScreen (Bottom Nav)

Bottom Nav gồm:
- Feed
- Search
- Post
- Message
- Profile
LUỒNG APP 
main.dart 
   ↓
app.dart (MaterialApp)
   ↓
MainScreen (Bottom Navigation)
   ↓
Feed / Search / Post / Message / Profile


Làm các file:
lib/
├── main.dart
├── app.dart
├── routes/app_routes.dart

core/
(toàn bộ)

screens/auth/
├── login_screen.dart
└── register_screen.dart
Nhiệm vụ:
Setup app (MaterialApp, theme, route) 
Làm UI login / register 
Điều hướng giữa các màn

Thành viên 2 — FEED + POST + STORY
Là phần “Instagram chính”
Làm các file:
screens/feed/
├── feed_screen.dart
├── comment_screen.dart
└── notification_screen.dart

screens/post/
├── create_post_screen.dart
└── camera_screen.dart

screens/story/
├── story_view_screen.dart
└── create_story_screen.dart

widgets/post/
(toàn bộ)

widgets/story/
(toàn bộ)
Nhiệm vụ:
UI feed (list bài post) 
Story ngang (giống IG) 
Comment UI 
Notification UI 
UI đăng bài + camera (mock)

Thành viên 3 — CHAT + MESSAGE + NOTES
Làm phần nhắn tin
Làm các file:
screens/message/
├── message_screen.dart
├── chat_screen.dart
└── notes_screen.dart

widgets/chat/
(toàn bộ)
Nhiệm vụ:
Danh sách chat 
UI chat chi tiết 
Ghi chú (IG Notes)

Thành viên 4 — PROFILE + SEARCH + SETTINGS
Phần user + khám phá
Làm các file:
screens/profile/
├── profile_screen.dart
├── edit_profile_screen.dart
├── followers_screen.dart
└── following_screen.dart

screens/search/
└── search_screen.dart

screens/settings/
└── settings_screen.dart
Nhiệm vụ:
Profile UI 
Followers / Following 
Search grid (ảnh) 
Settings UI


LƯU Ý: FILE KHÔNG ĐƯỢC ĐỤNG CHUNG
Những file này chỉ 1 người được sửa:
main.dart
app.dart
app_routes.dart
pubspec.yaml
→ Nếu cần sửa thì báo người phụ trách, không tự sửa

QUY TẮC GIT (TRÁNH XUNG ĐỘT)
Mỗi người làm 1 branch riêng, Không ai code trực tiếp vào main :
git checkout -b feature/auth
git checkout -b feature/feed
git checkout -b feature/chat
git checkout -b feature/profile

QUY TRÌNH LÀM VIỆC
1.	Pull code mới nhất: 
git pull origin main
2.	Code xong: 
git add .
git commit -m "done UI feed"
git push origin feature/feed
3.	Tạo Pull Request → merge vào main

