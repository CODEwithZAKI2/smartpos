import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/product_model.dart';
import 'package:smartpos/providers/product_provider.dart';
import 'package:smartpos/screens/inventory_screen.dart';

class UpdateProduct extends ConsumerWidget {
  const UpdateProduct({super.key, required this.barcode});
  final String barcode;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getProductAsync = ref.watch(getProductByBarcodeProvider(barcode));

    return Scaffold(
      appBar: AppBar(title: Text('Add product')),
      body: getProductAsync.when(
        data: (product) {
          if (product == null) {
            return Center(child: Text('Product not found'));
          }
          return UpdateProductWidgets(barcode: barcode, product: product);
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class UpdateProductWidgets extends ConsumerStatefulWidget {
  const UpdateProductWidgets({
    super.key,
    required this.barcode,
    required this.product,
  });
  final String barcode;
  final ProductModel product;
  @override
  ConsumerState<UpdateProductWidgets> createState() =>
      _UpdateProductWidgetsState();
}

class _UpdateProductWidgetsState extends ConsumerState<UpdateProductWidgets> {
  String barcode = '';
  @override
  void initState() {
    barcode = widget.barcode;
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _costPriceController.text = widget.product.costPrice.toString();
    _stockQuantityController.text = widget.product.stockQuantity.toString();
    _categoryController.text = widget.product.category;
    super.initState();
  }

  final TextEditingController _barcodeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  void _onUpdateProduct() async {
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
      await ref.read(productServiceProvider).updateProduct(product);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product Updated'),
          backgroundColor: Colors.green,
        ),
      );
      ref.invalidate(getProductByBarcodeProvider);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                                labelText: 'Category name',
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _onUpdateProduct,
                              label: Text('Update'),
                              icon: Icon(Icons.edit),
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
