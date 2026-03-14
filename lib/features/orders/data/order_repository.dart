import 'package:dio/dio.dart';
import 'package:parts_adda/core/api/api_endpoints.dart';
import '../domain/models/order_model.dart';

class OrderRepository {
  final Dio dio;

  OrderRepository({required this.dio});

  Future<List<OrderModel>> getOrders({String? statusFilter}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getOrders,
        queryParameters: {if (statusFilter != null) "status": statusFilter},
      );

      return (response.data['data'] as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders');
    }
  }

  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await dio.get(ApiEndpoints.orderById(orderId));

      return OrderModel.fromJson(response.data['data']['order']);
    } catch (e) {
      throw Exception('Failed to load order');
    }
  }

  Future<OrderTracking> getTracking(String orderId) async {
    try {
      final response = await dio.get(ApiEndpoints.orderTrack(orderId));

      return OrderTracking.fromJson(response.data['data']['tracking']);
    } catch (e) {
      throw Exception('Failed to load tracking');
    }
  }

  /// Place order
  Future<OrderModel> placeOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required double subtotal,
    required double discount,
    required double deliveryCharge,
    required double gst,
    required double total,
    String paymentMethod = "online",
    String? couponCode,
    bool isB2B = false,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.placeOrders,
        data: {
          "items": items,
          "shipping_address": shippingAddress,
          "subtotal": subtotal,
          "discount": discount,
          "delivery_charge": deliveryCharge,
          "gst": gst,
          "total": total,
          "paymentMethod": paymentMethod,
          "couponCode": couponCode,
          "isB2B": isB2B,
        },
      );

      return OrderModel.fromJson(response.data['data']['order']);
    } catch (e) {
      throw Exception('Order placement failed');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await dio.post(ApiEndpoints.orderCancel(orderId));
    } catch (e) {
      throw Exception('Failed to cancel order');
    }
  }
}
