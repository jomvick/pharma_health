import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/medicine.dart';
import '../models/sale.dart';
import 'medicine_provider.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final dio = ref.watch(dioProvider);
  return CartNotifier(dio, ref);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Dio _dio;
  final Ref _ref;

  CartNotifier(this._dio, this._ref) : super([]);

  void addToCart(Medicine medicine) {
// ... rest of logic unchanged ...
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

  Future<void> finalizeSale() async {
    if (state.isEmpty) return;

    try {
      final response = await _dio.post('/sales', data: {
        'items': state.map((item) => item.toJson()).toList(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        clearCart();
        // Optionnel: rafraîchir le stock
        _ref.invalidate(medicinesProvider);
      }
    } catch (e) {
      print('Error finalizing sale: $e');
      rethrow;
    }
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
