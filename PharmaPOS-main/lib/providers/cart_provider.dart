import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../models/sale.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Medicine medicine) {
    final existingIndex = state.indexWhere(
      (item) => item.medicine.id == medicine.id,
    );
    if (existingIndex != -1) {
      final updatedItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        CartItem(medicine: medicine, quantity: updatedItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(medicine: medicine, quantity: 1)];
    }
  }

  void removeFromCart(String medicineId) {
    state = state.where((item) => item.medicine.id != medicineId).toList();
  }

  void updateQuantity(String medicineId, int delta) {
    state = state
        .map((item) {
          if (item.medicine.id == medicineId) {
            final newQuantity = item.quantity + delta;
            if (newQuantity > 0) {
              return CartItem(medicine: item.medicine, quantity: newQuantity);
            }
            return null;
          }
          return item;
        })
        .whereType<CartItem>()
        .toList();
  }

  void clearCart() {
    state = [];
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return state.fold(
      0.0,
      (sum, item) => sum + (item.medicine.price * item.quantity),
    );
  }
}
