import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/services/base/eCommerce/message_provider_base.dart';
import 'package:ekray/utils/api_client.dart';

final messageServiceProvider = Provider((ref) => MessageService(ref));

class MessageService implements MessageProviderBase {
  final Ref ref;
  MessageService(this.ref);

  @override
  Future<Response> getShops({String? search}) async {
    final response = await ref
        .read(apiClientProvider)
        .get(AppConstants.getShopsList, query: {'search': search});
    return response;
  }

  @override
  Future<Response> getMessages(
      {required int shopId, required int page, required int perPage}) {
    final response =
        ref.read(apiClientProvider).get(AppConstants.getMessage, query: {
      'shop_id': shopId,
      'page': page,
      'per_page': perPage,
    });
    return response;
  }

  @override
  Future<Response> sendMessage(
      {required int shopId, required String type, required String message}) {
    final response =
        ref.read(apiClientProvider).post(AppConstants.sendMessage, data: {
      'shop_id': shopId,
      'type': type,
      'message': message,
    });
    return response;
  }

  @override
  Future<Response> storeMessage(
      {required int shopId,
      required int userId,
      int? productId,
      required String type}) {
    final response = ref.read(apiClientProvider).post(
      AppConstants.storeMessage,
      data: {
        'shop_id': shopId,
        'user_id': userId,
        'product_id': productId,
        'type': type,
      },
    );
    return response;
  }

  @override
  Future<Response> getTotalUn(
      {required int shopId, required int page, required int perPage}) {
    final response =
        ref.read(apiClientProvider).get(AppConstants.getMessage, query: {
      'shop_id': shopId,
      'page': page,
      'per_page': perPage,
    });
    return response;
  }

  @override
  Future<Response> getTotalUnreadMessages() {
    Map<dynamic, dynamic>? userInfo =
        Hive.box(AppConstants.userBox).get(AppConstants.userData);
    final userId = userInfo?['id'];
    debugPrint("User ID: $userId");

    final response =
        ref.read(apiClientProvider).get(AppConstants.unreadMessage, query: {
      'user_id': userId,
    });
    return response;
  }
}
