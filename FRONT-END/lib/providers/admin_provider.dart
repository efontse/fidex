import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  Map<String, dynamic>? _analytics;
  List<UserModel> _users = [];
  Map<String, dynamic>? _settings;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get analytics => _analytics;
  List<UserModel> get users => _users;
  Map<String, dynamic>? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AdminService.getAnalytics();
    _isLoading = false;

    if (response.success && response.data != null) {
      _analytics = response.data;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AdminService.getUsers();
    _isLoading = false;

    if (response.success && response.data != null) {
      _users = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> updateUser(int userId, {String? role, bool? isActive}) async {
    final response = await AdminService.updateUser(userId, role: role, isActive: isActive);
    if (response.success) {
      await fetchUsers();
      await fetchAnalytics();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    final response = await AdminService.deleteUser(userId);
    if (response.success) {
      await fetchUsers();
      await fetchAnalytics();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> moderateProduct(int productId, bool isApproved) async {
    final response = await AdminService.moderateProduct(productId, isApproved);
    if (response.success) {
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSettings() async {
    final response = await AdminService.getSettings();
    if (response.success && response.data != null) {
      _settings = response.data['settings'] ?? response.data;
      notifyListeners();
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> newSettings) async {
    final response = await AdminService.updateSettings(newSettings);
    if (response.success) {
      await fetchSettings();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }
}
