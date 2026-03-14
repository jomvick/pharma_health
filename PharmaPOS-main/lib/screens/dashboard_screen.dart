import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/medicine_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_widgets.dart';
import '../models/user.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState.role;

    final medicinesAsync = ref.watch(medicinesProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      drawer: const AppDrawer(),
      body: medicinesAsync.when(
        data: (medicines) {
          final totalMedicines = medicines.length;
          final totalStock = medicines.fold<int>(0, (sum, m) => sum + m.stock);
          final lowStockCount = medicines.where((m) => m.stock < m.minStock).length;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, role),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Section
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Médicaments',
                              value: totalMedicines.toString(),
                              icon: LucideIcons.package,
                              color: AppColors.primary500,
                              onTap: () => context.go('/inventory'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Stock total',
                              value: totalStock.toString(),
                              icon: LucideIcons.layers,
                              color: AppColors.secondary500,
                              onTap: () => context.go('/inventory'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Alert Section
                      if (lowStockCount > 0) ...[
                        AlertBanner(
                          count: lowStockCount,
                          onTap: () => context.go('/inventory'),
                        ),
                        const SizedBox(height: 24),
                      ],

                  // Quick Actions
                  const Text(
                    'Actions Rapides',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        QuickActionBtn(
                          label: 'Vente',
                          icon: LucideIcons.shoppingCart,
                          color: AppColors.primary600,
                          onTap: () => context.go('/pos'),
                        ),
                        QuickActionBtn(
                          label: 'Stock',
                          icon: LucideIcons.packagePlus,
                          color: AppColors.success500,
                          onTap: () => context.go('/inventory'),
                        ),
                        QuickActionBtn(
                          label: 'Client',
                          icon: LucideIcons.users,
                          color: AppColors.secondary500,
                          onTap: () => context.go('/clients'),
                        ),
                        QuickActionBtn(
                          label: 'Rapport',
                          icon: LucideIcons.fileBarChart,
                          color: AppColors.warning500,
                          onTap: () => context.go('/reports'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Activités Récentes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ActivityTile(
                    title: 'Vente #9382',
                    subtitle: 'Paratécamaol, Amoxicilline (+2)',
                    time: 'Il y a 2 min',
                    icon: LucideIcons.receipt,
                    iconColor: AppColors.primary500,
                  ),
                  const ActivityTile(
                    title: 'Réapprovisionnement',
                    subtitle: 'Doliprane 500mg (10 boites)',
                    time: 'Il y a 15 min',
                    icon: LucideIcons.packagePlus,
                    iconColor: AppColors.success500,
                  ),
                  const ActivityTile(
                    title: 'Alerte Stock Bas',
                    subtitle: 'Efferalgan 1g',
                    time: 'Il y a 1h',
                    icon: LucideIcons.alertTriangle,
                    iconColor: AppColors.alert500,
                  ),
                  
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserRole? role) {
    return SliverAppBar(
      backgroundColor: AppColors.primary600,
      foregroundColor: AppColors.white,
      pinned: true,
      expandedHeight: 140.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bonjour 👋',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white70,
                ),
              ),
              Text(
                role == UserRole.admin ? 'Administrateur' : 
                role == UserRole.pharmacist ? 'Pharmacien' : 'Caissier',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary600, AppColors.primary700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  LucideIcons.stethoscope,
                  size: 160,
                  color: AppColors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
