enum DealerOrderStatus {
  newOrder,
  confirmed,
  processing,
  packed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returnRequested,
  returned,
}

extension DealerOrderStatusX on DealerOrderStatus {
  String get label {
    switch (this) {
      case DealerOrderStatus.newOrder:
        return 'New';
      case DealerOrderStatus.confirmed:
        return 'Confirmed';
      case DealerOrderStatus.processing:
        return 'Processing';
      case DealerOrderStatus.packed:
        return 'Packed';
      case DealerOrderStatus.shipped:
        return 'Shipped';
      case DealerOrderStatus.outForDelivery:
        return 'Out for Delivery';
      case DealerOrderStatus.delivered:
        return 'Delivered';
      case DealerOrderStatus.cancelled:
        return 'Cancelled';
      case DealerOrderStatus.returnRequested:
        return 'Return Requested';
      case DealerOrderStatus.returned:
        return 'Returned';
    }
  }

  String get apiValue => name;

  bool get isActive =>
      this == DealerOrderStatus.newOrder ||
      this == DealerOrderStatus.confirmed ||
      this == DealerOrderStatus.processing ||
      this == DealerOrderStatus.packed;

  bool get canConfirm => this == DealerOrderStatus.newOrder;

  bool get canPack =>
      this == DealerOrderStatus.confirmed ||
      this == DealerOrderStatus.processing;

  bool get canShip => this == DealerOrderStatus.packed;

  bool get canDeliver =>
      this == DealerOrderStatus.shipped ||
      this == DealerOrderStatus.outForDelivery;

  bool get canCancel => isActive;

  bool get canAcceptReturn => this == DealerOrderStatus.returnRequested;

  /// Next logical action label
  String? get nextActionLabel {
    if (canConfirm) return 'Confirm Order';
    if (canPack) return 'Mark as Packed';
    if (canShip) return 'Mark as Shipped';
    if (canDeliver) return 'Mark as Delivered';
    if (canAcceptReturn) return 'Accept Return';
    return null;
  }

  DealerOrderStatus? get nextStatus {
    if (canConfirm) return DealerOrderStatus.confirmed;
    if (canPack) return DealerOrderStatus.packed;
    if (canShip) return DealerOrderStatus.shipped;
    if (canDeliver) return DealerOrderStatus.delivered;
    if (canAcceptReturn) return DealerOrderStatus.returned;
    return null;
  }

  static DealerOrderStatus fromString(String s) =>
      DealerOrderStatus.values.firstWhere(
        (e) => e.apiValue == s,
        orElse: () => DealerOrderStatus.newOrder,
      );
}

// ── Buyer info ────────────────────────────────────────────────

class BuyerInfo {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final bool isB2b;
  final String? businessName;

  const BuyerInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.isB2b = false,
    this.businessName,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> j) => BuyerInfo(
    id: j['id'] as String,
    name: j['name'] as String,
    phone: j['phone'] as String,
    email: j['email'] as String?,
    isB2b: j['isB2b'] as bool? ?? false,
    businessName: j['businessName'] as String?,
  );
}

// ── Delivery address ──────────────────────────────────────────

class DeliveryAddress {
  final String fullName;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;

  const DeliveryAddress({
    required this.fullName,
    required this.phone,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
  });

  String get singleLine => '$line1, $city, $state – $pincode';

  factory DeliveryAddress.fromJson(Map<String, dynamic> j) => DeliveryAddress(
    fullName: j['fullName'] as String,
    phone: j['phone'] as String,
    line1: j['line1'] as String,
    line2: j['line2'] as String?,
    city: j['city'] as String,
    state: j['state'] as String,
    pincode: j['pincode'] as String,
  );
}

// ── Order item ────────────────────────────────────────────────

class DealerOrderItem {
  final String id;
  final String partId;
  final String partName;
  final String partSku;
  final String? partImage;
  final double unitPrice;
  final double? mrp;
  final int quantity;
  final double lineTotal;

  const DealerOrderItem({
    required this.id,
    required this.partId,
    required this.partName,
    required this.partSku,
    this.partImage,
    required this.unitPrice,
    this.mrp,
    required this.quantity,
    required this.lineTotal,
  });

