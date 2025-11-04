import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/eCommerce/dashboard/dashboard.dart';
import 'package:ekray/services/eCommerce/dashboard_service/dashboard_service.dart';
import 'package:ekray/utils/request_handler.dart';

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, AsyncValue<Dashboard>>((ref) {
  final controller = DashboardController(ref);
  controller.getDashboardData();
  return controller;
});

class DashboardController extends StateNotifier<AsyncValue<Dashboard>> {
  final Ref ref;
  DashboardController(this.ref) : super(const AsyncLoading());

  Future<void> getDashboardData() async {
    try {
      final response =
          await ref.read(dashboardServiceProvider).getDashboardData();
      final data = response.data['data'];
      state = AsyncData(Dashboard.fromMap(data));
    } catch (error, stackTrace) {
      debugPrint(error.toString());

      state = AsyncError(
        error is DioException ? ApiInterceptors.handleError(error) : error,
        stackTrace,
      );
      throw Exception(stackTrace);
    }
  }
}
