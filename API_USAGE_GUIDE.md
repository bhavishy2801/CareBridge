# API Integration Guide

This document provides examples of how to use the integrated API services in your CareBridge Flutter app.

## Base URL
All endpoints use: `https://carebridge-xhnj.onrender.com`

## Authentication

### Login
```dart
import 'package:care_bridge/services/auth_service.dart';
import 'package:care_bridge/models/user.dart';

final authService = AuthService();

try {
  final user = await authService.login(
    'user@example.com',
    'password123',
    UserRole.patient, // or UserRole.doctor, UserRole.caregiver, UserRole.admin
  );
  
  print('Logged in: ${user.name}');
} catch (e) {
  print('Login failed: $e');
}
```

### Signup
```dart
try {
  final user = await authService.signup(
    'John Doe',
    'john@example.com',
    'password123',
    UserRole.patient,
  );
  
  print('Signed up: ${user.name}');
} catch (e) {
  print('Signup failed: $e');
}
```

### Logout
```dart
await authService.logout();
```

### Get Current User & Token
```dart
final user = await authService.getCurrentUser();
final token = await authService.getToken();
```

## Using API Service

Always initialize ApiService with the auth token:

```dart
import 'package:care_bridge/services/api_service.dart';
import 'package:care_bridge/services/auth_service.dart';

final token = await AuthService().getToken();
final apiService = ApiService(authToken: token);
```

## Appointments

### Create Appointment (Patient)
```dart
import 'package:care_bridge/models/appointment.dart';

try {
  final appointment = await apiService.createAppointment(
    doctorId: 'doctor123',
    date: DateTime.now().add(Duration(days: 7)),
  );
  
  print('Appointment created: ${appointment.id}');
} catch (e) {
  print('Error: $e');
}
```

