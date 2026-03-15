import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartpos/models/order_item.dart';

class OrderModel {
  final String id;
  final String receiptNumber;
  final List<OrderItem> items;
  final double subTotal;
  final double? taxAmount;
  final double grandTotal;
  final String paymentMethod;
  final double? amountTendered;
  final double? changeDue;
  final Timestamp createdAt;
  final String cashierId;

  const OrderModel({
    required this.id,
    required this.receiptNumber,
    required this.items,
    required this.subTotal,
    this.taxAmount,
    required this.grandTotal,
    required this.paymentMethod,
    this.amountTendered,
    this.changeDue,
    required this.createdAt,
    required this.cashierId,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      receiptNumber: data['receiptNumber'] as String,
      items:
          (data['items'] as List<dynamic>?)?.map((item) {
            try {
              return OrderItem.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('❌ Error parsing order item: $e');
              print('📦 Item data: $item');
              rethrow;
            }
          }).toList() ??
          [],
      subTotal: (data['subTotal'] as num).toDouble(),
      taxAmount:
          data['taxAmount'] != null
              ? (data['taxAmount'] as num).toDouble()
              : null,
      grandTotal: (data['grandTotal'] as num).toDouble(),
      paymentMethod: data['paymentMethod'] as String,
      amountTendered:
          data['amountTendered'] != null
              ? (data['amountTendered'] as num).toDouble()
              : null,
      createdAt: data['createdAt'] as Timestamp,
      cashierId: data['cashierId'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'receiptNumber': receiptNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'subTotal': subTotal,
      if (taxAmount != null) 'taxAmount': taxAmount,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      if (amountTendered != null) 'amountTendered': amountTendered,
      'createdAt': createdAt,
      'cashierId': cashierId,
    };
  }

  OrderModel copyWith({
    String? id,
    String? receiptNumber,
    List<OrderItem>? items,
    double? subTotal,
    double? taxAmount,
    double? grandTotal,
    String? paymentMethod,
    double? amountTendered,
    double? changeDue,
    Timestamp? createdAt,
    String? cashierId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      taxAmount: taxAmount ?? this.taxAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountTendered: amountTendered ?? this.amountTendered,
      changeDue: changeDue ?? this.changeDue,
      createdAt: createdAt ?? this.createdAt,
      cashierId: cashierId ?? this.cashierId,
    );
  }
  DateTime get createdDate => createdAt.toDate();
}
