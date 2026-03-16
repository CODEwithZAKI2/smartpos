import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpos/models/cart_model.dart';
import 'package:smartpos/models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartModel>> {
  CartNotifier() : super([]);

  void addProduct(ProductModel product) {
    try {
      final existingIndex = state.indexWhere(
        (cart) => cart.product.barcode == product.barcode,
      );
      if (existingIndex != -1) {
        // 1. Make a completely separate copy of the list
        final newState = [...state];

        // 2. Identify the old item
        final existingItem = newState[existingIndex];

        // 3. Replace it in your COPY with a new version (quantity + 1)
        newState[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
          lineTotal: (existingItem.quantity + 1) * product.price,
        );

        // 4. Overwrite the old state with your new cloned list
        state = newState;
      } else {
        final newItem = CartModel(
          product: product,
          quantity: 1,
          lineTotal: product.price,
          addedAt: Timestamp.now(),
        );

        state = [...state, newItem];
      }
    } catch (e) {
      throw Exception('Failed to add product into the cart: $e');
    }
  }

  void removeProduct(String barcode) {
    try {
      state = state.where((item) => item.product.barcode != barcode).toList();
    } catch (e) {
      throw Exception('Failed to remove product with barcode{$barcode}: $e');
    }
  }

  void increaseQuantity(String barcode) {
    try {
      final existingIndex = state.indexWhere(
        (cart) => cart.product.barcode == barcode,
      );
      if (existingIndex != -1) {
        // 1. Make a completely separate copy of the list
        final newState = [...state];

        // 2. Identify the old item
        final existingItem = newState[existingIndex];

        // 3. Replace it in your COPY with a new version (quantity + 1)
        newState[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
          lineTotal: (existingItem.quantity + 1) * existingItem.product.price,
        );

        // 4. Overwrite the old state with your new cloned list
        state = newState;
      }
    } catch (e) {
      throw Exception('Failed to increase quantity with barcode{$barcode}: $e');
    }
  }

  void decreaseQuantity(String barcode) {
    try {
      final existingIndex = state.indexWhere(
        (cart) => cart.product.barcode == barcode,
      );
      if (existingIndex != -1) {
        // 1. Make a completely separate copy of the list
        final newState = [...state];

        // 2. Identify the old item
        final existingItem = newState[existingIndex];
        if (existingItem.quantity == 1) {
          removeProduct(barcode);
        } else {
          // 3. Replace it in your COPY with a new version (quantity + 1)
          newState[existingIndex] = existingItem.copyWith(
            quantity: existingItem.quantity - 1,
            lineTotal: (existingItem.quantity - 1) * existingItem.product.price,
          );

          // 4. Overwrite the old state with your new cloned list
          state = newState;
        }
      }
    } catch (e) {
      throw Exception('Failed to decrease quantity with barcode{$barcode}: $e');
    }
  }

  void clearCart() {
    try {
      state = [];
    } catch (e) {
      throw Exception('Failed to clear the cart');
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartModel>>(
  (ref) => CartNotifier(),
);
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (total, item) => total + item.lineTotal);
});
