import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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
          return MaterialApp.router(
            title: 'CareBridge',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              cardTheme: CardTheme(
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
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/signup';

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        if (isAuthenticated && isAuthRoute) {
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

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // Patient Routes
        GoRoute(
          path: '/patient/home',
          builder: (context, state) => const PatientHomeScreen(),
        ),
        GoRoute(
          path: '/patient/symptom-form',
          builder: (context, state) => const SymptomFormScreen(),
        ),
        GoRoute(
          path: '/patient/care-plan',
          builder: (context, state) => const CarePlanViewScreen(),
        ),
        GoRoute(
          path: '/patient/tasks',
          builder: (context, state) => const DailyTasksScreen(),
        ),

        // Doctor Routes
        GoRoute(
          path: '/doctor/dashboard',
          builder: (context, state) => const DoctorDashboardScreen(),
        ),
        GoRoute(
          path: '/doctor/patient-detail',
          builder: (context, state) {
            final patient = state.extra as PatientSummary;
            return CreateCarePlanScreen(patient: patient);
          },
        ),

        // Caregiver Routes
        GoRoute(
          path: '/caregiver/dashboard',
          builder: (context, state) => const CaregiverDashboardScreen(),
        ),

        // Admin Routes
        GoRoute(
          path: '/admin/panel',
          builder: (context, state) => const AdminPanelScreen(),
        ),
      ],
    );
  }
}

