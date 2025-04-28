import '../models/models.dart';
import 'dart:math';

class VitalService {
  final Random _random = Random();
  
  // Singleton pattern
  static final VitalService _instance = VitalService._internal();
  factory VitalService() => _instance;
  VitalService._internal();

  // Obtener todos los tipos de signos vitales
  Future<List<VitalType>> getAllVitalTypes() async {
    // Simular una llamada a API
    await Future.delayed(const Duration(milliseconds: 800));
    return getMockVitalTypes();
  }

  // Obtener lecturas de un paciente
  Future<List<VitalReading>> getPatientReadings(int patientId) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(milliseconds: 800));
    return getMockReadings(patientId);
  }

  // Obtener lecturas recientes de un paciente (para un signo vital específico)
  Future<List<VitalReading>> getRecentReadings(int patientId, int typeId, int limit) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(milliseconds: 500));
    
    final readings = getMockReadings(patientId)
        .where((reading) => reading.typeId == typeId)
        .toList();
    
    // Limitar la cantidad de resultados
    return readings.length > limit ? readings.sublist(0, limit) : readings;
  }

  // Agregar nueva lectura
  Future<bool> addReading(VitalReading reading) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(seconds: 1));
    
    // Simular verificación de umbrales
    await _checkThresholds(reading);
    
    return true;
  }

  // Verificar umbrales y generar alertas
  Future<void> _checkThresholds(VitalReading reading) async {
    try {
      // En una app real, esto se realizaría en el servidor
      final vitalTypes = getMockVitalTypes();
      final vitalType = vitalTypes.firstWhere((type) => type.id == reading.typeId);
      
      if (reading.value < vitalType.normalMin || reading.value > vitalType.normalMax) {
        print('Valor fuera de rango normal. Se generaría una alerta.');
        // La generación de alertas se haría en un servicio real
      }
    } catch (e) {
      print('Error al verificar umbrales: $e');
    }
  }

  // Para demostración: obtener datos ficticios de tipos de signos vitales
  List<VitalType> getMockVitalTypes() {
    return [
      VitalType(
        id: 1,
        name: 'Frecuencia Cardíaca',
        unit: 'bpm',
        normalMin: 60.0,
        normalMax: 100.0,
      ),
      VitalType(
        id: 2,
        name: 'Temperatura',
        unit: '°C',
        normalMin: 36.1,
        normalMax: 37.2,
      ),
      VitalType(
        id: 3,
        name: 'Presión Sistólica',
        unit: 'mmHg',
        normalMin: 90.0,
        normalMax: 120.0,
      ),
      VitalType(
        id: 4,
        name: 'Presión Diastólica',
        unit: 'mmHg',
        normalMin: 60.0,
        normalMax: 80.0,
      ),
      VitalType(
        id: 5,
        name: 'Nivel de Oxígeno',
        unit: '%',
        normalMin: 95.0,
        normalMax: 100.0,
      ),
    ];
  }

  // Para demostración: obtener datos ficticios de lecturas
  List<VitalReading> getMockReadings(int patientId) {
    final now = DateTime.now();
    final readings = <VitalReading>[];
    
    // Crear algunas lecturas para cada tipo de signo vital
    for (int typeId = 1; typeId <= 5; typeId++) {
      final vitalType = getMockVitalTypes().firstWhere((type) => type.id == typeId);
      
      for (int i = 0; i < 10; i++) {
        final hours = i * 2; // Cada 2 horas
        final timestamp = now.subtract(Duration(hours: hours));
        
        // Generar un valor aleatorio, con posibilidad de estar fuera de rango
        double value;
        if (_random.nextInt(10) < 8) {
          // 80% dentro del rango normal
          value = vitalType.normalMin + 
              _random.nextDouble() * (vitalType.normalMax - vitalType.normalMin);
        } else {
          // 20% fuera del rango (para simular alertas)
          if (_random.nextBool()) {
            // Por encima del máximo
            value = vitalType.normalMax + _random.nextDouble() * 20;
          } else {
            // Por debajo del mínimo
            value = vitalType.normalMin - _random.nextDouble() * 20;
            if (value < 0) value = 0; // Evitar valores negativos
          }
        }
        
        // Redondear a 1 decimal
        value = double.parse(value.toStringAsFixed(1));
        
        readings.add(VitalReading(
          id: (patientId * 1000) + (typeId * 100) + i,
          patientId: patientId,
          typeId: typeId,
          value: value,
          timestamp: timestamp,
        ));
      }
    }
    
    // Ordenar por timestamp (más recientes primero)
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return readings;
  }
} 