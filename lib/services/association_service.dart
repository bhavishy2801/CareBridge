import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AssociationService {
  static const String baseUrl = 'https://carebridge-szmf.onrender.com/api';

  final String authToken;

  AssociationService({required this.authToken});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  // =====================
  // SCAN QR CODE (Doctor/Caretaker)
  // =====================

  Future<Map<String, dynamic>> scanQrCode(String qrCodeId, {String? notes}) async {
    try {
      print('📡 API Request: POST $baseUrl/associations/scan');
      print('📦 Body: {qrCodeId: $qrCodeId${notes != null ? ', notes: $notes' : ''}}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/associations/scan'),
        headers: headers,
        body: json.encode({
          'qrCodeId': qrCodeId,
          if (notes != null) 'notes': notes,
        }),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        final errorMsg = error['msg'] ?? error['message'] ?? 'Failed to scan QR code';
        print('❌ API Error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Exception in scanQrCode: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('QR scan error: $e');
    }
  }

  // =====================
  // GET MY ASSOCIATIONS
  // =====================

  Future<Map<String, dynamic>> getMyAssociations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/associations'),
        headers: headers,
      );

      print('AssociationService.getMyAssociations response status: ${response.statusCode}');
      print('AssociationService.getMyAssociations response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        final msg = error['msg'] ?? error['message'] ?? 'Failed to get associations';
        print('❌ AssociationService.getMyAssociations error: $msg');
        throw Exception(msg);
      }
    } catch (e) {
      print('❌ Exception in getMyAssociations: $e');
      throw Exception('Get associations error: $e');
    }
  }

  // =====================
  // GET PATIENT BY QR CODE (Preview)
  // =====================

  Future<Map<String, dynamic>> getPatientByQr(String qrCodeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/associations/patient/$qrCodeId'),
        headers: headers,
      );

      print('AssociationService.getPatientByQr response status: ${response.statusCode}');
      print('AssociationService.getPatientByQr response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Patient not found');
      }
    } catch (e) {
      print('❌ Exception in getPatientByQr: $e');
      throw Exception('Get patient error: $e');
    }
  }

  // =====================
  // CHECK IF CAN COMMUNICATE
  // =====================

  Future<bool> canCommunicate(String targetUserId, String targetUserType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/associations/can-communicate'),
        headers: headers,
        body: json.encode({
          'targetUserId': targetUserId,
          'targetUserType': targetUserType,
        }),
      );

      print('AssociationService.canCommunicate response status: ${response.statusCode}');
      print('AssociationService.canCommunicate response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['canCommunicate'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Exception in canCommunicate: $e');
      return false;
    }
  }

  // =====================
  // DEACTIVATE ASSOCIATION
  // =====================

  Future<void> deactivateAssociation(String associationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/associations/$associationId/deactivate'),
        headers: headers,
      );

      print('AssociationService.deactivateAssociation response status: ${response.statusCode}');
      print('AssociationService.deactivateAssociation response body: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Failed to deactivate association');
      }
    } catch (e) {
      print('❌ Exception in deactivateAssociation: $e');
      throw Exception('Deactivate association error: $e');
    }
  }

  // =====================
  // UPDATE LAST VISIT (Doctor only)
  // =====================

  Future<void> updateLastVisit(String patientId, {String? diagnosis, String? notes}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/associations/visit/$patientId'),
        headers: headers,
        body: json.encode({
          if (diagnosis != null) 'diagnosis': diagnosis,
          if (notes != null) 'notes': notes,
        }),
      );

      print('AssociationService.updateLastVisit response status: ${response.statusCode}');
      print('AssociationService.updateLastVisit response body: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Failed to update visit');
      }
    } catch (e) {
      print('Exception in updateLastVisit: $e');
      throw Exception('Update visit error: $e');
    }
  }
}
