// Dữ liệu giả để test UI
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/profile_model.dart'; 
import '../../models/post_model.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('instagram_v5.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Bảng User (Thêm cột số lượng follow tĩnh để quản lý động)
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        fullName TEXT,
        bio TEXT,
        avatarUrl TEXT,
        gender TEXT,
        followersCount INTEGER,
        followingCount INTEGER
      )
    ''');

    // 2. Bảng Bài đăng (Thêm cột đếm lượt thích)
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        imageUrl TEXT,
        caption TEXT,
        likesCount INTEGER
      )
    ''');

    // 3. Bảng Bình luận liên kết với bài đăng
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        username TEXT,
        content TEXT
      )
    ''');

    // 4. Bảng Story Highlights
    await db.execute('''
      CREATE TABLE highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        imageUrl TEXT,
        isAdd TEXT
      )
    ''');

    // --- CHÈN DỮ LIỆU MẪU ĐỘNG BAN ĐẦU ---
    await db.insert('user_profile', {
      'id': 1,
      'username': 'hoa_phan',
      'fullName': 'Phan Thị Hồng Hoa',
      'bio': 'Software Engineering Student 💻✨',
      'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      'followersCount': 66,
      'followingCount': 116
    });

    // Chèn 2 bài viết mẫu ban đầu
    await db.insert('posts', {
      'id': 101, 
      'userId': 1, 
      'imageUrl': 'https://picsum.photos/400?random=1', 
      'caption': 'Học Flutter rất vui! 🚀', 
      'likesCount': 15
    });
    await db.insert('posts', {
      'id': 102, 
      'userId': 1, 
      'imageUrl': 'https://picsum.photos/400?random=2', 
      'caption': 'Giao diện Instagram Clone.', 
      'likesCount': 28
    });

    // Chèn bình luận mẫu cho bài viết 101
    await db.insert('comments', {'postId': 101, 'username': 'user_0', 'content': 'Đẹp quá 😍'});
    await db.insert('comments', {'postId': 101, 'username': 'user_1', 'content': '10 điểm ❤️'});

    // Chèn Highlights mẫu
    await db.insert('highlights', {'userId': 1, 'title': 'Mới', 'imageUrl': '', 'isAdd': 'true'});
    await db.insert('highlights', {'userId': 1, 'title': 'Du lịch', 'imageUrl': 'https://picsum.photos/200?random=10', 'isAdd': 'false'});
    await db.insert('highlights', {'userId': 1, 'title': 'Thú cưng', 'imageUrl': 'https://picsum.photos/200?random=11', 'isAdd': 'false'});
  }

  // --- CÁC HÀM TRUY VẤN DỮ LIỆU ĐỘNG ---
  
  // Lấy thông tin User
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await instance.database;
    final res = await db.query('user_profile', where: 'id = ?', whereArgs: [userId]);
    return res.isNotEmpty ? res.first : null;
  }

  // Lấy toàn bộ bài đăng của một User cụ thể
  Future<List<Map<String, dynamic>>> getPostsByUserId(int userId) async {
    final db = await instance.database;
    return await db.query('posts', where: 'userId = ?', orderBy: 'id DESC', whereArgs: [userId]);
  }

  // 🔥 THÊM HÀM NÀY: Giúp trang HOME có thể gọi để chèn bài viết mới vào SQLite
  Future<int> insertPost(int userId, String imageUrl, String caption) async {
    final db = await instance.database;
    return await db.insert('posts', {
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likesCount': 0 // Bài viết mới mặc định có 0 lượt thích
    });
  }


  Future<int> insertHighlight(int userId,String title,String imageUrl,) async {
    final db = await instance.database;
    return await db.insert('highlights',{
      'userId': userId,
      'title': title,
      'imageUrl': imageUrl,
      'isAdd': 'false',
    },);
  }

  // Lấy danh sách bình luận theo ID bài viết
  Future<List<Map<String, dynamic>>> getCommentsByPostId(int postId) async {
    final db = await instance.database;
    return await db.query('comments', where: 'postId = ?', whereArgs: [postId]);
  }

  // Thêm bình luận mới
  Future<int> insertComment(int postId, String username, String content) async {
    final db = await instance.database;
    return await db.insert('comments', {'postId': postId, 'username': username, 'content': content});
  }

  // Lấy danh sách tin nổi bật (Highlights)
  Future<List<Map<String, dynamic>>> getHighlights(int userId) async {
    final db = await instance.database;
    return await db.query('highlights', where: 'userId = ?', whereArgs: [userId]);
  }

  // Cập nhật số lượt thích của bài viết khi bấm Tim
  Future<int> updatePostLikes(int postId, int newLikes) async {
    final db = await instance.database;
    return await db.update('posts', {'likesCount': newLikes}, where: 'id = ?', whereArgs: [postId]);
  }

  // Thêm hàm này vào trong class DatabaseHelper của bạn
Future<int> deletePost(int postId) async {
  final db = await instance.database;
  return await db.delete(
    'posts', // Tên bảng bài viết của bạn, hãy sửa lại nếu tên bảng khác
    where: 'id = ?',
    whereArgs: [postId],
  );
}

Future<int> deleteHighlight(int highlightId) async {
  final db = await instance.database;
  return await db.delete(
    'highlights', // Tên bảng highlight của bạn, hãy sửa lại nếu tên bảng khác
    where: 'id = ?',
    whereArgs: [highlightId],
  );
}
}