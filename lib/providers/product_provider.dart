import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/product_model.dart';
import 'package:smartpos/services/product_service.dart';

// 1. Core Service
final productServiceProvider = Provider((ref) => ProductService());

// 2. Stream of Inventory
final allProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final productService = ref.read(productServiceProvider);
  return productService.getAllProducts();
});

// 3. Single Fetching
final getProductByBarcodeProvider =
    FutureProvider.family<ProductModel?, String>((ref, barcode) async {
      final productService = ref.read(productServiceProvider);
      return await productService.getProductByBarcode(barcode);
    });
