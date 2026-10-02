import 'package:flutter/material.dart';
import '../models/basket_model.dart';
import '../services/basket_service.dart';

class BasketProvider with ChangeNotifier {
  BasketModel? _basket;
  bool _isLoading = false;
  String? _errorMessage;

  BasketModel? get basket => _basket;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _basket?.totalItemCount ?? 0;
  double get totalAmount => _basket?.totalAmount ?? 0.0;

  Future<void> fetchBasket() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await BasketService.getBasket();
    _isLoading = false;

    if (response.success && response.data != null) {
      _basket = response.data;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> addToBasket(int productId, {int quantity = 1}) async {
    final response = await BasketService.addToBasket(productId, quantity: quantity);
    if (response.success) {
      await fetchBasket();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity(int basketItemId, int quantity) async {
    if (quantity <= 0) {
      return await removeItem(basketItemId);
    }
    final response = await BasketService.updateItemQuantity(basketItemId, quantity);
    if (response.success) {
      await fetchBasket();
      return true;
    }
    return false;
  }

  Future<bool> removeItem(int basketItemId) async {
    final response = await BasketService.removeItem(basketItemId);
    if (response.success) {
      await fetchBasket();
      return true;
    }
    return false;
  }

  void clearLocalBasket() {
    _basket = null;
    notifyListeners();
  }
}
