import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _pendingPhoneNumber;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingPhoneNumber => _pendingPhoneNumber;
  bool get isAuthenticated => _currentUser != null;

  void setPendingPhoneNumber(String phone) {
    _pendingPhoneNumber = phone;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.getProfile();
      if (response.success && response.data != null) {
        _currentUser = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /**
   * Log in with Email and Password (primary auth)
   */
  Future<bool> login({
    required String email,
    required String password,
    String? farmingField,
    String? companyName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.login(
      email: email,
      password: password,
      farmingField: farmingField,
      companyName: companyName,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _currentUser = response.data;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Invalid email or password';
      notifyListeners();
      return false;
    }
  }

  /**
   * Register with Email, Password, and Role-specific attributes
   */
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? farmingField,
    String? companyName,
    String? phoneNumber,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      farmingField: farmingField,
      companyName: companyName,
      phoneNumber: phoneNumber,
      address: address,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _currentUser = response.data;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Registration failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestOtp(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.requestOtp(phoneNumber: phoneNumber);
    _isLoading = false;

    if (response.success) {
      _pendingPhoneNumber = phoneNumber;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otpCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.verifyOtp(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    if (response.success) {
      if (response.data != null && response.data!['user'] != null) {
        _currentUser = UserModel.fromJson(response.data!['user']);
      } else {
        await checkAuthStatus();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    _pendingPhoneNumber = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
