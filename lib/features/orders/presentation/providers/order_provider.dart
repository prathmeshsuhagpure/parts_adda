import 'package:flutter/foundation.dart';
import '../../data/order_repository.dart';
import '../../domain/models/order_model.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo;

  OrderProvider({required OrderRepository repo}) : _repo = repo;

  // ── Orders list
  OrderStatus _listStatus = OrderStatus.initial;
  List<OrderModel> _orders = [];

  // ── Single order detail
  OrderStatus _detailStatus = OrderStatus.initial;
  OrderModel? _selectedOrder;

  // ── Tracking
  OrderStatus _trackingStatus = OrderStatus.initial;
  OrderTracking? _tracking;

  // ── Placing order
  bool _isPlacingOrder = false;
  String? _placedOrderId;

  String? _error;

  // ── Getters
  OrderStatus get listStatus => _listStatus;
  List<OrderModel> get orders => _orders;
  OrderStatus get detailStatus => _detailStatus;
  OrderModel? get selectedOrder => _selectedOrder;
  OrderStatus get trackingStatus => _trackingStatus;
  OrderTracking? get tracking => _tracking;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get placedOrderId => _placedOrderId;
  String? get error => _error;

  bool get isListLoading => _listStatus == OrderStatus.loading;
  bool get isDetailLoading => _detailStatus == OrderStatus.loading;
  bool get isTrackingLoading => _trackingStatus == OrderStatus.loading;

  // ─────────────────────────────────────────────────────────
  // Load all orders
  // ─────────────────────────────────────────────────────────
  Future<void> loadOrders({String? statusFilter}) async {
    _listStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repo.getOrders(statusFilter: statusFilter);
      _listStatus = OrderStatus.loaded;
    } catch (e) {
      _listStatus = OrderStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Load single order detail
  // ─────────────────────────────────────────────────────────
  Future<void> loadOrderDetail(String orderId) async {
    _detailStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _selectedOrder = await _repo.getOrderById(orderId);
      _detailStatus = OrderStatus.loaded;
    } catch (e) {
      _detailStatus = OrderStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Load tracking info
  // ─────────────────────────────────────────────────────────
  Future<void> loadTracking(String orderId) async {
    _trackingStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getOrderById(orderId),
        _repo.getTracking(orderId),
      ]);
      _selectedOrder = results[0] as OrderModel;
      _tracking = results[1] as OrderTracking;
      _trackingStatus = OrderStatus.loaded;
    } catch (e) {
      _trackingStatus = OrderStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Place order from cart
  // ─────────────────────────────────────────────────────────
  Future<bool> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? paymentGatewayId,
  }) async {
    _isPlacingOrder = true;
    _placedOrderId = null;
    _error = null;
    notifyListeners();

    try {
      final order = await _repo.placeOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
        paymentGatewayId: paymentGatewayId,
      );
      _placedOrderId = order.id;
      _isPlacingOrder = false;
      // Prepend to list
      _orders.insert(0, order);
      notifyListeners();
      return true;
    } catch (e) {
      _isPlacingOrder = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Cancel order
  // ─────────────────────────────────────────────────────────
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _repo.cancelOrder(orderId);
      // Update local list
      _orders = _orders
          .map((o) => o.id == orderId ? o.copyWith(status: 'cancelled') : o)
          .toList();
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder!.copyWith(status: 'cancelled');
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
