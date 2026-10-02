import '../constants/api_endpoints.dart';
import '../models/basket_model.dart';
import 'api_service.dart';

class BasketService {
  static Future<ApiResponse<BasketModel>> getBasket() async {
    final response = await ApiService.get(ApiEndpoints.basket);
    if (response.success && response.data != null) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: BasketModel.fromJson(response.data['basket'] ?? response.data),
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<dynamic>> addToBasket(int productId, {int quantity = 1}) async {
    return await ApiService.post(
      ApiEndpoints.basketItems,
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  static Future<ApiResponse<dynamic>> updateItemQuantity(int basketItemId, int quantity) async {
    return await ApiService.patch(
      ApiEndpoints.basketItem(basketItemId),
      body: {'quantity': quantity},
    );
  }

  static Future<ApiResponse<dynamic>> removeItem(int basketItemId) async {
    return await ApiService.delete(ApiEndpoints.basketItem(basketItemId));
  }
}
