import 'package:dio/dio.dart';
import 'package:parts_adda/core/api/api_endpoints.dart';
import '../../../core/api/api_client.dart';
import '../domain/models/cart_model.dart';

class CartRepository {
  final Dio dio;

  CartRepository({Dio? dio}) : dio = dio ?? ApiClient.instance;

  /// Get cart
  Future<CartModel> getCart() async {
    try {
      final response = await dio.get(ApiEndpoints.cart);

      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']['cart']);
      }

      throw Exception("Invalid response");
    } on DioException catch (e) {
      throw Exception("Error getting cart: ${e.message}");
    }
  }

  /// Add item to cart
  Future<CartModel> addItem({
    required String partId,
    required String sellerId,
    required String partName,
    required String partSku,
    required String? partImage,
    required String sellerName,
    required double price,
    double? mrp,
    int quantity = 1,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.cartItems,
        data: {
          "partId": partId,
          "sellerId": sellerId,
          "quantity": quantity,
          "partName": partName,
          "part_sku": partSku,
          "part_image": partImage,
          "seller_name": sellerName,
          "price": price,
          "mrp": mrp,
        },
      );

      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add item');
    }
  }

  /// Update item quantity
  Future<CartModel> updateItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await dio.put(
        ApiEndpoints.updateCartItem(itemId),
        data: {"quantity": quantity},
      );

      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update item');
    }
  }

  /// Remove item
  Future<CartModel> removeItem({required String itemId}) async {
    try {
      final response = await dio.delete(ApiEndpoints.removeCartItem(itemId));

      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to remove item');
    }
  }

  /// Apply coupon
  Future<CartModel> applyCoupon({required String couponCode}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.cartCoupon,
        data: {"coupon_code": couponCode},
      );

      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Invalid coupon');
    }
  }

  /// Remove coupon
  Future<CartModel> removeCoupon() async {
    try {
      final response = await dio.delete(ApiEndpoints.cartCouponRemove);

      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to remove coupon');
    }
  }
}
