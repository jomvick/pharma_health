import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_colors.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

class StockEntryScreen extends ConsumerStatefulWidget {
  const StockEntryScreen({super.key});

  @override
  ConsumerState<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends ConsumerState<StockEntryScreen> {
  int _currentStep = 0;
  Medicine? _selectedMedicine;
  final _formKey = GlobalKey<FormState>();

  final _quantityController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _supplierController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrée de stock'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_selectedMedicine != null) {
              setState(() => _currentStep++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez sélectionner un médicament')),
              );
            }
          } else if (_currentStep == 1) {
            if (_formKey.currentState!.validate()) {
              setState(() => _currentStep++);
            }
          } else if (_currentStep == 2) {
            // Handle confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entrée de stock enregistrée')),
            );
            Navigator.of(context).pop();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(
            title: const Text('Sélectionner un médicament'),
            content: _buildMedicineSelection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Informations du lot'),
            content: _buildLotForm(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Confirmation'),
            content: _buildConfirmation(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSelection() {
    final medicinesAsync = ref.watch(medicinesProvider);
    return medicinesAsync.when(
      data: (medicines) => DropdownButtonFormField<Medicine>(
        value: _selectedMedicine,
        onChanged: (Medicine? newValue) {
          setState(() {
            _selectedMedicine = newValue;
          });
        },
        items: medicines.map<DropdownMenuItem<Medicine>>((Medicine medicine) {
          return DropdownMenuItem<Medicine>(
            value: medicine,
            child: Text(medicine.name),
          );
        }).toList(),
        decoration: const InputDecoration(labelText: 'Médicament'),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, s) => const Text('Erreur'),
    );
  }

  Widget _buildLotForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantité'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Champ requis' : null,
          ),
          TextFormField(
            controller: _batchNumberController,
            decoration: const InputDecoration(labelText: 'Numéro de lot'),
            validator: (value) => value!.isEmpty ? 'Champ requis' : null,
          ),
          TextFormField(
            controller: _expiryDateController,
            decoration: const InputDecoration(labelText: 'Date d\'expiration (YYYY-MM-DD)') ,
            validator: (value) => value!.isEmpty ? 'Champ requis' : null,
          ),
          TextFormField(
            controller: _supplierController,
            decoration: const InputDecoration(labelText: 'Fournisseur'),
            validator: (value) => value!.isEmpty ? 'Champ requis' : null,
          ),
          TextFormField(
            controller: _purchasePriceController,
            decoration: const InputDecoration(labelText: 'Prix d\'achat unitaire'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Champ requis' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    if (_selectedMedicine == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Médicament: ${_selectedMedicine!.name}'),
        Text('Quantité: ${_quantityController.text}'),
        Text('Lot: ${_batchNumberController.text}'),
        Text('Expiration: ${_expiryDateController.text}'),
        Text('Fournisseur: ${_supplierController.text}'),
        Text('Prix d\'achat: ${_purchasePriceController.text}'),
      ],
    );
  }
}
