import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app_colors.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _priceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _initialStockController = TextEditingController();
  final _expirationController = TextEditingController();
  DateTime? _expirationDate;

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _manufacturerController.dispose();
    _priceController.dispose();
    _minStockController.dispose();
    _initialStockController.dispose();
    _expirationController.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      helpText: 'Date d\'expiration',
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
        _expirationController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _addMedicine() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would add the medicine to the API
      context.go('/inventory');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Médicament ajouté (simulation)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inventory'),
        ),
        title: const Text('Nouveau médicament'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                _nameController,
                'Nom du médicament',
                Icons.medication,
              ),
              _buildTextField(
                _barcodeController,
                'Code-barres',
                Icons.qr_code_scanner,
              ),
              _buildTextField(
                _categoryController,
                'Catégorie',
                Icons.label_outline,
              ),
              _buildTextField(
                _manufacturerController,
                'Fabricant',
                Icons.business,
              ),
              _buildTextField(
                _priceController,
                'Prix de vente',
                Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _minStockController,
                'Stock minimum',
                Icons.warning_amber_outlined,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(_initialStockController, 'Stock initial (optionnel)', Icons.inventory, keyboardType: TextInputType.number, required: false),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _expirationController,
                  readOnly: true,
                  onTap: _pickExpirationDate,
                  decoration: InputDecoration(
                    labelText: 'Date d\'expiration',
                    prefixIcon: const Icon(Icons.calendar_today, color: AppColors.gray400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Ajouter le médicament'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.gray400),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Ce champ est requis';
          }
          return null;
        },
      ),
    );
  }
}
