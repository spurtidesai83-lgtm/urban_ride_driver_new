class ReportRecord {
  final int dutyNo;
  final String date;
  final double km;
  final double steeringTime;
  final double overtime;
  final String route;
  final String status;

  ReportRecord({
    required this.dutyNo,
    required this.date,
    required this.km,
    required this.steeringTime,
    required this.overtime,
    required this.route,
    required this.status,
  });
}
