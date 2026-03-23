import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/cart_model.dart';
import 'package:smartpos/models/order_item.dart';
import 'package:smartpos/models/order_model.dart';
import 'package:smartpos/providers/auth_provider.dart';
import 'package:smartpos/providers/cart_provider.dart';
import 'package:smartpos/providers/order_provider.dart';
import 'package:smartpos/providers/product_provider.dart';
import 'package:smartpos/screens/order_placed.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  void onDecreaseQuantity(String barcode) async {
    try {
      ref.read(cartProvider.notifier).decreaseQuantity(barcode);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void onIncreaseQuantity(String barcode) async {
    try {
      ref.read(cartProvider.notifier).increaseQuantity(barcode);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _selectedPayment = 'cod';

  void _placeOrder(
    List<CartModel> cartItems,
    double total,
    BuildContext context,
  ) async {
    List<OrderItem> items = [];
    for (var item in cartItems) {
      items.add(
        OrderItem(
          productId: item.product.id ?? item.product.barcode,
          name: item.product.name,
          price: item.product.price,
          quantity: item.quantity,
        ),
      );
    }
    try {
      final user = await ref.read(currentRealtimeUserProvider.future);
      if (user == null) {
        return;
      }
      final orderProvider = ref.watch(orderServiceProvider);
      final order = OrderModel(
        id: uuid.v1(),
        receiptNumber: orderProvider.generateReceiptNumber(),
        items: items,
        subTotal: total,
        grandTotal: total,
        paymentMethod: _selectedPayment,
        createdAt: Timestamp.fromDate(DateTime.now()),
        cashierId: user.id,
      );
      await orderProvider.createOrder(order: order);
      if (mounted) {
        final productProvider = ref.watch(productServiceProvider);
        for (var item in cartItems) {
          await productProvider.decreaseStock(
            item.product.barcode,
            item.quantity,
          );
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => OrderPlaced(order: order,)),
          (route) => false,
        );
        ref.read(cartProvider.notifier).clearCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(blurRadius: 2, offset: Offset(0, 2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Scanned Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('TOTAL PRICE'),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cartItems.length} Items total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '\$$cartTotal',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Divider(),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 12),
                  if (cartItems.isEmpty)
                    Center(child: Text('Cart is Empty, scan products')),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          elevation: 4,
                          shadowColor: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItems[index].product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${cartItems[index].product.price}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          onDecreaseQuantity(
                                            cartItems[index].product.barcode,
                                          );
                                        },
                                        icon: Icon(Icons.remove),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${cartItems[index].quantity}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        onPressed: () {
                                          onIncreaseQuantity(
                                            cartItems[index].product.barcode,
                                          );
                                        },
                                        icon: Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // COD Option (Active)
                    GestureDetector(
                      onTap: () => setState(() => _selectedPayment = 'cod'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              _selectedPayment == 'cod'
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.08)
                                  : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                _selectedPayment == 'cod'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('💵', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cash',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Pay now with cash',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedPayment == 'cod')
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Card Option (Disabled - Coming Soon)
                    Opacity(
                      opacity: 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Row(
                          children: [
                            Text('💳', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Credit / Debit Card',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              'Coming Soon',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.lock_outline, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
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
                  onPressed:
                      cartItems.isNotEmpty
                          ? () {
                            _placeOrder(cartItems, cartTotal, context);
                          }
                          : null,
                  child: Text(
                    'Place Order',
                    style: TextStyle(color: Colors.white),
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