  factory DealerOrderItem.fromJson(Map<String, dynamic> j) => DealerOrderItem(
    id: j['id'] as String,
    partId: j['partId'] as String,
    partName: j['partName'] as String,
    partSku: j['partSku'] as String,
    partImage: j['partImage'] as String?,
    unitPrice: (j['unitPrice'] as num).toDouble(),
    mrp: j['mrp'] != null ? (j['mrp'] as num).toDouble() : null,
    quantity: j['quantity'] as int,
    lineTotal: (j['lineTotal'] as num).toDouble(),
  );
}

// ── Timeline event ────────────────────────────────────────────

class OrderTimelineEvent {
  final String title;
  final String? description;
  final DateTime? timestamp;
  final bool isDone;
  final bool isActive;

  const OrderTimelineEvent({
    required this.title,
    this.description,
    this.timestamp,
    this.isDone = false,
    this.isActive = false,
  });
}

// ── Main dealer order model ───────────────────────────────────

class DealerOrder {
  final String id;
  final String orderNumber;
  final DealerOrderStatus status;
  final BuyerInfo buyer;
  final DeliveryAddress address;
  final List<DealerOrderItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double total;
  final String paymentMethod;
  final bool isPaid;
  final String? trackingNumber;
  final String? courierPartner;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DealerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.buyer,
    required this.address,
    required this.items,
    required this.subtotal,
    this.deliveryCharge = 0,
    this.discount = 0,
    required this.total,
    required this.paymentMethod,
    this.isPaid = false,
    this.trackingNumber,
    this.courierPartner,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalQuantity => items.fold(0, (s, i) => s + i.quantity);

  List<OrderTimelineEvent> get timeline {
    final allSteps = [
      DealerOrderStatus.newOrder,
      DealerOrderStatus.confirmed,
      DealerOrderStatus.packed,
      DealerOrderStatus.shipped,
      DealerOrderStatus.delivered,
    ];
    if (status == DealerOrderStatus.cancelled) {
      return [
        OrderTimelineEvent(
          title: 'Order Placed',
          isDone: true,
          timestamp: createdAt,
        ),
        OrderTimelineEvent(
          title: 'Order Cancelled',
          isActive: true,
          isDone: true,
          description: cancellationReason,
        ),
      ];
    }
    final currentIdx = allSteps.indexOf(status);
    return allSteps.asMap().entries.map((e) {
      final done = e.key < currentIdx;
      final active = e.key == currentIdx;
      return OrderTimelineEvent(
        title: e.value.label,
        isDone: done || active,
        isActive: active,
        timestamp: done || active
            ? createdAt.add(Duration(hours: e.key * 6))
            : null,
      );
    }).toList();
  }

  DealerOrder copyWith({
    DealerOrderStatus? status,
    String? trackingNumber,
    String? courierPartner,
    String? cancellationReason,
  }) => DealerOrder(
    id: id,
    orderNumber: orderNumber,
    status: status ?? this.status,
    buyer: buyer,
    address: address,
    items: items,
    subtotal: subtotal,
    deliveryCharge: deliveryCharge,
    discount: discount,
    total: total,
    paymentMethod: paymentMethod,
    isPaid: isPaid,
    trackingNumber: trackingNumber ?? this.trackingNumber,
    courierPartner: courierPartner ?? this.courierPartner,
    cancellationReason: cancellationReason ?? this.cancellationReason,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  factory DealerOrder.fromJson(Map<String, dynamic> j) => DealerOrder(
    id: j['id'] as String,
    orderNumber: j['orderNumber'] as String,
    status: DealerOrderStatusX.fromString(j['status'] as String),
    buyer: BuyerInfo.fromJson(j['buyer'] as Map<String, dynamic>),
    address: DeliveryAddress.fromJson(j['address'] as Map<String, dynamic>),
    items: (j['items'] as List)
        .map((i) => DealerOrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    subtotal: (j['subtotal'] as num).toDouble(),
    deliveryCharge: (j['deliveryCharge'] as num?)?.toDouble() ?? 0,
    discount: (j['discount'] as num?)?.toDouble() ?? 0,
    total: (j['total'] as num).toDouble(),
    paymentMethod: j['paymentMethod'] as String,
    isPaid: j['isPaid'] as bool? ?? false,
    trackingNumber: j['trackingNumber'] as String?,
    courierPartner: j['courierPartner'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );
}
