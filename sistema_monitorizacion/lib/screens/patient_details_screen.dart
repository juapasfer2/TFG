import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/services.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailsScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final PatientService _patientService = PatientService();
  final VitalService _vitalService = VitalService();
  
  Patient? _patient;
  List<VitalReading> _readings = [];
  List<VitalType> _vitalTypes = [];
  bool _isLoading = true;
  int _selectedVitalTypeId = 1; // Por defecto, frecuencia cardíaca

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
      // Obtener datos del paciente
      _patient = _patientService.getMockPatients()
          .firstWhere((p) => p.id == widget.patientId);
      
      // Obtener tipos de signos vitales
      _vitalTypes = _vitalService.getMockVitalTypes();
      
      // Obtener lecturas
      _readings = _vitalService.getMockReadings(widget.patientId);
      
      // Establecer el signo vital seleccionado por defecto (si hay tipos disponibles)
      if (_vitalTypes.isNotEmpty) {
        _selectedVitalTypeId = _vitalTypes.first.id;
      }
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
        title: Text(_patient == null 
            ? 'Detalles del Paciente' 
            : _patient!.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navegar a historial completo
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patient == null
              ? const Center(child: Text('Paciente no encontrado'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientInfoCard(),
                        const SizedBox(height: 24),
                        _buildVitalSignsSection(),
                        const SizedBox(height: 24),
                        _buildVitalHistoryChart(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepOrange.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patient!.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_patient!.medicalRecordNumber}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.cake,
                  label: 'Fecha de Nacimiento',
                  value: DateFormat('dd/MM/yyyy').format(_patient!.dateOfBirth),
                ),
                _InfoItem(
                  icon: Icons.calendar_today,
                  label: 'Edad',
                  value: '${DateTime.now().year - _patient!.dateOfBirth.year} años',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignsSection() {
    // Filtrar lecturas por tipo
    final typeReadings = _readings
        .where((reading) => reading.typeId == _selectedVitalTypeId)
        .toList();
    
    // Obtener el tipo de signo vital seleccionado
    final selectedType = _vitalTypes
        .firstWhere((type) => type.id == _selectedVitalTypeId);
    
    // Obtener la lectura más reciente
    final latestReading = typeReadings.isNotEmpty 
        ? typeReadings.first 
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signos Vitales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Selector de tipo de signo vital
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _vitalTypes.map((type) {
              final isSelected = type.id == _selectedVitalTypeId;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(type.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedVitalTypeId = type.id;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        
        // Valor actual
        Card(
          elevation: 2,
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedType.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      latestReading != null
                          ? DateFormat('dd/MM HH:mm').format(latestReading.timestamp)
                          : 'Sin datos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      latestReading != null
                          ? latestReading.value.toString()
                          : '--',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        selectedType.unit,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Normal: ${selectedType.normalMin} - ${selectedType.normalMax} ${selectedType.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalHistoryChart() {
    // Filtrar lecturas por tipo y ordenar por fecha
    final typeReadings = _readings
        .where((reading) => reading.typeId == _selectedVitalTypeId)
        .toList();
    
    if (typeReadings.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No hay datos históricos disponibles'),
        ),
      );
    }
    
    // Obtener el tipo de signo vital seleccionado
    final selectedType = _vitalTypes
        .firstWhere((type) => type.id == _selectedVitalTypeId);

    // Convertir lecturas a puntos para el gráfico
    final spots = typeReadings.map((reading) {
      // Convertir timestamp a valor x (posición en el gráfico)
      final xValue = typeReadings.indexOf(reading).toDouble();
      return FlSpot(xValue, reading.value);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial',
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
                color: Colors.grey.withOpacity(0.2),
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
                      final index = value.toInt();
                      if (index >= 0 && index < typeReadings.length) {
                        return Text(
                          DateFormat('HH:mm').format(typeReadings[index].timestamp),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 20,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
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
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
                // Línea para el valor normal mínimo
                LineChartBarData(
                  spots: List.generate(
                    typeReadings.length,
                    (index) => FlSpot(index.toDouble(), selectedType.normalMin),
                  ),
                  isCurved: false,
                  color: Colors.green.withOpacity(0.5),
                  barWidth: 1,
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                ),
                // Línea para el valor normal máximo
                LineChartBarData(
                  spots: List.generate(
                    typeReadings.length,
                    (index) => FlSpot(index.toDouble(), selectedType.normalMax),
                  ),
                  isCurved: false,
                  color: Colors.red.withOpacity(0.5),
                  barWidth: 1,
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 