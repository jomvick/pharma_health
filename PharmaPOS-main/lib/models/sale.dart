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

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['_id'] ?? json['id'] ?? '',
      items: (json['items'] as List?)?.map((i) => CartItem.fromJson(i)).toList() ?? [],
      total: (json['total'] ?? 0).toDouble(),
      date: json['horodatage'] != null ? DateTime.parse(json['horodatage']) : DateTime.now(),
    );
  }

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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      medicine: Medicine.fromJson(json['medicineRef'] ?? json['medicine']),
      quantity: json['quantite'] ?? json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine': medicine.id,
      'quantite': quantity,
      'prixUnitaire': medicine.price,
    };
  }

  @override
  List<Object?> get props => [medicine, quantity];
}
