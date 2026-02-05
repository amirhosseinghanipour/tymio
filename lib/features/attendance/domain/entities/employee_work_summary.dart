/// Summary of an employee's work for a given period (day/week/month).
class EmployeeWorkSummary {
  final String userId;
  final String employeeName;
  final String employeeEmail;
  /// Total worked minutes in the period.
  final int totalMinutes;
  /// Number of days with at least one check-in in the period.
  final int daysWorked;

  const EmployeeWorkSummary({
    required this.userId,
    required this.employeeName,
    required this.employeeEmail,
    required this.totalMinutes,
    required this.daysWorked,
  });

  String get formattedHours {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}
