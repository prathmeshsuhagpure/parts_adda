import '../../../category/domain/models/category_model.dart';

class PartModel {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final BrandInfo brand;
  final CategoryInfo category;
  final double price;
  final double? mrp;
  final double? b2bPrice;
  final int stock;
  final List<String> images;
  final List<CompatibilityInfo> compatibility;
  final List<SellerListing> sellerListings;
  final double? rating;
  final int reviewCount;
  final int soldCount;
  final bool isActive;
  final String? oemNumber;
  final String? partType;
  final Map<String, dynamic>? specifications;
  final DateTime createdAt;

  PartModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.brand,
    required this.category,
    required this.price,
    this.mrp,
    this.b2bPrice,
    required this.stock,
    this.images = const [],
    this.compatibility = const [],
    this.sellerListings = const [],
    this.rating,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.isActive = true,
    this.oemNumber,
    this.partType,
    this.specifications,
    required this.createdAt,
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      id: json['_id'],
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      brand: json['brand'] != null
          ? BrandInfo.fromJson(json['brand'])
          : BrandInfo(id: json['brandId'] ?? '', name: ''),

      category: json['categoryId'] is Map
          ? CategoryInfo.fromJson(json['categoryId'])
          : CategoryInfo(id: json['categoryId'] ?? '', name: ''),
      price: (json['price'] ?? 0).toDouble(),
      mrp: json['mrp']?.toDouble(),
      b2bPrice: json['b2bPrice']?.toDouble(),
      stock: json['stock'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      compatibility: (json['compatibility'] as List? ?? [])
          .map((e) => CompatibilityInfo.fromJson(e))
          .toList(),
      sellerListings: (json['sellerListings'] as List? ?? [])
          .map((e) => SellerListing.fromJson(e))
          .toList(),
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      soldCount: json['soldCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      oemNumber: json['oemNumber'],
      partType: json['partType'],
      specifications: json['specifications'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "name": name,
      "description": description,
      "brand": brand.toJson(),
      "category": category.toJson(),
      "price": price,
      "mrp": mrp,
      "b2bPrice": b2bPrice,
      "stock": stock,
      "images": images,
      "compatibility": compatibility.map((e) => e.toJson()).toList(),
      "sellerListings": sellerListings.map((e) => e.toJson()).toList(),
      "rating": rating,
      "reviewCount": reviewCount,
      "soldCount": soldCount,
      "isActive": isActive,
      "oemNumber": oemNumber,
      "partType": partType,
      "specifications": specifications,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

class BrandInfo {
  final String id;
  final String name;
  final String? logo;
  final bool isOem;

  BrandInfo({
    required this.id,
    required this.name,
    this.logo,
    this.isOem = false,
  });

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      isOem: json['isOem'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "logo": logo, "isOem": isOem};
  }
}

class CompatibilityInfo {
  final String vehicleId;
  final String make;
  final String model;
  final int yearFrom;
  final int yearTo;
  final String? variant;

  CompatibilityInfo({
    required this.vehicleId,
    required this.make,
    required this.model,
    required this.yearFrom,
    required this.yearTo,
    this.variant,
  });

  factory CompatibilityInfo.fromJson(Map<String, dynamic> json) {
    return CompatibilityInfo(
      vehicleId: json['vehicleId'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      yearFrom: json['yearFrom'] ?? 0,
      yearTo: json['yearTo'] ?? 0,
      variant: json['variant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vehicleId": vehicleId,
      "make": make,
      "model": model,
      "yearFrom": yearFrom,
      "yearTo": yearTo,
      "variant": variant,
    };
  }
}

class SellerListing {
  final String sellerId;
  final String sellerName;
  final double price;
  final double? mrp;
  final int stock;
  final double rating;
  final String? deliveryInfo;
  final bool isFreeDelivery;

  SellerListing({
    required this.sellerId,
    required this.sellerName,
    required this.price,
    this.mrp,
    required this.stock,
    required this.rating,
    this.deliveryInfo,
    this.isFreeDelivery = false,
  });

  factory SellerListing.fromJson(Map<String, dynamic> json) {
    return SellerListing(
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      price: (json['price'] ?? 0).toDouble(),
      mrp: json['mrp']?.toDouble(),
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      deliveryInfo: json['deliveryInfo'],
      isFreeDelivery: json['isFreeDelivery'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sellerId": sellerId,
      "sellerName": sellerName,
      "price": price,
      "mrp": mrp,
      "stock": stock,
      "rating": rating,
      "deliveryInfo": deliveryInfo,
      "isFreeDelivery": isFreeDelivery,
    };
  }
}
