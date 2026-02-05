import '../entities/app_user.dart';

abstract class AuthRepositoryInterface {
  Stream<AppUser?> get authStateChanges;
  
  Future<AppUser> signIn(String email, String password);
  
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? employerId,
  });
  
  Future<void> signOut();
  
  Future<List<AppUser>> getEmployees(String employerId);
}
