import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AuthService {
  User? _currentUser;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Getter para el usuario actual
  User? get currentUser => _currentUser;

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => _currentUser != null;

  // Método para iniciar sesión
  Future<User?> login(String email, String password) async {
    try {
      // Simular una llamada a API
      await Future.delayed(const Duration(seconds: 1));
      
      // Verificar credenciales (demo)
      if (email == 'enfermera@demo.com' && password == '123456') {
        _currentUser = User(
          id: 1,
          name: 'Enfermera Demo',
          email: email,
          roleId: 2, // Role enfermera
        );
      } else if (email == 'admin@demo.com' && password == '123456') {
        _currentUser = User(
          id: 2,
          name: 'Administrador',
          email: email,
          roleId: 1, // Role admin
        );
      } else {
        return null;
      }
      
      // Guardar información de sesión
      await _saveSession(email, password);
      
      return _currentUser;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    _currentUser = null;
    
    // Eliminar información de sesión
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }

  // Método para verificar sesión guardada
  Future<User?> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    
    if (email != null && password != null) {
      return await login(email, password);
    }
    return null;
  }

  // Método para guardar sesión
  Future<void> _saveSession(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }
} 