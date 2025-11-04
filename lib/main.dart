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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  firebaseMessagingForgroundHandler();
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM Token: $fcmToken");
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
