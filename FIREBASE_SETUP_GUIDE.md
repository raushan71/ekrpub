# Firebase Setup Guide for Ekray

## Prerequisites
- Firebase project "ekray" already created at https://console.firebase.google.com/
- Android package name: `com.ekray.apps`
- iOS bundle ID: `com.ekray.apps`

## Option 1: Using FlutterFire CLI (Recommended - Automatic)

This is the easiest method as it will automatically configure everything.

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Configure Firebase
```bash
flutterfire configure
```

**During the setup:**
1. Select your Firebase project: `ekray`
2. Select platforms: Android and iOS
3. For Android: Enter package name `com.ekray.apps`
4. For iOS: Enter bundle ID `com.ekray.apps`
5. The CLI will automatically:
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Update `lib/firebase_options.dart` with correct values

## Option 2: Manual Setup

### For Android App

1. **Add Android App in Firebase Console:**
   - Go to https://console.firebase.google.com/
   - Select your project "ekray"
   - Click on the Android icon (or "Add app" > Android)
   - Android package name: `com.ekray.apps`
   - App nickname (optional): Ekray Android
   - Debug signing certificate SHA-1 (optional - can add later)
   - Click "Register app"

2. **Download google-services.json:**
   - After registering, download the `google-services.json` file
   - Replace `android/app/google-services.json` with the downloaded file

### For iOS App

1. **Add iOS App in Firebase Console:**
   - In Firebase Console, click "Add app" > iOS
   - iOS bundle ID: `com.ekray.apps`
   - App nickname (optional): Ekray iOS
   - App Store ID (optional - can add later)
   - Click "Register app"

2. **Download GoogleService-Info.plist:**
   - After registering, download the `GoogleService-Info.plist` file
   - Replace `ios/Runner/GoogleService-Info.plist` with the downloaded file

3. **Update Xcode Project:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Make sure the bundle identifier matches `com.ekray.apps`

### Enable Firebase Cloud Messaging (FCM)

1. In Firebase Console, go to your project settings
2. Navigate to Cloud Messaging
3. Enable Cloud Messaging API (if not already enabled)
4. For iOS: Upload your APNs Authentication Key or Certificate (required for iOS push notifications)

## After Configuration

### Verify Configuration Files

1. **Android**: Check that `android/app/google-services.json` exists and contains your project ID
2. **iOS**: Check that `ios/Runner/GoogleService-Info.plist` exists and contains your bundle ID

### Regenerate firebase_options.dart (if using manual setup)

If you manually added the apps, you can regenerate the `firebase_options.dart` file:

```bash
flutterfire configure
```

Or manually update `lib/firebase_options.dart` with values from your Firebase project.

### Test the Setup

```bash
flutter clean
flutter pub get
flutter run
```

Check the console logs - you should see:
```
FCM Token: <your-token>
```

## Troubleshooting

### Android Issues
- Make sure `google-services.json` is in `android/app/` directory
- Verify `android/app/build.gradle` has `apply plugin: 'com.google.gms.google-services'`
- Check that package name in `google-services.json` matches `com.ekray.apps`

### iOS Issues
- Make sure `GoogleService-Info.plist` is in `ios/Runner/` directory
- Verify bundle ID in Xcode matches `com.ekray.apps`
- For push notifications, ensure APNs certificate/key is uploaded to Firebase

## Next Steps

After Firebase is configured:
1. Test push notifications
2. Configure notification channels for Android
3. Set up notification handlers for your Laravel backend

