import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/delivery_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  OrderModel? _currentOrder;
  DeliveryModel? _currentDelivery;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderModel? get currentOrder => _currentOrder;
  DeliveryModel? get currentDelivery => _currentDelivery;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await OrderService.getOrderHistory();
    _isLoading = false;

    if (response.success && response.data != null) {
      _orders = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> checkout({
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await OrderService.checkout(
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      await fetchOrders();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchTracking(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await OrderService.getOrderTracking(orderId);
    _isLoading = false;

    if (response.success && response.data != null) {
      _currentOrder = response.data!['order'];
      _currentDelivery = response.data!['delivery'];
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }
}
