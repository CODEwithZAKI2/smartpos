import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartpos/models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebase = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebase.authStateChanges();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredentials = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredentials.user == null) {
        throw Exception('Login failed: User not found');
      }
      final userId = userCredentials.user!.uid;
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User data not found in database');
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredentials.user == null) {
        throw Exception('Registration failed');
      }
      final userId = userCredentials.user!.uid;

      final newUser = UserModel(
        id: userId,
        email: email,
        role: 'cashier',
        name: name,
        createdAt: Timestamp.now(),
      );
      await _firestore.collection('users').doc(userId).set(newUser.toJson());

      return newUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account already exists with this email');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        default:
          throw Exception('Registration failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _firebase.signOut();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }

  Stream<UserModel?> getRealTimeCurrentUser() {
    try {
      final currentUser = _firebase.currentUser;

      if (currentUser == null) {
        return Stream.value(null); // ✅ Return empty stream, not null
      }

      // ✅ Use .snapshots() for real-time updates
      return _firestore
          .collection('users')
          .doc(currentUser.uid)
          .snapshots() // ✅ This returns Stream<DocumentSnapshot>
          .map((snapshot) {
            // ✅ Transform to UserModel
            if (!snapshot.exists) {
              return null;
            }
            return UserModel.fromFirestore(snapshot);
          });
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }
}
