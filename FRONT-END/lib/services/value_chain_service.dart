import '../constants/api_endpoints.dart';
import '../models/value_chain_model.dart';
import 'api_service.dart';

class ValueChainService {
  static Future<ApiResponse<List<ValueChainModel>>> getEvents({int? productId}) async {
    final url = productId != null
        ? ApiEndpoints.productValueChain(productId)
        : ApiEndpoints.valueChain;

    final response = await ApiService.get(url);
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data is List ? response.data : (response.data['events'] ?? []);
      final events = list.map((e) => ValueChainModel.fromJson(e)).toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: events,
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

  static Future<ApiResponse<ValueChainModel>> addEvent({
    int? productId,
    required String status,
    String? notes,
    String? timestamp,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.valueChain,
      body: {
        if (productId != null) 'productId': productId,
        'status': status,
        if (notes != null) 'notes': notes,
        if (timestamp != null) 'timestamp': timestamp,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: ValueChainModel.fromJson(response.data['event'] ?? response.data),
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
