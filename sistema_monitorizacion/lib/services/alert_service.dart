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

  // Obtener todas las alertas
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

  // Obtener alertas no reconocidas
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

  // Reconocer una alerta
  Future<bool> acknowledgeAlert(String alertId, int userId) async {
    try {
      final idInt = int.parse(alertId);
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/alerts/$idInt/acknowledge');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode({'userId': userId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al reconocer alerta: $e');
      return false;
    }
  }
  
  // Obtener alertas por paciente
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
} 