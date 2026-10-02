import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Default Base URL
  // On Web / Desktop / iOS Simulator: http://localhost:5000/api
  // On Android Emulator: http://10.0.2.2:5000/api
  static String baseUrl = kIsWeb
      ? 'http://localhost:5000/api'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:5000/api'
          : 'http://localhost:5000/api');

  // Auth Routes
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/register';
  static String get requestOtp => '$baseUrl/auth/request-otp';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get me => '$baseUrl/auth/me';
  static String get upload => '$baseUrl/upload';

  // Products
  static String get products => '$baseUrl/products';
  static String get farmerProducts => '$baseUrl/farmer/products';
  static String updateProduct(int id) => '$baseUrl/farmer/products/$id';
  static String deleteProduct(int id) => '$baseUrl/farmer/products/$id';
  static String updateStock(int id) => '$baseUrl/products/$id/stock';

  // Value Chain
  static String get valueChain => '$baseUrl/farmer/value-chain';
  static String productValueChain(int id) => '$baseUrl/farmer/value-chain/product/$id';

  // Basket & Orders
  static String get basket => '$baseUrl/basket';
  static String get basketItems => '$baseUrl/basket/items';
  static String basketItem(int id) => '$baseUrl/basket/items/$id';
  static String get checkout => '$baseUrl/checkout';
  static String get consumerOrders => '$baseUrl/orders/history';
  static String orderTracking(int id) => '$baseUrl/orders/$id/tracking';

  // Logistics
  static String get logisticsDeliveries => '$baseUrl/logistician/deliveries';
  static String contactProducer(int id) => '$baseUrl/logistician/deliveries/$id/contact-producer';
  static String locateConsumer(int id) => '$baseUrl/logistician/deliveries/$id/locate-consumer';
  static String updateDeliveryStatus(int id) => '$baseUrl/logistician/deliveries/$id/status';

  // Admin
  static String get adminAnalytics => '$baseUrl/admin/analytics';
  static String get adminUsers => '$baseUrl/admin/users';
  static String adminUser(int id) => '$baseUrl/admin/users/$id';
  static String adminModerateProduct(int id) => '$baseUrl/admin/products/$id/moderate';
  static String get adminSettings => '$baseUrl/admin/settings';

  // Health
  static String get health => '$baseUrl/health';
}
