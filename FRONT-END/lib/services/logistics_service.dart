import '../constants/api_endpoints.dart';
import '../models/delivery_model.dart';
import 'api_service.dart';

class LogisticsService {
  static Future<ApiResponse<List<DeliveryModel>>> getDeliveries() async {
    final response = await ApiService.get(ApiEndpoints.logisticsDeliveries);
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data is List ? response.data : (response.data['deliveries'] ?? []);
      final deliveries = list.map((d) => DeliveryModel.fromJson(d)).toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: deliveries,
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

  static Future<ApiResponse<dynamic>> contactProducer(int deliveryId) async {
    return await ApiService.post(ApiEndpoints.contactProducer(deliveryId));
  }

  static Future<ApiResponse<dynamic>> locateConsumer(int deliveryId) async {
    return await ApiService.post(ApiEndpoints.locateConsumer(deliveryId));
  }

  static Future<ApiResponse<dynamic>> updateStatus(int deliveryId, String status) async {
    return await ApiService.patch(
      ApiEndpoints.updateDeliveryStatus(deliveryId),
      body: {'status': status},
    );
  }
}
