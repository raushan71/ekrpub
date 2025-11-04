import 'package:dio/dio.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_submit_model.dart';

abstract class ReturnProductService {
  Future<Response> submitReturnProduct(
      {required ReturnOrderSubmitModel returnOrder});

  Future<Response> getReturnOrders();
  Future<Response> getReturnOrderDetails({required int orderId});
}
