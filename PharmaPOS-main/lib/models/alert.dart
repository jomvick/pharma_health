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
}
