import 'package:flutter/material.dart';
import 'package:smartpos/screens/add_product_screen.dart';
import 'package:smartpos/screens/checkout_screen.dart';
import 'package:smartpos/screens/inventory_screen.dart';
import 'package:smartpos/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),

        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.category, size: 28),
                const SizedBox(width: 6),
                Text('Quick Actions', style: TextStyle(fontSize: 28)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          QuickActions(),
        ],
      ),
    );
  }
}

class QuickActions extends StatefulWidget {
  const QuickActions({super.key});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'Inventory': InventoryScreen()},
      {'AddProduct': AddProductScreen()},
      {'Checkout': CheckoutScreen()},
    ];

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 1,
          childAspectRatio: 2,
          crossAxisSpacing: 1,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => actions[index].values.first,
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade300,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  actions[index].keys.first,
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
