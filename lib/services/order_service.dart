import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartpos/models/order_model.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> createOrder({required OrderModel order}) async {
    try {
      final orderId = _firestore.collection('orders').doc().id;
      final newOrder = order.copyWith(id: orderId);
      await _firestore.collection('orders').doc(orderId).set(newOrder.toJson());
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) {
        throw Exception('Order does not exists');
      }
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch order with id{$orderId}: $e');
    }
  }

  Future<OrderModel?> getOrderByReceiptNumber(String receiptNumber) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('orders')
              .where('receiptNumber', isEqualTo: receiptNumber)
              .get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      final doc = querySnapshot.docs.first;
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw Exception(
        'Failed to fetch order with receipt {$receiptNumber}: $e',
      );
    }
  }

  Stream<List<OrderModel>> getTodayOrders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    try {
      final querysnapshots =
          _firestore
              .collection('orders')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where(
                'createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(endOfDate),
              )
              .orderBy('createdAt', descending: true)
              .snapshots();

      return querysnapshots.map(
        (snapshots) =>
            snapshots.docs.map((doc) => OrderModel.fromFirestore(doc)).toList(),
      );
    } catch (e) {
      throw Exception('Failed to fetch today\'s orders: $e');
    }
  }

  String generateReceiptNumber() {
    // 1. Get current date (e.g., 20260316)
  final now = DateTime.now();
  final dateString = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  
  // 2. Generate random 4 digit number (0000 to 9999)
  final random = Random().nextInt(10000).toString().padLeft(4, '0');
  
  // Result: "ORD-20260316-4921"
  return 'ORD-$dateString-$random';
  }
}
