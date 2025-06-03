import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class VitalService {
  final AuthService _authService = AuthService();
  
  // Singleton pattern
  static final VitalService _instance = VitalService._internal();
  factory VitalService() => _instance;
  VitalService._internal();

  // Obtener todos los tipos de signos vitales
  Future<List<VitalType>> getAllVitalTypes() async {
    try {
      // Usar endpoint específico para enfermeras
      final currentUser = _authService.currentUser;
      String endpoint = '/api/admin/vital-types';
      
      if (currentUser?.role?.name == 'NURSE') {
        endpoint = '/api/nurse/vital-types';
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> typesJson = jsonDecode(utf8.decode(response.bodyBytes));
        return typesJson.map((json) => VitalType.fromJson(json)).toList();
      } else {
        print('Error al obtener tipos de signos vitales: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener tipos de signos vitales: $e');
      return [];
    }
  }

  // Obtener un tipo de signo vital por ID
  Future<VitalType?> getVitalTypeById(int typeId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/vital-types/$typeId');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final typeJson = jsonDecode(response.body);
        return VitalType.fromJson(typeJson);
      } else {
        print('Error al obtener tipo de signo vital: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener tipo de signo vital: $e');
      return null;
    }
  }

  // Crear nuevo tipo de signo vital
  Future<VitalType?> createVitalType(VitalTypeRequest request) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/vital-types');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final typeJson = jsonDecode(response.body);
        return VitalType.fromJson(typeJson);
      } else {
        print('Error al crear tipo de signo vital: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al crear tipo de signo vital: $e');
      return null;
    }
  }

  // Actualizar tipo de signo vital
  Future<VitalType?> updateVitalType(int typeId, VitalTypeRequest request) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/vital-types/$typeId');
      final response = await http.put(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final typeJson = jsonDecode(response.body);
        return VitalType.fromJson(typeJson);
      } else {
        print('Error al actualizar tipo de signo vital: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar tipo de signo vital: $e');
      return null;
    }
  }

  // Eliminar tipo de signo vital
  Future<bool> deleteVitalType(int typeId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/vital-types/$typeId');
      final response = await http.delete(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar tipo de signo vital: $e');
      return false;
    }
  }

  // Obtener todas las lecturas de signos vitales
  Future<List<VitalReading>> getAllVitalReadings() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/vital-readings');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> readingsJson = jsonDecode(response.body);
        return readingsJson.map((json) => VitalReading.fromJson(json)).toList();
      } else {
        print('Error al obtener lecturas vitales: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener lecturas vitales: $e');
      return [];
    }
  }

  // Obtener lecturas de un paciente
  Future<List<VitalReading>> getPatientReadings(int patientId) async {
    try {
      final currentUser = _authService.currentUser;
      String endpoint = '/api/admin/vital-readings/patient/$patientId';
      
      // Si es enfermera, usar endpoint específico
      if (currentUser?.role?.name == 'NURSE') {
        endpoint = '/api/nurse/my-patients/$patientId/vital-readings';
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> readingsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return readingsJson.map((json) => VitalReading.fromJson(json)).toList();
      } else {
        print('Error al obtener lecturas del paciente: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener lecturas del paciente: $e');
      return [];
    }
  }

  // Obtener lecturas recientes de un paciente (para un signo vital específico)
  Future<List<VitalReading>> getRecentReadings(int patientId, int typeId, int limit) async {
    try {
      final currentUser = _authService.currentUser;
      String endpoint = '/api/admin/vital-readings/patient/$patientId/type/$typeId';
      
      // Si es enfermera, usar endpoint específico
      if (currentUser?.role?.name == 'NURSE') {
        endpoint = '/api/nurse/my-patients/$patientId/vital-readings/type/$typeId';
      }
      
      final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> readingsJson = jsonDecode(utf8.decode(response.bodyBytes));
        final readings = readingsJson.map((json) => VitalReading.fromJson(json)).toList();
        
        // Ordenar por timestamp (más recientes primero)
        readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Limitar la cantidad de resultados
        return readings.length > limit ? readings.sublist(0, limit) : readings;
      } else {
        print('Error al obtener lecturas recientes: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener lecturas recientes: $e');
      return [];
    }
  }

  // Agregar nueva lectura
  Future<VitalReading?> addReading(VitalReadingRequest reading) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/vital-readings');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(reading.toJson()),
      );

      if (response.statusCode == 201) {
        final readingJson = jsonDecode(response.body);
        return VitalReading.fromJson(readingJson);
      } else {
        print('Error al agregar lectura: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al agregar lectura: $e');
      return null;
    }
  }

  // Actualizar lectura
  Future<VitalReading?> updateReading(int id, VitalReadingRequest reading) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/vital-readings/$id');
      final response = await http.put(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(reading.toJson()),
      );

      if (response.statusCode == 200) {
        final readingJson = jsonDecode(response.body);
        return VitalReading.fromJson(readingJson);
      } else {
        print('Error al actualizar lectura: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar lectura: $e');
      return null;
    }
  }

  // Eliminar lectura
  Future<bool> deleteReading(int id) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/vital-readings/$id');
      final response = await http.delete(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar lectura: $e');
      return false;
    }
  }
} 