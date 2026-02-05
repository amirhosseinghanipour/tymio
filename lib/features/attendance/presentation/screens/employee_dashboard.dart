import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import 'employee_history_screen.dart';

class EmployeeDashboard extends ConsumerWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value!;
    final todayAttendanceAsync = ref.watch(todayAttendanceProvider(user.id));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(SolarIconsOutline.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Check In/Out Section (multiple sessions per day)
            Expanded(
              child: todayAttendanceAsync.when(
                data: (todayRecords) {
                  // Open session = most recent record with no check-out (list sorted by checkIn asc)
                  final openSessions =
                      todayRecords.where((a) => a.checkOut == null).toList();
                  final openSession =
                      openSessions.isEmpty ? null : openSessions.last;
                  final hasOpenSession = openSession != null;

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () {
                            final controller = ref
                                .read(attendanceControllerProvider.notifier);
                            if (hasOpenSession) {
                              controller.checkOut(openSession.id);
                            } else {
                              controller.checkIn(user.id);
                            }
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasOpenSession
                                  ? AppColors.error
                                  : AppColors.success,
                              boxShadow: [
                                BoxShadow(
                                  color: (hasOpenSession
                                          ? AppColors.error
                                          : AppColors.success)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasOpenSession
                                      ? SolarIconsBold.exit
                                      : SolarIconsBold.login,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  hasOpenSession
                                      ? 'Check Out'
                                      : 'Check In',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (hasOpenSession)
                          Text(
                            'Checked in at ${DateFormat('hh:mm a').format(openSession.checkIn)}',
                            style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500),
                          ),
                        if (todayRecords.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Text(
                            "Today's sessions",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ...todayRecords.map((a) {
                            final out = a.checkOut != null
                                ? DateFormat('hh:mm a').format(a.checkOut!)
                                : 'now';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${DateFormat('hh:mm a').format(a.checkIn)} – $out',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),

            const SizedBox(height: 24),
            CustomButton(
              text: 'View History',
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeHistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
