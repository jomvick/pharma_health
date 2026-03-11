import 'package:dio/dio.dart';
import '../models/medicine.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<List<Medicine>> getMedicines() async {
    try {
      final response = await _dio.get('/medicines');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Medicine.fromJson(json)).toList();
      }
      throw Exception('Failed to load medicines');
    } catch (e) {
      print('Error fetching medicines: $e');
      return []; // Return empty list or throw depending on how the app handles it
    }
  }

  Future<Medicine?> getMedicineById(String id) async {
    try {
      final response = await _dio.get('/medicines/$id');
      if (response.statusCode == 200) {
         return Medicine.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching medicine $id: $e');
      return null;
    }
  }
}

final mockMedicines = [
  Medicine(
    id: '1',
    name: 'Paracétamol 500mg',
    manufacturer: 'Generic Labs',
    barcode: '3400934268798',
    category: 'Antalgique',
    price: 1.99,
    stock: 150,
    minStock: 50,
    batches: [
      Batch(
        id: 'b1-1',
        number: 'LOT2024A',
        quantity: 100,
        expiryDate: DateTime(2025, 12, 31),
        supplier: 'Grossiste Pharma',
        purchasePrice: 1.50,
        entryDate: DateTime(2023, 3, 8),
      ),
      Batch(
        id: 'b1-2',
        number: 'LOT2024B',
        quantity: 50,
        expiryDate: DateTime(2026, 6, 30),
        supplier: 'Grossiste Pharma',
        purchasePrice: 1.55,
        entryDate: DateTime(2023, 5, 12),
      ),
    ],
  ),
  Medicine(
    id: '2',
    name: 'Amoxicilline 1g',
    manufacturer: 'PharmaPlus',
    barcode: '3400937614487',
    category: 'Antibiotique',
    price: 4.50,
    stock: 35,
    minStock: 20,
    batches: [
      Batch(
        id: 'b2-1',
        number: 'AMX2023C',
        quantity: 35,
        expiryDate: DateTime(2024, 8, 31),
        supplier: 'MediDist',
        purchasePrice: 3.80,
        entryDate: DateTime(2023, 1, 20),
      ),
    ],
  ),
  Medicine(
    id: '3',
    name: 'Ibuprofène 400mg',
    manufacturer: 'Sandoz',
    barcode: '3400936741215',
    category: 'Anti-inflammatoire',
    price: 2.80,
    stock: 210,
    minStock: 75,
    batches: [
      Batch(
        id: 'b3-1',
        number: 'IBU-A2025',
        quantity: 210,
        expiryDate: DateTime(2026, 8, 31),
        supplier: 'Grossiste Pharma',
        purchasePrice: 2.00,
        entryDate: DateTime(2023, 3, 7),
      ),
    ],
  ),
];
