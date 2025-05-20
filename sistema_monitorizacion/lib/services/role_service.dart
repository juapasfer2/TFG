import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class RoleService {
  final AuthService _authService = AuthService();

  // Obtener todos los roles (solo admin)
  Future<List<Role>> getAllRoles() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/roles');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> rolesJson = jsonDecode(response.body);
        return rolesJson.map((roleJson) => Role.fromJson(roleJson)).toList();
      } else {
        print('Error al obtener roles: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener roles: $e');
      return [];
    }
  }

  // Obtener un rol por ID (solo admin)
  Future<Role?> getRoleById(int id) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/roles/$id');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final roleJson = jsonDecode(response.body);
        return Role.fromJson(roleJson);
      } else {
        print('Error al obtener rol: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener rol: $e');
      return null;
    }
  }

  // Crear un nuevo rol (solo admin)
  Future<Role?> createRole(Role role) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/roles');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode == 201) {
        final roleJson = jsonDecode(response.body);
        return Role.fromJson(roleJson);
      } else {
        print('Error al crear rol: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al crear rol: $e');
      return null;
    }
  }

  // Actualizar un rol existente (solo admin)
  Future<Role?> updateRole(int id, Role role) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/roles/$id');
      final response = await http.put(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode == 200) {
        final roleJson = jsonDecode(response.body);
        return Role.fromJson(roleJson);
      } else {
        print('Error al actualizar rol: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar rol: $e');
      return null;
    }
  }

  // Eliminar un rol (solo admin)
  Future<bool> deleteRole(int id) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/roles/$id');
      final response = await http.delete(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar rol: $e');
      return false;
    }
  }
} 