import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controladores para los campos de edición
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = _authService.currentUser;
      
      // Inicializar controladores con datos actuales
      if (_currentUser != null) {
        _nameController.text = _currentUser!.name;
        _emailController.text = _currentUser!.email;
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    // En una implementación real, aquí guardarías los cambios
    // en una base de datos o mediante una API
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados correctamente (simulado)')),
    );
    
    _toggleEditMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Editar perfil',
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: 'Guardar cambios',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('No hay usuario autenticado'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildUserInfoSection(),
                      const SizedBox(height: 24),
                      _buildSecuritySection(),
                      const SizedBox(height: 24),
                      _buildPreferencesSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.deepOrange.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 16),
          _isEditing
              ? TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  _currentUser!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 8),
          Text(
            _currentUser!.roleId == 1 ? 'Administrador' : 'Enfermera',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Contacto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.email,
              title: 'Correo electrónico',
              value: _currentUser!.email,
              isEditable: true,
              controller: _emailController,
            ),
            const Divider(),
            _buildInfoItem(
              icon: Icons.badge,
              title: 'ID de Usuario',
              value: '#${_currentUser!.id}',
              isEditable: false,
            ),
            const Divider(),
            _buildInfoItem(
              icon: Icons.work,
              title: 'Rol',
              value: _currentUser!.roleId == 1 ? 'Administrador' : 'Enfermera',
              isEditable: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seguridad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Cambiar contraseña'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función no implementada en versión demo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Autenticación de dos factores'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función no implementada en versión demo')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferencias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función no implementada en versión demo')),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Modo oscuro'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función no implementada en versión demo')),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Idioma'),
              subtitle: const Text('Español'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función no implementada en versión demo')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isEditable,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (_isEditing && isEditable)
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
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
