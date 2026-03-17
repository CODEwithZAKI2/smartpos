import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartpos/models/product_model.dart';
import 'package:smartpos/providers/product_provider.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add product')),
      body: AddProductWidgets(),
    );
  }
}

class AddProductWidgets extends ConsumerStatefulWidget {
  const AddProductWidgets({super.key});

  @override
  ConsumerState<AddProductWidgets> createState() => _AddProductWidgetsState();
}

class _AddProductWidgetsState extends ConsumerState<AddProductWidgets> {
  String barcode = '';
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  void _onAddProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _costPriceController.text.isEmpty ||
        _stockQuantityController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid data'),
          backgroundColor: Colors.red,
        ),
      );
    }
    String name = _nameController.text;
    double price = double.parse(_priceController.text);
    double costPrice = double.parse(_costPriceController.text);
    int stockQuantity = int.parse(_stockQuantityController.text);
    String category = _categoryController.text;
    Timestamp createdAt = Timestamp.fromDate(DateTime.now());

    final product = ProductModel(
      id: 'Placeholder',
      barcode: barcode,
      name: name,
      price: price,
      costPrice: costPrice,
      stockQuantity: stockQuantity,
      category: category,
      createdAt: createdAt,
    );
    try {
      await ref.read(productServiceProvider).addProduct(product: product);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added'), backgroundColor: Colors.green),
      );
      setState(() {
        barcode = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _onScanProduct() async {
    final rawBarCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => ScanProduct()),
    );
    if (rawBarCode != null) {
      setState(() {
        barcode = rawBarCode;
      });
    }
    print('Raw Barcode is: $rawBarCode');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (barcode.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: InkWell(
                  onTap: _onScanProduct,
                  child: Container(
                    alignment: Alignment.center,
                    width: 250,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 28, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Scan Product',
                          style: TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (barcode.isNotEmpty)
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 80),
              decoration: BoxDecoration(),
              child: Column(
                children: [
                  Text(
                    'Product Details',
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
                              controller: _barcodeController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Adjust value here
                                ),
                                enabled: false,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: const Color(0xFF6B7280),
                                ),
                                labelText: barcode,

                                prefixIcon: Icon(
                                  Icons.barcode_reader,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Adjust value here
                                ),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF6B7280),
                                ),
                                labelText: 'Product Name',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Adjust value here
                                ),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF6B7280),
                                ),
                                labelText: 'Product Price',
                              ),
                              keyboardType: TextInputType.numberWithOptions(),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _costPriceController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Adjust value here
                                ),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF6B7280),
                                ),
                                labelText: 'Product Cost Price',
                              ),
                              keyboardType: TextInputType.numberWithOptions(),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _stockQuantityController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Adjust value here
                                ),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF6B7280),
                                ),
                                labelText: 'Stock Quantity',
                              ),
                              keyboardType: TextInputType.numberWithOptions(),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _categoryController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Adjust value here
                                ),
                                labelStyle: TextStyle(
                                  color: const Color(0xFF6B7280),
                                ),
                                labelText: 'Category Name',
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _onAddProduct,
                              label: Text('Save'),
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
        ],
      ),
    );
  }
}

class ScanProduct extends StatelessWidget {
  const ScanProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;

        // 2. We got a barcode! Let's get the first one.
        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
          final rawBarcode = barcodes.first.rawValue!;

          // 3. Close the scanner modal automatically!
          Navigator.of(context).pop(rawBarcode);
        }
      },
    );
  }
}
