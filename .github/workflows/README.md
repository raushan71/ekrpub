# GitHub Actions Workflows

This repository includes automated CI/CD workflows for building, testing, and deploying the Ekray Flutter app.

## 📋 Available Workflows

### 1. **Android Build** (`.github/workflows/android-build.yml`)
- **Triggers**: Push/PR to `main` or `develop`, Manual dispatch
- **Runs on**: Ubuntu Latest
- **Actions**:
  - ✅ Flutter dependency installation
  - ✅ Code analysis (`flutter analyze`)
  - ✅ Unit tests
  - ✅ Build Debug APK
  - ✅ Build Release APK
  - ✅ Build Release App Bundle (AAB)
  - ✅ Upload artifacts (30 days retention)

### 2. **iOS Build** (`.github/workflows/ios-build.yml`)
- **Triggers**: Push/PR to `main` or `develop`, Manual dispatch
- **Runs on**: macOS Latest
- **Actions**:
  - ✅ Flutter dependency installation
  - ✅ CocoaPods installation
  - ✅ Code analysis
  - ✅ Unit tests
  - ✅ Build iOS Simulator (for Appetize.io)
  - ✅ Build iOS Device (optional)
  - ✅ Verify Runner.app exists
  - ⚠️ IPA generation (requires code signing setup)

### 2.1. **iOS Appetize.io Test** (`.github/workflows/ios-appetize.yml`)
- **Triggers**: Push/PR to `main` or `develop`, Manual dispatch, After iOS Build workflow
- **Runs on**: macOS Latest
- **Actions**:
  - ✅ Build iOS app for simulator
  - ✅ Verify Runner.app bundle
  - ✅ Create zip archive for Appetize.io
  - ✅ Upload to Appetize.io (requires token)
  - ✅ Post preview URL to PR comments
  - ✅ Upload build artifacts

### 3. **Code Analysis & Tests** (`.github/workflows/analyze-test.yml`)
- **Triggers**: Push/PR to `main` or `develop`, Manual dispatch
- **Runs on**: Ubuntu Latest
- **Actions**:
  - ✅ Flutter doctor check
  - ✅ Code formatting check
  - ✅ Flutter analyzer
  - ✅ Linter error detection
  - ✅ Unit tests with coverage
  - ✅ Code coverage upload (Codecov)

### 4. **Debug & Check** (`.github/workflows/debug-check.yml`)
- **Triggers**: Push/PR to `main` or `develop`, Manual dispatch
- **Runs on**: Ubuntu Latest
- **Actions**:
  - ✅ Flutter doctor verification
  - ✅ API configuration check
  - ✅ Package name verification
  - ✅ Firebase configuration check
  - ✅ Bundle identifier verification
  - ✅ Import statements check
  - ✅ Build dry-run

### 5. **Release Build** (`.github/workflows/release-build.yml`)
- **Triggers**: GitHub Release creation, Manual dispatch
- **Runs on**: Ubuntu Latest
- **Actions**:
  - ✅ Full test suite
  - ✅ Release APK build
  - ✅ Release App Bundle build
  - ✅ Build info generation
  - ✅ Artifact upload (90 days retention)
  - ✅ Automatic GitHub Release creation

## 🚀 Usage

### Manual Workflow Trigger
1. Go to **Actions** tab in GitHub
2. Select the workflow you want to run
3. Click **Run workflow**
4. Select branch and click **Run workflow**

### Automatic Triggers
- **Push**: Any push to `main` or `develop` triggers workflows
- **Pull Request**: PRs to `main` or `develop` trigger workflows
- **Release**: Creating a GitHub release triggers release build

## 📦 Artifacts

All workflows upload build artifacts:
- **APK Debug**: `app-debug.apk` (30 days)
- **APK Release**: `app-release.apk` (30 days)
- **App Bundle**: `app-release.aab` (30 days)
- **Release Builds**: (90 days retention)

### Download Artifacts
1. Go to **Actions** tab
2. Click on a completed workflow run
3. Scroll to **Artifacts** section
4. Download the files you need

## 🔧 Configuration

### Flutter Version
All workflows use Flutter **3.27.0** (stable channel) which includes Dart SDK 3.5.3+. To update:
```yaml
flutter-version: '3.27.0'  # Update in each workflow file
```

### Java Version
Android builds use Java **17** (Zulu distribution).

### Build Configuration
- **Debug builds**: Include debug symbols, not optimized
- **Release builds**: Optimized, minified, ready for production
- **App Bundle**: Required for Google Play Store upload

## 🐛 Troubleshooting

### Build Failures
- Check workflow logs in **Actions** tab
- Verify Flutter dependencies: `flutter pub get`
- Check for syntax errors: `flutter analyze`

### iOS Build Issues
- iOS builds require macOS runners (paid GitHub plans)
- Code signing required for IPA generation
- CocoaPods installation may fail - check Podfile
- **Runner.app not found**: The workflow now builds for simulator and verifies the app exists before upload
- **Appetize.io upload fails**: Ensure `APPETIZE_TOKEN` secret is set correctly

### Firebase Configuration
- Ensure `google-services.json` exists for Android
- Ensure `GoogleService-Info.plist` exists for iOS
- Verify Firebase project setup

## 📝 Notes

- **Free GitHub Accounts**: Limited to 2000 minutes/month
- **macOS Runners**: Available on paid plans (10x cost)
- **Artifact Retention**: Free accounts have 90 days retention
- **Concurrent Jobs**: Depends on your GitHub plan

## 🔐 Secrets (Optional)

### Android Release Builds
For release builds with signing, add these secrets:
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `KEYSTORE_BASE64` (base64 encoded keystore file)

### Appetize.io Integration
To enable iOS app testing on Appetize.io, add this secret:
- `APPETIZE_TOKEN` - Your Appetize.io API token

**Getting your Appetize.io token:**
1. Sign up or log in at [https://appetize.io](https://appetize.io)
2. Go to your dashboard
3. Navigate to API settings
4. Copy your API token
5. Add it as a GitHub Secret named `APPETIZE_TOKEN`

Once configured, the iOS Appetize.io workflow will:
- Automatically build and upload your iOS app
- Provide a public URL to test your app in the browser
- Comment on pull requests with the preview URL

