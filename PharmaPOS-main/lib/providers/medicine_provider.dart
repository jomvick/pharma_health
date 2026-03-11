import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/medicine.dart';
import '../services/api_service.dart';
import '../services/api_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5000/api'),
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  dio.interceptors.add(ApiInterceptor());
  
  return dio;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

final medicinesProvider = FutureProvider<List<Medicine>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getMedicines();
});

final medicineProvider =
    FutureProvider.family<Medicine?, String>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getMedicineById(id);
});
