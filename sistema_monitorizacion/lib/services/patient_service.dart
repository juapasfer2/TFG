import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class PatientService {
  final AuthService _authService = AuthService();
  
  // Singleton pattern
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  // Obtener todos los pacientes
  Future<List<Patient>> getAllPatients() async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/patients');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        // Asegurarnos de decodificar con UTF-8
        final List<dynamic> patientsJson = jsonDecode(utf8.decode(response.bodyBytes));
        final List<PatientResponse> patientResponses = patientsJson
            .map((json) => PatientResponse.fromJson(json))
            .toList();
        return patientResponses.map((pr) => pr.toPatient()).toList();
      } else {
        print('Error al obtener pacientes: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener pacientes: $e');
      return [];
    }
  }

  // Obtener paciente por ID
  Future<Patient?> getPatientById(String id) async {
    try {
      final idInt = int.parse(id);
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/patients/$idInt');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        // Asegurarnos de decodificar con UTF-8
        final patientJson = jsonDecode(utf8.decode(response.bodyBytes));
        final patientResponse = PatientResponse.fromJson(patientJson);
        return patientResponse.toPatient();
      } else {
        print('Error al obtener paciente: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener paciente: $e');
      return null;
    }
  }

  // Agregar nuevo paciente
  Future<bool> addPatient(Patient patient) async {
    try {
      final patientRequest = PatientRequest(
        firstName: patient.firstName,
        lastName: patient.lastName,
        dateOfBirth: patient.dateOfBirth,
        medicalRecordNumber: patient.medicalRecordNumber,
      );
      
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/patients');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(patientRequest.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error al agregar paciente: $e');
      return false;
    }
  }

  // Actualizar paciente
  Future<bool> updatePatient(Patient patient) async {
    try {
      final patientRequest = PatientRequest(
        firstName: patient.firstName,
        lastName: patient.lastName,
        dateOfBirth: patient.dateOfBirth,
        medicalRecordNumber: patient.medicalRecordNumber,
      );
      
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/patients/${patient.id}');
      final response = await http.put(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(patientRequest.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar paciente: $e');
      return false;
    }
  }

  // Eliminar paciente
  Future<bool> deletePatient(String id) async {
    try {
      final idInt = int.parse(id);
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/patients/$idInt');
      final response = await http.delete(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar paciente: $e');
      return false;
    }
  }
  
  // Asignar enfermero a paciente
  Future<bool> assignNurseToPatient(int patientId, int nurseId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/patients/$patientId/nurses/$nurseId');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al asignar enfermero a paciente: $e');
      return false;
    }
  }
  
  // Eliminar enfermero de paciente
  Future<bool> removeNurseFromPatient(int patientId, int nurseId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/admin/patients/$patientId/nurses/$nurseId');
      final response = await http.delete(
        url,
        headers: _authService.getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar enfermero de paciente: $e');
      return false;
    }
  }

  // Obtener pacientes asignados a un enfermero
  Future<List<Patient>> getPatientsForNurse(int nurseId) async {
    try {
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/$nurseId/patients');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        // Asegurarnos de decodificar con UTF-8
        final List<dynamic> patientsJson = jsonDecode(utf8.decode(response.bodyBytes));
        final List<PatientResponse> patientResponses = patientsJson
            .map((json) => PatientResponse.fromJson(json))
            .toList();
        return patientResponses.map((pr) => pr.toPatient()).toList();
      } else {
        print('Error al obtener pacientes del enfermero: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener pacientes del enfermero: $e');
      return [];
    }
  }
  
  // Método alternativo: usar el método general y filtrar por el ID del enfermero actual
  Future<List<Patient>> getMyPatients() async {
    try {
      // Primero obtenemos el usuario actual
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return [];
      }

      // Si es enfermera, usar el endpoint específico
      if (currentUser.role?.name == 'NURSE') {
        final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/my-patients');
        final response = await http.get(
          url,
          headers: _authService.getAuthHeaders(),
        );

        if (response.statusCode == 200) {
          // Asegurarnos de decodificar con UTF-8
          final List<dynamic> patientsJson = jsonDecode(utf8.decode(response.bodyBytes));
          final List<PatientResponse> patientResponses = patientsJson
              .map((json) => PatientResponse.fromJson(json))
              .toList();
          return patientResponses.map((pr) => pr.toPatient()).toList();
        } else {
          print('Error al obtener mis pacientes: ${response.statusCode}');
          print('Respuesta: ${response.body}');
          return [];
        }
      }
      
      // Si es admin, obtener todos los pacientes
      if (currentUser.role?.name == 'ADMIN') {
        return await getAllPatients();
      }
      
      return [];
    } catch (e) {
      print('Error al obtener mis pacientes: $e');
      return [];
    }
  }

  // Obtener un paciente específico para enfermeras
  Future<Patient?> getMyPatientById(String id) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser?.role?.name != 'NURSE') {
        // Si no es enfermera, usar el método general
        return await getPatientById(id);
      }

      final idInt = int.parse(id);
      final url = Uri.parse('${Constants.apiBaseUrl}/api/nurse/my-patients/$idInt');
      final response = await http.get(
        url,
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        // Asegurarnos de decodificar con UTF-8
        final patientJson = jsonDecode(utf8.decode(response.bodyBytes));
        final patientResponse = PatientResponse.fromJson(patientJson);
        return patientResponse.toPatient();
      } else {
        print('Error al obtener mi paciente: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener mi paciente: $e');
      return null;
    }
  }
} 