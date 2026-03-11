enum AlertType { lowStock, expiry, sale }

class Alert {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final AlertType type;
  final bool read;
  final String? medicineId;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.read = false,
    this.medicineId,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    AlertType type = AlertType.lowStock;
    if (json['type'] == 'expiration' || json['type'] == 'expiry') {
      type = AlertType.expiry;
    } else if (json['type'] == 'sale') {
      type = AlertType.sale;
    }

    return Alert(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? (type == AlertType.lowStock ? 'Stock bas' : 'Alerte'),
      message: json['message'] ?? '',
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      type: type,
      read: json['lu'] ?? json['read'] ?? false,
      medicineId: json['medicineId'] ?? json['medicineRef']?['_id'] ?? json['medicineRef'],
    );
  }
}
