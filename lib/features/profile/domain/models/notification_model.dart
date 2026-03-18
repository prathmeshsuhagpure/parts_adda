enum NotifType {
  order,
  promo,
  system,
  review,
  payout,
  newOrder,
  lowStock,
  delivery,
  payment;

  static NotifType fromString(String value) {
    return NotifType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => NotifType.system,
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final NotifType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  /// ───────────── JSON → MODEL ─────────────
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: NotifType.fromString(json['type'] ?? 'system'),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      isRead: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// ───────────── MODEL → JSON ─────────────
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "userId": userId,
      "type": type.name,
      "title": title,
      "body": body,
      "data": data,
      "read": isRead,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  /// ───────────── COPY WITH ─────────────
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotifType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}