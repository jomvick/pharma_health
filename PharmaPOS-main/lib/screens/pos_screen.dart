import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../models/medicine.dart';
import '../providers/cart_provider.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Point de Vente'),
        backgroundColor: AppColors.white,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher médicament...',
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: medicinesAsync.when(
        data: (medicines) => _buildMedicineList(medicines),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCart(context),
              label: Text('${ref.watch(cartProvider.notifier).totalItems}'),
              icon: const Icon(LucideIcons.shoppingCart),
              backgroundColor: AppColors.blue600,
            )
          : null,
    );
  }

  Widget _buildMedicineList(List<Medicine> medicines) {
    final filteredMedicines = medicines.where((medicine) {
      return medicine.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          medicine.barcode.contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMedicines.length,
      itemBuilder: (context, index) {
        final medicine = filteredMedicines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MedicineCard(
            medicine: medicine,
            onTap: () {
              ref.read(cartProvider.notifier).addToCart(medicine);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ajouté au panier'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 1.0,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const CartView(),
          );
        },
      ),
    );
  }
}

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Panier (${cartNotifier.totalItems})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => context.pop(),
              )
            ],
          ),
        ),
        if (cart.isEmpty)
          const Expanded(
            child: Center(child: Text('Le panier est vide')),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final cartItem = cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                cartItem.medicine.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2,
                                  color: AppColors.red500),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .removeFromCart(cartItem.medicine.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.minus),
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                          cartItem.medicine.id, -1),
                                ),
                                Text('${cartItem.quantity}'),
                                IconButton(
                                  icon: const Icon(LucideIcons.plus),
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                          cartItem.medicine.id, 1),
                                ),
                              ],
                            ),
                            Text(
                              '${(cartItem.medicine.price * cartItem.quantity).toStringAsFixed(2)} FCFA',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${cartNotifier.totalPrice.toStringAsFixed(2)} FCFA',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Mock checkout
                    cartNotifier.clearCart();
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vente confirmée')),
                    );
                  },
                  icon: const Icon(LucideIcons.receipt),
                  label: const Text('Valider la vente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green600,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}
