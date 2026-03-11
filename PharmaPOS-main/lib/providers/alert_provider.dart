import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert.dart';
import 'medicine_provider.dart';
import '../services/api_service.dart';

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AsyncValue<List<Alert>>>((ref) {
      final dio = ref.watch(dioProvider);
      return AlertsNotifier(dio);
    });

class AlertsNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  final Dio _dio;

  AlertsNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/alerts');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final alerts = data.map((json) => Alert.fromJson(json)).toList();
        state = AsyncValue.data(alerts);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String alertId) async {
    try {
      await _dio.patch('/alerts/$alertId/read');
      // Refresh list after marking as read
      await fetchAlerts();
    } catch (e) {
      print('Error marking alert as read: $e');
    }
  }
}
