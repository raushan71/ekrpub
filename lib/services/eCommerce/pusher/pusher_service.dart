import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ekray/config/app_constants.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();

  factory PusherService() {
    return _instance;
  }

  PusherService._internal();

  late PusherChannelsFlutter _pusher;

  Future<void> init({
    required void Function(PusherEvent) onEvent,
    void Function(String?, String?)? onConnectionChange,
    void Function(String?, int?, dynamic)? onError,
  }) async {
    _pusher = PusherChannelsFlutter.getInstance();

    await _pusher.init(
      apiKey: AppConstants.pusherApiKey,
      cluster: AppConstants.pusherCluster,
      onEvent: onEvent,
      onConnectionStateChange: onConnectionChange,
      onError: onError,
    );

    await _pusher.connect();
  }

  void subscribe(String channelName) {
    _pusher.subscribe(channelName: channelName);
    debugPrint("Subscribed to channel: $channelName");
  }

  // void subscribeToUserChannel(int userId) {
  //   final channelName = "chat_user_$userId";
  //   _pusher.subscribe(channelName: channelName);
  //   debugPrint("Subscribed to channel: $channelName");
  // }

  void _onPusherEvent(PusherEvent event) {
    debugPrint("Event received: ${event.eventName}");
    debugPrint("Data: ${event.data}");
  }

  void _onSubscriptionSucceeded(String? event, String channelName) {
    debugPrint("Subscription succeeded on $channelName");
  }

  void _onConnectionStateChange(String? currentState, String? previousState) {
    debugPrint("Pusher state: $previousState → $currentState");
  }

  void _onError(String? message, int? code, dynamic exception) {
    debugPrint("Pusher error: $message (code: $code)");
    if (exception != null) {
      debugPrint("Exception: $exception");
    }
  }
}
