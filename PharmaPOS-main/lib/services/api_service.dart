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

  Future<bool> updateMedicine(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/medicines/$id', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('DEBUG: Error updating medicine: $e');
      return false;
    }
  }
}
