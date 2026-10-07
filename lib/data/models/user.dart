class User {
  const User({required this.id, required this.fullName, this.email});

  final int id;
  final String fullName;
  final String? email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: (json['full_name'] ?? json['name'] ?? '') as String,
      email: json['email'] as String?,
    );
  }
}
