import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/auth_models.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  // Obtener todos los usuarios (solo admin)
  Future<List<UserResponse>> getAllUsers() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/users');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = jsonDecode(response.body);
        return usersJson.map((userJson) => UserResponse.fromJson(userJson)).toList();
      } else {
        print('Error al obtener usuarios: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  // Obtener un usuario por ID (solo admin)
  Future<UserResponse?> getUserById(int id) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/users/$id');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final userJson = jsonDecode(response.body);
        return UserResponse.fromJson(userJson);
      } else {
        print('Error al obtener usuario: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Crear un nuevo usuario (solo admin)
  Future<UserResponse?> createUser(UserRequest userRequest) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/users');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(userRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final userJson = jsonDecode(response.body);
        return UserResponse.fromJson(userJson);
      } else {
        print('Error al crear usuario: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al crear usuario: $e');
      return null;
    }
  }

  // Actualizar un usuario existente (solo admin)
  Future<UserResponse?> updateUser(int id, UserRequest userRequest) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/users/$id');
      final response = await http.put(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(userRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final userJson = jsonDecode(response.body);
        return UserResponse.fromJson(userJson);
      } else {
        print('Error al actualizar usuario: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return null;
    }
  }

  // Eliminar un usuario (solo admin)
  Future<bool> deleteUser(int id) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/users/$id');
      final response = await http.delete(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      return false;
    }
  }
} 