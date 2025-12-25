import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'https://carebridge-szmf.onrender.com';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static const String _qrCodeKey = 'qr_code_id';

  // =====================
  // LOCAL STORAGE
  // =====================

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<void> saveUser(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setString(_tokenKey, token);
    if (user.qrCodeId != null) {
      await prefs.setString(_qrCodeKey, user.qrCodeId!);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getQrCodeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_qrCodeKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_qrCodeKey);
  }

  // =====================
  // LOGIN
  // =====================

  Future<User> login(String email, String password, UserRole role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'role': role.name == 'caregiver' ? 'caretaker' : role.name,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userData = data['user'];

        final user = User.fromJson(userData);
        await saveUser(user, token);
        return user;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Invalid credentials');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // =====================
  // SIGNUP (UPDATED FOR v2.0)
  // =====================

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String gender,
    String? phone,
    int? age,
    String? bloodGroup,
    String? address,
    String? specialization,
    Map<String, dynamic>? emergencyContact,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role.name == 'caregiver' ? 'caretaker' : role.name,
        'gender': gender,
      };

      if (phone != null) body['phone'] = phone;

      // Role-based fields
      if (role == UserRole.patient) {
        body['age'] = age;
        body['bloodGroup'] = bloodGroup;
        if (address != null) body['address'] = address;
        if (emergencyContact != null) body['emergencyContact'] = emergencyContact;
      }

      if (role == UserRole.doctor) {
        body['specialization'] = specialization;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'message': data['msg'] ?? 'User registered successfully',
          'userId': data['userId'],
          'qrCodeId': data['qrCodeId'], // Only for patients
        };
      } else {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  // =====================
  // GET PROFILE (REFRESH USER DATA)
  // =====================

  Future<User?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user']);
        await saveUser(user, token);
        return user;
      } else {
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  /// Get profile with explicit token (for backward compatibility)
  Future<User> getProfileWithToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  // =====================
  // UPDATE PROFILE
  // =====================

  Future<User> updateProfile(String token, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  // =====================
  // HELPERS
  // =====================

  UserRole _parseRole(dynamic roleValue) {
    if (roleValue is String) {
      switch (roleValue.toLowerCase()) {
        case 'patient':
          return UserRole.patient;
        case 'doctor':
          return UserRole.doctor;
        case 'caregiver':
        case 'caretaker':
          return UserRole.caregiver;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.patient;
      }
    }
    return UserRole.patient;
  }
}
