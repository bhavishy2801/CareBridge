import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  // DEBUG MODE: Set to true to skip login
  static const bool debugMode = false;
  
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    if (debugMode) {
      // Mock user for debugging - change role as needed
      _currentUser = User(
        id: 'debug-user-123',
        name: 'Debug User',
        email: 'debug@test.com',
        role: UserRole.patient, // Change to: doctor, patient, caregiver, admin
      );
      _token = 'debug-token';
    } else {
      _currentUser = await _authService.getCurrentUser();
      _token = await _authService.getToken();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password, role);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> signup(String name, String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final message = await _authService.signup(name, email, password, role);
      // Signup successful but user must login separately
      return message;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}
