import '../models/models.dart';

class AlertService {
  final List<Alert> _mockAlerts = [];
  
  // Singleton pattern
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal() {
    _initMockAlerts();
  }

  // Inicializar alertas simuladas
  void _initMockAlerts() {
    final now = DateTime.now();
    
    // Crear algunas alertas de ejemplo
    _mockAlerts.addAll([
      Alert(
        id: 1,
        readingId: 101,
        level: 'high',
        timestamp: now.subtract(Duration(minutes: 30)),
        acknowledged: false,
        acknowledgedBy: null,
      ),
      Alert(
        id: 2,
        readingId: 203,
        level: 'low',
        timestamp: now.subtract(Duration(hours: 2)),
        acknowledged: true,
        acknowledgedBy: 1,
      ),
      Alert(
        id: 3,
        readingId: 305,
        level: 'high',
        timestamp: now.subtract(Duration(hours: 5)),
        acknowledged: true,
        acknowledgedBy: 2,
      ),
      Alert(
        id: 4,
        readingId: 402,
        level: 'high',
        timestamp: now.subtract(Duration(hours: 1)),
        acknowledged: false,
        acknowledgedBy: null,
      ),
      Alert(
        id: 5,
        readingId: 504,
        level: 'low',
        timestamp: now.subtract(Duration(hours: 3)),
        acknowledged: false,
        acknowledgedBy: null,
      ),
    ]);
  }

  // Obtener todas las alertas
  Future<List<Alert>> getAllAlerts() async {
    // Simular una llamada a API
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockAlerts;
  }

  // Obtener alertas no reconocidas
  Future<List<Alert>> getUnacknowledgedAlerts() async {
    // Simular una llamada a API
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAlerts.where((alert) => !alert.acknowledged).toList();
  }

  // Reconocer una alerta
  Future<bool> acknowledgeAlert(String alertId, int userId) async {
    // Simular una llamada a API
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final idInt = int.parse(alertId);
      final alertIndex = _mockAlerts.indexWhere((a) => a.id == idInt);
      
      if (alertIndex != -1) {
        // Crear una nueva alerta reconocida (inmutabilidad)
        final newAlert = Alert(
          id: _mockAlerts[alertIndex].id,
          readingId: _mockAlerts[alertIndex].readingId,
          level: _mockAlerts[alertIndex].level,
          timestamp: _mockAlerts[alertIndex].timestamp,
          acknowledged: true,
          acknowledgedBy: userId,
        );
        
        // Reemplazar la alerta en la lista
        _mockAlerts[alertIndex] = newAlert;
        return true;
      }
      return false;
    } catch (e) {
      print('Error al reconocer alerta: $e');
      return false;
    }
  }

  // Para demostración: obtener datos ficticios de alertas
  List<Alert> getMockAlerts() {
    return List.from(_mockAlerts);
  }
} 