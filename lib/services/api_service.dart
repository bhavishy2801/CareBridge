import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/symptom_report.dart';
import '../models/care_plan.dart';
import '../models/patient_summary.dart';
import '../models/adherence_data.dart';
import '../models/appointment.dart';
import '../models/daily_log.dart';
import '../models/previsit_form.dart';
import '../models/notification_model.dart';

class ApiService {
  static const String baseUrl = 'https://carebridge-szmf.onrender.com/api';

  final String? authToken;

  ApiService({this.authToken});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // ========== APPOINTMENTS ==========

  /// Create a new appointment (Patient role)
  Future<Appointment> createAppointment({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/'),
        headers: headers,
        body: json.encode({
          'doctorId': doctorId,
          'date': date.toIso8601String(),
        }),
      );

      print('ApiService.createAppointment response status: ${response.statusCode}');
      print('ApiService.createAppointment response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating appointment: $e');
    }
  }

  /// Get all appointments for the authenticated doctor
  Future<List<Appointment>> getDoctorAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/doctor'),
        headers: headers,
      );

      print('ApiService.getDoctorAppointments response status: ${response.statusCode}');
      print('ApiService.getDoctorAppointments response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get doctor appointments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor appointments: $e');
    }
  }

  /// Get all appointments for the authenticated patient
  Future<List<Appointment>> getPatientAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/patient'),
        headers: headers,
      );

      print('ApiService.getPatientAppointments response status: ${response.statusCode}');
      print('ApiService.getPatientAppointments response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get patient appointments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching patient appointments: $e');
    }
  }

  // ========== CARE PLANS ==========

  /// Create a care plan (Doctor role)
  Future<CarePlan> createCarePlan({
    String? appointmentId,
    required String patientId,
    required List<Map<String, dynamic>> medications,
    required List<Map<String, dynamic>> exercises,
    required String instructions,
    required String warningSigns,
    String? pdfUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'patientId': patientId,
        'medications': medications,
        'exercises': exercises,
        'instructions': instructions,
        'warningSigns': warningSigns,
      };

      if (appointmentId != null) body['appointmentId'] = appointmentId;
      if (pdfUrl != null) body['pdfUrl'] = pdfUrl;

      print('Creating care plan with body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/careplan/'),
        headers: headers,
        body: json.encode(body),
      );

      print('Care plan response status: ${response.statusCode}');
      print('Care plan response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CarePlan.fromJson(json.decode(response.body));
      } else {
        final errorBody = response.body;
        throw Exception(
          'Failed to create care plan (${response.statusCode}): $errorBody',
        );
      }
    } catch (e) {
      print('Care plan error: $e');
      rethrow;
    }
  }

  /// Get all care plans for a specific patient
  Future<List<CarePlan>> getCarePlans(String patientId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/careplan/$patientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('CarePlan API Response Status: ${response.statusCode}');
      print('CarePlan API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        // Handle both array and single object responses
        if (data is List) {
          return data.map((e) => CarePlan.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [CarePlan.fromJson(data)];
        }
        return [];
      } else {
        throw Exception('Failed to get care plans: ${response.body}');
      }
    } catch (e) {
      print('CarePlan fetch error: $e');
      rethrow;
    }
  }

  // ========== DAILY LOGS ==========

  /// Create a daily log (Patient role)
  Future<DailyLog> createDailyLog({
    required String carePlanId,
    required DateTime date,
    required bool medicationTaken,
    required bool exerciseDone,
    required int symptomRating,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dailylog/'),
        headers: headers,
        body: json.encode({
          'carePlanId': carePlanId,
          'date': date.toIso8601String(),
          'medicationTaken': medicationTaken,
          'exerciseDone': exerciseDone,
          'symptomRating': symptomRating,
        }),
      );

      print('ApiService.createDailyLog response status: ${response.statusCode}');
      print('ApiService.createDailyLog response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DailyLog.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create daily log: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating daily log: $e');
    }
  }

  /// Get daily logs for a patient (Doctor role)
  Future<List<DailyLog>> getDailyLogs(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dailylog/$patientId'),
        headers: headers,
      );

      print('ApiService.getDailyLogs response status: ${response.statusCode}');
      print('ApiService.getDailyLogs response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DailyLog.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get daily logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching daily logs: $e');
    }
  }

  // ========== PREVISIT FORMS ==========

  /// Create a previsit form (Patient role)
  Future<PrevisitForm> createPrevisitForm({
    required String appointmentId,
    required List<String> symptoms,
    required List<String> reports,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/previsit/'),
        headers: headers,
        body: json.encode({
          'appointmentId': appointmentId,
          'symptoms': symptoms,
          'reports': reports,
        }),
      );

      print('ApiService.createPrevisitForm response status: ${response.statusCode}');
      print('ApiService.createPrevisitForm response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PrevisitForm.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create previsit form: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating previsit form: $e');
    }
  }

  /// Get previsit form for an appointment (Doctor role)
  Future<PrevisitForm?> getPrevisitForm(String appointmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/previsit/$appointmentId'),
        headers: headers,
      );

      print('ApiService.getPrevisitForm response status: ${response.statusCode}');
      print('ApiService.getPrevisitForm response body: ${response.body}');

      if (response.statusCode == 200) {
        return PrevisitForm.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get previsit form: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching previsit form: $e');
    }
  }

  // ========== DASHBOARD ==========

  /// Get dashboard data for doctor
  Future<Map<String, dynamic>> getDoctorDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/doctor'),
        headers: headers,
      );

      print('ApiService.getDoctorDashboard response status: ${response.statusCode}');
      print('ApiService.getDoctorDashboard response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get doctor dashboard: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor dashboard: $e');
    }
  }

  /// Get dashboard data for patient
  Future<Map<String, dynamic>> getPatientDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/patient'),
        headers: headers,
      );

      print('ApiService.getPatientDashboard response status: ${response.statusCode}');
      print('ApiService.getPatientDashboard response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get patient dashboard: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching patient dashboard: $e');
    }
  }

  /// Get dashboard data for caregiver
  Future<Map<String, dynamic>> getCaregiverDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/caregiver'),
        headers: headers,
      );

      print('ApiService.getCaregiverDashboard response status: ${response.statusCode}');
      print('ApiService.getCaregiverDashboard response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get caregiver dashboard: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching caregiver dashboard: $e');
    }
  }

  // ========== SYNC ==========

  /// Sync multiple daily logs
  Future<Map<String, dynamic>> syncDailyLogs(List<DailyLog> logs) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync/dailylogs'),
        headers: headers,
        body: json.encode({'logs': logs.map((log) => log.toJson()).toList()}),
      );

      print('ApiService.syncDailyLogs response status: ${response.statusCode}');
      print('ApiService.syncDailyLogs response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to sync daily logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error syncing daily logs: $e');
    }
  }

  // ========== LEGACY METHODS (kept for compatibility) ==========

  // Symptom Reports
  Future<void> submitSymptomReport(SymptomReport report) async {
    // This can be mapped to previsit form or a separate endpoint if available
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<SymptomReport>> getSymptomReports(String patientId) async {
    // This can be mapped to daily logs or a separate endpoint if available
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // Patient Summaries
  Future<List<PatientSummary>> getPatientSummaries(String doctorId) async {
    // This may need to be implemented based on your backend
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // Adherence Data
  Future<List<AdherenceData>> getAdherenceData(String caregiverId) async {
    // This can be mapped to daily logs
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  Future<void> updateAdherence(
    String patientId,
    Map<String, bool> adherence,
  ) async {
    // This can be mapped to daily logs
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Admin
  Future<void> updateClinicSettings(Map<String, dynamic> settings) async {
    // TODO: Implement if backend supports
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> getClinicSettings() async {
    // TODO: Implement if backend supports
    await Future.delayed(const Duration(milliseconds: 500));
    return {};
  }

  // ========== NOTIFICATIONS ==========

  /// Get all notifications for the authenticated user
  Future<List<AppNotification>> getNotifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Notifications API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => AppNotification.fromJson(json)).toList();
        }
        print('ApiService.getNotifications response status: ${response.statusCode}');
        print('ApiService.getNotifications response body: ${response.body}');
        return [];
      } else {
        throw Exception('Failed to get notifications: ${response.body}');
      }
    } catch (e) {
      debugPrint('Notifications fetch error: $e');
      rethrow;
    }
  }

       

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(
    String token,
    String notificationId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllNotificationsAsRead(String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String token, String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return false;
    }
  }
}
