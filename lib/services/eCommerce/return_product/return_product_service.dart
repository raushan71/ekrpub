import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_submit_model.dart';
import 'package:ekray/services/base/eCommerce/return_product_base.dart';
import 'package:ekray/utils/api_client.dart';

final returnProductServiceProvider =
    Provider((ref) => ReturnProductServiceImpl(ref));

class ReturnProductServiceImpl implements ReturnProductService {
  final Ref ref;

  ReturnProductServiceImpl(this.ref);

  @override
  Future<Response> submitReturnProduct(
      {required ReturnOrderSubmitModel returnOrder}) async {
    final response = await ref.read(apiClientProvider).post(
          AppConstants.returnOrderSubmit,
          data: returnOrder.toMap(),
        );
    return response;
  }

  @override
  Future<Response> getReturnOrders() async {
    return await ref.read(apiClientProvider).get(AppConstants.returnOrdersList);
  }

  @override
  Future<Response> getReturnOrderDetails({required int orderId}) async {
    final response = await ref.read(apiClientProvider).get(
          '${AppConstants.returnOrderDetails}/$orderId',
        );
    return response;
  }
}
