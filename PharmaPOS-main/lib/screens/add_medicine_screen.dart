import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../providers/medicine_provider.dart';
import '../services/api_service.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  final String? medicineId;
  const AddMedicineScreen({super.key, this.medicineId});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _initialStockController = TextEditingController();
  final _expirationController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedManufacturer;
  DateTime? _expirationDate;
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _categories = ['Analgésiques', 'Antibiotiques', 'Vitamines', 'Antipaludéens', 'Cardiologie', 'Autres'];
  final List<String> _manufacturers = ['Sanofi', 'Pfizer', 'GSK', 'Bayer', 'Innotech', 'Local Lab'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.medicineId != null;
    if (_isEditMode) {
      _loadMedicineData();
    }
  }

  Future<void> _loadMedicineData() async {
    setState(() => _isLoading = true);
    try {
      final medicine = await ref.read(apiServiceProvider).getMedicineById(widget.medicineId!);
      if (medicine != null) {
        _nameController.text = medicine.name;
        _barcodeController.text = medicine.barcode;
        _priceController.text = medicine.price.toString();
        _minStockController.text = medicine.minStock.toString();
        _selectedCategory = _categories.contains(medicine.category) ? medicine.category : null;
        _selectedManufacturer = _manufacturers.contains(medicine.manufacturer) ? medicine.manufacturer : null;
        
        if (medicine.batches.isNotEmpty) {
          final expiry = medicine.batches.first.expiryDate;
          _expirationDate = expiry;
          _expirationController.text = '${expiry.day.toString().padLeft(2, '0')}/${expiry.month.toString().padLeft(2, '0')}/${expiry.year}';
        }
      }
    } catch (e) {
      print('Error loading medicine: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary600,
              onPrimary: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
      helpText: 'Date d\'expiration',
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
        _expirationController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _addMedicine() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final apiService = ref.read(apiServiceProvider);
        
        // Payload simplifié pour correspondre exactement au CreateMedicineDto du backend
        final medicineData = {
          'name': _nameController.text, 
          'category': _selectedCategory,
          'codeBarre': _barcodeController.text,
          'fournisseur': _selectedManufacturer,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'min_threshold': int.tryParse(_minStockController.text) ?? 5,
          'stock_quantity': int.tryParse(_initialStockController.text) ?? 1, // Assurer au moins 1 si possible
          'expiry_date': _expirationDate?.toIso8601String(),
        };

        print('DEBUG: Sending medicine data: $medicineData');
        
        bool success;
        if (_isEditMode) {
          success = await apiService.updateMedicine(widget.medicineId!, medicineData);
        } else {
          success = await apiService.createMedicine(medicineData);
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (success) {
          ref.invalidate(medicinesProvider);
          if (_isEditMode) {
            ref.invalidate(medicineProvider(widget.medicineId!));
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode ? 'Médicament mis à jour !' : 'Médicament enregistré dans la base Atlas !'),
              backgroundColor: AppColors.success600,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          context.go('/inventory');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de l\'opération. Vérifiez votre connexion ou les données.'),
              backgroundColor: AppColors.alert500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        print('DEBUG: Error in _addMedicine: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur serveur : $e'),
              backgroundColor: AppColors.alert500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => _isEditMode ? context.go('/medicine/${widget.medicineId}') : context.go('/inventory'),
        ),
        title: Text(_isEditMode ? 'Modifier le Médicament' : 'Nouveau Médicament'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading && _isEditMode && _nameController.text.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(LucideIcons.info, 'Informations Générales'),
                  _buildFormCard([
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nom du médicament',
                      hint: 'Ex: Doliprane 500mg',
                      icon: LucideIcons.pill,
                    ),
                    _buildTextField(
                      controller: _barcodeController,
                      label: 'Code-barres',
                      hint: 'Scanner ou saisir le code',
                      icon: LucideIcons.qrCode,
                    ),
                _buildDropdown(
                  label: 'Catégorie',
                  value: _selectedCategory,
                  items: _categories,
                  icon: LucideIcons.tag,
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                _buildDropdown(
                  label: 'Fabricant',
                  value: _selectedManufacturer,
                  items: _manufacturers,
                  icon: LucideIcons.factory,
                  onChanged: (val) => setState(() => _selectedManufacturer = val),
                ),
              ]),
              
              const SizedBox(height: 24),
              _buildSectionHeader(LucideIcons.banknote, 'Prix et Vente'),
              _buildFormCard([
                _buildTextField(
                  controller: _priceController,
                  label: 'Prix de vente (FCFA)',
                  hint: '0.00',
                  icon: LucideIcons.dollarSign,
                  keyboardType: TextInputType.number,
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader(LucideIcons.box, 'Stock et Logistique'),
              _buildFormCard([
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _initialStockController,
                        label: 'Stock Initial',
                        hint: '0',
                        icon: LucideIcons.package,
                        keyboardType: TextInputType.number,
                        required: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _minStockController,
                        label: 'Stock Alerte',
                        hint: '5',
                        icon: LucideIcons.alertCircle,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  controller: _expirationController,
                  label: 'Date d\'expiration',
                  hint: 'JJ/MM/AAAA',
                  icon: LucideIcons.calendar,
                  readOnly: true,
                  onTap: _pickExpirationDate,
                ),
              ]),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.primary600.withOpacity(0.4),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enregistrer le Médicament',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary600),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.gray500,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.gray400),
              prefixIcon: Icon(icon, color: AppColors.gray400, size: 20),
              filled: true,
              fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.alert500, width: 1),
              ),
            ),
            validator: (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            decoration: InputDecoration(
              hintText: 'Choisir...',
              hintStyle: const TextStyle(color: AppColors.gray400),
              prefixIcon: Icon(icon, color: AppColors.gray400, size: 20),
              filled: true,
              fillColor: AppColors.gray50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
