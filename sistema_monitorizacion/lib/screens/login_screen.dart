import 'package:flutter/material.dart';
import '../services/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Navegar a la pantalla correspondiente según el rol
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          _errorMessage = 'Credenciales inválidas. Intente nuevamente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo y título
              const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sistema de Monitorización',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              
              // Formulario de login
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              
              // Mensaje de error
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Modo demo (para desarrollo)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Entrar en modo demostración'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 