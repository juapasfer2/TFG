import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/models.dart';
import '../services/services.dart';

class SimulateScreen extends StatefulWidget {
  @override
  _SimulateScreenState createState() => _SimulateScreenState();
}

class _SimulateScreenState extends State<SimulateScreen> {
  final PatientService _patientService = PatientService();
  final VitalService _vitalService = VitalService();
  
  List<Patient> _patients = [];
  List<VitalType> _vitalTypes = [];
  
  int _selectedPatientId = 0;
  int _selectedVitalTypeId = 0;
  double _simulatedValue = 0;
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _resultMessage = '';
  bool _showResult = false;
  bool _isSuccess = false;

  final TextEditingController _valueController = TextEditingController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar pacientes
      _patients = _patientService.getMockPatients();
      
      // Cargar tipos de signos vitales
      _vitalTypes = _vitalService.getMockVitalTypes();
      
      // Establecer selecciones por defecto
      if (_patients.isNotEmpty) {
        _selectedPatientId = _patients.first.id;
      }
      
      if (_vitalTypes.isNotEmpty) {
        _selectedVitalTypeId = _vitalTypes.first.id;
        // Obtener valor aleatorio dentro del rango normal
        final selectedType = _vitalTypes.first;
        _simulatedValue = _generateRandomValue(selectedType);
        _valueController.text = _simulatedValue.toString();
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _generateRandomValue(VitalType type) {
    // Generar un valor dentro del rango normal
    double value = type.normalMin + _random.nextDouble() * (type.normalMax - type.normalMin);
    
    // Redondear a 1 decimal
    return double.parse(value.toStringAsFixed(1));
  }

  void _onPatientChanged(int? value) {
    if (value != null) {
      setState(() {
        _selectedPatientId = value;
      });
    }
  }

  void _onVitalTypeChanged(int? value) {
    if (value != null) {
      setState(() {
        _selectedVitalTypeId = value;
        
        // Actualizar el valor simulado
        final selectedType = _vitalTypes.firstWhere((t) => t.id == value);
        _simulatedValue = _generateRandomValue(selectedType);
        _valueController.text = _simulatedValue.toString();
      });
    }
  }

  void _generateRandomValueForType() {
    final selectedType = _vitalTypes.firstWhere((t) => t.id == _selectedVitalTypeId);
    final value = _generateRandomValue(selectedType);
    setState(() {
      _simulatedValue = value;
      _valueController.text = value.toString();
    });
  }

  void _generateAbnormalValue() {
    final selectedType = _vitalTypes.firstWhere((t) => t.id == _selectedVitalTypeId);
    
    // Decidir si generar un valor alto o bajo (50% de probabilidad cada uno)
    bool generateHigh = _random.nextBool();
    double value;
    
    if (generateHigh) {
      // Generar un valor por encima del máximo normal
      value = selectedType.normalMax + _random.nextDouble() * 10;
    } else {
      // Generar un valor por debajo del mínimo normal
      value = selectedType.normalMin - _random.nextDouble() * 10;
      if (value < 0) value = 0; // Evitar valores negativos
    }
    
    // Redondear a 1 decimal
    value = double.parse(value.toStringAsFixed(1));
    
    setState(() {
      _simulatedValue = value;
      _valueController.text = value.toString();
    });
  }

  Future<void> _submitReading() async {
    // Validar valor
    final value = double.tryParse(_valueController.text);
    if (value == null) {
      _showResultMessage('Por favor, ingrese un valor numérico válido.', false);
      return;
    }
    
    // Verificar que se haya seleccionado paciente y tipo de signo vital
    if (_selectedPatientId == 0) {
      _showResultMessage('Por favor, seleccione un paciente.', false);
      return;
    }
    
    if (_selectedVitalTypeId == 0) {
      _showResultMessage('Por favor, seleccione un tipo de signo vital.', false);
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Crear la lectura
      final reading = VitalReading(
        id: 100 + _random.nextInt(1000), // ID simulado
        patientId: _selectedPatientId,
        typeId: _selectedVitalTypeId,
        value: value,
        timestamp: DateTime.now(),
      );
      
      // Enviar la lectura
      final success = await _vitalService.addReading(reading);
      
      if (success) {
        _showResultMessage('Lectura enviada correctamente.', true);
        // Generar un nuevo valor aleatorio
        _generateRandomValueForType();
      } else {
        _showResultMessage('Error al enviar la lectura.', false);
      }
    } catch (e) {
      print('Error al enviar lectura: $e');
      _showResultMessage('Error al enviar la lectura: $e', false);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showResultMessage(String message, bool isSuccess) {
    setState(() {
      _resultMessage = message;
      _showResult = true;
      _isSuccess = isSuccess;
    });
    
    // Ocultar el mensaje después de un tiempo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showResult = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simular Datos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty || _vitalTypes.isEmpty
              ? const Center(child: Text('No hay datos disponibles para simulación'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildSimulationForm(),
                      const SizedBox(height: 24),
                      _buildSubmitSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Simulador de Datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Esta herramienta permite generar datos simulados de signos vitales para probar el sistema. '
              'Seleccione un paciente, un tipo de signo vital y un valor para generar una lectura.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationForm() {
    final selectedType = _vitalTypes
        .firstWhere((t) => t.id == _selectedVitalTypeId, 
        orElse: () => _vitalTypes.first);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de paciente
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Paciente',
                border: OutlineInputBorder(),
              ),
              value: _selectedPatientId,
              items: _patients.map((patient) {
                return DropdownMenuItem<int>(
                  value: patient.id,
                  child: Text(patient.fullName),
                );
              }).toList(),
              onChanged: _onPatientChanged,
            ),
            const SizedBox(height: 16),
            
            // Selector de tipo de signo vital
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Tipo de Signo Vital',
                border: OutlineInputBorder(),
              ),
              value: _selectedVitalTypeId,
              items: _vitalTypes.map((type) {
                return DropdownMenuItem<int>(
                  value: type.id,
                  child: Text('${type.name} (${type.unit})'),
                );
              }).toList(),
              onChanged: _onVitalTypeChanged,
            ),
            const SizedBox(height: 16),
            
            // Campo de valor
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      border: const OutlineInputBorder(),
                      suffixText: selectedType.unit,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _generateRandomValueForType,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _generateAbnormalValue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.warning),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Información de valores normales
            Text(
              'Valores normales: ${selectedType.normalMin} - ${selectedType.normalMax} ${selectedType.unit}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReading,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text('ENVIAR LECTURA'),
        ),
        if (_showResult)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isSuccess ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _resultMessage,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
} 