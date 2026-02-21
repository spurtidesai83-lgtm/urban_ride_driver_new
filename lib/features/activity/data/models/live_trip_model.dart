class LiveTripModel {
  final int tripNo;
  final String dutyNo;
  final String fromLocation;
  final String toLocation;
  final int kms;
  final String status;
  final DateTime? tripDate;
  final String startTime;
  final String endTime;
  final String steering;
  final String rest;

  LiveTripModel({
    required this.tripNo,
    required this.dutyNo,
    required this.fromLocation,
    required this.toLocation,
    required this.kms,
    required this.status,
    required this.tripDate,
    required this.startTime,
    required this.endTime,
    required this.steering,
    required this.rest,
  });

  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';

  factory LiveTripModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final tripDateRaw = json['tripDate'];
    if (tripDateRaw is String && tripDateRaw.isNotEmpty) {
      parsedDate = DateTime.tryParse(tripDateRaw);
    }

    return LiveTripModel(
      tripNo: _parseInt(json['tripNo']),
      dutyNo: (json['dutyNo'] ?? '').toString(),
      fromLocation: (json['fromLocation'] ?? '').toString(),
      toLocation: (json['toLocation'] ?? '').toString(),
      kms: _parseInt(json['kms']),
      status: (json['status'] ?? '').toString(),
      tripDate: parsedDate,
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
      steering: (json['steering'] ?? '').toString(),
      rest: (json['rest'] ?? '').toString(),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
