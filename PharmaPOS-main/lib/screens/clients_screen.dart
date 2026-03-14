import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../app_colors.dart';
import '../widgets/app_drawer.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Gestion des Clients'),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.users, size: 80, color: AppColors.gray400),
            const SizedBox(height: 16),
            const Text(
              'Gestion des Clients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette fonctionnalité sera disponible prochainement.',
              style: TextStyle(color: AppColors.gray500),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Retour au Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
