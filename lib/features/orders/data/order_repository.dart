import 'package:dio/dio.dart';
import '../domain/models/order_model.dart';

class OrderRepository {
  final Dio dio;

  OrderRepository({required this.dio});

  /// Get all orders
  Future<List<OrderModel>> getOrders({String? statusFilter}) async {
    try {
      final response = await dio.get(
        '/orders',
        queryParameters: {
          if (statusFilter != null) "status": statusFilter,
        },
      );

      return (response.data['orders'] as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders');
    }
  }

  /// Get single order
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await dio.get('/orders/$orderId');

      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      throw Exception('Failed to load order');
    }
  }

  /// Get tracking details
  Future<OrderTracking> getTracking(String orderId) async {
    try {
      final response = await dio.get('/orders/$orderId/tracking');

      return OrderTracking.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load tracking');
    }
  }

  /// Place order
  Future<OrderModel> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? paymentGatewayId,
  }) async {
    try {
      final response = await dio.post(
        '/orders',
        data: {
          "address_id": addressId,
          "payment_method": paymentMethod,
          if (paymentGatewayId != null)
            "payment_gateway_id": paymentGatewayId,
        },
      );

      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      throw Exception('Order placement failed');
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await dio.post('/orders/$orderId/cancel');
    } catch (e) {
      throw Exception('Failed to cancel order');
    }
  }
}