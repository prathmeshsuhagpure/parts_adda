import 'package:dio/dio.dart';
import 'package:parts_adda/core/api/api_endpoints.dart';
import '../domain/models/address_model.dart';
import '../domain/models/vehicle_model.dart';
import '../../auth/domain/models/user_model.dart';

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
  }) async {
    try {
      final res = await dio.put(
        ApiEndpoints.updateProfile,
        data: {
          if (name != null) "name": name,
          if (email != null) "email": email,
          if (avatar != null) "avatar": avatar,
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

  Future<List<VehicleModel>> getVehicles() async {
    try {
      final res = await dio.get('/user/vehicles');

      return (res.data['vehicles'] as List)
          .map((e) => VehicleModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<VehicleModel> addVehicle(Map<String, dynamic> data) async {
    try {
      final res = await dio.post('/user/vehicles', data: data);

      return VehicleModel.fromJson(res.data['vehicle']);
    } catch (e) {
      throw Exception('Failed to add vehicle');
    }
  }

  Future<void> removeVehicle(String id) async {
    try {
      await dio.delete('/user/vehicles/$id');
    } catch (e) {
      throw Exception('Failed to remove vehicle');
    }
  }

  Future<List<dynamic>> getWishlist() async {
    try {
      final res = await dio.get(ApiEndpoints.wishlist);
      return res.data['wishlist'];
    } catch (e) {
      throw Exception('Failed to load wishlist');
    }
  }

  Future<Map<String, dynamic>> addToWishlist(String partId) async {
    try {
      final res = await dio.post('/user/wishlist', data: {"part_id": partId});

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
}
