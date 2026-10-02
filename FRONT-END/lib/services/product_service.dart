import '../constants/api_endpoints.dart';
import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  static Future<ApiResponse<List<ProductModel>>> getProducts({
    String? category,
    String? search,
  }) async {
    String url = ApiEndpoints.products;
    final params = <String>[];
    if (category != null && category.isNotEmpty && category != 'All') {
      params.add('category=${Uri.encodeComponent(category)}');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search)}');
    }
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final response = await ApiService.get(url, requiresAuth: false);
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data is List ? response.data : (response.data['products'] ?? []);
      final products = list.map((json) => ProductModel.fromJson(json)).toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: products,
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

  static Future<ApiResponse<List<ProductModel>>> getFarmerProducts() async {
    final response = await ApiService.get(ApiEndpoints.farmerProducts);
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data is List ? response.data : (response.data['products'] ?? []);
      final products = list.map((json) => ProductModel.fromJson(json)).toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: products,
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

  static Future<ApiResponse<ProductModel>> createProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    String? harvestDate,
    required String unit,
    String? imageUrl,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.farmerProducts,
      body: {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category': category,
        if (harvestDate != null) 'harvestDate': harvestDate,
        'unit': unit,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: ProductModel.fromJson(response.data['product'] ?? response.data),
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<ProductModel>> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    String? harvestDate,
    required String unit,
    String? imageUrl,
  }) async {
    final response = await ApiService.put(
      ApiEndpoints.updateProduct(id),
      body: {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category': category,
        if (harvestDate != null) 'harvestDate': harvestDate,
        'unit': unit,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: ProductModel.fromJson(response.data['product'] ?? response.data),
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<dynamic>> deleteProduct(int productId) async {
    return await ApiService.delete(ApiEndpoints.deleteProduct(productId));
  }

  static Future<ApiResponse<dynamic>> updateStock(int productId, int quantity) async {
    return await ApiService.patch(
      ApiEndpoints.updateStock(productId),
      body: {'quantity': quantity},
    );
  }
}
