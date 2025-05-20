import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Importar pantallas
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patient_details_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/thresholds_screen.dart';
import 'screens/simulate_screen.dart';
import 'screens/admin_users_screen.dart';
import 'services/auth_service.dart';
import 'screens/user_profile_screen.dart';

void main() {
  // No inicializar Firebase aquí para evitar problemas de compilación
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: SistemaMonitorizacion(),
    ),
  );
}

class AppState extends ChangeNotifier {
  // Aquí se podría implementar la lógica de estado de la aplicación
  bool _isDarkMode = false;
  final AuthService _authService = AuthService();

  bool get isDarkMode => _isDarkMode;
  AuthService get authService => _authService;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class SistemaMonitorizacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return MaterialApp(
      title: 'Sistema de Monitorización',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: appState.isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      
      // Definir rutas para la navegación
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/patients': (context) => PatientsScreen(),
        '/alerts': (context) => AlertsScreen(),
        '/thresholds': (context) => ThresholdsScreen(),
        '/simulate': (context) => SimulateScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/admin/users': (context) => AdminUsersScreen(),
      },
      // Manejo de rutas dinámicas (con parámetros)
      onGenerateRoute: (settings) {
        if (settings.name == '/patient_details') {
          final int patientId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => PatientDetailsScreen(patientId: patientId),
          );
        }
        return null;
      },
    );
  }
}