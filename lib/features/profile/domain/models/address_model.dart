class AddressModel {
  final String id;
  final String label; // 'Home' | 'Work' | 'Other'
  final String fullName;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
    id: j['_id'],
    label: j['label'] ?? 'Home',
    fullName: j['fullName'],
    phone: j['phone'],
    line1: j['line1'],
    line2: j['line2'],
    city: j['city'],
    state: j['state'],
    pincode: j['pincode'],
    isDefault: j['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'label': label,
    'fullName': fullName,
    'phone': phone,
    'line1': line1,
    'line2': line2,
    'city': city,
    'state': state,
    'pincode': pincode,
    'isDefault': isDefault,
  };
}