### Get Doctor's Appointments (Doctor)
```dart
try {
  final appointments = await apiService.getDoctorAppointments();
  
  for (var appointment in appointments) {
    print('Appointment: ${appointment.date} - Patient: ${appointment.patientId}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Get Patient's Appointments (Patient)
```dart
try {
  final appointments = await apiService.getPatientAppointments();
  
  for (var appointment in appointments) {
    print('Appointment: ${appointment.date} - Doctor: ${appointment.doctorId}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Care Plans

### Create Care Plan (Doctor)
```dart
import 'package:care_bridge/models/care_plan.dart';

try {
  final carePlan = await apiService.createCarePlan(
    appointmentId: 'appointment123',
    patientId: 'patient123',
    medications: [
      {
        'name': 'Aspirin',
        'dosage': '100mg',
        'frequency': 'Once daily',
        'instructions': 'Take with food'
      },
    ],
    exercises: [
      {
        'name': 'Walking',
        'duration': '30 minutes',
        'description': 'Light walking in the morning'
      },
    ],
    instructions: [
      'Monitor blood pressure daily',
      'Stay hydrated',
      'Follow up in 2 weeks'
    ],
    warningSigns: ['Severe headache', 'Chest pain'],
    pdfUrl: 'https://example.com/careplan.pdf',
  );
  
  print('Care plan created: ${carePlan.id}');
} catch (e) {
  print('Error: $e');
}
```

### Get Care Plans for Patient
```dart
try {
  final carePlans = await apiService.getCarePlans('patient123');
  
  for (var plan in carePlans) {
    print('Care Plan: ${plan.id}');
    print('Medications: ${plan.medications.length}');
    print('Exercises: ${plan.exercises.length}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Daily Logs

### Create Daily Log (Patient)
```dart
import 'package:care_bridge/models/daily_log.dart';

try {
  final dailyLog = await apiService.createDailyLog(
    carePlanId: 'careplan123',
    date: DateTime.now(),
    medicationTaken: true,
    exerciseDone: true,
    symptomRating: 3, // 0-10 scale
  );
  
  print('Daily log created: ${dailyLog.id}');
} catch (e) {
  print('Error: $e');
}
```

### Get Daily Logs for Patient (Doctor)
```dart
try {
  final logs = await apiService.getDailyLogs('patient123');
  
  for (var log in logs) {
    print('Date: ${log.date}');
    print('Medication taken: ${log.medicationTaken}');
    print('Exercise done: ${log.exerciseDone}');
    print('Symptom rating: ${log.symptomRating}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Previsit Forms

### Create Previsit Form (Patient)
```dart
import 'package:care_bridge/models/previsit_form.dart';

try {
  final previsitForm = await apiService.createPrevisitForm(
    appointmentId: 'appointment123',
    symptoms: [
      'Headache',
      'Fatigue',
      'Dizziness'
    ],
    reports: [
      'url/to/report1.pdf',
      'url/to/report2.jpg'
    ],
  );
  
  print('Previsit form created: ${previsitForm.id}');
} catch (e) {
  print('Error: $e');
}
```

### Get Previsit Form (Doctor)
```dart
try {
  final form = await apiService.getPrevisitForm('appointment123');
  
  if (form != null) {
    print('Symptoms: ${form.symptoms.join(", ")}');
    print('Reports: ${form.reports.length}');
  } else {
    print('No previsit form found');
  }
} catch (e) {
  print('Error: $e');
}
```

## Notifications

### Get User Notifications
```dart
try {
  final notifications = await apiService.getNotifications();
  
  for (var notification in notifications) {
    print('${notification.title}: ${notification.message}');
    print('Read: ${notification.isRead}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Dashboard Data

### Doctor Dashboard
```dart
try {
  final dashboardData = await apiService.getDoctorDashboard();
  
  print('Role: ${dashboardData['role']}');
  print('Message: ${dashboardData['message']}');
  print('User ID: ${dashboardData['userId']}');
} catch (e) {
  print('Error: $e');
}
```

### Patient Dashboard
```dart
try {
  final dashboardData = await apiService.getPatientDashboard();
  
  print('Dashboard data: $dashboardData');
} catch (e) {
  print('Error: $e');
}
```

### Caregiver Dashboard
```dart
try {
  final dashboardData = await apiService.getCaregiverDashboard();
  
  print('Dashboard data: $dashboardData');
} catch (e) {
  print('Error: $e');
}
```

## Sync (Offline Support)

### Sync Multiple Daily Logs
```dart
import 'package:care_bridge/models/daily_log.dart';

final logs = [
  DailyLog(
    carePlanId: 'careplan123',
    date: DateTime.now().subtract(Duration(days: 2)),
    medicationTaken: true,
    exerciseDone: false,
    symptomRating: 4,
    clientId: 'local-id-1',
  ),
  DailyLog(
    carePlanId: 'careplan123',
    date: DateTime.now().subtract(Duration(days: 1)),
    medicationTaken: true,
    exerciseDone: true,
    symptomRating: 3,
    clientId: 'local-id-2',
  ),
];

try {
  final result = await apiService.syncDailyLogs(logs);
  
  print('Synced logs: ${result['count']}');
  print('Message: ${result['message']}');
} catch (e) {
  print('Error: $e');
}
```

## Error Handling

All API methods throw exceptions on failure. Always wrap calls in try-catch blocks:

```dart
try {
  final result = await apiService.someMethod();
  // Handle success
} catch (e) {
  // Handle error
  if (e.toString().contains('401')) {
    // Handle unauthorized - maybe logout and redirect to login
    await authService.logout();
  } else {
    // Show error message to user
    print('Error: $e');
  }
}
```

## Using with Provider Pattern

Example integration with your AuthProvider:

```dart
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  ApiService? _apiService;
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  ApiService get apiService {
    if (_apiService == null) {
      throw Exception('Not authenticated');
    }
    return _apiService!;
  }
  
  Future<void> login(String email, String password, UserRole role) async {
    try {
      _currentUser = await _authService.login(email, password, role);
      final token = await _authService.getToken();
      _apiService = ApiService(authToken: token);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _apiService = null;
    notifyListeners();
  }
}
```

Then use it in widgets:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return ElevatedButton(
      onPressed: () async {
        try {
          final appointments = await authProvider.apiService.getPatientAppointments();
          // Use appointments
        } catch (e) {
          // Handle error
        }
      },
      child: Text('Load Appointments'),
    );
  }
}
```

## Complete Example: Patient Creating Daily Log

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:care_bridge/services/api_service.dart';
import 'package:care_bridge/services/auth_service.dart';
import 'package:care_bridge/providers/auth_provider.dart';

class DailyLogScreen extends StatefulWidget {
  final String carePlanId;
  
  const DailyLogScreen({required this.carePlanId});

  @override
  _DailyLogScreenState createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  bool _medicationTaken = false;
  bool _exerciseDone = false;
  double _symptomRating = 5;
  bool _isLoading = false;

  Future<void> _submitLog() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.apiService.createDailyLog(
        carePlanId: widget.carePlanId,
        date: DateTime.now(),
        medicationTaken: _medicationTaken,
        exerciseDone: _exerciseDone,
        symptomRating: _symptomRating.round(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily log saved successfully!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Log')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CheckboxListTile(
              title: Text('Medication Taken'),
              value: _medicationTaken,
              onChanged: (val) => setState(() => _medicationTaken = val!),
            ),
            CheckboxListTile(
              title: Text('Exercise Done'),
              value: _exerciseDone,
              onChanged: (val) => setState(() => _exerciseDone = val!),
            ),
            Text('Symptom Rating: ${_symptomRating.round()}'),
            Slider(
              value: _symptomRating,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (val) => setState(() => _symptomRating = val),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitLog,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Submit Log'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Notes

1. **Authentication**: Always ensure the user is authenticated before making API calls
2. **Error Handling**: Wrap all API calls in try-catch blocks
3. **Loading States**: Show loading indicators while API calls are in progress
4. **Token Management**: The auth token is automatically included in all API requests
5. **Offline Support**: Use the sync endpoints to handle offline scenarios
6. **Model Validation**: Ensure all required fields are provided when creating/updating resources
