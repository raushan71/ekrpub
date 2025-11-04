import 'package:dio/dio.dart';

abstract class MessageProviderBase {
  Future<Response> storeMessage({
    required int shopId,
    required int userId,
    required int productId,
    required String type,
  });
  Future<Response> getMessages(
      {required int shopId, required int page, required int perPage});
  Future<Response> sendMessage({
    required int shopId,
    required String type,
    required String message,
  });
  Future<Response> getShops({required String search});
  Future<Response> getTotalUnreadMessages();
}
