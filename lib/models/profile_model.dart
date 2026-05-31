class ProfileModel {
  int? id;

  String fullName;

  String username;

  String bio;

  String gender;

  String avatarUrl;

  ProfileModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.bio,
    required this.gender,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'bio': bio,
      'gender': gender,
      'avatarUrl': avatarUrl,
    };
  }

  factory ProfileModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ProfileModel(
      id: map['id'],

      fullName: map['fullName'] ?? '',

      username: map['username'] ?? '',

      bio: map['bio'] ?? '',

      gender: map['gender'] ?? 'Nữ',

      avatarUrl:
          map['avatarUrl'] ??
              'https://i.pravatar.cc/150?img=3',
    );
  }
}
