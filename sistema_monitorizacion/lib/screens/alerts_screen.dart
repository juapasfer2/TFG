import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/services.dart';

class AlertsScreen extends StatefulWidget {
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  final AlertService _alertService = AlertService();
  final PatientService _patientService = PatientService();
  final VitalService _vitalService = VitalService();
  final AuthService _authService = AuthService();
  
  late TabController _tabController;
  List<Alert> _pendingAlerts = [];
  List<Alert> _acknowledgedAlerts = [];
  bool _isLoading = true;
  
  // Mapas para datos relacionados
  Map<int, Patient> _patientsMap = {};
  Map<int, VitalReading> _readingsMap = {};
  Map<int, VitalType> _vitalTypesMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar todas las alertas usando el método apropiado según el rol
      List<Alert> allAlerts;
      
      if (_alertService.isNurse) {
        // Las enfermeras solo ven sus alertas
        allAlerts = await _alertService.getMyAlerts();
      } else {
        // Admins y doctores ven todas las alertas
        allAlerts = await _alertService.getAllAlerts();
      }
      
      // Separar alertas pendientes y reconocidas
      _pendingAlerts = allAlerts.where((alert) => !alert.acknowledged).toList();
      _acknowledgedAlerts = allAlerts.where((alert) => alert.acknowledged).toList();
      
      // Cargar datos relacionados
      await _loadRelatedData(allAlerts);
    } catch (e) {
      print('Error al cargar alertas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar alertas: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRelatedData(List<Alert> alerts) async {
    // Obtener pacientes según el rol
    List<Patient> patients;
    if (_alertService.isNurse) {
      patients = await _patientService.getMyPatients();
    } else {
      patients = await _patientService.getAllPatients();
    }
    _patientsMap = {for (var patient in patients) patient.id: patient};
    
    // Obtener tipos de signos vitales
    final vitalTypes = await _vitalService.getAllVitalTypes();
    _vitalTypesMap = {for (var type in vitalTypes) type.id: type};
    
    // Obtener lecturas relacionadas con las alertas
    for (var alert in alerts) {
      try {
        // Intentar obtener las lecturas por ID desde la API
        final readings = await _vitalService.getAllVitalReadings();
        final reading = readings.firstWhere((r) => r.id == alert.readingId, 
                                           orElse: () => VitalReading(
                                             id: alert.readingId,
                                             patientId: 1,
                                             typeId: 1,
                                             value: 0,
                                             timestamp: alert.timestamp
                                           ));
        _readingsMap[reading.id] = reading;
      } catch (e) {
        print('Error al obtener lectura: $e');
      }
    }
  }

  Future<void> _acknowledgeAlert(Alert alert) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('Usuario no autenticado o sin ID válido');
      }

      final success = await _alertService.acknowledgeAlert(
        alert.id, // Ahora es int directamente
        currentUser.id!, // ID del usuario logueado (con null assertion ya que verificamos arriba)
      );
      
      if (success) {
        setState(() {
          _pendingAlerts.remove(alert);
          
          final acknowledgedAlert = Alert(
            id: alert.id,
            readingId: alert.readingId,
            level: alert.level,
            timestamp: alert.timestamp,
            acknowledged: true,
            acknowledgedBy: currentUser.id!,
          );
          _acknowledgedAlerts.add(acknowledgedAlert);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alerta reconocida correctamente')),
          );
        }
      } else {
        throw Exception('No se pudo reconocer la alerta');
      }
    } catch (e) {
      print('Error al reconocer alerta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reconocer alerta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Gestión de Alertas'),
            if (_alertService.isNurse) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Mis Alertas',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Pendientes',
              icon: _pendingAlerts.isNotEmpty 
                  ? Badge(
                      label: Text('${_pendingAlerts.length}'),
                      child: const Icon(Icons.warning),
                    )
                  : const Icon(Icons.warning_outlined),
            ),
            Tab(
              text: 'Historial',
              icon: Icon(Icons.history),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsList(_pendingAlerts, true),
                _buildAlertsList(_acknowledgedAlerts, false),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildAlertsList(List<Alert> alerts, bool showActions) {
    if (alerts.isEmpty) {
      return Center(
        child: Text(
          showActions 
              ? 'No hay alertas pendientes' 
              : 'No hay alertas reconocidas',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final reading = _readingsMap[alert.readingId];
          final vitalType = reading != null ? _vitalTypesMap[reading.typeId] : null;
          final patient = reading != null ? _patientsMap[reading.patientId] : null;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAlertLevelIcon(alert.level),
                      const SizedBox(width: 8),
                      Text(
                        'Alerta ${alert.level.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getAlertColor(alert.level),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(alert.timestamp),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (patient != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Paciente: ${patient.fullName}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  if (vitalType != null && reading != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${vitalType.name}: ${reading.value} ${vitalType.unit}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  if (alert.acknowledged && alert.acknowledgedBy != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Reconocida por: Usuario ID ${alert.acknowledgedBy}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (showActions)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              // Navegar a detalles del paciente si es necesario
                              if (reading != null) {
                                Navigator.pushNamed(
                                  context, 
                                  '/patient_details',
                                  arguments: reading.patientId,
                                );
                              }
                            },
                            child: const Text('Ver Paciente'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _acknowledgeAlert(alert),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getAlertColor(alert.level),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Reconocer'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertLevelIcon(String level) {
    IconData icon;
    Color color = _getAlertColor(level);
    
    switch (level.toLowerCase()) {
      case 'high':
        icon = Icons.arrow_upward;
        break;
      case 'low':
        icon = Icons.arrow_downward;
        break;
      default:
        icon = Icons.warning;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getAlertColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'low':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
} 