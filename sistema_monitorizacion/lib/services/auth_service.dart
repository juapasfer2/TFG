import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/auth_models.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../utils/constants.dart';

class AuthService {
  User? _currentUser;
  String? _token;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null && _token != null;
  bool get isAdmin => _currentUser?.role?.name == 'ADMIN';

  // Método para iniciar sesión
  Future<User?> login(String email, String password) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(AuthRequest(email: email, password: password).toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        _token = authResponse.token;
        
        _currentUser = User(
          name: authResponse.name,
          email: authResponse.email,
          role: Role(id: 0, name: authResponse.role),
        );
        
        // Guardar información de sesión
        await _saveSession(authResponse.token, email);
        
        return _currentUser;
      } else {
        print('Error en login: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    
    // Eliminar información de sesión
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
  }

  // Método para verificar sesión guardada
  Future<User?> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');
    
    if (token != null && email != null) {
      // Aquí deberías validar el token con el backend
      // Por simplicidad, asumimos que el token es válido
      _token = token;
      
      try {
        // Obtener información del usuario actual
        final userResponse = await getUserInfo();
        return userResponse;
      } catch (e) {
        print('Error al verificar sesión: $e');
        await logout();
        return null;
      }
    }
    return null;
  }

  // Obtener información del usuario actual
  Future<User?> getUserInfo() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/users/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUser = User.fromJson(userData);
        return _currentUser;
      } else {
        print('Error al obtener info de usuario: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener info de usuario: $e');
      return null;
    }
  }

  // Método para guardar sesión
  Future<void> _saveSession(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
  }
  
  // Método para obtener headers con token
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }
} 