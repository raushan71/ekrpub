# Script to generate base64 keystore for GitHub Secrets

## Windows PowerShell

```powershell
# Navigate to your keystore directory
cd android/app

# Encode keystore to base64
$keystorePath = "key.jks"
$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystorePath))

# Save to file
$base64 | Out-File -Encoding ASCII keystore_base64.txt

# Display (copy this to GitHub Secrets)
Write-Host "Copy the following to GitHub Secret KEYSTORE_BASE64:"
Write-Host $base64
```

## Linux/Mac

```bash
# Navigate to your keystore directory
cd android/app

# Encode keystore to base64
base64 -i key.jks -o keystore_base64.txt

# Display (copy this to GitHub Secrets)
echo "Copy the following to GitHub Secret KEYSTORE_BASE64:"
cat keystore_base64.txt
```

## Get SHA-1 and SHA-256

```bash
# Replace with your actual passwords
keytool -list -v -keystore android/app/key.jks -alias key -storepass raushan7171 -keypass raushan7171
```

Look for:
- **Certificate fingerprints:**
  - SHA1: AA:BB:CC:DD:EE:FF:...
  - SHA256: AA:BB:CC:DD:EE:FF:...

Add both to Firebase Console.

