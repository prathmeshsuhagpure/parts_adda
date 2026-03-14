class OrderModel {
  final String id;
  final String status;
  final List<dynamic> items;
  final double total;
  final DateTime createdAt;

  final String? orderNumber;
  final String? paymentMethod;
  final String? paymentStatus;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double gst;
  final bool isB2B;
  final List<Map<String, dynamic>> timeline;

  const OrderModel({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
    this.orderNumber,
    this.paymentMethod,
    this.paymentStatus,
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.deliveryCharge = 0.0,
    this.gst = 0.0,
    this.isB2B = false,
    this.timeline = const [],
  });

  OrderModel copyWith({String? status}) => OrderModel(
    id: id,
    status: status ?? this.status,
    items: items,
    total: total,
    createdAt: createdAt,
    orderNumber: orderNumber,
    paymentMethod: paymentMethod,
    paymentStatus: paymentStatus,
    subtotal: subtotal,
    discount: discount,
    deliveryCharge: deliveryCharge,
    gst: gst,
    isB2B: isB2B,
    timeline: timeline,
  );

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['_id'],
    status: j['status'],
    items: j['items'] ?? [],
    total: (j['total'] ?? 0).toDouble(),
    createdAt: DateTime.parse(j['createdAt']),
    orderNumber: j['orderNumber'] as String?,
    paymentMethod: j['paymentMethod'] as String?,
    paymentStatus: j['paymentStatus'] as String?,
    subtotal: (j['subtotal'] ?? 0).toDouble(),
    discount: (j['discount'] ?? 0).toDouble(),
    deliveryCharge: (j['deliveryCharge'] ?? 0).toDouble(),
    gst: (j['gst'] ?? 0).toDouble(),
    isB2B: j['isB2B'] ?? false,
    timeline:
        (j['timeline'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [],
  );
}

class OrderTracking {
  final List<TrackingEvent> events;
  final String? agentName;
  final String? agentPhone;
  final int? etaMinutes;
  final DateTime? estimatedDelivery;

  const OrderTracking({
    required this.events,
    this.agentName,
    this.agentPhone,
    this.etaMinutes,
    this.estimatedDelivery,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> j) => OrderTracking(
    events: (j['events'] as List? ?? [])
        .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
    agentName: j['agentName'],
    agentPhone: j['agentPhone'],
    etaMinutes: j['etaMinutes'],
    estimatedDelivery: j['estimatedDelivery'] != null
        ? DateTime.parse(j['estimatedDelivery'])
        : null,
  );
}

class TrackingEvent {
  final String title;
  final String? timestamp;
  final String? description;
  final bool isDone;
  final bool isActive;

  const TrackingEvent({
    required this.title,
    this.timestamp,
    this.description,
    this.isDone = false,
    this.isActive = false,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> j) => TrackingEvent(
    title: j['title'],
    timestamp: j['timestamp'],
    description: j['description'],
    isDone: j['isDone'],
    isActive: j['isActive'],
  );
}
