import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/providers/auth_provider.dart';
import 'package:smartpos/screens/home_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: RegisterForm()));
  }
}

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool hidePassword = true;
  void _onRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
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
      final name = _nameController.text;
      final userModel = await ref
          .watch(authServiceProvider)
          .register(email: email, password: password, name: name);
      print('Successfully registered, your role is {${userModel.role}}');
      ref.invalidate(authServiceProvider);
      ref.invalidate(currentRealtimeUserProvider);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create user: $e')));
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
              'Register',
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
                        controller: _nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.onPrimary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Adjust value here
                          ),
                          labelStyle: TextStyle(color: const Color(0xFF6B7280)),
                          labelText: 'Your name',
                          prefixIcon: Icon(
                            Icons.person,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                        onPressed: _onRegister,
                        label: Text('Register'),
                        icon: Icon(Icons.save),
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
