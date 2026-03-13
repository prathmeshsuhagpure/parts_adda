class OrderModel {
  final String id;
  final String status;
  final List<dynamic> items;
  final double total;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  OrderModel copyWith({String? status}) => OrderModel(
    id: id,
    status: status ?? this.status,
    items: items,
    total: total,
    createdAt: createdAt,
  );

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['_id'],
    status: j['status'],
    items: j['items'] ?? [],
    total: (j['total'] ?? 0).toDouble(),
    createdAt: DateTime.parse(j['createdAt']),
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
    events: (j['events'] ?? []).map((e) => TrackingEvent.fromJson(e)).toList(),
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
