// fake_data_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FakeDataHelper {
  static final FakeDataHelper instance = FakeDataHelper._init();

  static Database? _database;

  FakeDataHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('instagram_v5.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        imageUrl TEXT,
        caption TEXT,
        likesCount INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        username TEXT,
        content TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        imageUrl TEXT,
        isAdd TEXT
      )
    ''');
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await instance.database;

    final res = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [userId],
    );

    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> getPostsByUserId(int userId) async {
    final db = await instance.database;

    return await db.query(
      'posts',
      where: 'userId = ?',
      orderBy: 'id DESC',
      whereArgs: [userId],
    );
  }

  Future<int> insertPost(
    int userId,
    String imageUrl,
    String caption,
  ) async {
    final db = await instance.database;

    return await db.insert('posts', {
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likesCount': 0,
    });
  }

  Future<int> insertHighlight(
    int userId,
    String title,
    String imageUrl,
  ) async {
    final db = await instance.database;

    return await db.insert('highlights', {
      'userId': userId,
      'title': title,
      'imageUrl': imageUrl,
      'isAdd': 'false',
    });
  }

  Future<List<Map<String, dynamic>>> getCommentsByPostId(int postId) async {
    final db = await instance.database;

    return await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
    );
  }

  Future<int> insertComment(
    int postId,
    String username,
    String content,
  ) async {
    final db = await instance.database;

    return await db.insert('comments', {
      'postId': postId,
      'username': username,
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> getHighlights(int userId) async {
    final db = await instance.database;

    return await db.query(
      'highlights',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updatePostLikes(
    int postId,
    int newLikes,
  ) async {
    final db = await instance.database;

    return await db.update(
      'posts',
      {'likesCount': newLikes},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<int> deletePost(int postId) async {
    final db = await instance.database;

    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<int> deleteHighlight(int highlightId) async {
    final db = await instance.database;

    return await db.delete(
      'highlights',
      where: 'id = ?',
      whereArgs: [highlightId],
    );
  }
}