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

  String get displayName => '$make $model ($year)';
}