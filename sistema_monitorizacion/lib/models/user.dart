import 'role.dart';

class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final Role? role;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
    };
    
    if (id != null) data['id'] = id;
    if (password != null) data['password'] = password;
    if (role != null) data['role_id'] = role!.id;
    
    return data;
  }
} 