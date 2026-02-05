import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance.dart';

class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.userId,
    required super.checkIn,
    super.checkOut,
    required super.date,
    super.checkInLat,
    super.checkInLng,
    super.checkOutLat,
    super.checkOutLng,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      userId: map['userId'] ?? '',
      checkIn: (map['checkIn'] as Timestamp).toDate(),
      checkOut: map['checkOut'] != null ? (map['checkOut'] as Timestamp).toDate() : null,
      date: (map['date'] as Timestamp).toDate(),
      checkInLat: map['checkInLat'],
      checkInLng: map['checkInLng'],
      checkOutLat: map['checkOutLat'],
      checkOutLng: map['checkOutLng'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'date': Timestamp.fromDate(date),
      'checkInLat': checkInLat,
      'checkInLng': checkInLng,
      'checkOutLat': checkOutLat,
      'checkOutLng': checkOutLng,
    };
  }
}
