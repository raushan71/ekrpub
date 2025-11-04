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
  - ✅ Build iOS Debug
  - ✅ Build iOS Release
  - ⚠️ IPA generation (requires code signing setup)

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
All workflows use Flutter **3.24.0** (stable channel). To update:
```yaml
flutter-version: '3.24.0'  # Update in each workflow file
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

For release builds with signing, add these secrets:
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `KEYSTORE_BASE64` (base64 encoded keystore file)

Then update workflows to use signing configuration.

