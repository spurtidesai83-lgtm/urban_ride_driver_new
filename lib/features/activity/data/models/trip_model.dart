class TripModel {
  final String id;
  final String status;
  final String from;
  final String to;
  final DateTime date;
  final String timeDisplay;
  final String? endTime;
  final String tripType;
  final String steeringTime;
  final String? restTime;
  final int? kms;
  final String buttonText;

  TripModel({
    required this.id,
    required this.status,
    required this.from,
    required this.to,
    required this.date,
    required this.timeDisplay,
    this.endTime,
    required this.tripType,
    required this.steeringTime,
    this.restTime,
    this.kms,
    required this.buttonText,
  });

  TripModel copyWith({
    String? id,
    String? status,
    String? from,
    String? to,
    DateTime? date,
    String? timeDisplay,
    String? endTime,
    String? tripType,
    String? steeringTime,
    String? restTime,
    int? kms,
    String? buttonText,
  }) {
    return TripModel(
      id: id ?? this.id,
      status: status ?? this.status,
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      timeDisplay: timeDisplay ?? this.timeDisplay,
      endTime: endTime ?? this.endTime,
      tripType: tripType ?? this.tripType,
      steeringTime: steeringTime ?? this.steeringTime,
      restTime: restTime ?? this.restTime,
      kms: kms ?? this.kms,
      buttonText: buttonText ?? this.buttonText,
    );
  }
}
