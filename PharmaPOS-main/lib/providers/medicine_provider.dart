import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../services/api_service.dart';

final medicinesProvider = FutureProvider<List<Medicine>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMedicines();
});

final medicineProvider =
    FutureProvider.family<Medicine?, String>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMedicineById(id);
});
