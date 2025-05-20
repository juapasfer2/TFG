import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../widgets/alert_card.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PatientService _patientService = PatientService();
  final AlertService _alertService = AlertService();
  final AuthService _authService = AuthService();
  
  List<Patient> _patients = [];
  List<Alert> _unacknowledgedAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // En modo demo, usando datos ficticios
      _patients = _patientService.getMockPatients();
      _unacknowledgedAlerts = _alertService.getMockAlerts()
          .where((alert) => !alert.acknowledged)
          .toList();
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Monitorización'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Implementar navegación a perfil de usuario
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Cerrar sesión
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nombre del Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'email@ejemplo.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Pacientes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/patients');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alertas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/alerts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurar Umbrales'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/thresholds');
              },
            ),
            if (_authService.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Administrar Usuarios'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin/users');
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlertSection(),
                    const SizedBox(height: 24),
                    _buildPatientSection(),
                    const SizedBox(height: 24),
                    _buildStatisticsSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simular nuevos datos
          Navigator.pushNamed(context, '/simulate');
        },
        tooltip: 'Simular Datos',
        child: const Icon(Icons.add_chart),
      ),
    );
  }

  Widget _buildAlertSection() {
    if (_unacknowledgedAlerts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No hay alertas pendientes',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas Pendientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _unacknowledgedAlerts.length,
          itemBuilder: (context, index) {
            return AlertCard(
              alert: _unacknowledgedAlerts[index],
              onAcknowledge: () {
                // Implementar reconocimiento de alerta
                setState(() {
                  _unacknowledgedAlerts.removeAt(index);
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPatientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pacientes Recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/patients');
              },
              child: const Text('Ver Todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final patient in _patients.take(3))
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(patient.fullName),
              subtitle: Text('ID: ${patient.medicalRecordNumber}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/patient_details',
                  arguments: patient.id,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas Generales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Lun');
                        case 2:
                          return const Text('Mié');
                        case 4:
                          return const Text('Vie');
                        case 6:
                          return const Text('Dom');
                        default:
                          return const Text('');
                      }
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value % 2 == 0) {
                        return Text(value.toInt().toString());
                      }
                      return const Text('');
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(1, 2),
                    const FlSpot(2, 5),
                    const FlSpot(3, 3.1),
                    const FlSpot(4, 4),
                    const FlSpot(5, 3),
                    const FlSpot(6, 4),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 2),
                    const FlSpot(1, 4),
                    const FlSpot(2, 3),
                    const FlSpot(3, 5),
                    const FlSpot(4, 4.5),
                    const FlSpot(5, 5),
                    const FlSpot(6, 6),
                  ],
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatCard(
              title: 'Total Pacientes',
              value: '45',
              icon: Icons.person,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Alertas Hoy',
              value: '12',
              icon: Icons.warning,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Lecturas Hoy',
              value: '156',
              icon: Icons.insights,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 