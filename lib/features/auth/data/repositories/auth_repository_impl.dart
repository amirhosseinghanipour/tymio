import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepositoryInterface {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id) as AppUser;
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) {
        throw Exception('User data not found');
      }
      
      return UserModel.fromMap(doc.data()!, doc.id) as AppUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? employerId,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        employerId: employerId,
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());
      return user as AppUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<List<AppUser>> getEmployees(String employerId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('employerId', isEqualTo: employerId)
        .get();
    
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id) as AppUser)
        .toList();
  }
}
