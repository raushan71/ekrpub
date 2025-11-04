import 'package:dio/dio.dart';
import 'package:ekray/models/eCommerce/cart/add_to_cart_model.dart';
import 'package:ekray/models/eCommerce/cart/gift_add_model.dart';

abstract class CartProviderBase {
  Future<Response> addToCart({required AddToCartModel addToCartModel});
  Future<Response> increentQty({required int productId});
  Future<Response> decrementQty({required int productId});
  Future<Response> getAllCarts();
  Future<Response> getAllGifts({required int shopId});
  Future<Response> addGiftToCart({required GiftAddModel giftAddModel});
  Future<Response> deleteGiftFromCart({required int giftId});
  Future<Response> cartSummery({
    required String? couponId,
    required List<int> shopIds,
  });
  Future<Response> buyNow({
    required int productId,
    required String couponCode,
    required int quantity,
  });
}
