// models/user_model.dart
class User {
  final int? id;
  final String email;
  final String password;
  final String? name;
  final String? username;
  final String? birthday;

  User({
    this.id,
    required this.email,
    required this.password,
    this.name,
    this.username,
    this.birthday,
  });

  // Chuyển Map từ database thành Object User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ??
          'Instagram User', // Nếu null thì thay bằng chuỗi mặc định
      username: map['username'] ?? '',
      birthday: map['birthday'] ?? '',
    );
  }

  // Chuyển Object User thành Map để insert vào Database SQL
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'username': username,
      'birthday': birthday,
    };
  }
}
