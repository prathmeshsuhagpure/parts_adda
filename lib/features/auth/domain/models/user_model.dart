enum UserRole { customer, dealer, admin }

enum Gender { male, female, other }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? avatar;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final bool isVerified;
  final B2bProfile? b2bProfile;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.avatar,
    this.gender,
    this.dateOfBirth,
    this.isVerified = false,
    this.b2bProfile,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: UserRole.values.firstWhere(
            (e) => e.name == json['role'],
      ),
      avatar: json['avatar'],
      gender: json['gender'] != null
          ? Gender.values.firstWhere(
            (e) => e.name == json['gender'],
        orElse: () => Gender.other,
      )
          : null,

      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      isVerified: json['isVerified'] ?? false,
      b2bProfile: json['b2bProfile'] != null
          ? B2bProfile.fromJson(json['b2bProfile'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "email": email,
      "role": role.name,
      "avatar": avatar,
      "gender": gender?.name,
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "isVerified": isVerified,
      "b2bProfile": b2bProfile?.toJson(),
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

class B2bProfile {
  final String businessName;
  final String gstNumber;
  final String? panNumber;
  final double creditLimit;
  final double creditUsed;
  final String verificationStatus;

  B2bProfile({
    required this.businessName,
    required this.gstNumber,
    this.panNumber,
    this.creditLimit = 0.0,
    this.creditUsed = 0.0,
    this.verificationStatus = "pending",
  });

  factory B2bProfile.fromJson(Map<String, dynamic> json) {
    return B2bProfile(
      businessName: json['businessName'],
      gstNumber: json['gstNumber'],
      panNumber: json['panNumber'],
      creditLimit: (json['creditLimit'] ?? 0).toDouble(),
      creditUsed: (json['creditUsed'] ?? 0).toDouble(),
      verificationStatus: json['verificationStatus'] ?? "pending",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "businessName": businessName,
      "gstNumber": gstNumber,
      "panNumber": panNumber,
      "creditLimit": creditLimit,
      "creditUsed": creditUsed,
      "verificationStatus": verificationStatus,
    };
  }
}

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthTokenModel(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      user: UserModel.fromJson(data['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "user": user.toJson(),
    };
  }
}