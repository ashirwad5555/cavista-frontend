class Request {
  final String id;
  final String patientName;
  final String reason;
  final DateTime date;
  final String time;

  Request({
    required this.id,
    required this.patientName,
    required this.reason,
    required this.date,
    required this.time,
  });
}