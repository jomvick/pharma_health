import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicinesAsync = ref.watch(medicinesProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Inventaire'),
        backgroundColor: AppColors.white,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(LucideIcons.search),
                    filled: true,
                    fillColor: AppColors.gray100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('all', 'Tout'),
                      _buildFilterChip('low-stock', 'Stock bas'),
                      _buildFilterChip('expiring', 'Expiration'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: medicinesAsync.when(
        data: (medicines) => _buildMedicineList(medicines),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-medicine'),
        backgroundColor: AppColors.green600,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final bool isSelected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterType = selected ? type : 'all';
          });
        },
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.blue600,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.gray900,
        ),
        checkmarkColor: AppColors.white,
      ),
    );
  }

  Widget _buildMedicineList(List<Medicine> medicines) {
    final filteredMedicines = medicines.where((medicine) {
      final matchesSearch = medicine.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          medicine.barcode.contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_filterType == 'low-stock') {
        return medicine.stock < medicine.minStock;
      } else if (_filterType == 'expiring') {
        final nearestExpiry = medicine.batches.isNotEmpty
            ? medicine.batches
                .map((b) => b.expiryDate)
                .reduce((a, b) => a.isBefore(b) ? a : b)
            : null;
        return nearestExpiry != null &&
            nearestExpiry.difference(DateTime.now()).inDays <= 30;
      }

      return true;
    }).toList();

    if (filteredMedicines.isEmpty) {
      return const Center(child: Text('Aucun médicament trouvé'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMedicines.length,
      itemBuilder: (context, index) {
        final medicine = filteredMedicines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MedicineCard(
            medicine: medicine,
            onTap: () => context.go('/medicine/${medicine.id}'),
          ),
        );
      },
    );
  }
}
