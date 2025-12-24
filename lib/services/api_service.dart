import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/symptom_report.dart';
import '../models/care_plan.dart';
import '../models/patient_summary.dart';
import '../models/adherence_data.dart';

class ApiService {
  static const String baseUrl = 'https://api.carebridge.com'; // TODO: Update with actual URL

  final String? authToken;

  ApiService({this.authToken});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // Symptom Reports
  Future<void> submitSymptomReport(SymptomReport report) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<SymptomReport>> getSymptomReports(String patientId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // Care Plans
  Future<CarePlan> createCarePlan(CarePlan carePlan) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return carePlan;
  }

  Future<CarePlan?> getCarePlan(String patientId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }

  // Patient Summaries
  Future<List<PatientSummary>> getPatientSummaries(String doctorId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // Adherence Data
  Future<List<AdherenceData>> getAdherenceData(String caregiverId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  Future<void> updateAdherence(String patientId, Map<String, bool> adherence) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Admin
  Future<void> updateClinicSettings(Map<String, dynamic> settings) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> getClinicSettings() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return {};
  }
}
