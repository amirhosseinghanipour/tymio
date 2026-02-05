import '../../domain/entities/attendance.dart';

abstract class AttendanceRepositoryInterface {
  Future<void> checkIn(String userId);
  Future<void> checkOut(String attendanceId);
  Stream<Attendance?> getTodayAttendance(String userId);
  Stream<List<Attendance>> getHistory(String userId);
  Stream<List<Attendance>> getEmployeesAttendance(List<String> userIds);
}
