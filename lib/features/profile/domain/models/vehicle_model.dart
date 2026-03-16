/*
class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? fuelType;
  final String? variant;
  final String? registrationNumber;

  const VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.fuelType,
    this.variant,
    this.registrationNumber,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> j) => VehicleModel(
    id: j['_id'],
    make: j['make'],
    model: j['model'],
    year: j['year'],
    fuelType: j['fuelType'],
    variant: j['variant'],
    registrationNumber: j['registrationNumber'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'make': make,
    'model': model,
    'year': year,
    'fuelType': fuelType,
    'variant': variant,
    'registrationNumber': registrationNumber,
  };

  String get displayName => '$make $model ($year)';
}*/

class BrandModel {
  final String id;
  final String name;

  const BrandModel({
    required this.id,
    required this.name,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}

class VehicleModel {
  final String id;
  final String name;
  final String? brandId;

  const VehicleModel({
    required this.id,
    required this.name,
    this.brandId,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id'],
      name: json['name'],
      brandId: json['brandId'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "brandId": brandId,
  };

  String get displayName => name;

}

class GenerationModel {
  final String id;
  final String name;
  final int startYear;
  final int? endYear;
  final String modelId;

  const GenerationModel({
    required this.id,
    required this.name,
    required this.startYear,
    this.endYear,
    required this.modelId,
  });

  factory GenerationModel.fromJson(Map<String, dynamic> json) {
    return GenerationModel(
      id: json['_id'],
      name: json['name'],
      startYear: json['startYear'],
      endYear: json['endYear'],
      modelId: json['model'],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "startYear": startYear,
    "endYear": endYear,
    "model": modelId,
  };
}

class VariantModel {
  final String id;
  final String variantName;
  final int engineCC;
  final String fuelType;
  final String transmission;
  final String trimLevel;
  final String emissionStandard;
  final String generationId;

  const VariantModel({
    required this.id,
    required this.variantName,
    required this.engineCC,
    required this.fuelType,
    required this.transmission,
    required this.trimLevel,
    required this.emissionStandard,
    required this.generationId,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['_id'],
      variantName: json['variantName'],
      engineCC: json['engineCC'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      trimLevel: json['trimLevel'],
      emissionStandard: json['emissionStandard'],
      generationId: json['generation'],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "variantName": variantName,
    "engineCC": engineCC,
    "fuelType": fuelType,
    "transmission": transmission,
    "trimLevel": trimLevel,
    "emissionStandard": emissionStandard,
    "generation": generationId,
  };

  String get displayName => "$variantName • $fuelType • $transmission";
}

class UserVehicleModel {
  final String id;
  final VariantModel variant;
  final String? registrationNumber;

  const UserVehicleModel({
    required this.id,
    required this.variant,
    this.registrationNumber,
  });

  factory UserVehicleModel.fromJson(Map<String, dynamic> json) {
    return UserVehicleModel(
      id: json['_id'],
      variant: VariantModel.fromJson(json['variant']),
      registrationNumber: json['registrationNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "variant": variant.toJson(),
    "registrationNumber": registrationNumber,
  };
}