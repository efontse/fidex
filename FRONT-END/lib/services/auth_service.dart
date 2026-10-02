import '../constants/api_endpoints.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  /**
   * Log in user with email and password
   */
  static Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
    String? farmingField,
    String? companyName,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.login,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
        if (farmingField != null && farmingField.trim().isNotEmpty)
          'farmingField': farmingField.trim(),
        if (companyName != null && companyName.trim().isNotEmpty)
          'companyName': companyName.trim(),
      },
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      final token = response.data['token'];
      if (token != null) {
        await ApiService.saveToken(token);
      }
      return ApiResponse(
        success: true,
        message: response.message,
        data: UserModel.fromJson(response.data['user'] ?? response.data),
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  /**
   * Register a new user with email, password, and role details
   */
  static Future<ApiResponse<UserModel>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? farmingField,
    String? companyName,
    String? phoneNumber,
    String? address,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.register,
      body: {
        'fullName': fullName,
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role,
        if (farmingField != null && farmingField.trim().isNotEmpty)
          'farmingField': farmingField.trim(),
        if (companyName != null && companyName.trim().isNotEmpty)
          'companyName': companyName.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phoneNumber': phoneNumber.trim(),
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
      },
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      final token = response.data['token'];
      if (token != null) {
        await ApiService.saveToken(token);
      }
      return ApiResponse(
        success: true,
        message: response.message,
        data: UserModel.fromJson(response.data['user'] ?? response.data),
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> requestOtp({
    required String phoneNumber,
    String deviceId = 'flutter-mobile-client',
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.requestOtp,
      body: {
        'phoneNumber': phoneNumber,
        'deviceId': deviceId,
      },
      requiresAuth: false,
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

  static Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    String deviceId = 'flutter-mobile-client',
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.verifyOtp,
      body: {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
        'deviceId': deviceId,
      },
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      final token = response.data['token'];
      if (token != null) {
        await ApiService.saveToken(token);
      }
    }

    return ApiResponse(
      success: response.success,
      message: response.message,
      data: response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<UserModel>> getProfile() async {
    final response = await ApiService.get(ApiEndpoints.me);
    if (response.success && response.data != null) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: UserModel.fromJson(response.data['user'] ?? response.data),
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  static Future<void> logout() async {
    await ApiService.clearToken();
  }
}
