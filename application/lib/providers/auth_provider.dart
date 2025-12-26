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
  bool get isAuthenticated => _token != null;

  /// Load user + token on app start
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    if (debugMode) {
      _currentUser = User(
        id: 'debug-user-123',
        name: 'Debug User',
        email: 'debug@test.com',
        role: UserRole.patient,
      );
      _token = 'debug-token';
    } else {
      _currentUser = await _authService.getCurrentUser();
      _token = await _authService.getToken();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// LOGIN
  Future<void> login(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password, role);
      _token = await _authService.getToken();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// SIGNUP (UPDATED – ROLE AWARE)
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
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        password: password,
        role: role,
        gender: gender,
        age: age,
        bloodGroup: bloodGroup,
        specialization: specialization,
      );

      // Signup does NOT auto-login
      return result['message'] ?? 'User registered successfully';
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  /// REFRESH USER DATA (fetch updated profile from server)
  Future<void> refreshUser() async {
    if (_token == null) return;
    
    try {
      final updatedUser = await _authService.getProfile();
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail - user data is still cached
      debugPrint('Failed to refresh user: $e');
    }
  }

  /// Update local user with new associations
  void updateUserAssociations({
    List<AssociatedDoctor>? doctors,
    List<AssociatedPatient>? patients,
  }) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      associatedDoctors: doctors ?? _currentUser!.associatedDoctors,
      associatedPatients: patients ?? _currentUser!.associatedPatients,
    );
    notifyListeners();
  }
}
