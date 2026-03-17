import 'package:flutter/material.dart';
import 'package:smartpos/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
