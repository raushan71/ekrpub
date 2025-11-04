import 'package:dio/dio.dart';
import 'package:ekray/models/eCommerce/order/add_product_review_model.dart';
import 'package:ekray/models/eCommerce/order/buy_now_order_place.dart';
import 'package:ekray/models/eCommerce/order/order_place_model.dart';

abstract class OrderProviderBase {
  Future<Response> placeOrder({required OrderPlaceModel orderPlaceModel});
  Future<Response> buyNow({required BuyNowOrderPlace orderPlaceModel});
  Future<Response> orderAgain(
      {required int orderId, required String paymentMethod});
  Future<Response> getOrders({
    required String? orderStatus,
    required int page,
    required int perPage,
  });
  Future<Response> getOrderDetails({required int orderId});
  Future<Response> cancelOrder({required int orderId});
  Future<Response> addProductReview(
      {required AddProductReviewModel addProductReviewModel});
}
