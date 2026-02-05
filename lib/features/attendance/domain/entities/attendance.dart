class Attendance {
  final String id;
  final String userId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final DateTime date;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  const Attendance({
    required this.id,
    required this.userId,
    required this.checkIn,
    this.checkOut,
    required this.date,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });
}
