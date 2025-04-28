import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/services.dart';

class PatientsScreen extends StatefulWidget {
  @override
  _PatientsScreenState createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _patientService = PatientService();
  
  List<Patient> _patients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // En modo demo, usando datos ficticios
      _patients = _patientService.getMockPatients();
    } catch (e) {
      print('Error al cargar pacientes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    
    final query = _searchQuery.toLowerCase();
    return _patients.where((patient) => 
      patient.fullName.toLowerCase().contains(query) ||
      patient.medicalRecordNumber.toLowerCase().contains(query)
    ).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _patients.isEmpty
                    ? const Center(child: Text('No hay pacientes registrados'))
                    : _filteredPatients.isEmpty
                        ? const Center(child: Text('No se encontraron resultados'))
                        : _buildPatientsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a pantalla para agregar paciente
          //_showAddPatientDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función no implementada en la versión demo')),
          );
        },
        tooltip: 'Agregar Paciente',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar paciente...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildPatientsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return _buildPatientListItem(patient);
      },
    );
  }

  Widget _buildPatientListItem(Patient patient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange.withOpacity(0.1),
          child: const Icon(
            Icons.person,
            color: Colors.deepOrange,
          ),
        ),
        title: Text(patient.fullName),
        subtitle: Text('ID: ${patient.medicalRecordNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(patient.dateOfBirth),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          // Navegar a detalles del paciente
          Navigator.pushNamed(
            context,
            '/patient_details',
            arguments: patient.id,
          );
        },
      ),
    );
  }
  
  // Método para mostrar diálogo de agregar paciente
  // En una versión completa, implementaríamos esta funcionalidad
  /*
  void _showAddPatientDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddPatientForm(
          onPatientAdded: (Patient patient) {
            setState(() {
              _patients.add(patient);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
  */
} 