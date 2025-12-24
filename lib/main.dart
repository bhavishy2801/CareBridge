import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';

// Models
import 'models/user.dart';
import 'models/patient_summary.dart';

// Screens - Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

// Screens - Patient
import 'screens/patient/patient_home_screen.dart';
import 'screens/patient/symptom_form_screen.dart';
import 'screens/patient/care_plan_view_screen.dart';
import 'screens/patient/daily_tasks_screen.dart';

// Screens - Doctor
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/doctor/create_care_plan_screen.dart';

// Screens - Caregiver
import 'screens/caregiver/caregiver_dashboard_screen.dart';

// Screens - Admin
import 'screens/admin/admin_panel_screen.dart';

// Services
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'CareBridge',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            initialRoute: _getInitialRoute(authProvider),
            routes: _createRoutes(),
            onGenerateRoute: (settings) {
              if (settings.name == '/doctor/patient-detail') {
                final patient = settings.arguments as PatientSummary?;
                if (patient != null) {
                  return MaterialPageRoute(
                    builder: (context) => CreateCarePlanScreen(patient: patient),
                  );
                }
              }
              return null;
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  String _getInitialRoute(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return '/login';
    }

    final user = authProvider.currentUser;
    switch (user?.role) {
      case UserRole.patient:
        return '/patient/home';
      case UserRole.doctor:
        return '/doctor/dashboard';
      case UserRole.caregiver:
        return '/caregiver/dashboard';
      case UserRole.admin:
        return '/admin/panel';
      default:
        return '/login';
    }
  }

  Map<String, WidgetBuilder> _createRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/signup': (context) => const SignupScreen(),
      '/patient/home': (context) => const PatientHomeScreen(),
      '/patient/symptom-form': (context) => const SymptomFormScreen(),
      '/patient/care-plan': (context) => const CarePlanViewScreen(),
      '/patient/tasks': (context) => const DailyTasksScreen(),
      '/doctor/dashboard': (context) => const DoctorDashboardScreen(),
      '/caregiver/dashboard': (context) => const CaregiverDashboardScreen(),
      '/admin/panel': (context) => const AdminPanelScreen(),
    };
  }
}

