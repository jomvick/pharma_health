import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

class MedicineDetailScreen extends ConsumerWidget {
  final String medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicineAsync = ref.watch(medicineProvider(medicineId));

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Détail du médicament'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: medicineAsync.when(
        data: (medicine) {
          if (medicine == null) {
            return const Center(child: Text('Médicament non trouvé'));
          }
          return _buildMedicineDetails(context, medicine);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMedicineDetails(BuildContext context, Medicine medicine) {
    final isLowStock = medicine.stock < medicine.minStock;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLowStock) ...[
            _buildLowStockWarning(medicine),
            const SizedBox(height: 16),
          ],
          _buildInfoCard(medicine),
          const SizedBox(height: 16),
          _buildBatchesCard(medicine),
        ],
      ),
    );
  }

  Widget _buildLowStockWarning(Medicine medicine) {
    return Card(
      color: AppColors.orange100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(LucideIcons.alertTriangle, color: AppColors.orange600),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Le stock actuel (${medicine.stock}) est inférieur au seuil minimum (${medicine.minStock})',
                style: const TextStyle(color: AppColors.orange600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Medicine medicine) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Stock disponible', '${medicine.stock}',
                isLowStock: medicine.stock < medicine.minStock),
            _buildInfoRow('Stock minimum', '${medicine.minStock}'),
            _buildInfoRow('Prix de vente', '${medicine.price.toStringAsFixed(2)} FCFA'),
            _buildInfoRow('Catégorie', medicine.category),
            _buildInfoRow('Code-barres', medicine.barcode),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLowStock = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.gray600)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLowStock ? AppColors.red600 : AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesCard(Medicine medicine) {
    final sortedBatches = [...medicine.batches]..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lots en stock (${medicine.batches.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedBatches.map((batch) => _buildBatchRow(batch)),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchRow(Batch batch) {
    final daysUntilExpiry = batch.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 30;
    final isExpired = daysUntilExpiry < 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(batch.number, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Quantité: ${batch.quantity}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expire le: ${batch.expiryDate.day}/${batch.expiryDate.month}/${batch.expiryDate.year}'),
                if (isExpiringSoon || isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.red100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isExpired ? 'Expiré' : '$daysUntilExpiry j',
                      style: const TextStyle(color: AppColors.red600, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
