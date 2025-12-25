# API Endpoints Quick Reference

**Base URL:** `https://carebridge-xhnj.onrender.com`

## Authentication (No token required)

| Method | Endpoint | Body | Returns |
|--------|----------|------|---------|
| POST | `/auth/signup` | `{ name, email, password, role }` | User + Token |
| POST | `/auth/login` | `{ email, password }` | User + Token |

## Appointments (Token required)

| Method | Endpoint | Role | Body | Returns |
|--------|----------|------|------|---------|
| POST | `/appointments/` | Patient | `{ doctorId, date }` | Appointment |
| GET | `/appointments/doctor` | Doctor | - | Appointment[] |
| GET | `/appointments/patient` | Patient | - | Appointment[] |

## Care Plans (Token required)

| Method | Endpoint | Role | Body | Returns |
|--------|----------|------|------|---------|
| POST | `/careplan/` | Doctor | `{ appointmentId, patientId, medications, exercises, instructions, warningSigns?, pdfUrl? }` | CarePlan |
| GET | `/careplan/:patientId` | Any | - | CarePlan[] |

## Daily Logs (Token required)

| Method | Endpoint | Role | Body | Returns |
|--------|----------|------|------|---------|
| POST | `/dailylog/` | Patient | `{ carePlanId, date, medicationTaken, exerciseDone, symptomRating }` | DailyLog |
| GET | `/dailylog/:patientId` | Doctor | - | DailyLog[] |

## Previsit Forms (Token required)

| Method | Endpoint | Role | Body | Returns |
|--------|----------|------|------|---------|
| POST | `/previsit/` | Patient | `{ appointmentId, symptoms, reports }` | PrevisitForm |
| GET | `/previsit/:appointmentId` | Doctor | - | PrevisitForm |

## Notifications (Token required)

| Method | Endpoint | Role | Returns |
|--------|----------|------|---------|
| GET | `/notifications/` | Any | Notification[] |

## Dashboard (Token required)

| Method | Endpoint | Role | Returns |
|--------|----------|------|---------|
| GET | `/dashboard/doctor` | Doctor | `{ role, message, userId }` |
| GET | `/dashboard/patient` | Patient | `{ role, message, userId }` |
| GET | `/dashboard/caregiver` | Caregiver | `{ role, message, userId }` |

## Sync (Token required)

| Method | Endpoint | Body | Returns |
|--------|----------|------|---------|
| POST | `/sync/dailylogs` | `{ logs: [{ carePlanId, date, medicationTaken, exerciseDone, symptomRating, clientId }] }` | `{ message, count }` |

## Flutter Method Reference

### AuthService
```dart
// Login
await authService.login(email, password, role);

// Signup
await authService.signup(name, email, password, role);

// Logout
await authService.logout();

// Get current user
await authService.getCurrentUser();

// Get token
await authService.getToken();
```

### ApiService (requires token)
```dart
final apiService = ApiService(authToken: token);

// Appointments
await apiService.createAppointment(doctorId: id, date: date);
await apiService.getDoctorAppointments();
await apiService.getPatientAppointments();

// Care Plans
await apiService.createCarePlan(appointmentId: id, patientId: id, medications: [], exercises: [], instructions: []);
await apiService.getCarePlans(patientId);

// Daily Logs
await apiService.createDailyLog(carePlanId: id, date: date, medicationTaken: true, exerciseDone: true, symptomRating: 5);
await apiService.getDailyLogs(patientId);

// Previsit Forms
await apiService.createPrevisitForm(appointmentId: id, symptoms: [], reports: []);
await apiService.getPrevisitForm(appointmentId);

// Notifications
await apiService.getNotifications();

// Dashboard
await apiService.getDoctorDashboard();
await apiService.getPatientDashboard();
await apiService.getCaregiverDashboard();

// Sync
await apiService.syncDailyLogs([log1, log2, ...]);
```

## Common Patterns

### Making an authenticated request
```dart
try {
  final token = await AuthService().getToken();
  final apiService = ApiService(authToken: token);
  final result = await apiService.someMethod();
  // Handle success
} catch (e) {
  // Handle error
}
```

### With Provider
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final result = await authProvider.apiService.someMethod();
```

## Response Formats

### User Object
```json
{
  "_id": "string",
  "name": "string",
  "email": "string",
  "role": "patient|doctor|caregiver|admin",
  "phoneNumber": "string?",
  "profileImage": "string?"
}
```

### Appointment Object
```json
{
  "_id": "string",
  "patientId": "string",
  "doctorId": "string",
  "date": "ISO8601 date string",
  "status": "string?",
  "createdAt": "ISO8601 date string",
  "updatedAt": "ISO8601 date string"
}
```

### Care Plan Object
```json
{
  "_id": "string",
  "appointmentId": "string",
  "patientId": "string",
  "medications": [{ "name": "string", "dosage": "string", "frequency": "string", "instructions": "string?" }],
  "exercises": [{ "name": "string", "duration": "string", "description": "string?" }],
  "instructions": ["string"],
  "warningSigns": ["string"],
  "pdfUrl": "string?",
  "createdAt": "ISO8601 date string"
}
```

### Daily Log Object
```json
{
  "_id": "string",
  "carePlanId": "string",
  "date": "ISO8601 date string",
  "medicationTaken": "boolean",
  "exerciseDone": "boolean",
  "symptomRating": "number (0-10)",
  "clientId": "string?",
  "createdAt": "ISO8601 date string"
}
```

### Previsit Form Object
```json
{
  "_id": "string",
  "appointmentId": "string",
  "symptoms": ["string"],
  "reports": ["string"],
  "createdAt": "ISO8601 date string"
}
```

### Notification Object
```json
{
  "_id": "string",
  "userId": "string",
  "type": "reminder|alert|missedTask",
  "title": "string",
  "message": "string",
  "scheduledTime": "ISO8601 date string",
  "isRead": "boolean",
  "data": "object?"
}
```
