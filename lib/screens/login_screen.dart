import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/providers/auth_provider.dart';
import 'package:smartpos/screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: LoginForm()));
  }
}

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool hidePassword = true;
  void _onLogin() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        !_emailController.text.contains('@')) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Invalid Data'),
              content: Text('Please enter valid characters.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Okay'),
                ),
              ],
            ),
      );
    }
    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      final userModel = await ref
          .watch(authServiceProvider)
          .login(email: email, password: password);
      print('Welcome back, your name is {${userModel.name}}');
      ref.invalidate(authServiceProvider);
      ref.invalidate(currentRealtimeUserProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to login user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 80),
        decoration: BoxDecoration(),
        child: Column(
          children: [
            Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.onPrimary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Adjust value here
                          ),
                          labelStyle: TextStyle(color: const Color(0xFF6B7280)),
                          labelText: 'Email Address',
                          prefixIcon: Icon(
                            Icons.email,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.onPrimary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Adjust value here
                          ),
                          labelStyle: TextStyle(color: const Color(0xFF6B7280)),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: const Color(0xFF6B7280),
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        obscureText: hidePassword,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _onLogin,
                        label: Text('Login'),
                        icon: Icon(Icons.login),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Don\'t have an account?'),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
