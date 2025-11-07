import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ekray/controllers/eCommerce/message/message_controller.dart';
import 'package:ekray/controllers/eCommerce/typing_indicator_controller.dart';
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
    debugPrint("🔔 Pusher Event: ${event.eventName}");
    debugPrint("📦 Event Data: ${event.data}");

    try {
      if (event.data.isEmpty) {
        debugPrint("⚠️ No data received in event");
        return;
      }
      
      final decoded = jsonDecode(event.data);
      
      // Handle both event types: send-message-to-user and send-message-to-shop
      if (event.eventName == 'send-message-to-user' || event.eventName == 'send-message-to-shop') {
        if (decoded["message"] != null) {
          final message = Messages.fromMap(decoded["message"]);
          debugPrint("✅ Parsed message: ${message.toMap()}");
          debugPrint("📝 Message type: ${message.type}, Shop ID: ${message.shop?.id}, User ID: ${message.user?.id}");

          // Add message to the current chat if it matches the active shop
          // We need to get the current shop ID from context, but for now add to all
          ref.read(getMessageControllerProvider.notifier).addNewMessage(message);
          
          // Refresh shop list to update last message
          ref.read(getShopsControllerProvider.notifier).getShops();
          
          // Refresh unread messages count
          ref.refresh(getTotalUnreadMessagesControllerProvider);
          
          debugPrint("✅ Message added to UI via Pusher");
        } else {
          debugPrint("⚠️ No message data in event payload");
        }
      } else if (event.eventName == 'typing-indicator') {
        // Handle typing indicator from shop
        if (decoded["type"] == "shop" && decoded["is_typing"] != null) {
          final isTyping = decoded["is_typing"] as bool;
          final shopId = decoded["shop_id"] as int?;
          debugPrint("📝 Typing indicator: shop=$shopId, typing=$isTyping");
          
          // Update typing indicator provider
          if (shopId != null) {
            ref.read(typingIndicatorProvider(shopId).notifier).setTyping(shopId, isTyping);
          }
        }
      } else {
        debugPrint("ℹ️ Unhandled event type: ${event.eventName}");
      }
    } catch (e, stk) {
      debugPrint("❌ Error parsing Pusher message: $e");
      debugPrint("📚 Stack trace: $stk");
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
