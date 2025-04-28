class User {
  final int id;
  final String name;
  final String email;
  final int roleId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleId: json['role_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role_id': roleId,
    };
  }
} 