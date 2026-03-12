enum ListingStatus { active, inactive, pending, rejected }

extension ListingStatusLabel on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.inactive:
        return 'Inactive';
      case ListingStatus.pending:
        return 'Pending';
      case ListingStatus.rejected:
        return 'Rejected';
    }
  }

  String get apiValue => name;

  static ListingStatus fromString(String s) => ListingStatus.values.firstWhere(
    (e) => e.name == s,
    orElse: () => ListingStatus.pending,
  );
}

class InventoryItem {
  final String id;
  final String partId; // global part ID in catalog
  final String name;
  final String sku;
  final String brand;
  final String category;
  final String? image;
  final double price;
  final double? mrp;
  final double? b2bPrice;
  final int stock;
  final int soldCount;
  final double? rating;
  final int reviewCount;
  final ListingStatus status;
  final String? oemNumber;
  final String? partType; // 'OEM' | 'aftermarket'
  final String? description;
  final Map<String, String> specifications;
  final List<String> compatibleMakes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.partId,
    required this.name,
    required this.sku,
    required this.brand,
    required this.category,
    this.image,
    required this.price,
    this.mrp,
    this.b2bPrice,
    required this.stock,
    this.soldCount = 0,
    this.rating,
    this.reviewCount = 0,
    required this.status,
    this.oemNumber,
    this.partType,
    this.description,
    this.specifications = const {},
    this.compatibleMakes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
    id: j['id'] as String,
    partId: j['partId'] as String,
    name: j['name'] as String,
    sku: j['sku'] as String,
    brand: j['brand'] as String? ?? '',
    category: j['category'] as String? ?? '',
    image: j['image'] as String?,
    price: (j['price'] as num).toDouble(),
    mrp: j['mrp'] != null ? (j['mrp'] as num).toDouble() : null,
    b2bPrice: j['b2bPrice'] != null ? (j['b2bPrice'] as num).toDouble() : null,
    stock: j['stock'] as int? ?? 0,
    soldCount: j['soldCount'] as int? ?? 0,
    rating: j['rating'] != null ? (j['rating'] as num).toDouble() : null,
    reviewCount: j['reviewCount'] as int? ?? 0,
    status: ListingStatusLabel.fromString(j['status'] as String? ?? 'pending'),
    oemNumber: j['oemNumber'] as String?,
    partType: j['partType'] as String?,
    description: j['description'] as String?,
    specifications:
        (j['specifications'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        {},
    compatibleMakes:
        (j['compatibleMakes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'brand': brand,
    'category': category,
    'price': price,
    'mrp': mrp,
    'b2bPrice': b2bPrice,
    'stock': stock,
    'oemNumber': oemNumber,
    'partType': partType,
    'description': description,
    'specifications': specifications,
    'compatibleMakes': compatibleMakes,
    'status': status.apiValue,
  };

  InventoryItem copyWith({
    String? name,
    String? sku,
    String? brand,
    String? category,
    String? image,
    double? price,
    double? mrp,
    double? b2bPrice,
    int? stock,
    ListingStatus? status,
    String? oemNumber,
    String? partType,
    String? description,
    Map<String, String>? specifications,
    List<String>? compatibleMakes,
  }) => InventoryItem(
    id: id,
    partId: partId,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    brand: brand ?? this.brand,
    category: category ?? this.category,
    image: image ?? this.image,
    price: price ?? this.price,
    mrp: mrp ?? this.mrp,
    b2bPrice: b2bPrice ?? this.b2bPrice,
    stock: stock ?? this.stock,
    soldCount: soldCount,
    rating: rating,
    reviewCount: reviewCount,
    status: status ?? this.status,
    oemNumber: oemNumber ?? this.oemNumber,
    partType: partType ?? this.partType,
    description: description ?? this.description,
    specifications: specifications ?? this.specifications,
    compatibleMakes: compatibleMakes ?? this.compatibleMakes,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
