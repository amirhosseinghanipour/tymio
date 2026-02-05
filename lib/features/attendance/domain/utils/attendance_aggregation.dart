import '../entities/attendance.dart';
import '../entities/employee_work_summary.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Builds work summaries per employee from attendance records and employee list.
List<EmployeeWorkSummary> aggregateWorkSummaries({
  required List<Attendance> attendance,
  required List<AppUser> employees,
}) {
  final byUser = <String, List<Attendance>>{};
  for (final a in attendance) {
    byUser.putIfAbsent(a.userId, () => []).add(a);
  }

  final summaries = <EmployeeWorkSummary>[];
  for (final emp in employees) {
    final records = byUser[emp.id] ?? [];
    int totalMinutes = 0;
    final dates = <DateTime>{};

    for (final r in records) {
      if (r.checkOut != null) {
        totalMinutes += r.checkOut!.difference(r.checkIn).inMinutes;
      }
      dates.add(DateTime(r.date.year, r.date.month, r.date.day));
    }

    summaries.add(EmployeeWorkSummary(
      userId: emp.id,
      employeeName: emp.name,
      employeeEmail: emp.email,
      totalMinutes: totalMinutes,
      daysWorked: dates.length,
    ));
  }

  summaries.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));
  return summaries;
}
