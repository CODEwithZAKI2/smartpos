import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/user_model.dart';
import 'package:smartpos/services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final currentRealtimeUserProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.getRealTimeCurrentUser();
});
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});
