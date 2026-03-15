import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartpos/models/product_model.dart';

class CartModel {
  final ProductModel product;
  final int quantity;
  final double lineTotal;
  final Timestamp addedAt;

  const CartModel({
    required this.product,
    required this.quantity,
    required this.lineTotal,
    required this.addedAt,
  });

  CartModel copyWith({int? quantity}) {
    return CartModel(
      product: product,
      quantity: quantity ?? this.quantity,
      lineTotal: lineTotal,
      addedAt: addedAt,
    );
  }

  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartModel(
      product: ProductModel.fromJson(data['product'] as Map<String, dynamic>),
      quantity: (data['quantity'] as num).toInt(),
      lineTotal: (data['lineTotal'] as num).toDouble(),
      addedAt: data['addedAt'] as Timestamp,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'addedAt': addedAt,
      'quantity': quantity,
      'product': product.toJson(),
      'lineTotal': lineTotal,
    };
  }

  DateTime get addedDate => addedAt.toDate();
}
