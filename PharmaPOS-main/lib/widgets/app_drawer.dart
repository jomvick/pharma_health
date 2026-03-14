import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../app_colors.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState.role;

    String roleName = 'Utilisateur';
    if (role == UserRole.admin) roleName = 'Administrateur';
    if (role == UserRole.pharmacist) roleName = 'Pharmacien';
    if (role == UserRole.seller) roleName = 'Caissier';

    return Drawer(
      backgroundColor: AppColors.surface,
      elevation: 0,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary600,
            ),
            accountName: const Text(
              'Profil Utilisateur',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
            accountEmail: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white20,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                roleName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.white,
                ),
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.white,
              child: Icon(
                Icons.person,
                color: AppColors.primary600,
                size: 40,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (role == UserRole.admin || role == UserRole.pharmacist)
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Tableau de bord',
                    onTap: () {
                      context.pop();
                      context.go('/dashboard');
                    },
                  ),
                _buildDrawerItem(
                  context,
                  icon: Icons.point_of_sale,
                  title: 'Point de vente',
                  onTap: () {
                    context.pop();
                    context.go('/pos');
                  },
                ),
                if (role == UserRole.admin || role == UserRole.pharmacist)
                  _buildDrawerItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventaire',
                    onTap: () {
                      context.pop();
                      context.go('/inventory');
                    },
                  ),
                const Divider(color: AppColors.border),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alert100,
                foregroundColor: AppColors.alert600,
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gray600),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.gray900,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: AppColors.gray100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
