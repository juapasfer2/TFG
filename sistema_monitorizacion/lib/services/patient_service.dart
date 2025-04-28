import '../models/models.dart';

class PatientService {
  // Singleton pattern
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  // Obtener todos los pacientes
  Future<List<Patient>> getAllPatients() async {
    // Simular una llamada a API
    await Future.delayed(const Duration(milliseconds: 800));
    return getMockPatients();
  }

  // Obtener paciente por ID
  Future<Patient?> getPatientById(String id) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final idInt = int.parse(id);
      return getMockPatients().firstWhere((p) => p.id == idInt);
    } catch (e) {
      print('Error al obtener paciente: $e');
      return null;
    }
  }

  // Agregar nuevo paciente (simulado)
  Future<bool> addPatient(Patient patient) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Actualizar paciente (simulado)
  Future<bool> updatePatient(Patient patient) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Eliminar paciente (simulado)
  Future<bool> deletePatient(String id) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Para demostración: obtener datos ficticios
  List<Patient> getMockPatients() {
    return [
      Patient(
        id: 1,
        firstName: 'Juan',
        lastName: 'Pérez',
        dateOfBirth: DateTime(1980, 5, 15),
        medicalRecordNumber: 'MRN12345',
      ),
      Patient(
        id: 2,
        firstName: 'María',
        lastName: 'González',
        dateOfBirth: DateTime(1975, 8, 22),
        medicalRecordNumber: 'MRN67890',
      ),
      Patient(
        id: 3,
        firstName: 'Carlos',
        lastName: 'Rodríguez',
        dateOfBirth: DateTime(1990, 3, 10),
        medicalRecordNumber: 'MRN54321',
      ),
      Patient(
        id: 4,
        firstName: 'Ana',
        lastName: 'Martínez',
        dateOfBirth: DateTime(1988, 11, 28),
        medicalRecordNumber: 'MRN98765',
      ),
      Patient(
        id: 5,
        firstName: 'Luis',
        lastName: 'Sánchez',
        dateOfBirth: DateTime(1965, 7, 3),
        medicalRecordNumber: 'MRN45678',
      ),
    ];
  }
} 