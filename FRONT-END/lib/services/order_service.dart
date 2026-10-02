import '../constants/api_endpoints.dart';
import '../models/order_model.dart';
import '../models/delivery_model.dart';
import 'api_service.dart';

class OrderService {
  static Future<ApiResponse<Map<String, dynamic>>> checkout({
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.checkout,
      body: {
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
      },
    );

    return ApiResponse(
      success: response.success,
      message: response.message,
      data: response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<List<OrderModel>>> getOrderHistory() async {
    final response = await ApiService.get(ApiEndpoints.consumerOrders);
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data is List ? response.data! as List : (response.data!['orders'] ?? []);
      final orders = list.map((o) => OrderModel.fromJson(o)).toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: orders,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      data: [],
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getOrderTracking(int orderId) async {
    final response = await ApiService.get(ApiEndpoints.orderTracking(orderId));
    if (response.success && response.data != null) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: {
          'order': response.data!['order'] != null ? OrderModel.fromJson(response.data!['order']) : null,
          'delivery': response.data!['delivery'] != null ? DeliveryModel.fromJson(response.data!['delivery']) : null,
        },
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }
}
