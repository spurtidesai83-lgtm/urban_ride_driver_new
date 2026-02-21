// API Profile Response Model - matches backend structure
class ApiProfileResponse {
  final bool success;
  final ApiProfileData data;
  final String message;

  ApiProfileResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ApiProfileResponse.fromJson(Map<String, dynamic> json) {
    return ApiProfileResponse(
      success: json['success'] ?? false,
      data: ApiProfileData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ApiProfileData {
  final String iamUuid;
  final String fullName;
  final int phoneNumber;
  final String? birthDate;
  final String? profilePicture;
  final String role;
  final String department;
  final String division;
  final String depot;
  final String designation;
  final String status;

  ApiProfileData({
    required this.iamUuid,
    required this.fullName,
    required this.phoneNumber,
    this.birthDate,
    this.profilePicture,
    required this.role,
    required this.department,
    required this.division,
    required this.depot,
    required this.designation,
    required this.status,
  });

  factory ApiProfileData.fromJson(Map<String, dynamic> json) {
    return ApiProfileData(
      iamUuid: json['iamUuid'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? 0,
      birthDate: json['birthDate'],
      profilePicture: json['profilePicture'],
      role: json['role'] ?? '',
      department: json['department'] ?? '',
      division: json['division'] ?? '',
      depot: json['depot'] ?? '',
      designation: json['designation'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
