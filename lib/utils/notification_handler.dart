import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekray/firebase_options.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/models/eCommerce/shop_message_model/shop.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  debugPrint('Handling a background message ${message.messageId}');
}

Future<void> firebaseMessagingForgroundHandler() async {
  FirebaseMessaging.onMessage.listen((message) {
    debugPrint(message.data.toString());
    debugPrint(message.data.toString());
    debugPrint(message.toString());
    debugPrint('Handling a ForeGround message ${message.messageId}');
    debugPrint('Handling a ForeGround message ${message.notification}');
    showFlutterNotification(message);
  });
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@drawable/notification_icon'),
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: onDidReceiveLocalNotification,
    onDidReceiveNotificationResponse: onSelectNotification,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  final AppleNotification? iOS = message.notification?.apple;
  if (notification != null && (android != null || iOS != null) && !kIsWeb) {
    // Convert message data to a string payload for local notification click handling
    String? payload;
    if (message.data.isNotEmpty) {
      try {
        // Create a simple string representation of the data for payload
        // Format: key1:value1, key2:value2
        final payloadParts = <String>[];
        message.data.forEach((key, value) {
          payloadParts.add('$key:$value');
        });
        payload = payloadParts.join(', ');
      } catch (e) {
        debugPrint('Error converting notification data to payload: $e');
        payload = message.data.toString();
      }
    }
    
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@drawable/notification_icon',
          // Enable tap action
          enableVibration: true,
          priority: Priority.high,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload, // Pass data as payload for click handling
    );
  }
}

// handle notification navigation
void handleMessage(RemoteMessage? message) {
  if (message == null) return;
  if (message.data['type'] == 'Conversetion') {
    // call the context less route here
  }
}

// Background notification selection
Future<void> onDidReceiveLocalNotification(
  NotificationResponse notificationResponse,
) async {
  // ContextLess.navigatorkey.currentState!.pushNamedAndRemoveUntil(
  //   Routes.messageScreen,
  //   arguments: MessageScreenArgument(
  //     orderId: orderId,
  //     senderId: receiverId,
  //     receiverId: senderId,
  //   ),
  //   (route) => true,
  // );
}

// Foreground notification selection (for local notifications shown in foreground)
Future<void> onSelectNotification(
  NotificationResponse notificationResponse,
) async {
  // Handle notification click with payload
  final String? payload = notificationResponse.payload;
  if (payload != null && payload.isNotEmpty) {
    debugPrint('Local notification clicked with payload: $payload');
    try {
      // Try to parse as JSON map (data format from Firebase)
      // Payload format: {link: chat:1, click_action: FLUTTER_NOTIFICATION_CLICK}
      if (payload.contains('link')) {
        // Extract link from payload string
        final linkMatch = RegExp(r'link[:\s]+([^\s,}]+)').firstMatch(payload);
        if (linkMatch != null) {
          final link = linkMatch.group(1)?.replaceAll("'", '').replaceAll('"', '').trim();
          if (link != null && link.isNotEmpty) {
            // Check if it's a chat link
            if (link.startsWith('chat:')) {
              _navigateToChat(link);
            } else {
              // Otherwise, treat as product link
              _navigateToProduct(link);
            }
          }
        }
      } else if (payload.contains('product')) {
        // Extract product ID from payload string
        final linkMatch = RegExp(r'product[:\s]+([^\s,}]+)').firstMatch(payload);
        if (linkMatch != null) {
          final link = linkMatch.group(1)?.replaceAll("'", '').replaceAll('"', '').trim();
          if (link != null && link.isNotEmpty) {
            _navigateToProduct(link);
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }
}

// Helper function to navigate to chat
void _navigateToChat(String link) {
  String linkStr = link.trim();
  
  // Check if it's a chat link (format: chat:shop_id)
  if (linkStr.startsWith('chat:')) {
    final chatId = linkStr.replaceFirst('chat:', '').trim();
    final shopId = int.tryParse(chatId);
    
    if (shopId != null && shopId > 0) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        try {
          // Import Shop model (already imported at top of file via routes.dart)
          final shop = Shop(
            id: shopId,
            name: null,
            logo: null,
            rating: null,
            lastOnline: null,
          );
          
          GlobalFunction.navigatorKey.currentState?.pushNamed(
            Routes.getChatViewRouteName(AppConstants.appServiceName),
            arguments: shop,
          );
          debugPrint('✅ Navigated to chat from local notification: $shopId');
        } catch (e) {
          debugPrint('❌ Error navigating to chat: $e');
          // Fallback: navigate to messages list
          try {
            GlobalFunction.navigatorKey.currentState?.pushNamed(
              Routes.getMyMessageViewRouteName(AppConstants.appServiceName),
            );
            debugPrint('✅ Navigated to messages list as fallback');
          } catch (fallbackError) {
            debugPrint('❌ Error navigating to messages list: $fallbackError');
          }
        }
      });
    }
  }
}

// Helper function to navigate to product
void _navigateToProduct(String link) {
  // Parse product ID from link
  String linkStr = link.trim();
  int? productId;
  
  // Extract product ID from various link formats
  if (RegExp(r'^\d+$').hasMatch(linkStr)) {
    productId = int.tryParse(linkStr);
  } else if (linkStr.contains('/product/')) {
    final parts = linkStr.split('/product/');
    if (parts.length > 1) {
      final idPart = parts[1].split('/')[0].split('?')[0].split('#')[0];
      productId = int.tryParse(idPart);
    }
  } else if (linkStr.contains('product')) {
    final regex = RegExp(r'product[\/\-_]?(\d+)', caseSensitive: false);
    final match = regex.firstMatch(linkStr);
    if (match != null && match.groupCount > 0) {
      productId = int.tryParse(match.group(1)!);
    }
  }
  
  if (productId != null && productId > 0) {
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        GlobalFunction.navigatorKey.currentState?.pushNamed(
          Routes.getProductDetailsRouteName(AppConstants.appServiceName),
          arguments: productId,
        );
        debugPrint('✅ Navigated to product from local notification: $productId');
      } catch (e) {
        debugPrint('❌ Error navigating to product: $e');
      }
    });
  }
}

// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
