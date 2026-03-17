import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/providers/auth_provider.dart';
import 'package:smartpos/screens/home_screen.dart';
import 'package:smartpos/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return MaterialApp(
      home: userAsync.when(
        data: (user) {
          // Not logged in
          if (user == null) {
            print('User is not logging');
            return const LoginScreen();
          }

          return const HomeScreen();
        },
        loading: () => Center(child: const CircularProgressIndicator()),
        error: (error, stack) {
          print('Error loading user: $error');
          return const Placeholder();
        },
      ),
    );
  }
}
