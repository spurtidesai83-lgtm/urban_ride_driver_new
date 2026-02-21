class TripModel {
  final String id;
  final String status;
  final String from;
  final String to;
  final DateTime date;
  final String timeDisplay;
  final String tripType;
  final String steeringTime;
  final String buttonText;

  TripModel({
    required this.id,
    required this.status,
    required this.from,
    required this.to,
    required this.date,
    required this.timeDisplay,
    required this.tripType,
    required this.steeringTime,
    required this.buttonText,
  });
}
