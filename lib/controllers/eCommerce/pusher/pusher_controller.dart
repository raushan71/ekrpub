import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ekray/controllers/eCommerce/message/message_controller.dart';
import 'package:ekray/models/eCommerce/message_model/messages.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/services/eCommerce/pusher/pusher_service.dart';

final pusherControllerProvider =
    StateNotifierProvider<PusherController, void>((ref) {
  return PusherController(ref);
});

class PusherController extends StateNotifier<void> {
  final Ref ref;
  final PusherService _pusherService = PusherService();

  PusherController(this.ref) : super(null);

  /// Initialize Pusher and connect
  Future<void> init() async {
    await _pusherService.init(
      onEvent: _handleEvent,
      onConnectionChange: _handleConnectionChange,
      onError: _handleError,
    );

    // Subscribe to authenticated user's channel
    final user = await ref.read(hiveServiceProvider).getUserInfo();
    if (user?.id != null) {
      subscribeToUser(user!.id!);
    }
  }

  /// Subscribe to user's personal channel
  void subscribeToUser(int userId) {
    final channel = "chat_user_$userId";
    debugPrint("Subscribing to channel: $channel");
    _pusherService.subscribe(channel);
  }

  /// Handle incoming events
  void _handleEvent(PusherEvent event) {
    debugPrint("Event: ${event.eventName}");
    debugPrint("Data: ${event.data}");

    try {
      if (event.data.isEmpty) {
        debugPrint("No data received");
        return;
      }
      final decoded = jsonDecode(event.data);
      final message = Messages.fromMap(decoded["message"]);
      debugPrint("Parsed message: ${message.toMap()}");

      ref.read(getMessageControllerProvider.notifier).addNewMessage(message);
      ref.read(getShopsControllerProvider.notifier).getShops();
      ref.refresh(getTotalUnreadMessagesControllerProvider);
    } catch (e, stk) {
      debugPrint("Error parsing message: $e | $stk");
      return;
    }
  }

  /// Connection change
  void _handleConnectionChange(String? current, String? previous) {
    debugPrint("🔌 Pusher state: $previous → $current");
  }

  /// Error
  void _handleError(String? message, int? code, dynamic error) {
    debugPrint("Pusher error: $message | code: $code");
  }
}
