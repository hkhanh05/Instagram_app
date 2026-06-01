class PostModel {
  final int? id;
  final int userId;
  final String imageUrl;
  final String caption;
  final int likesCount;

  PostModel({
    this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.likesCount,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      userId: map['userId'],
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      likesCount: map['likesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likesCount': likesCount,
    };
  }
}