import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class AlertService {
  final AuthService _authService = AuthService();
  
  // Singleton pattern
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  // ==================== MÉTODOS GENERALES ====================
  
  // Obtener todas las alertas (usa endpoint específico según rol)
  Future<List<Alert>> getAllAlerts() async {
    try {
      final currentUser = _authService.currentUser;
      String endpoint = '/api/admin/alerts';
      
      // Si es enfermera, usar endpoint específico
      if (currentUser?.role?.name == 'NURSE') {
        endpoint = '/api/nurse/my-alerts';
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener alertas: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener alertas: $e');
      return [];
    }
  }

  // Obtener alertas no reconocidas (usa endpoint específico según rol)
  Future<List<Alert>> getUnacknowledgedAlerts() async {
    try {
      final currentUser = _authService.currentUser;
      String endpoint = '/api/admin/alerts/unacknowledged';
      
      // Si es enfermera, usar endpoint específico
      if (currentUser?.role?.name == 'NURSE') {
        endpoint = '/api/nurse/my-alerts/unacknowledged';
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener alertas no reconocidas: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener alertas no reconocidas: $e');
      return [];
    }
  }

  // Obtener alerta específica por ID
  Future<Alert?> getAlertById(int alertId) async {
    try {
      final currentUser = _authService.currentUser;
      String endpoint = '/api/admin/alerts/$alertId';
      
      // Si es enfermera, usar endpoint específico
      if (currentUser?.role?.name == 'NURSE') {
        endpoint = '/api/nurse/alerts/$alertId';
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final alertJson = jsonDecode(utf8.decode(response.bodyBytes));
        return Alert.fromJson(alertJson);
      } else {
        print('Error al obtener alerta específica: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener alerta específica: $e');
      return null;
    }
  }

  // Reconocer una alerta (usa endpoint específico según rol)
  Future<bool> acknowledgeAlert(int alertId, int userId) async {
    try {
      final currentUser = _authService.currentUser;
      String endpoint = '/api/admin/alerts/$alertId/acknowledge';
      
      // Si es enfermera, usar endpoint específico
      if (currentUser?.role?.name == 'NURSE') {
        endpoint = '/api/nurse/alerts/$alertId/acknowledge';
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al reconocer alerta: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al reconocer alerta: $e');
      return false;
    }
  }

  // ==================== MÉTODOS PARA ADMINISTRADORES ====================
  
  // Ver alertas de una enfermera específica (solo admin)
  Future<List<Alert>> getAlertsByNurse(int nurseId) async {
    try {
      if (!_authService.isAdmin) {
        throw Exception('Acceso denegado: Solo administradores pueden ver alertas de otras enfermeras');
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/alerts/nurse/$nurseId');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener alertas de la enfermera: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener alertas de la enfermera: $e');
      return [];
    }
  }

  // Ver alertas no reconocidas de una enfermera específica (solo admin)
  Future<List<Alert>> getUnacknowledgedAlertsByNurse(int nurseId) async {
    try {
      if (!_authService.isAdmin) {
        throw Exception('Acceso denegado: Solo administradores pueden ver alertas de otras enfermeras');
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/alerts/nurse/$nurseId/unacknowledged');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener alertas no reconocidas de la enfermera: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener alertas no reconocidas de la enfermera: $e');
      return [];
    }
  }

  // ==================== MÉTODOS PARA ENFERMERAS ====================
  
  // Ver mis alertas (específico para enfermeras)
  Future<List<Alert>> getMyAlerts() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/my-alerts');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener mis alertas: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener mis alertas: $e');
      return [];
    }
  }

  // Ver mis alertas no reconocidas (específico para enfermeras)
  Future<List<Alert>> getMyUnacknowledgedAlerts() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/my-alerts/unacknowledged');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener mis alertas no reconocidas: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener mis alertas no reconocidas: $e');
      return [];
    }
  }

  // Ver alertas por ID de enfermera (para enfermeras que quieren ver sus propias alertas por ID)
  Future<List<Alert>> getAlertsByNurseId(int nurseId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/alerts/nurse/$nurseId');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener alertas por ID de enfermera: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener alertas por ID de enfermera: $e');
      return [];
    }
  }

  // Ver alertas no reconocidas por ID de enfermera
  Future<List<Alert>> getUnacknowledgedAlertsByNurseId(int nurseId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/alerts/nurse/$nurseId/unacknowledged');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener alertas no reconocidas por ID de enfermera: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener alertas no reconocidas por ID de enfermera: $e');
      return [];
    }
  }

  // ==================== MÉTODOS DE UTILIDAD ====================
  
  // Obtener alertas por paciente (mantenido para compatibilidad)
  Future<List<Alert>> getAlertsByPatient(int patientId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/alerts/patient/$patientId');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsJson = jsonDecode(response.body);
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('Error al obtener alertas del paciente: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener alertas del paciente: $e');
      return [];
    }
  }

  // Método helper para determinar qué tipo de usuario es
  bool get isAdmin => _authService.isAdmin;
  bool get isNurse => _authService.currentUser?.role?.name == 'NURSE';
  bool get isDoctor => _authService.currentUser?.role?.name == 'DOCTOR';
} 