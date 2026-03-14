import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert.dart';

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AsyncValue<List<Alert>>>((ref) {
      return AlertsNotifier();
    });

class AlertsNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  AlertsNotifier() : super(const AsyncValue.loading()) {
    _fetchAlerts();
  }

  final List<Alert> _alerts = mockAlerts;

  Future<void> _fetchAlerts() async {
    await Future.delayed(const Duration(seconds: 1));
    state = AsyncValue.data(_alerts);
  }

  void markAsRead(String alertId) {
    state.whenData((alerts) {
      final updatedAlerts = alerts.map((alert) {
        if (alert.id == alertId) {
          return Alert(
            id: alert.id,
            title: alert.title,
            message: alert.message,
            date: alert.date,
            type: alert.type,
            read: true,
            medicineId: alert.medicineId,
          );
        }
        return alert;
      }).toList();
      state = AsyncValue.data(updatedAlerts);
    });
  }
}

final mockAlerts = [
  Alert(
    id: '1',
    title: 'Stock bas',
    message: 'Le stock de Paracétamol 500mg est bas (35 restants).',
    date: DateTime.now().subtract(const Duration(minutes: 30)),
    type: AlertType.lowStock,
    medicineId: '1',
  ),
  Alert(
    id: '2',
    title: 'Expiration proche',
    message: 'Un lot d\'Amoxicilline 1g expire dans 25 jours.',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    type: AlertType.expiry,
    medicineId: '2',
    read: true,
  ),
  Alert(
    id: '3',
    title: 'Vente',
    message: 'Vente de 2 boîtes de Ibuprofène 400mg.',
    date: DateTime.now().subtract(const Duration(days: 1)),
    type: AlertType.sale,
    medicineId: '3',
  ),
];
