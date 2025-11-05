# Firebase Google Sign-In Setup for GitHub Actions

## Overview
This guide explains how to configure Firebase Google Sign-In in GitHub Actions workflows using your release keystore.

## Problem
When building Android apps in CI/CD, the debug keystore is used by default, which has different SHA-1/SHA-256 fingerprints than your release keystore. This causes Google Sign-In to fail because Firebase only recognizes the fingerprints you've added from your release keystore.

## Solution
Use your release keystore in GitHub Actions so the built APK/AAB has the same SHA-1/SHA-256 fingerprints as your production app.

## Step 1: Prepare Your Keystore

If you don't have a keystore yet, create one:

```bash
keytool -genkey -v -keystore ekray-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

**Important:** Keep this keystore file secure! You'll need it for all future app updates.

## Step 2: Get SHA-1 and SHA-256 Fingerprints

Get the fingerprints from your release keystore:

```bash
keytool -list -v -keystore ekray-release-key.jks -alias key -storepass YOUR_STORE_PASSWORD -keypass YOUR_KEY_PASSWORD
```

Look for:
- **SHA-1:** `AA:BB:CC:DD:EE:FF:...`
- **SHA-256:** `AA:BB:CC:DD:EE:FF:...`

## Step 3: Add Fingerprints to Firebase

1. Go to Firebase Console → Project Settings → Your Android App
2. Scroll to "SHA certificate fingerprints"
3. Click "Add fingerprint"
4. Add both SHA-1 and SHA-256 from your release keystore
5. Download updated `google-services.json`
6. Replace `android/app/google-services.json` in your repo

## Step 4: Encode Keystore for GitHub Secrets

### On Windows (PowerShell):
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ekray-release-key.jks")) | Out-File -Encoding ASCII keystore_base64.txt
```

### On Linux/Mac:
```bash
base64 -i ekray-release-key.jks -o keystore_base64.txt
```

Copy the entire content of `keystore_base64.txt` (it's a long single line).

## Step 5: Add GitHub Secrets

1. Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add these secrets:

### Required Secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `KEYSTORE_BASE64` | `[base64 encoded keystore]` | The entire base64-encoded `.jks` file content |
| `KEYSTORE_PASSWORD` | `raushan7171` | Your keystore password |
| `KEY_ALIAS` | `key` | Your key alias |
| `KEY_PASSWORD` | `raushan7171` | Your key password |

**Security Note:** Never commit these secrets or the keystore file to your repository!

## Step 6: Verify Workflow Configuration

The workflows have been updated to:
1. Decode the keystore from `KEYSTORE_BASE64`
2. Create `key.properties` with the secrets
3. Use the release keystore for signing

**Files updated:**
- `.github/workflows/android-build.yml`
- `.github/workflows/release-build.yml`
- `android/app/build.gradle`

## Step 7: Test the Build

1. Push your changes to trigger the workflow
2. Check the workflow logs for:
   ```
   🔐 Setting up release keystore...
   ✅ Keystore decoded successfully
   ✅ key.properties created
   ```
3. The APK/AAB will now be signed with your release keystore

## Verification

After a successful build, verify the APK is signed correctly:

```bash
# Download the APK from GitHub Actions artifacts
# Then check the signature:
jarsigner -verify -verbose -certs app-release.apk
```

Or extract and check the certificate:

```bash
unzip -q app-release.apk -d extracted
keytool -printcert -file extracted/META-INF/CERT.RSA
```

The SHA-1 and SHA-256 should match what you added to Firebase.

## Troubleshooting

### Error: "Keystore not found in secrets"
- Verify all 4 secrets are added: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
- Check that `KEYSTORE_BASE64` contains the complete base64 string (no line breaks)

### Error: "Wrong password"
- Verify `KEYSTORE_PASSWORD` and `KEY_PASSWORD` match your actual keystore passwords
- Test locally: `keytool -list -keystore ekray-release-key.jks -storepass YOUR_PASSWORD`

### Error: "Alias not found"
- Verify `KEY_ALIAS` matches your keystore alias
- List aliases: `keytool -list -keystore ekray-release-key.jks -storepass YOUR_PASSWORD`

### Google Sign-In still fails
- Double-check SHA-1/SHA-256 in Firebase Console match your release keystore
- Ensure you downloaded the updated `google-services.json` after adding fingerprints
- Verify the APK was signed with release keystore (not debug)

## Security Best Practices

1. ✅ Keystore file is in `.gitignore` (already configured)
2. ✅ Secrets stored in GitHub Secrets (not in code)
3. ✅ Keystore only decoded in CI, never committed
4. ⚠️ Keep a secure backup of your keystore file
5. ⚠️ Never share keystore passwords publicly

## Next Steps

After setting up:
1. ✅ Google Sign-In will work in CI builds
2. ✅ Production APKs will have correct signatures
3. ✅ Firebase will recognize the fingerprints
4. ✅ All users can use Google Sign-In

