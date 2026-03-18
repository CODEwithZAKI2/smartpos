import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartpos/providers/cart_provider.dart';
import 'package:smartpos/providers/product_provider.dart';
import 'package:smartpos/screens/checkout_screen.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;

  // Create the controller
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    // Initialize it: it takes 2 seconds to reach the bottom
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // THE MAGIC WORD: tell it to repeat infinitely!
    // reverse: true makes it bounce back up smoothly instead of teleporting to the top
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // ALWAYS dispose controllers when leaving the screen to save memory!
    _animationController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) async {
                    // If we are already processing a barcode, ignore this camera frame!
                    if (_isScanning) return;
                    final List<Barcode> barcodes = capture.barcodes;

                    // 2. We got a barcode! Let's get the first one.
                    if (barcodes.isNotEmpty &&
                        barcodes.first.rawValue != null) {
                      // LOCK THE SCANNER!
                      setState(() {
                        _isScanning = true;
                      });
                      final rawBarcode = barcodes.first.rawValue!;
                      print('Raw barcode is: $rawBarcode');

                      try {
                        final product = await ref
                            .read(productServiceProvider)
                            .getProductByBarcode(rawBarcode);

                        if (!mounted) return;
                        if (product == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Product not found')),
                          );
                        } else {
                          ref.read(cartProvider.notifier).addProduct(product);
                        }
                        // DELAY FOR COOLDOWN (e.g., wait 2 seconds before allowing the next scan)
                        // This gives the cashier time to move the physical product away from the camera
                        await Future.delayed(const Duration(seconds: 2));

                        // UNLOCK THE SCANNER!
                        if (mounted) {
                          setState(() {
                            _isScanning = false;
                          });
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
                Positioned.fill(
                  child: CustomPaint(painter: ScannerOverlayPainter()),
                ),
                // Place this inside your Stack, underneath your CustomPaint overlay
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    // TweenAnimationBuilder constantly loops a value from 0.0 to 1.0 (Top to Bottom)
                    child: // Replace your TweenAnimationBuilder with this:
                        AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        // _animationController.value constantly loops automatically from 0.0 to 1.0 and back!
                        // We multiply it by 250 (the height of your box) to get the physical pixel position
                        final yPosition = _animationController.value * 250;

                        return Stack(
                          children: [
                            // Your blue border
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.6),
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            // The Laser Line
                            Positioned(
                              top: yPosition,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 400 - 25, // Overlaps the camera by 25 pixels!
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return Transform.translate(
                          offset: Offset(0, -35),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Card(
                              elevation: 4,
                              shadowColor: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                cartItems[index]
                                                    .product
                                                    .barcode,
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
                                                cartItems[index]
                                                    .product
                                                    .barcode,
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
                          ),
                        );
                      },
                    ),
                  ),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => CheckoutScreen(),
                                    ),
                                  );
                                }
                                : null,
                        child: Text(
                          'Pay',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. We draw a semi-transparent black rectangle over the entire screen
    final backgroundPaint = Paint()..color = Colors.black54;

    // We get the center point of the screen
    final center = Offset(size.width / 2, size.height / 2);

    // 2. We define our cutout box (250x250) right in the middle
    final cutoutRect = Rect.fromCenter(center: center, width: 250, height: 250);

    // 3. We use RRect (Rounded Rectangle) to make the cutout look smooth
    final cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      Radius.circular(12),
    );

    // 4. This is the magic part! We tell the canvas to draw the black background
    // BUT exclude our cutout square.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(cutoutRRect),
      ),
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
