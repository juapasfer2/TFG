import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/services.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final PatientService _patientService = PatientService();
  final AuthService _authService = AuthService();
  final AlertService _alertService = AlertService();
  
  int _totalPatients = 0;
  int _totalAlerts = 0;
  int _totalUsers = 0;
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
      // En modo demo, cargamos datos de prueba
      final patients = _patientService.getMockPatients();
      final alerts = _alertService.getMockAlerts();
      
      setState(() {
        _totalPatients = patients.length;
        _totalAlerts = alerts.length;
        _totalUsers = 5; // Número ficticio para demo
      });
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
        title: const Text('Panel de Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _authService.currentUser?.name ?? 'Administrador',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _authService.currentUser?.email ?? 'admin@ejemplo.com',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Panel Admin'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Gestión de Usuarios'),
              onTap: () {
                Navigator.pop(context);
                // Implementar navegación a gestión de usuarios
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función no implementada en versión demo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración del Sistema'),
              onTap: () {
                Navigator.pop(context);
                // Implementar navegación a configuración
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función no implementada en versión demo')),
                );
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                _authService.logout();
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
                    _buildOverviewSection(),
                    const SizedBox(height: 24),
                    _buildStatisticsSection(),
                    const SizedBox(height: 24),
                    _buildActionSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Sistema',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  title: 'Pacientes',
                  value: _totalPatients.toString(),
                  icon: Icons.person,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Alertas',
                  value: _totalAlerts.toString(),
                  icon: Icons.notifications,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Usuarios',
                  value: _totalUsers.toString(),
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas de Uso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
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
                          if (value % 5 == 0) {
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
                      spots: const [
                        FlSpot(0, 5),
                        FlSpot(1, 8),
                        FlSpot(2, 12),
                        FlSpot(3, 10),
                        FlSpot(4, 15),
                        FlSpot(5, 18),
                        FlSpot(6, 16),
                      ],
                      isCurved: true,
                      color: Colors.deepOrange,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Actividad del sistema por día',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Administrativas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                _buildActionButton(
                  title: 'Crear Usuario',
                  icon: Icons.person_add,
                  color: Colors.blue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función no implementada en versión demo')),
                    );
                  },
                ),
                _buildActionButton(
                  title: 'Gestionar Permisos',
                  icon: Icons.security,
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función no implementada en versión demo')),
                    );
                  },
                ),
                _buildActionButton(
                  title: 'Logs del Sistema',
                  icon: Icons.list_alt,
                  color: Colors.amber,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función no implementada en versión demo')),
                    );
                  },
                ),
                _buildActionButton(
                  title: 'Respaldo',
                  icon: Icons.backup,
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función no implementada en versión demo')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 100,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
