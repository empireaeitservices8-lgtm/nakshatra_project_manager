// =============================================================================
//  AuthViewModel — Manages registration, login, forgot password, & user session
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  final TaskManagerApiService _api;

  AuthViewModel({TaskManagerApiService? api})
      : _api = api ?? TaskManagerApiService();

  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ─── Login ──────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      final user = await _api.loginUser(email: email, password: password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _successMessage = "Logged in successfully";
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _handleError(e.message);
      return false;
    } on NetworkException catch (e) {
      _handleError(e.message);
      return false;
    } catch (e) {
      _handleError("An unexpected error occurred during login: $e");
      return false;
    }
  }

  // ─── Register ───────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String role,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      final user = await _api.registerUser(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone,
        role: role,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _successMessage = "Registration successful";
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _handleError(e.message);
      return false;
    } on NetworkException catch (e) {
      _handleError(e.message);
      return false;
    } catch (e) {
      _handleError("An unexpected error occurred during registration: $e");
      return false;
    }
  }

  // ─── Forgot Password ────────────────────────────────────────────────────────
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _api.forgotPassword(email: email);
      _successMessage = result is Map && result.containsKey("message")
          ? result["message"].toString()
          : "Password reset link sent to $email";
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _handleError(e.message);
      return false;
    } on NetworkException catch (e) {
      _handleError(e.message);
      return false;
    } catch (e) {
      _handleError("Failed to request password reset: $e");
      return false;
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────
  void logout() {
    _api.apiService.clearSession();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _clearMessages();
    notifyListeners();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _status = AuthStatus.authenticating;
    }
    notifyListeners();
  }

  void _handleError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _status = AuthStatus.error;
    notifyListeners();
  }
}
