import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/models/user_model.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository({required this.dio});

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio
          .get(ApiEndpoints.me)
          .timeout(const Duration(seconds: 8));

      final body = response.data;

      if (body == null || body['data'] == null) {
        throw Exception("User data missing in response");
      }

      return UserModel.fromJson(body['data']);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<AuthTokenModel> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {"phoneOrEmail": phoneOrEmail, "password": password},
      );

      return AuthTokenModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Login failed');
    }
  }

  Future<AuthTokenModel> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          "name": name,
          "phone": phone,
          "email": email,
          "password": password,
          "role": role,
        },
      );

      return AuthTokenModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Signup failed');
    }
  }

  Future<void> applyForDealer({
    required String businessName,
    required String contactName,
    required String phone,
    required String email,
    required String address,
    required String gstNumber,
    required String panNumber,
    required String city,
    required String state,
    required String pincode,
    required String password,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.applyForDealer,
        data: {
          "shopName": businessName,
          "name": contactName,
          "gstNumber": gstNumber,
          "panNumber": panNumber,
          "phone": phone,
          "email": email,
          "address": address,
          "city": city,
          "state": state,
          "pincode": pincode,
          "password": password,
        },
      );
    } catch (e) {
      throw Exception('B2B application failed');
    }
  }

  Future<String> getDealerStatus() async {
    try {
      final response = await dio
          .get(ApiEndpoints.dealerStatus)
          .timeout(const Duration(seconds: 10));

      final body = response.data;

      if (body == null || body['data'] == null) {
        throw Exception("Dealer status missing in response");
      }

      return body['data']['status'];
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch dealer status: $e');
    }
  }

  Future<void> logout() async {
    try {
      await dio.post(ApiEndpoints.logout);
    } catch (e) {
      throw Exception('Logout failed');
    }
  }

  Future<void> updateFcmToken(String token) async {
    await dio.post(ApiEndpoints.registerFcmToken, data: {"fcmToken": token});
  }
}
