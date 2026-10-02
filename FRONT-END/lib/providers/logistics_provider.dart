import 'package:flutter/material.dart';
import '../models/delivery_model.dart';
import '../services/logistics_service.dart';

class LogisticsProvider with ChangeNotifier {
  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastActionResult;

  List<DeliveryModel> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastActionResult => _lastActionResult;

  Future<void> fetchDeliveries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await LogisticsService.getDeliveries();
    _isLoading = false;

    if (response.success && response.data != null) {
      _deliveries = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> contactProducer(int deliveryId) async {
    final response = await LogisticsService.contactProducer(deliveryId);
    if (response.success) {
      _lastActionResult = response.message;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> locateConsumer(int deliveryId) async {
    final response = await LogisticsService.locateConsumer(deliveryId);
    if (response.success && response.data != null) {
      _lastActionResult = response.message;
      await fetchDeliveries();
      return response.data is Map<String, dynamic> ? response.data : {'message': response.message};
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStatus(int deliveryId, String status) async {
    final response = await LogisticsService.updateStatus(deliveryId, status);
    if (response.success) {
      await fetchDeliveries();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }
}
