class DriverModel {
  final String id;
  final String? phoneNumber;
  final String? email;
  final String? fullName;
  final String? profileImageUrl;
  final String? vehicleNumber;
  final String? licenseNumber;
  final bool isVerified;
  final bool isOnline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverModel({
    required this.id,
    this.phoneNumber,
    this.email,
    this.fullName,
    this.profileImageUrl,
    this.vehicleNumber,
    this.licenseNumber,
    this.isVerified = false,
    this.isOnline = false,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create DriverModel from JSON
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Method to convert DriverModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // CopyWith method for immutability
  DriverModel copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? fullName,
    String? profileImageUrl,
    String? vehicleNumber,
    String? licenseNumber,
    bool? isVerified,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
