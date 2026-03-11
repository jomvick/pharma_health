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
      name: json['nom'] ?? json['name'] ?? '',
      manufacturer: json['fournisseur'] ?? json['manufacturer'] ?? '',
      barcode: json['codeBarre'] ?? json['barcode'] ?? '',
      category: json['categorie'] ?? json['category'] ?? '',
      price: (json['prixVente'] ?? json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      minStock: json['seuilAlerte'] ?? json['minStock'] ?? 0,
      batches: json['lots'] != null
          ? (json['lots'] as List).map((b) => Batch.fromJson(b)).toList()
          : [],
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
      number: json['numeroLot'] ?? json['number'] ?? '',
      quantity: json['quantite'] ?? json['quantity'] ?? 0,
      expiryDate: json['dateExpiration'] != null
          ? DateTime.parse(json['dateExpiration'])
          : DateTime.now(),
      supplier: json['fournisseur'] ?? json['supplier'] ?? '',
      purchasePrice: (json['prixAchat'] ?? json['purchasePrice'] ?? 0).toDouble(),
      entryDate: json['dateEntree'] != null
          ? DateTime.parse(json['dateEntree'])
          : DateTime.now(),
    );
  }
}
