import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../models/alert.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_row.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: alertsAsync.when(
        data: (alerts) => _buildAlertList(context, ref, alerts),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildAlertList(BuildContext context, WidgetRef ref, List<Alert> alerts) {
    if (alerts.isEmpty) {
      return const Center(child: Text('Aucune notification'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AlertRow(
            alert: alert,
            onTap: () {
              ref.read(alertsProvider.notifier).markAsRead(alert.id);
            },
          ),
        );
      },
    );
  }
}
