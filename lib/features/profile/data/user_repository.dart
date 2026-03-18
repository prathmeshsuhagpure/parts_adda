import 'package:dio/dio.dart';
import 'package:parts_adda/core/api/api_endpoints.dart';
import 'package:parts_adda/features/profile/domain/models/notification_model.dart';
import '../domain/models/address_model.dart';
import '../domain/models/vehicle_model.dart';
import '../../auth/domain/models/user_model.dart';
import '../presentation/screens/notifications_screen.dart';

class UserRepository {
  final Dio dio;

  UserRepository({required this.dio});

  Future<UserModel> getProfile() async {
    try {
      final res = await dio.get(ApiEndpoints.getUserProfile);
      return UserModel.fromJson(res.data['data']['user']);
    } catch (e) {
      throw Exception('Failed to load profile');
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? avatar,
    String? dateOfBirth,
    String? phone,
    String? gender,
  }) async {
    try {
      final res = await dio.put(
        ApiEndpoints.updateProfile,
        data: {
          if (name != null) "name": name,
          if (email != null) "email": email,
          if (avatar != null) "avatar": avatar,
          if (dateOfBirth != null) "dateOfBirth": dateOfBirth,
          if (phone != null) "phone": phone,
          if (gender != null) "gender": gender,
        },
      );

      return UserModel.fromJson(res.data['data']['user']);
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final res = await dio.get(ApiEndpoints.getAddresses);

      return (res.data['data']['addresses'] as List)
          .map((e) => AddressModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load addresses');
    }
  }

  Future<AddressModel> addAddress(Map<String, dynamic> data) async {
    try {
      final res = await dio.post(ApiEndpoints.addAddresses, data: data);

      if (res.data['success'] == true) {
        return AddressModel.fromJson(res.data['data']['address']);
      }

      throw Exception(res.data['message'] ?? 'Failed to add address');
    } catch (e) {
      throw Exception('Failed to add address');
    }
  }

  Future<AddressModel> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await dio.put(ApiEndpoints.updateAddress(id), data: data);

      if (res.data['success'] == true) {
        return AddressModel.fromJson(res.data['data']['address']);
      }

      throw Exception(res.data['message'] ?? 'Failed to update address');
    } catch (e) {
      throw Exception('Failed to update address');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await dio.delete(ApiEndpoints.deleteAddress(id));
    } catch (e) {
      throw Exception('Failed to delete address');
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      await dio.post('/user/addresses/$id/default');
    } catch (e) {
      throw Exception('Failed to set default address');
    }
  }

  Future<List<BrandModel>> getVehicleBrands() async {
    final res = await dio.get(ApiEndpoints.vehicleBrands);

    return (res.data['data'] as List)
        .map((e) => BrandModel.fromJson(e))
        .toList();
  }

  /// GET MODELS BY BRAND
  Future<List<VehicleModel>> getVehicleModels(String brandId) async {
    final res = await dio.get(ApiEndpoints.vehicleModels(brandId));

    print("response: $res");
    return (res.data['data'] as List)
        .map((e) => VehicleModel.fromJson(e))
        .toList();
  }

  /// GET GENERATIONS BY MODEL
  Future<List<GenerationModel>> getVehicleGenerations(String modelId) async {
    final res = await dio.get(ApiEndpoints.vehicleGenerations(modelId));

    return (res.data['data'] as List)
        .map((e) => GenerationModel.fromJson(e))
        .toList();
  }

  /// GET VARIANTS
  Future<List<VariantModel>> getVehicleVariants(String generationId) async {
    final res = await dio.get(ApiEndpoints.vehicleVariants(generationId));

    return (res.data['data'] as List)
        .map((e) => VariantModel.fromJson(e))
        .toList();
  }

  Future<List<UserVehicleModel>> getUserVehicles() async {
    final res = await dio.get(ApiEndpoints.getVehicles);

    return (res.data['data'] as List)
        .map((e) => UserVehicleModel.fromJson(e))
        .toList();
  }

  Future<UserVehicleModel> addVehicle(Map<String, dynamic> data) async {
    final res = await dio.post(ApiEndpoints.addVehicle, data: data);

    return UserVehicleModel.fromJson(res.data['data']['vehicle']);
  }

  Future<void> removeVehicle(String id) async {
    await dio.delete(ApiEndpoints.removeVehicle(id));
  }

  Future<List<dynamic>> getWishlist() async {
    try {
      final res = await dio.get(ApiEndpoints.wishlist);
      return res.data['data']['wishlist'];
    } catch (e) {
      throw Exception('Failed to load wishlist');
    }
  }

  Future<Map<String, dynamic>> toggleWishlist(String partId) async {
    final res = await dio.post(ApiEndpoints.wishlistItem(partId));

    if (res.data['success'] == true) {
      return res.data['data'];
    } else {
      throw Exception("Wishlist operation failed");
    }
  }

  Future<Map<String, dynamic>> addToWishlist(String partId) async {
    try {
      final res = await dio.post(ApiEndpoints.wishlistItem(partId));

      return res.data['part'];
    } catch (e) {
      throw Exception('Failed to add to wishlist');
    }
  }

  Future<void> removeFromWishlist(String partId) async {
    try {
      await dio.delete('/user/wishlist/$partId');
    } catch (e) {
      throw Exception('Failed to remove from wishlist');
    }
  }

  /// GET NOTIFICATIONS
  Future<List<NotificationModel>> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await dio.get(
        ApiEndpoints.notifications,
        queryParameters: {"page": page, "limit": limit},
      );

      final List data = res.data['data'];

      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to load notifications");
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await dio.post(ApiEndpoints.markNotificationRead(id));
    } catch (e) {
      throw Exception("Failed to mark notification as read");
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await dio.post(ApiEndpoints.markAllRead);
    } catch (e) {
      throw Exception("Failed to mark all notifications as read");
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final res = await dio.get(ApiEndpoints.notificationsUnreadCount);

      return res.data['data']['count'] ?? 0;
    } catch (e) {
      throw Exception("Failed to fetch unread count");
    }
  }
}
