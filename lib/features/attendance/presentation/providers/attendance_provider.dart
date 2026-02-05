import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository_interface.dart';
import '../../domain/entities/attendance.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepositoryInterface>((ref) {
  return AttendanceRepositoryImpl(ref.read(firestoreProvider));
});

final todayAttendanceProvider = StreamProvider.family<List<Attendance>, String>((ref, userId) {
  return ref.watch(attendanceRepositoryProvider).getTodayAttendance(userId);
});

final attendanceHistoryProvider = StreamProvider.family<List<Attendance>, String>((ref, userId) {
  return ref.watch(attendanceRepositoryProvider).getHistory(userId);
});

final employeesAttendanceProvider = StreamProvider.family<List<Attendance>, List<String>>((ref, userIds) {
  return ref.watch(attendanceRepositoryProvider).getEmployeesAttendance(userIds);
});

class AttendanceController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  AttendanceRepositoryInterface get _repository =>
      ref.read(attendanceRepositoryProvider);

  Future<void> checkIn(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.checkIn(userId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> checkOut(String attendanceId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.checkOut(attendanceId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final attendanceControllerProvider =
    NotifierProvider<AttendanceController, AsyncValue<void>>(
        AttendanceController.new);
