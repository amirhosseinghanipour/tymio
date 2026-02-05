class Attendance {
  final String id;
  final String userId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final DateTime date;

  const Attendance({
    required this.id,
    required this.userId,
    required this.checkIn,
    this.checkOut,
    required this.date,
  });
}
