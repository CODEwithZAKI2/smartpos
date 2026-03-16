import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartpos/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct({required ProductModel product}) async {
    try {
      ProductModel newProduct = product.copyWith(id: product.barcode);
      await _firestore
          .collection('products')
          .doc(product.barcode)
          .set(newProduct.toJson());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      if (barcode.isEmpty) {
        throw Exception('Invalid or Empty barcode');
      }

      final doc = await _firestore.collection('products').doc(barcode).get();
      if (!doc.exists) {
        return null;
      }
      final product = ProductModel.fromFirestore(doc);
      return product;
    } catch (e) {
      throw Exception('Failed to fetch product with barcode{$barcode}: $e');
    }
  }

  Stream<List<ProductModel>> getAllProducts() {
    try {
      return _firestore
          .collection('products')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ProductModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw Exception('Failed to fetch all products: $e');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.barcode)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> decreaseStock(String barcode, int quantitySold) async {
    try {
      final doc = await _firestore.collection('products').doc(barcode).get();
      if (!doc.exists) {
        throw Exception('Product not found!');
      }
      final product = ProductModel.fromFirestore(doc);
      if (product.stockQuantity < quantitySold) {
        throw Exception('Out of Stock product can\'t be updated');
      }

      await _firestore.collection('products').doc(barcode).update({
        'stockQuantity': FieldValue.increment(-quantitySold),
      });
    } catch (e) {
      throw Exception('Failed to update product quantity: $e');
    }
  }
}
