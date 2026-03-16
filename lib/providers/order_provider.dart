import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/order_model.dart';
import 'package:smartpos/providers/product_provider.dart';
import 'package:smartpos/services/order_service.dart';

final orderServiceProvider = Provider((ref) => OrderService());

final getOrderByIdProvider = FutureProvider.family<OrderModel?, String>((
  ref,
  orderId,
) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getOrderById(orderId);
});

final getOrderByReceiptNumberProvider =
    FutureProvider.family<OrderModel?, String>((ref, receiprtNumber) async {
      final orderService = ref.read(orderServiceProvider);
      return await orderService.getOrderByReceiptNumber(receiprtNumber);
    });
final getTodayOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getTodayOrders();
});
