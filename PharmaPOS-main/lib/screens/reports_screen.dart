import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../widgets/app_drawer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Rapports et Statistiques'),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rapports Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 20),
            _buildReportCard(
              context,
              title: 'Rapport d\'Inventaire',
              description: 'État actuel des stocks et alertes.',
              icon: LucideIcons.box,
              color: AppColors.primary600,
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              title: 'Rapport de Ventes',
              description: 'Analyse des ventes par période.',
              icon: LucideIcons.trendingUp,
              color: AppColors.success600,
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              title: 'Rapport Financier',
              description: 'Revenus et marges (Bientôt disponible).',
              icon: LucideIcons.dollarSign,
              color: AppColors.warning600,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    bool enabled = true,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gray200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: enabled ? AppColors.gray900 : AppColors.gray400,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: AppColors.gray500),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: AppColors.gray400),
        onTap: enabled ? () {} : null,
      ),
    );
  }
}
