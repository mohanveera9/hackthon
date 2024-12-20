class User {
  final String id;
  final String email;
  final String username;
  final String phone;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      username: json['username'],
      phone: json['phno'],
    );
  }
}
