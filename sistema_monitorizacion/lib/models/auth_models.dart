class AuthRequest {
  final String email;
  final String password;

  AuthRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String token;
  final String email;
  final String name;
  final String role;

  AuthResponse({
    required this.token,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
    );
  }
}

class UserRequest {
  final String name;
  final String email;
  final String password;
  final int roleId;

  UserRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'roleId': roleId,
    };
  }
}

class UserResponse {
  final int id;
  final String name;
  final String email;
  final String? roleName;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    this.roleName,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleName: json['roleName'],
    );
  }
} 