import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/threshold.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class ThresholdService {
  final AuthService _authService = AuthService();
  
  // Singleton pattern
  static final ThresholdService _instance = ThresholdService._internal();
  factory ThresholdService() => _instance;
  ThresholdService._internal();

  // Obtener todos los umbrales
  Future<List<ThresholdResponse>> getAllThresholds() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/thresholds');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> thresholdsJson = jsonDecode(response.body);
        return thresholdsJson.map((json) => ThresholdResponse.fromJson(json)).toList();
      } else {
        print('Error al obtener umbrales: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener umbrales: $e');
      return [];
    }
  }

  // Obtener umbral por ID
  Future<ThresholdResponse?> getThresholdById(int id) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/thresholds/$id');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final thresholdJson = jsonDecode(response.body);
        return ThresholdResponse.fromJson(thresholdJson);
      } else {
        print('Error al obtener umbral: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener umbral: $e');
      return null;
    }
  }

  // Obtener umbrales por tipo
  Future<List<ThresholdResponse>> getThresholdsByType(int typeId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/thresholds/type/$typeId');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> thresholdsJson = jsonDecode(response.body);
        return thresholdsJson.map((json) => ThresholdResponse.fromJson(json)).toList();
      } else {
        print('Error al obtener umbrales por tipo: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener umbrales por tipo: $e');
      return [];
    }
  }

  // Obtener umbral único por tipo
  Future<ThresholdResponse?> getThresholdByTypeId(int typeId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/thresholds/type/$typeId/single');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final thresholdJson = jsonDecode(response.body);
        return ThresholdResponse.fromJson(thresholdJson);
      } else {
        print('Error al obtener umbral por tipo: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener umbral por tipo: $e');
      return null;
    }
  }

  // Crear nuevo umbral
  Future<ThresholdResponse?> createThreshold(ThresholdRequest thresholdRequest) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/thresholds');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(thresholdRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final thresholdJson = jsonDecode(response.body);
        return ThresholdResponse.fromJson(thresholdJson);
      } else {
        print('Error al crear umbral: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al crear umbral: $e');
      return null;
    }
  }

  // Actualizar umbral existente
  Future<ThresholdResponse?> updateThreshold(int id, ThresholdRequest thresholdRequest) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/thresholds/$id');
      final response = await http.put(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(thresholdRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final thresholdJson = jsonDecode(response.body);
        return ThresholdResponse.fromJson(thresholdJson);
      } else {
        print('Error al actualizar umbral: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar umbral: $e');
      return null;
    }
  }

  // Eliminar umbral
  Future<bool> deleteThreshold(int id) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/thresholds/$id');
      final response = await http.delete(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar umbral: $e');
      return false;
    }
  }
} 