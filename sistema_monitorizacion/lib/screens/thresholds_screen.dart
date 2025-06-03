import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart' as app_models;
import '../services/services.dart';

class ThresholdsScreen extends StatefulWidget {
  @override
  _ThresholdsScreenState createState() => _ThresholdsScreenState();
}

class _ThresholdsScreenState extends State<ThresholdsScreen> {
  final VitalService _vitalService = VitalService();
  final ThresholdService _thresholdService = ThresholdService();
  
  List<app_models.VitalType> _vitalTypes = [];
  Map<int, app_models.ThresholdResponse> _thresholds = {};
  Map<int, TextEditingController> _minControllers = {};
  Map<int, TextEditingController> _maxControllers = {};
  
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Limpiar controladores
    for (final controller in _minControllers.values) {
      controller.dispose();
    }
    for (final controller in _maxControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar tipos de signos vitales
      _vitalTypes = await _vitalService.getAllVitalTypes();
      
      // Cargar umbrales desde la API
      final thresholds = await _thresholdService.getAllThresholds();
      for (final threshold in thresholds) {
        _thresholds[threshold.typeId] = threshold;
      }
      
      // Inicializar umbrales con valores por defecto si no existen
      for (final type in _vitalTypes) {
        if (!_thresholds.containsKey(type.id)) {
          // Por defecto, usar los rangos normales del tipo
          _thresholds[type.id] = app_models.ThresholdResponse(
            id: 0,
            typeId: type.id,
            typeName: type.name,
            minValue: type.normalMin,
            maxValue: type.normalMax,
            level: 'normal',
            description: 'Rango normal para ${type.name}',
          );
        }
        
        // Crear controladores para cada umbral
        final threshold = _thresholds[type.id]!;
        _minControllers[type.id] = TextEditingController(
          text: threshold.minValue.toString(),
        );
        _maxControllers[type.id] = TextEditingController(
          text: threshold.maxValue.toString(),
        );
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveThresholds() async {
    // Validar cambios
    bool isValid = true;
    String errorMessage = '';
    
    for (final type in _vitalTypes) {
      final minText = _minControllers[type.id]!.text;
      final maxText = _maxControllers[type.id]!.text;
      
      if (minText.isEmpty || maxText.isEmpty) {
        isValid = false;
        errorMessage = 'Los valores de umbrales no pueden estar vacíos';
        break;
      }
      
      final minValue = double.tryParse(minText);
      final maxValue = double.tryParse(maxText);
      
      if (minValue == null || maxValue == null) {
        isValid = false;
        errorMessage = 'Los valores deben ser números válidos';
        break;
      }
      
      if (minValue >= maxValue) {
        isValid = false;
        errorMessage = 'El valor mínimo debe ser menor que el valor máximo';
        break;
      }
    }
    
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }
    
    // Mostrar diálogo de confirmación
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Actualizar umbrales
      for (final type in _vitalTypes) {
        final minValue = double.parse(_minControllers[type.id]!.text);
        final maxValue = double.parse(_maxControllers[type.id]!.text);
        
        final oldThreshold = _thresholds[type.id]!;
        
        // Crear solicitud para actualizar el umbral
        final request = app_models.ThresholdRequest(
          typeId: type.id,
          minValue: minValue,
          maxValue: maxValue,
          level: oldThreshold.level,
          description: oldThreshold.description,
        );
        
        if (oldThreshold.id > 0) {
          // Actualizar umbral existente
          final updated = await _thresholdService.updateThreshold(oldThreshold.id, request);
          if (updated != null) {
            _thresholds[type.id] = updated;
          }
        } else {
          // Crear nuevo umbral
          final created = await _thresholdService.createThreshold(request);
          if (created != null) {
            _thresholds[type.id] = created;
          }
        }
      }
      
      setState(() {
        _hasChanges = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Umbrales guardados correctamente')),
      );
    } catch (e) {
      print('Error al guardar umbrales: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar umbrales: $e')),
      );
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
        title: const Text('Configurar Umbrales'),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveThresholds,
              tooltip: 'Guardar Cambios',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vitalTypes.isEmpty
              ? const Center(child: Text('No hay tipos de signos vitales definidos'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildThresholdsList(),
                      ),
                      if (_hasChanges)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ElevatedButton(
                            onPressed: _saveThresholds,
                            child: const Text('GUARDAR CAMBIOS'),
                          ),
                        ),
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
              'Configuración de Umbrales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los umbrales determinan cuándo se generan alertas. '
              'Si un valor está por debajo del mínimo o por encima del máximo, '
              'se generará una alerta para el personal médico.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdsList() {
    return ListView.builder(
      itemCount: _vitalTypes.length,
      itemBuilder: (context, index) {
        final vitalType = _vitalTypes[index];
        return _buildThresholdItem(vitalType);
      },
    );
  }

  Widget _buildThresholdItem(app_models.VitalType vitalType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForVitalType(vitalType.id),
                  color: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  vitalType.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${vitalType.unit})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThresholdField(
                    'Mínimo',
                    _minControllers[vitalType.id]!,
                    vitalType.unit,
                    vitalType.id,
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildThresholdField(
                    'Máximo',
                    _maxControllers[vitalType.id]!,
                    vitalType.unit,
                    vitalType.id,
                    false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Normal: ${vitalType.normalMin} - ${vitalType.normalMax} ${vitalType.unit}',
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

  Widget _buildThresholdField(
    String label,
    TextEditingController controller,
    String unit,
    int typeId,
    bool isMin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixText: unit,
            suffixStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d*')),
          ],
          onChanged: (value) {
            setState(() {
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }

  IconData _getIconForVitalType(int typeId) {
    switch (typeId) {
      case 1: // Frecuencia Cardíaca
        return Icons.favorite;
      case 2: // Temperatura
        return Icons.thermostat;
      case 3: // Presión Sistólica
      case 4: // Presión Diastólica
        return Icons.speed;
      case 5: // Nivel de Oxígeno
        return Icons.air;
      default:
        return Icons.monitor_heart;
    }
  }
} 