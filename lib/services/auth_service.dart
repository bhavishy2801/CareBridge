import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'https://carebridge-xhnj.onrender.com';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

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
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
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
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userData = data['user'];

        final user = User(
          id: userData['id'] ?? userData['_id'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? email,
          role: _parseRole(userData['role']),
          gender: userData['gender'],
          age: userData['age'],
          bloodGroup: userData['bloodGroup'],
          specialization: userData['specialization'],
        );

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
  // SIGNUP (UPDATED)
  // =====================

  Future<String> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String gender,
    int? age,
    String? bloodGroup,
    String? specialization,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
        'gender': gender,
      };

      // Role-based fields
      if (role == UserRole.patient) {
        body['age'] = age;
        body['bloodGroup'] = bloodGroup;
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
        return data['msg'] ?? 'User registered successfully';
      } else {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
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
