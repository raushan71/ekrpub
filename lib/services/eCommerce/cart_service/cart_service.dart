import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/models/eCommerce/cart/add_to_cart_model.dart';
import 'package:ekray/models/eCommerce/cart/gift_add_model.dart';
import 'package:ekray/services/base/eCommerce/cart_provider_base.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/api_client.dart';

class CartService implements CartProviderBase {
  final Ref ref;
  CartService(this.ref);

  @override
  Future<Response> addToCart({required AddToCartModel addToCartModel}) async {
    final response = await ref.read(apiClientProvider).post(
          AppConstants.addToCart,
          data: addToCartModel.toMap(),
        );
    return response;
  }

  @override
  Future<Response> increentQty({required int productId}) async {
    final response = await ref
        .read(apiClientProvider)
        .post(AppConstants.incrementQty, data: {'product_id': productId});

    return response;
  }

  @override
  Future<Response> decrementQty({required int productId}) async {
    final response = await ref
        .read(apiClientProvider)
        .post(AppConstants.decrementQty, data: {
      'product_id': productId,
    });
    return response;
  }

  @override
  Future<Response> cartSummery({
    required String? couponId,
    required List<int> shopIds,
    int? isBuyNow,
  }) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.cartSummery,
      data: {
        'coupon_code': couponId,
        'shop_ids': shopIds,
        "is_buy_now": isBuyNow
      },
    );
    return response;
  }

  @override
  Future<Response> getAllCarts() async {
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getAllCarts);
    return response;
  }

  @override
  Future<Response> buyNow({
    required int productId,
    required String? couponCode,
    required int quantity,
  }) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.buyNow,
      data: {
        'product_id': productId,
        'coupon_code': couponCode,
        'quantity': quantity,
      },
    );
    return response;
  }

  @override
  Future<Response> getAllGifts({required int shopId}) async {
    final response = await ref
        .read(apiClientProvider)
        .get(AppConstants.getAllGifts, query: {'shop_id': shopId});
    return response;
  }

  @override
  Future<Response> addGiftToCart({required GiftAddModel giftAddModel}) async {
    final userInfo = await ref.read(hiveServiceProvider).getUserInfo();
    final response = await ref.read(apiClientProvider).post(
      AppConstants.addGift,
      data: {...giftAddModel.toMap(), 'sender_name': userInfo?.name},
    );
    return response;
  }

  @override
  Future<Response> deleteGiftFromCart({required int giftId}) async {
    final response = await ref
        .read(apiClientProvider)
        .delete(AppConstants.removeGift, query: {
      'cart_id': giftId,
    });

    return response;
  }
}

final cartServiceProvider = Provider((ref) => CartService(ref));
