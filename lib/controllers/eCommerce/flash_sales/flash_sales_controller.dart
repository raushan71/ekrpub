import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/eCommerce/flash_sales_list_model/running_flash_sale.dart';
import 'package:ekray/models/eCommerce/product/product.dart';
import 'package:ekray/services/eCommerce/flash_sales/flash_sales_service.dart';

final flashSalesListControllerProvider =
    StateNotifierProvider<FlashSalesListController, bool>((ref) {
  return FlashSalesListController(ref);
});

class FlashSalesListController extends StateNotifier<bool> {
  final Ref ref;
  FlashSalesListController(this.ref) : super(false) {
    getFlashSalesList();
  }
  RunningFlashSale? runningFlashSale;
  Future<void> getFlashSalesList() async {
    try {
      state = true;
      final response =
          await ref.read(flashSalesServiceProvider).getFlashSalesList();
      final data = response.data['data']["running_flash_sale"];
      if (data != null) {
        runningFlashSale = RunningFlashSale.fromMap(data);
      } else {
        runningFlashSale = null;
      }

      state = false;
    } catch (e, stk) {
      state = false;
      debugPrint(e.toString());
      debugPrint(stk.toString());
    }
  }
}

final flashSaleDetailsControllerProvider =
    StateNotifierProvider<FlashSalesDetailsController, bool>((ref) {
  return FlashSalesDetailsController(ref);
});

class FlashSalesDetailsController extends StateNotifier<bool> {
  final Ref ref;
  FlashSalesDetailsController(this.ref) : super(false);
  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> getFlashSalesDetails({required int id}) async {
    try {
      state = true;
      final response =
          await ref.read(flashSalesServiceProvider).getFlashSalesDetail(id: id);
      final List<dynamic> data = response.data['data']["products"];
      _products = data.map((product) => Product.fromMap(product)).toList();
      state = false;
    } catch (e, stk) {
      state = false;
      debugPrint(e.toString());
      debugPrint(stk.toString());
    }
  }
}
