class Medicine {
  final String id;
  final String name;
  final String manufacturer;
  final String barcode;
  final String category;
  final double price;
  final int stock;
  final int minStock;
  final List<Batch> batches;

  Medicine({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.barcode,
    required this.category,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.batches,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      manufacturer: json['manufacturer'] ?? json['fournisseur'] ?? '',
      barcode: json['barcode'] ?? json['codeBarre'] ?? '',
      category: json['category'] ?? json['categorie'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 
             (json['prixVente'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock_quantity'] ?? json['stock'] ?? 0,
      minStock: json['min_threshold'] ?? json['seuilAlerte'] ?? json['minStock'] ?? 0,
      batches: (json['batches'] as List?)
              ?.map((b) => Batch.fromJson(b))
              .toList() ??
          [],
    );
  }
}

class Batch {
  final String id;
  final String number;
  final int quantity;
  final DateTime expiryDate;
  final String supplier;
  final double purchasePrice;
  final DateTime entryDate;

  Batch({
    required this.id,
    required this.number,
    required this.quantity,
    required this.expiryDate,
    required this.supplier,
    required this.purchasePrice,
    required this.entryDate,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['_id'] ?? json['id'] ?? '',
      number: json['number'] ?? json['numeroLot'] ?? '',
      quantity: json['quantity'] ?? json['quantite'] ?? 0,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : json['dateExpiration'] != null
            ? DateTime.parse(json['dateExpiration'])
            : DateTime.now(),
      supplier: json['supplier'] ?? json['fournisseur'] ?? '',
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 
                     (json['prixAchat'] as num?)?.toDouble() ?? 0.0,
      entryDate: json['entryDate'] != null
          ? DateTime.parse(json['entryDate'])
          : json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
    );
  }
}
