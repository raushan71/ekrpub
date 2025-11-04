# Quick Firebase Setup Steps for Ekray

## 🚀 Quick Start (Recommended - FlutterFire CLI)

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Configure Firebase for Ekray
```bash
flutterfire configure
```

**When prompted:**
- Select Firebase project: **ekray**
- Select platforms: **Android** and **iOS**
- Android package name: `com.ekray.apps`
- iOS bundle ID: `com.ekray.apps`

This will automatically:
✅ Download `google-services.json` for Android
✅ Download `GoogleService-Info.plist` for iOS  
✅ Update `lib/firebase_options.dart` with correct values

---

## 📱 Manual Setup (Alternative)

If you prefer to do it manually via Firebase Console:

### Android Setup:

1. Go to https://console.firebase.google.com/
2. Select project **"ekray"**
3. Click **"Add app"** → Select **Android** icon
4. Enter:
   - **Android package name**: `com.ekray.apps`
   - **App nickname**: Ekray Android (optional)
5. Click **"Register app"**
6. Download `google-services.json`
7. Replace file: `android/app/google-services.json`

### iOS Setup:

1. In Firebase Console, click **"Add app"** → Select **iOS** icon
2. Enter:
   - **iOS bundle ID**: `com.ekray.apps`
   - **App nickname**: Ekray iOS (optional)
3. Click **"Register app"**
4. Download `GoogleService-Info.plist`
5. Replace file: `ios/Runner/GoogleService-Info.plist`

### Enable Cloud Messaging:

1. In Firebase Console → **Project Settings** → **Cloud Messaging**
2. Enable **Cloud Messaging API**
3. For iOS: Upload **APNs Authentication Key** (required for push notifications)

---

## ✅ Verify Setup

After configuration, run:

```bash
flutter clean
flutter pub get
flutter run
```

Check console output - you should see:
```
FCM Token: <your-device-token>
```

---

## 📝 Current Configuration

Your app is configured to use:
- **Android package**: `com.ekray.apps`
- **iOS bundle ID**: `com.ekray.apps`
- **API endpoint**: `https://ekray.com/api`

Once Firebase files are updated, everything will work!

