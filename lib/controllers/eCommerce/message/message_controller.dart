import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/eCommerce/common/common_response.dart';
import 'package:ekray/models/eCommerce/message_model/message_model.dart';
import 'package:ekray/models/eCommerce/message_model/messages.dart';
import 'package:ekray/models/eCommerce/shop_message_model/shop_message_model.dart';
import 'package:ekray/services/eCommerce/message/message_service.dart';

final storeMessageControllerProvider =
    StateNotifierProvider<StoreMessageController, bool>(
        (ref) => StoreMessageController(ref));
final sendMessageControllerProvider =
    StateNotifierProvider<SendMessageController, bool>(
        (ref) => SendMessageController(ref));

final getMessageControllerProvider = StateNotifierProvider.autoDispose<
    GetMessageController,
    AsyncValue<List<Messages>>>((ref) => GetMessageController(ref));

final getShopsControllerProvider = StateNotifierProvider.autoDispose<
    GetShopsController,
    AsyncValue<ShopMessageModel?>>((ref) => GetShopsController(ref));

final getTotalUnreadMessagesControllerProvider =
    StateNotifierProvider.autoDispose<GetTotalUnreadMessagesController,
        AsyncValue<int?>>((ref) => GetTotalUnreadMessagesController(ref));

class StoreMessageController extends StateNotifier<bool> {
  final Ref ref;
  StoreMessageController(this.ref) : super(false);

  Future<CommonResponse> storeMessage(
      {required int shopId,
      required int userId,
      int? productId,
      String? type}) async {
    try {
      state = true;
      final response = await ref.read(messageServiceProvider).storeMessage(
          shopId: shopId, userId: userId, productId: productId, type: "user");
      state = false;
      return CommonResponse(isSuccess: true, message: response.data['message']);
    } catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        state = false;
      }

      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }
}

class SendMessageController extends StateNotifier<bool> {
  final Ref ref;
  SendMessageController(this.ref) : super(false);

  Future<CommonResponse> sendMessage({
    required int shopId,
    String? type,
    required String message,
  }) async {
    try {
      state = true;
      final response = await ref
          .read(messageServiceProvider)
          .sendMessage(shopId: shopId, message: message, type: "user");
      
      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = false;
        // Don't refresh messages here - Pusher will handle real-time updates
        // Only refresh if Pusher fails (which is rare now that it's working)
        return CommonResponse(
          isSuccess: true, 
          message: response.data['message'] ?? 'Message sent successfully'
        );
      } else {
        state = false;
        final errorMessage = response.data['message'] ?? 'Failed to send message';
        return CommonResponse(isSuccess: false, message: errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('Dio error sending message: ${e.response?.statusCode} - ${e.response?.data}');
      if (mounted) {
      state = false;
      }
      
      String errorMessage = 'Failed to send message';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } else if (errorData is String) {
          errorMessage = errorData;
        }
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      return CommonResponse(isSuccess: false, message: errorMessage);
    } catch (error) {
      debugPrint('Error sending message: $error');
      if (mounted) {
        state = false;
      }
      String errorMessage = 'An unknown error occurred while sending message';
      if (error.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (error.toString().isNotEmpty) {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      }
      return CommonResponse(isSuccess: false, message: errorMessage);
    }
  }

  Future<CommonResponse> getShops() async {
    try {
      state = true;
      final response = await ref.read(messageServiceProvider).getShops();
      state = false;
      return CommonResponse(isSuccess: true, message: response.data['message']);
    } catch (error) {
      debugPrint(error.toString());
      state = false;
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }
}

class GetMessageController extends StateNotifier<AsyncValue<List<Messages>>> {
  final Ref ref;
  GetMessageController(this.ref) : super(AsyncValue.data([]));

  int _currentpage = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  bool _isFetching = false;

  Future<void> getMessage({required int shopId, bool isInitial = false}) async {
    if (_isFetching || (!_hasMore && !isInitial)) return;

    try {
      if (isInitial) {
        state = const AsyncValue.loading();
        _currentpage = 1;
        _hasMore = true;
      }
      _isFetching = true;
      // state = const AsyncValue.loading();
      final response = await ref
          .read(messageServiceProvider)
          .getMessages(shopId: shopId, page: _currentpage, perPage: _perPage);

      final messageModel = MessageModel.fromMap(response.data);
      final newMessages = messageModel.data?.data ?? [];
      if (isInitial) {
        state = AsyncValue.data(newMessages);
      } else {
        state = AsyncValue.data([...state.value ?? [], ...newMessages]);
      }
      if (newMessages.length < _perPage) {
        _hasMore = false;
      } else {
        _currentpage++;
      }
    } catch (error, stk) {
      debugPrint(stk.toString());
      debugPrint(error.toString());
      state = AsyncValue.error(error.toString(), stk);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> addNewMessage(Messages newMessage) async {
    final currentState = state.value ?? [];
    state = AsyncValue.data([
      newMessage,
      ...currentState,
    ]);
  }
}

class GetShopsController extends StateNotifier<AsyncValue<ShopMessageModel?>> {
  final Ref ref;
  GetShopsController(this.ref) : super(AsyncValue.loading()) {
    getShops();
  }

  Future<void> getShops({String? search}) async {
    try {
      final previousData = state.valueOrNull;
      debugPrint("previousData: $previousData");
      if (previousData != null) {
        state = AsyncValue.data(previousData);
      } else {
        state = const AsyncValue.loading();
      }

      final response = await ref.read(messageServiceProvider).getShops(
            search: search,
          );
      final data = response.data;
      final shopList = ShopMessageModel.fromMap(data);
      if (mounted) {
        state = AsyncValue.data(shopList);
      }
    } catch (error, stk) {
      debugPrint(stk.toString());
      debugPrint(error.toString());
      state = AsyncValue.error(error.toString(), stk);
    }
  }
}

class GetTotalUnreadMessagesController extends StateNotifier<AsyncValue<int?>> {
  final Ref ref;
  GetTotalUnreadMessagesController(this.ref) : super(AsyncValue.loading()) {
    getTotalUnreadMessages();
  }

  Future<void> getTotalUnreadMessages() async {
    try {
      final response =
          await ref.read(messageServiceProvider).getTotalUnreadMessages();
      final data = response.data["data"];
      final totalUnreadMessages = data['unread_messages'] ?? 0;
      state = AsyncValue.data(totalUnreadMessages);
    } catch (error, stk) {
      debugPrint(stk.toString());
      debugPrint(error.toString());
    }
  }
}
