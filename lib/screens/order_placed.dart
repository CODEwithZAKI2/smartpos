
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/order_model.dart';
import 'package:smartpos/providers/printer_provider.dart';
import 'package:smartpos/screens/home_screen.dart';

class OrderPlaced extends ConsumerWidget {
  const OrderPlaced({super.key, required this.order});
  final OrderModel order;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerProv = ref.read(printerProvider);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Order Placed ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    const Color.fromARGB(255, 0, 134, 244),
                  ),
                ),
                onPressed: () async {
                  // Grab the globally selected printer from our settings!
                  final targetDevice = ref.read(selectedPrinterProvider);
                  
                  if (targetDevice == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a printer in Settings first!')),
                    );
                    return;
                  }

                  try {
                    await printerProv.connect(targetDevice);
                    await printerProv.printReceipt(order);
                    await printerProv.disconnect();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Printer Error: $e')),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.print, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('Print', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // Send them back to the Home Screen to start a new sale
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const HomeScreen()),
              );
            },
            child: const Text('Start New Sale'),
          ),
        ],
      ),
    );
  }
}
