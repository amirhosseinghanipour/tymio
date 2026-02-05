import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository_interface.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/employee_work_summary.dart';
import '../../domain/utils/attendance_aggregation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Period for employer analytics.
enum AnalyticsPeriod { today, thisWeek, thisMonth }

final attendanceRepositoryProvider = Provider<AttendanceRepositoryInterface>((ref) {
  return AttendanceRepositoryImpl(ref.read(firestoreProvider));
});

final todayAttendanceProvider = StreamProvider.family<Attendance?, String>((ref, userId) {
  return ref.watch(attendanceRepositoryProvider).getTodayAttendance(userId);
});

final attendanceHistoryProvider = StreamProvider.family<List<Attendance>, String>((ref, userId) {
  return ref.watch(attendanceRepositoryProvider).getHistory(userId);
});

final employeesAttendanceProvider = StreamProvider.family<List<Attendance>, List<String>>((ref, userIds) {
  return ref.watch(attendanceRepositoryProvider).getEmployeesAttendance(userIds);
});

/// Selected analytics period (today / this week / this month).
class AnalyticsPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() => AnalyticsPeriod.thisMonth;

  void setPeriod(AnalyticsPeriod period) {
    state = period;
  }
}

final analyticsPeriodProvider =
    NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>(
        AnalyticsPeriodNotifier.new);

/// Start and end of the selected period (date only, start of day).
(DateTime start, DateTime end) _periodToRange(AnalyticsPeriod period) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case AnalyticsPeriod.today:
      return (today, today);
    case AnalyticsPeriod.thisWeek:
      final weekday = now.weekday;
      final monday = today.subtract(Duration(days: weekday - 1));
      return (monday, today);
    case AnalyticsPeriod.thisMonth:
      final first = DateTime(now.year, now.month, 1);
      return (first, today);
  }
}

/// Attendance records for the current employer in the selected period.
final employerAttendanceInRangeProvider =
    FutureProvider.family<List<Attendance>, String>((ref, employerId) async {
  final employees = await ref.watch(employeesProvider(employerId).future);
  final period = ref.watch(analyticsPeriodProvider);
  final (start, end) = _periodToRange(period);
  final userIds = employees.map((e) => e.id).toList();
  if (userIds.isEmpty) return [];
  return ref
      .read(attendanceRepositoryProvider)
      .getEmployeesAttendanceInRange(userIds, start, end);
});

/// Work summaries for the current employer in the selected period.
final employerWorkSummariesProvider =
    FutureProvider.family<List<EmployeeWorkSummary>, String>((ref, employerId) async {
  final employees = await ref.watch(employeesProvider(employerId).future);
  final attendance =
      await ref.watch(employerAttendanceInRangeProvider(employerId).future);
  return aggregateWorkSummaries(attendance: attendance, employees: employees);
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
