import 'package:equatable/equatable.dart';

import 'medicine.dart';

class Sale extends Equatable {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;

  const Sale({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
  });

  @override
  List<Object?> get props => [id, items, total, date];
}

class CartItem extends Equatable {
  final Medicine medicine;
  final int quantity;

  const CartItem({
    required this.medicine,
    required this.quantity,
  });

  @override
  List<Object?> get props => [medicine, quantity];
}
