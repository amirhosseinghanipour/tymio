class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'employee' or 'employer'
  final String? employerId; // Only for employees

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.employerId,
  });

  bool get isEmployer => role == 'employer';
}
