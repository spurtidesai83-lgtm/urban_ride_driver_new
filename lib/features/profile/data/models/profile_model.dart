class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final int totalRides;
  final int dutiesDone;
  final int daysOfDuty;
  final double kmCovered;
  final double overtimeRate; // per hour
  final bool isVerified;
  final String? profileImageUrl;
  final String? vehicleNumber;
  final String? vehicleModel;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.totalRides,
    required this.dutiesDone,
    required this.daysOfDuty,
    required this.kmCovered,
    required this.overtimeRate,
    this.isVerified = false,
    this.profileImageUrl,
    this.vehicleNumber,
    this.vehicleModel,
  });

  ProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    int? totalRides,
    int? dutiesDone,
    int? daysOfDuty,
    double? kmCovered,
    double? overtimeRate,
    bool? isVerified,
    String? profileImageUrl,
    String? vehicleNumber,
    String? vehicleModel,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      totalRides: totalRides ?? this.totalRides,
      dutiesDone: dutiesDone ?? this.dutiesDone,
      daysOfDuty: daysOfDuty ?? this.daysOfDuty,
      kmCovered: kmCovered ?? this.kmCovered,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      isVerified: isVerified ?? this.isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
    );
  }
}
