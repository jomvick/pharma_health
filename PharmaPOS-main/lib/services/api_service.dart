import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../providers/token_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final token = ref.watch(tokenProvider);
  
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.get('API_URL', fallback: 'https://pharma-health.onrender.com/api'),
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  if (token != null) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));
  }

  return ApiService(dio);
});

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<List<Medicine>> getMedicines() async {
    try {
      final response = await _dio.get('/medicines');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['medicines'] ?? response.data;
        return data.map((m) => Medicine.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      print('DEBUG: Error getting medicines: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Medicine?> getMedicineById(String id) async {
    try {
      final response = await _dio.get('/medicines/$id');
      if (response.statusCode == 200) {
        final data = response.data['medicine'] ?? response.data;
        return Medicine.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createMedicine(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/medicines', data: data);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('DEBUG: Error creating medicine: $e');
      return false;
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
