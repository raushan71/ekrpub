// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ekray/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/models/eCommerce/cart/hive_cart_model.dart';
import 'package:ekray/firebase_options.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.appSettingsBox);
    await Hive.openBox(AppConstants.userBox);
    Hive.registerAdapter(HiveCartModelAdapter());
    await Hive.openBox<HiveCartModel>(AppConstants.cartModelBox);
    
    // Initialize Firebase for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  tearDownAll(() async {
    // Clean up Hive boxes after tests
    await Hive.close();
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Wait for the app to initialize (with timeout)
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that the app has launched (check for any widget in the app)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
