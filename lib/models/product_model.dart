import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id;
  final String barcode;
  final String name;
  final double price;
  final double? costPrice;
  final int stockQuantity;
  final String? imageUrl;
  final String category;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const ProductModel({
    required this.barcode,
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.costPrice,
    this.imageUrl,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    this.id,
  });

  ProductModel copyWith({
    String? id,
    String? barcode,
    String? name,
    double? price,
    double? costPrice,
    int? stockQuantity,
    String? imageUrl,
    String? category,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: data['id'] as String,
      barcode: doc.id,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      costPrice:
          data['costPrice'] != null
              ? (data['costPrice'] as num).toDouble()
              : null,
      stockQuantity: (data['stockQuantity'] as num).toInt(),
      imageUrl: data['imageUrl'] as String?,
      category: data['category'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt:
          data['updatedAt'] != null ? data['updatedAt'] as Timestamp : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'price': price,
      if (costPrice != null) 'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      costPrice:
          json['costPrice'] != null
              ? (json['costPrice'] as num).toDouble()
              : null,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }
}
