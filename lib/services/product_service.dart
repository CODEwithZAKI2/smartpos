import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartpos/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> addProduct({required ProductModel product}) async {
    try {
      //create new product id
      final productId = _firestore.collection('products').doc().id;
      ProductModel newProduct = product.copyWith(id: productId);
      await _firestore
          .collection('products')
          .doc(productId)
          .set(newProduct.toJson());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }
}
