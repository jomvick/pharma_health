import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/kpi_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data for the dashboard
    const totalMedicines = 125;
    const totalStock = 8590;
    const lowStockCount = 12;
    const unreadAlerts = 5;

    final stats = [
      {
        'label': 'Médicaments',
        'value': totalMedicines.toString(),
        'icon': LucideIcons.package,
        'color': AppColors.blue500,
        'action': () => GoRouter.of(context).go('/inventory')
      },
      {
        'label': 'Stock total',
        'value': totalStock.toString(),
        'icon': LucideIcons.trendingUp,
        'color': AppColors.green500,
        'action': () => GoRouter.of(context).go('/inventory')
      },
      {
        'label': 'Alertes stock',
        'value': lowStockCount.toString(),
        'icon': LucideIcons.alertTriangle,
        'color': AppColors.orange500,
        'action': () => GoRouter.of(context).go('/inventory')
      },
      {
        'label': 'Notifications',
        'value': unreadAlerts.toString(),
        'icon': LucideIcons.bell,
        'color': AppColors.red500,
        'action': () => GoRouter.of(context).go('/notifications')
      }
    ];

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.blue600,
            foregroundColor: AppColors.white,
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: const Text('Tableau de bord'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue600, AppColors.blue700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.logOut),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  GoRouter.of(context).go('/login');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: stats.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      return KpiCard(
                        label: stat['label'] as String,
                        value: stat['value'] as String,
                        icon: stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        onTap: stat['action'] as VoidCallback,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Actions rapides',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionCard(
                    context,
                    label: 'Nouvelle vente',
                    description: 'Point de vente',
                    icon: LucideIcons.shoppingCart,
                    color: AppColors.blue600,
                    onTap: () => GoRouter.of(context).go('/pos'),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    context,
                    label: 'Consulter stock',
                    description: 'Inventaire',
                    icon: LucideIcons.package,
                    color: AppColors.purple600,
                    onTap: () => GoRouter.of(context).go('/inventory'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String label,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
