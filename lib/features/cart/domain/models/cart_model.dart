class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final String? couponCode;
  final double? couponDiscount;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double gst;
  final double total;
  final DateTime? expiresAt;

  CartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    this.couponCode,
    this.couponDiscount,
    required this.subtotal,
    required this.discount,
    this.deliveryCharge = 0.0,
    required this.gst,
    required this.total,
    this.expiresAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      couponCode: json['couponCode'],
      couponDiscount: json['couponDiscount']?.toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "items": items.map((e) => e.toJson()).toList(),
      "couponCode": couponCode,
      "couponDiscount": couponDiscount,
      "subtotal": subtotal,
      "discount": discount,
      "deliveryCharge": deliveryCharge,
      "gst": gst,
      "total": total,
      "expiresAt": expiresAt?.toIso8601String(),
    };
  }
  CartModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    String? couponCode,
    double? couponDiscount,
    double? subtotal,
    double? discount,
    double? deliveryCharge,
    double? gst,
    double? total,
    DateTime? expiresAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      gst: gst ?? this.gst,
      total: total ?? this.total,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CartItemModel {
  final String id;
  final String partId;
  final String partName;
  final String? partSku;
  final String? partImage;
  final String sellerId;
  final String? sellerName;
  final double price;
  final double? mrp;
  final int quantity;
  final bool isAvailable;

  CartItemModel({
    required this.id,
    required this.partId,
    required this.partName,
    this.partSku,
    this.partImage,
    required this.sellerId,
    this.sellerName,
    required this.price,
    this.mrp,
    required this.quantity,
    this.isAvailable = true,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'],
      partId: json['partId'],
      partName: json['partName'],
      partSku: json['partSku'],
      partImage: json['partImage'],
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      price: (json['price'] ?? 0).toDouble(),
      mrp: json['mrp']?.toDouble(),
      quantity: json['quantity'] ?? 1,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "partId": partId,
      "partName": partName,
      "partSku": partSku,
      "partImage": partImage,
      "sellerId": sellerId,
      "sellerName": sellerName,
      "price": price,
      "mrp": mrp,
      "quantity": quantity,
      "isAvailable": isAvailable,
    };
  }

  CartItemModel copyWith({
    String? id,
    String? partId,
    int? quantity,
    double? price,
    String? partName,
    String? partImage,
    String? partSku,
    double? mrp,
    String? sellerId,
    String? sellerName,
    bool? isAvailable,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      partId: partId ?? this.partId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      partName: partName ?? this.partName,
      partImage: partImage ?? this.partImage,
      partSku: partSku ?? this.partSku,
      mrp: mrp ?? this.mrp,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
