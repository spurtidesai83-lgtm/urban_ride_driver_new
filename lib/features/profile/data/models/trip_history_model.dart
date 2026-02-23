/// Domain model for Trip History (UI layer)
class TripHistoryModel {
  final int totalNoOfDuties;
  final double kmsTraveled;
  final String steeringHrs; // Format: HH:MM:SS
  final double overTime;
  final List<TripDetailModel> tripDetails;

  TripHistoryModel({
    required this.totalNoOfDuties,
    required this.kmsTraveled,
    required this.steeringHrs,
    required this.overTime,
    required this.tripDetails,
  });

  TripHistoryModel copyWith({
    int? totalNoOfDuties,
    double? kmsTraveled,
    String? steeringHrs,
    double? overTime,
    List<TripDetailModel>? tripDetails,
  }) {
    return TripHistoryModel(
      totalNoOfDuties: totalNoOfDuties ?? this.totalNoOfDuties,
      kmsTraveled: kmsTraveled ?? this.kmsTraveled,
      steeringHrs: steeringHrs ?? this.steeringHrs,
      overTime: overTime ?? this.overTime,
      tripDetails: tripDetails ?? this.tripDetails,
    );
  }
}

class TripDetailModel {
  final int tripNo;
  final String fromLocation;
  final String toLocation;
  final String tripDate; // Format: YYYY-MM-DD
  final int kms;
  final String steeringHrs; // Format: HH:MM:SS
  final String status; // COMPLETED, IN_PROGRESS, CANCELLED

  TripDetailModel({
    required this.tripNo,
    required this.fromLocation,
    required this.toLocation,
    required this.tripDate,
    required this.kms,
    required this.steeringHrs,
    required this.status,
  });

  TripDetailModel copyWith({
    int? tripNo,
    String? fromLocation,
    String? toLocation,
    String? tripDate,
    int? kms,
    String? steeringHrs,
    String? status,
  }) {
    return TripDetailModel(
      tripNo: tripNo ?? this.tripNo,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      tripDate: tripDate ?? this.tripDate,
      kms: kms ?? this.kms,
      steeringHrs: steeringHrs ?? this.steeringHrs,
      status: status ?? this.status,
    );
  }
}
