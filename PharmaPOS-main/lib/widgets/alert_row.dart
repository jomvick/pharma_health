import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../models/alert.dart';

class AlertRow extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;

  const AlertRow({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: alert.read ? AppColors.white : AppColors.blue50,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: alert.read
              ? BorderSide.none
              : const BorderSide(color: AppColors.blue200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            alert.read ? FontWeight.w500 : FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(alert.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!alert.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.blue600,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Color color;
    IconData icon;

    switch (alert.type) {
      case AlertType.lowStock:
        color = AppColors.orange500;
        icon = LucideIcons.alertTriangle;
        break;
      case AlertType.expiry:
        color = AppColors.red500;
        icon = LucideIcons.calendarClock;
        break;
      case AlertType.sale:
        color = AppColors.green500;
        icon = LucideIcons.checkCircle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
