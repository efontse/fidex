import '../constants/api_endpoints.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AdminService {
  static Future<ApiResponse<Map<String, dynamic>>> getAnalytics() async {
    final response = await ApiService.get(ApiEndpoints.adminAnalytics);
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<List<UserModel>>> getUsers() async {
    final response = await ApiService.get(ApiEndpoints.adminUsers);
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data is List ? response.data : (response.data['users'] ?? []);
      final users = list.map((u) => UserModel.fromJson(u)).toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: users,
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

  static Future<ApiResponse<dynamic>> updateUser(int userId, {String? role, bool? isActive}) async {
    return await ApiService.patch(
      ApiEndpoints.adminUser(userId),
      body: {
        if (role != null) 'role': role,
        if (isActive != null) 'isActive': isActive,
      },
    );
  }

  static Future<ApiResponse<dynamic>> deleteUser(int userId) async {
    return await ApiService.delete(ApiEndpoints.adminUser(userId));
  }

  static Future<ApiResponse<dynamic>> moderateProduct(int productId, bool isApproved) async {
    return await ApiService.patch(
      ApiEndpoints.adminModerateProduct(productId),
      body: {'isApproved': isApproved},
    );
  }

  static Future<ApiResponse<dynamic>> getSettings() async {
    return await ApiService.get(ApiEndpoints.adminSettings);
  }

  static Future<ApiResponse<dynamic>> updateSettings(Map<String, dynamic> settings) async {
    return await ApiService.patch(
      ApiEndpoints.adminSettings,
      body: settings,
    );
  }
}
