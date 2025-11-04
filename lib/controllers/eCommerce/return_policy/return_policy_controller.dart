import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/eCommerce/common/common_response.dart';
import 'package:ekray/models/eCommerce/order/order_details_model.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_details_model/return_order_details_model.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_list_model/return_order_list_model.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_submit_model.dart';
import 'package:ekray/services/eCommerce/return_product/return_product_service.dart';
import 'package:ekray/utils/request_handler.dart';

final selectedReturnProductProvider =
    StateNotifierProvider<SelectedReturnProduct, List<Products>>(
        (ref) => SelectedReturnProduct());

final returnSubmitControllerProvider =
    StateNotifierProvider<ReturnProductSubmitController, bool>(
        (ref) => ReturnProductSubmitController(ref));

final returnOrderListProvider = StateNotifierProvider<ReturnOrderListController,
    AsyncValue<ReturnOrderListModel>>(
  (ref) => ReturnOrderListController(ref),
);

final returnOrderDetailsControllerProvider = StateNotifierProvider.family
    .autoDispose<ReturnOrderDetailsController,
        AsyncValue<ReturnOrderDetailsModel>, int>((ref, shopId) {
  final controller = ReturnOrderDetailsController(ref);
  controller.getReturnOrderDetails(orderId: shopId);
  return controller;
});

class SelectedReturnProduct extends StateNotifier<List<Products>> {
  SelectedReturnProduct() : super([]);

  void toggleProductSelection(Products product) {
    if (state.contains(product)) {
      state = state.where((item) => item != product).toList();
    } else {
      state = [...state, product];
    }
  }

  void clearSelection() {
    state = [];
  }
}

class ReturnProductSubmitController extends StateNotifier<bool> {
  final Ref ref;
  ReturnProductSubmitController(this.ref) : super(false);

  Future<CommonResponse> submitReturnProduct(
      {required ReturnOrderSubmitModel returnOrder}) async {
    state = true;
    final response = await ref
        .read(returnProductServiceProvider)
        .submitReturnProduct(returnOrder: returnOrder);
    final String message = response.data['message'];
    if (response.statusCode == 200) {
      state = false;

      return CommonResponse(isSuccess: true, message: message);
    }
    state = false;
    return CommonResponse(isSuccess: false, message: message);
  }
}

class ReturnOrderListController
    extends StateNotifier<AsyncValue<ReturnOrderListModel>> {
  final Ref ref;

  ReturnOrderListController(this.ref) : super(const AsyncValue.loading());

  Future<void> fetchReturnOrders() async {
    try {
      state = const AsyncValue.loading();

      final response =
          await ref.read(returnProductServiceProvider).getReturnOrders();

      final model = ReturnOrderListModel.fromMap(response.data);

      state = AsyncValue.data(model);
    } catch (e, st) {
      debugPrint("Error fetching return orders: $e");
      debugPrint("Error fetching return orders: $st");

      state = AsyncValue.error(e, st);
    }
  }
}

class ReturnOrderDetailsController
    extends StateNotifier<AsyncValue<ReturnOrderDetailsModel>> {
  final Ref ref;

  ReturnOrderDetailsController(
    this.ref,
  ) : super(const AsyncValue.loading());

  Future<void> getReturnOrderDetails({required int orderId}) async {
    try {
      final response = await ref
          .read(returnProductServiceProvider)
          .getReturnOrderDetails(orderId: orderId);
      state = AsyncData(ReturnOrderDetailsModel.fromMap(response.data));
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      state = AsyncError(
          error is DioException ? ApiInterceptors.handleError(error) : error,
          stackTrace);
    }
  }
}
