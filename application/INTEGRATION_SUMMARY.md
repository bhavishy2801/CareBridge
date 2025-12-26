# API Integration Summary

## Changes Made

### ✅ 1. Authentication Service ([auth_service.dart](lib/services/auth_service.dart))
- Updated `login()` method to use actual backend API at `https://carebridge-xhnj.onrender.com/auth/login`
- Updated `signup()` method to use actual backend API at `https://carebridge-xhnj.onrender.com/auth/signup`
- Added proper error handling and response parsing
- Handles both `_id` and `id` fields from backend
- Extracts JWT token from response and stores it securely

### ✅ 2. API Service ([api_service.dart](lib/services/api_service.dart))
Implemented all backend endpoints:

#### **Appointments**
- `createAppointment()` - POST /appointments/
- `getDoctorAppointments()` - GET /appointments/doctor
- `getPatientAppointments()` - GET /appointments/patient

#### **Care Plans**
- `createCarePlan()` - POST /careplan/
- `getCarePlans()` - GET /careplan/:patientId

#### **Daily Logs**
- `createDailyLog()` - POST /dailylog/
- `getDailyLogs()` - GET /dailylog/:patientId

#### **Previsit Forms**
- `createPrevisitForm()` - POST /previsit/
- `getPrevisitForm()` - GET /previsit/:appointmentId

#### **Notifications**
- `getNotifications()` - GET /notifications/

#### **Dashboard**
- `getDoctorDashboard()` - GET /dashboard/doctor
- `getPatientDashboard()` - GET /dashboard/patient
- `getCaregiverDashboard()` - GET /dashboard/caregiver

#### **Sync**
- `syncDailyLogs()` - POST /sync/dailylogs

### ✅ 3. New Models Created

#### [appointment.dart](lib/models/appointment.dart)
```dart
class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime date;
  final String? status;
  // ...
}
```

#### [daily_log.dart](lib/models/daily_log.dart)
```dart
class DailyLog {
  final String? id;
  final String carePlanId;
  final DateTime date;
  final bool medicationTaken;
  final bool exerciseDone;
  final int symptomRating;
  // ...
}
```

#### [previsit_form.dart](lib/models/previsit_form.dart)
```dart
class PrevisitForm {
  final String? id;
  final String appointmentId;
  final List<String> symptoms;
  final List<String> reports;
  // ...
}
```

### ✅ 4. Updated Existing Models

#### [patient_summary.dart](lib/models/patient_summary.dart)
- Added `lastAppointmentId` field to link patient summaries with appointments

### ✅ 5. Screen Updates

Updated the following screens to use the new API methods:
- [create_care_plan_screen.dart](lib/screens/doctor/create_care_plan_screen.dart) - Uses new `createCarePlan()` with named parameters
- [daily_tasks_screen.dart](lib/screens/patient/daily_tasks_screen.dart) - Uses `getCarePlans()` instead of `getCarePlan()`
- [patient_home_screen.dart](lib/screens/patient/patient_home_screen.dart) - Uses `getCarePlans()` instead of `getCarePlan()`
- [care_plan_view_screen.dart](lib/screens/patient/care_plan_view_screen.dart) - Uses `getCarePlans()` instead of `getCarePlan()`

## How to Use

### Basic Setup

1. **Login/Signup:**
```dart
final authService = AuthService();
final user = await authService.login('email@example.com', 'password', UserRole.patient);
```

2. **Initialize API Service:**
```dart
final token = await AuthService().getToken();
final apiService = ApiService(authToken: token);
```

3. **Make API Calls:**
```dart
// Get appointments
final appointments = await apiService.getPatientAppointments();

// Create daily log
await apiService.createDailyLog(
  carePlanId: 'plan123',
  date: DateTime.now(),
  medicationTaken: true,
  exerciseDone: true,
  symptomRating: 5,
);
```

## Key Features

✅ **Automatic Token Management**: Auth token is automatically included in all API requests  
✅ **Error Handling**: All methods throw exceptions with descriptive messages  
✅ **Type Safety**: All API responses are parsed into typed Dart models  
✅ **Null Safety**: Proper handling of optional fields from the backend  
✅ **Flexible ID Handling**: Supports both `_id` (MongoDB) and `id` formats  
✅ **Offline Support**: Sync endpoint for uploading queued data  

## Testing Your Integration

1. **Test Authentication:**
   - Try logging in with valid credentials
   - Check if token is saved using `await AuthService().getToken()`

2. **Test API Calls:**
   - Make sure you're authenticated before calling API methods
   - Check for proper error messages if requests fail

3. **Test Error Handling:**
   ```dart
   try {
     await apiService.getPatientAppointments();
   } catch (e) {
     print('Error: $e'); // Will show descriptive error messages
   }
   ```

## Important Notes

- **Base URL**: `https://carebridge-xhnj.onrender.com`
- **Authentication**: JWT token is stored in SharedPreferences
- **Token Header**: Sent as `Authorization: Bearer <token>`
- **Content Type**: All requests use `application/json`
- **Response Codes**: 200/201 for success, 404 for not found, others for errors

## Documentation

See [API_USAGE_GUIDE.md](API_USAGE_GUIDE.md) for comprehensive examples and complete usage documentation.

## Next Steps

1. Test each endpoint with your backend
2. Implement error handling in UI (show user-friendly messages)
3. Add loading indicators during API calls
4. Implement offline queue for daily logs (use sync endpoint)
5. Add retry logic for failed requests
6. Consider implementing a repository pattern for better organization

## Troubleshooting

**Issue**: "Not authenticated" error  
**Solution**: Make sure to login first and pass the token to ApiService

**Issue**: "Failed to parse response"  
**Solution**: Check if backend response format matches the model's fromJson() method

**Issue**: Connection errors  
**Solution**: Ensure device has internet and backend URL is accessible

**Issue**: 401 Unauthorized  
**Solution**: Token may have expired, logout and login again
