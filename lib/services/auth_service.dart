import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

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

  Future<User> login(String email, String password, UserRole role) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: '123',
      name: 'Demo User',
      email: email,
      role: role,
    );

    await saveUser(user, 'demo_token_123');
    return user;
  }

  Future<User> signup(String name, String email, String password, UserRole role) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: '123',
      name: name,
      email: email,
      role: role,
    );

    await saveUser(user, 'demo_token_123');
    return user;
  }
}
