import 'package:flutter/foundation.dart';
import '../../domain/models/dealer_order_model.dart';

enum DealerOrderLoadStatus { initial, loading, loaded, error }

class DealerOrderProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────
  DealerOrderLoadStatus _status = DealerOrderLoadStatus.initial;
  List<DealerOrder> _orders = [];
  String? _error;
  bool _isActing = false; // true while advancing/cancelling an order

  // ── Filters ───────────────────────────────────────────────
  DealerOrderStatus? _statusFilter;
  String _searchQuery = '';
  String _sortBy = 'newest'; // newest | oldest | totalHigh | totalLow

  // ── Getters ───────────────────────────────────────────────
  DealerOrderLoadStatus get status => _status;

  bool get isLoading => _status == DealerOrderLoadStatus.loading;

  bool get isActing => _isActing;

  String? get error => _error;

  DealerOrderStatus? get statusFilter => _statusFilter;

  String get searchQuery => _searchQuery;

  String get sortBy => _sortBy;

  List<DealerOrder> get orders {
    var list = List<DealerOrder>.from(_orders);
    if (_statusFilter != null) {
      list = list.where((o) => o.status == _statusFilter).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (o) =>
                o.orderNumber.toLowerCase().contains(q) ||
                o.buyer.name.toLowerCase().contains(q) ||
                o.buyer.phone.contains(q) ||
                o.items.any(
                  (i) =>
                      i.partName.toLowerCase().contains(q) ||
                      i.partSku.toLowerCase().contains(q),
                ),
          )
          .toList();
    }
    switch (_sortBy) {
      case 'oldest':
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'totalHigh':
        list.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'totalLow':
        list.sort((a, b) => a.total.compareTo(b.total));
        break;
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  // ── Summary stats ──────────────────────────────────────────
  int get newOrderCount =>
      _orders.where((o) => o.status == DealerOrderStatus.newOrder).length;

  int get pendingCount => _orders.where((o) => o.status.isActive).length;

  int get deliveredCount =>
      _orders.where((o) => o.status == DealerOrderStatus.delivered).length;

  int get returnCount => _orders
      .where(
        (o) =>
            o.status == DealerOrderStatus.returnRequested ||
            o.status == DealerOrderStatus.returned,
      )
      .length;

  double get todayRevenue {
    final today = DateTime.now();
    return _orders
        .where(
          (o) =>
              o.status == DealerOrderStatus.delivered &&
              o.updatedAt.year == today.year &&
              o.updatedAt.month == today.month &&
              o.updatedAt.day == today.day,
        )
        .fold(0.0, (s, o) => s + o.total);
  }

  double get totalRevenue => _orders
      .where((o) => o.status == DealerOrderStatus.delivered)
      .fold(0.0, (s, o) => s + o.total);

  // ── Load orders ───────────────────────────────────────────
  Future<void> loadOrders() async {
    _status = DealerOrderLoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      // TODO: replace with real API: await _api.get('/seller/orders');
      await Future.delayed(const Duration(milliseconds: 900));
      _orders = _mockOrders();
      _status = DealerOrderLoadStatus.loaded;
    } catch (e) {
      _status = DealerOrderLoadStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ── Advance status ────────────────────────────────────────
  Future<bool> advanceStatus(String orderId) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    final order = _orders[idx];
    final next = order.status.nextStatus;
    if (next == null) return false;

    _isActing = true;
    notifyListeners();
    try {
      // TODO: await _api.patch('/seller/orders/$orderId', {'status': next.apiValue});
      await Future.delayed(const Duration(milliseconds: 600));
      _orders[idx] = order.copyWith(status: next);
      _isActing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isActing = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Add tracking info ─────────────────────────────────────
  Future<bool> addTracking(
    String orderId, {
    required String trackingNumber,
    required String courier,
  }) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    _isActing = true;
    notifyListeners();
    try {
      // TODO: await _api.patch('/seller/orders/$orderId', {'trackingNumber': ...});
      await Future.delayed(const Duration(milliseconds: 500));
      _orders[idx] = _orders[idx].copyWith(
        status: DealerOrderStatus.shipped,
        trackingNumber: trackingNumber,
        courierPartner: courier,
      );
      _isActing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isActing = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Cancel order ──────────────────────────────────────────
  Future<bool> cancelOrder(String orderId, String reason) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    _isActing = true;
    notifyListeners();
    try {
      // TODO: await _api.patch('/seller/orders/$orderId/cancel', {'reason': reason});
      await Future.delayed(const Duration(milliseconds: 500));
      _orders[idx] = _orders[idx].copyWith(
        status: DealerOrderStatus.cancelled,
        cancellationReason: reason,
      );
      _isActing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isActing = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Accept return ─────────────────────────────────────────
  Future<bool> acceptReturn(String orderId) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    _isActing = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _orders[idx] = _orders[idx].copyWith(status: DealerOrderStatus.returned);
      _isActing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isActing = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Filter / sort helpers ─────────────────────────────────
  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setStatusFilter(DealerOrderStatus? s) {
    _statusFilter = s;
    notifyListeners();
  }

  void setSortBy(String s) {
    _sortBy = s;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Mock data ─────────────────────────────────────────────
  List<DealerOrder> _mockOrders() {
    final now = DateTime.now();
    final buyer1 = BuyerInfo(
      id: 'u1',
      name: 'Rahul Sharma',
      phone: '9876543210',
      isB2b: false,
    );
    final buyer2 = BuyerInfo(
      id: 'u2',
      name: 'Priya Motors',
      phone: '9123456780',
      isB2b: true,
      businessName: 'Priya Auto Works',
    );
    final buyer3 = BuyerInfo(
      id: 'u3',
      name: 'Amit Verma',
      phone: '9988776655',
      isB2b: false,
    );
    final buyer4 = BuyerInfo(
      id: 'u4',
      name: 'Suresh Garage',
      phone: '9871234560',
      isB2b: true,
      businessName: 'Suresh Auto Repairs',
    );
    final buyer5 = BuyerInfo(
      id: 'u5',
      name: 'Neha Singh',
      phone: '9000123456',
      isB2b: false,
    );

    DeliveryAddress addr(String city) => DeliveryAddress(
      fullName: 'Customer Name',
      phone: '9999999999',
      line1: '123, MG Road',
      city: city,
      state: 'Maharashtra',
      pincode: '411001',
    );

    return [
      DealerOrder(
        id: 'do1',
        orderNumber: 'ORD-2024-0091',
        status: DealerOrderStatus.newOrder,
        buyer: buyer1,
        address: addr('Pune'),
        items: [
          DealerOrderItem(
            id: 'oi1',
            partId: 'p1',
            partName: 'Bosch Wiper Blade 18"',
            partSku: 'BSH-WB18',
            unitPrice: 349,
            mrp: 499,
            quantity: 2,
            lineTotal: 698,
          ),
          DealerOrderItem(
            id: 'oi2',
            partId: 'p4',
            partName: 'NGK Iridium Spark Plug',
            partSku: 'NGK-IX5',
            unitPrice: 420,
            mrp: 550,
            quantity: 4,
            lineTotal: 1680,
          ),
        ],
        subtotal: 2378,
        total: 2378,
        paymentMethod: 'UPI',
        isPaid: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      DealerOrder(
        id: 'do2',
        orderNumber: 'ORD-2024-0090',
        status: DealerOrderStatus.confirmed,
        buyer: buyer2,
        address: addr('Mumbai'),
        items: [
          DealerOrderItem(
            id: 'oi3',
            partId: 'p2',
            partName: 'Mahle Oil Filter OC100',
            partSku: 'MHL-OC100',
            unitPrice: 240,
            mrp: 380,
            quantity: 10,
            lineTotal: 2400,
          ),
        ],
        subtotal: 2400,
        total: 2400,
        paymentMethod: 'Bank Transfer',
        isPaid: true,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      DealerOrder(
        id: 'do3',
        orderNumber: 'ORD-2024-0089',
        status: DealerOrderStatus.packed,
        buyer: buyer3,
        address: addr('Nagpur'),
        items: [
          DealerOrderItem(
            id: 'oi4',
            partId: 'p6',
            partName: 'Lumax LED Headlight H4',
            partSku: 'LMX-H4',
            unitPrice: 1200,
            mrp: 1600,
            quantity: 1,
            lineTotal: 1200,
          ),
        ],
        subtotal: 1200,
        total: 1250,
        deliveryCharge: 50,
        paymentMethod: 'COD',
        isPaid: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 18)),
      ),
      DealerOrder(
        id: 'do4',
        orderNumber: 'ORD-2024-0088',
        status: DealerOrderStatus.shipped,
        buyer: buyer4,
        address: addr('Nashik'),
        items: [
          DealerOrderItem(
            id: 'oi5',
            partId: 'p4',
            partName: 'NGK Iridium Spark Plug',
            partSku: 'NGK-IX5',
            unitPrice: 420,
            mrp: 550,
            quantity: 8,
            lineTotal: 3360,
          ),
          DealerOrderItem(
            id: 'oi6',
            partId: 'p2',
            partName: 'Mahle Oil Filter OC100',
            partSku: 'MHL-OC100',
            unitPrice: 240,
            mrp: 380,
            quantity: 5,
            lineTotal: 1200,
          ),
        ],
        subtotal: 4560,
        total: 4560,
        paymentMethod: 'Bank Transfer',
        isPaid: true,
        trackingNumber: 'SHP1234567890',
        courierPartner: 'Delhivery',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      DealerOrder(
        id: 'do5',
        orderNumber: 'ORD-2024-0087',
        status: DealerOrderStatus.delivered,
        buyer: buyer5,
        address: addr('Pune'),
        items: [
          DealerOrderItem(
            id: 'oi7',
            partId: 'p3',
            partName: 'Exide 45Ah Battery',
            partSku: 'EXD-45L',
            unitPrice: 3499,
            mrp: 4200,
            quantity: 1,
            lineTotal: 3499,
          ),
        ],
        subtotal: 3499,
        total: 3499,
        paymentMethod: 'Card',
        isPaid: true,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      DealerOrder(
        id: 'do6',
        orderNumber: 'ORD-2024-0086',
        status: DealerOrderStatus.returnRequested,
        buyer: buyer1,
        address: addr('Pune'),
        items: [
          DealerOrderItem(
            id: 'oi8',
            partId: 'p5',
            partName: 'Monroe Shock Absorber Front',
            partSku: 'MNR-SA01',
            unitPrice: 2100,
            mrp: 2800,
            quantity: 1,
            lineTotal: 2100,
          ),
        ],
        subtotal: 2100,
        total: 2100,
        paymentMethod: 'UPI',
        isPaid: true,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      DealerOrder(
        id: 'do7',
        orderNumber: 'ORD-2024-0085',
        status: DealerOrderStatus.cancelled,
        buyer: buyer3,
        address: addr('Nagpur'),
        items: [
          DealerOrderItem(
            id: 'oi9',
            partId: 'p6',
            partName: 'Lumax LED Headlight H4',
            partSku: 'LMX-H4',
            unitPrice: 1200,
            mrp: 1600,
            quantity: 2,
            lineTotal: 2400,
          ),
        ],
        subtotal: 2400,
        total: 2400,
        paymentMethod: 'UPI',
        isPaid: false,
        cancellationReason: 'Out of stock',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
