import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/firebase_options.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/cart/hive_cart_model.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/utils/notification_handler.dart';
import 'package:ekray/views/common/splash/layouts/splash_layout.dart';
import 'dart:io';

// Request notification permissions at app startup
Future<void> _requestNotificationPermissions() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Request permission with default allow
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false, // Full permission, not provisional
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  
  debugPrint('Notification permission status: ${settings.authorizationStatus}');
  
  if (Platform.isAndroid) {
    // For Android 13+, ensure notification permission is requested
    // This is handled automatically by Firebase Messaging
    debugPrint('Android notification permissions requested');
  }
}

// Handle notification navigation based on data payload
void _handleNotificationNavigation(RemoteMessage message) {
  debugPrint('Notification clicked: ${message.data}');
  
  final data = message.data;
  final link = data['link'] ?? data['product_link'] ?? data['url'] ?? data['product_id'];
  
  if (link != null && link.toString().isNotEmpty) {
    String linkStr = link.toString().trim();
    
    // Check if it's a chat notification (format: chat:shop_id or chat:user_id)
    if (linkStr.startsWith('chat:')) {
      // Chat notification - navigate to messages/chat
      final chatId = linkStr.replaceFirst('chat:', '').trim();
      final shopId = int.tryParse(chatId);
      
      if (shopId != null && shopId > 0) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          final navigator = GlobalFunction.navigatorKey.currentState;
          if (navigator != null) {
            try {
              // Navigate to messages page with shop ID
              // You may need to adjust this based on your routes
              navigator.pushNamed(
                '/messages', // Adjust route name as needed
                arguments: {'shopId': shopId},
              );
              debugPrint('✅ Navigated to chat with shop: $shopId');
            } catch (e) {
              debugPrint('❌ Error navigating to chat: $e');
            }
          }
        });
        return;
      }
    }
    
    // Parse product ID from link
    // Link format: /product/{id} or https://ekray.com/product/{id} or just product ID
    int? productId;
    
    // Extract product ID from various link formats
    if (RegExp(r'^\d+$').hasMatch(linkStr)) {
      // Direct product ID (most common case)
      productId = int.tryParse(linkStr);
    } else if (linkStr.contains('/product/')) {
      // URL format: https://ekray.com/product/123 or /product/123
      final parts = linkStr.split('/product/');
      if (parts.length > 1) {
        final idPart = parts[1].split('/')[0].split('?')[0].split('#')[0];
        productId = int.tryParse(idPart);
      }
    } else if (linkStr.contains('product')) {
      // Try to extract ID from product-related strings
      final regex = RegExp(r'product[\/\-_]?(\d+)', caseSensitive: false);
      final match = regex.firstMatch(linkStr);
      if (match != null && match.groupCount > 0) {
        productId = int.tryParse(match.group(1)!);
      }
    }
    
    if (productId != null && productId > 0) {
      // Navigate to product details after a delay to ensure app is ready
      Future.delayed(const Duration(milliseconds: 1000), () {
        final navigator = GlobalFunction.navigatorKey.currentState;
        if (navigator != null) {
          try {
            navigator.pushNamed(
              Routes.getProductDetailsRouteName(AppConstants.appServiceName),
              arguments: productId,
            );
            debugPrint('✅ Navigated to product: $productId');
          } catch (e) {
            debugPrint('❌ Error navigating to product: $e');
          }
        } else {
          debugPrint('⚠️ Navigator not ready yet');
        }
      });
    } else {
      debugPrint('⚠️ Could not parse product ID or chat ID from link: $link');
    }
  } else {
    // No link - might be a chat notification, navigate to messages
    debugPrint('ℹ️ No link found in notification data, assuming chat notification');
    Future.delayed(const Duration(milliseconds: 1000), () {
      final navigator = GlobalFunction.navigatorKey.currentState;
      if (navigator != null) {
        try {
          navigator.pushNamed('/messages'); // Navigate to messages page
          debugPrint('✅ Navigated to messages page');
        } catch (e) {
          debugPrint('❌ Error navigating to messages: $e');
        }
      }
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Request notification permissions at app startup (default allow)
  await _requestNotificationPermissions();
  
  await setupFlutterNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  firebaseMessagingForgroundHandler();
  
  // Handle notification click when app is opened from terminated state
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      _handleNotificationNavigation(message);
    }
  });
  
  // Handle notification click when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _handleNotificationNavigation(message);
  });
  
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM Token: $fcmToken");
  
  // Listen for token refresh and update on backend
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    debugPrint("FCM Token refreshed: $newToken");
    // Token will be updated on next login or can be updated via updateDeviceKey endpoint
  });
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: false,
  );

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.appSettingsBox);
  await Hive.openBox(AppConstants.userBox);
  Hive.registerAdapter(HiveCartModelAdapter());

  await Hive.openBox<HiveCartModel>(AppConstants.cartModelBox);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Update online status when app becomes active
      _updateOnlineStatus();
    }
  }

  void _updateOnlineStatus() async {
    try {
      // Get user info from Hive
      final userBox = Hive.box(AppConstants.userBox);
      final userData = userBox.get(AppConstants.userData);
      
      if (userData != null && userData['id'] != null) {
        // Update online status via API
        // This will be handled by the message service
        debugPrint('✅ App resumed - online status will be updated on next API call');
      }
    } catch (e) {
      debugPrint('❌ Error updating online status on app resume: $e');
    }
  }

  Locale resolveLocal({required String langCode}) {
    return Locale(langCode);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // XD Design Sizes
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: false,
      builder: (context, child) {
        return ValueListenableBuilder(
            valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
            builder: (context, box, _) {
              final isDark = box.get(AppConstants.isDarkTheme,
                  defaultValue: false) as bool;
              final primaryColor = box.get(AppConstants.primaryColor);
              if (primaryColor != null) {
                EcommerceAppColor.primary = hexToColor(primaryColor);
              }
              GlobalFunction.changeStatusBarTheme(isDark: isDark);
              final appLocal = box.get(AppConstants.appLocal);
              return ConnectivityAppWrapper(
                app: MaterialApp(
                  showPerformanceOverlay: false,
                  debugShowCheckedModeBanner: false,
                  title: 'Ekray',
                  navigatorKey: GlobalFunction.navigatorKey,
                  locale: resolveLocal(langCode: appLocal ?? 'en'),
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  theme: getAppTheme(context: context, isDarkTheme: isDark),
                  onGenerateRoute: generatedRoutes,
                  initialRoute: Routes.splash,
                  // home: ConfirmOTPLayout(
                  //     arguments: ConfirmOTPScreenArguments(
                  //         phoneNumber: "01909121212",
                  //         isPasswordRecover: false)),
                ),
              );
            });
      },
    );
  }
}
