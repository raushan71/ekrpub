# Firebase Admin SDK Setup on VPS

## Error: Missing Firebase Credentials File

**Error Message:**
```
SplFileObject::__construct(/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json): Failed to open stream: No such file or directory
```

This error occurs when Laravel backend tries to access Firebase Admin SDK but the credentials file is missing.

## Solution: Upload Firebase Service Account Credentials

### Step 1: Download Firebase Service Account JSON

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Download the JSON file (it will be named something like `your-project-firebase-adminsdk-xxxxx.json`)

### Step 2: Upload to VPS

**Option A: Using SCP (Secure Copy)**

```powershell
# Upload the file to your VPS
scp -i ~/.ssh/vps_deploy_key path/to/your-firebase-adminsdk.json vps:/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

**Option B: Using SFTP**

```powershell
# Connect via SFTP
sftp -i ~/.ssh/vps_deploy_key vps

# Navigate to directory
cd /home/ekray/htdocs/ekray.com/storage/app/public/

# Upload file (from your local machine)
put path/to/your-firebase-adminsdk.json firebase_credentials.json

# Exit
exit
```

**Option C: Manual Upload via SSH**

```powershell
# SSH into VPS
ssh vps

# Create directory if it doesn't exist
mkdir -p /home/ekray/htdocs/ekray.com/storage/app/public/

# Create the file (you'll paste the JSON content)
nano /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

Paste the entire JSON content, then save (Ctrl+X, Y, Enter).

### Step 3: Set Proper Permissions

```bash
# SSH into VPS
ssh vps

# Set ownership (adjust user/group based on your setup)
chown www-data:www-data /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json

# Set secure permissions (read-only for owner, no access for others)
chmod 600 /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

### Step 4: Configure Laravel to Use Firebase Credentials

**Option A: Using Environment Variable**

Add to your `.env` file on VPS:

```env
FIREBASE_CREDENTIALS=/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

Then update `config/firebase.php`:

```php
<?php

return [
    'credentials' => env('FIREBASE_CREDENTIALS', storage_path('app/public/firebase_credentials.json')),
];
```

**Option B: Update config/firebase.php directly**

```php
<?php

return [
    'credentials' => [
        'file' => storage_path('app/public/firebase_credentials.json'),
        // Or use array format:
        // 'type' => env('FIREBASE_CREDENTIALS_TYPE', 'service_account'),
        // 'project_id' => env('FIREBASE_PROJECT_ID'),
        // 'private_key_id' => env('FIREBASE_PRIVATE_KEY_ID'),
        // 'private_key' => env('FIREBASE_PRIVATE_KEY'),
        // 'client_email' => env('FIREBASE_CLIENT_EMAIL'),
        // 'client_id' => env('FIREBASE_CLIENT_ID'),
        // 'auth_uri' => env('FIREBASE_AUTH_URI', 'https://accounts.google.com/o/oauth2/auth'),
        // 'token_uri' => env('FIREBASE_AUTH_TOKEN_URI', 'https://oauth2.googleapis.com/token'),
    ],
];
```

### Step 5: Test Firebase Connection

Create a test route in `routes/web.php` (temporarily):

```php
Route::get('/test-firebase', function () {
    try {
        $firebase = app('firebase.auth');
        $user = $firebase->getUser('test-uid');
        return response()->json(['message' => 'Firebase connection successful']);
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});
```

Test it:
```bash
curl https://ekray.com/test-firebase
```

**Remove this test route after confirming it works!**

### Step 6: Secure the Credentials File

**Important Security Measures:**

1. **Add to .gitignore** (if not already):
```gitignore
/storage/app/public/firebase_credentials.json
```

2. **Restrict access:**
```bash
chmod 600 /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
chown www-data:www-data /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

3. **Optional: Move outside web root:**
```bash
# Move to a secure location outside web root
mkdir -p /home/ekray/.firebase
mv /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json /home/ekray/.firebase/
chmod 600 /home/ekray/.firebase/firebase_credentials.json

# Update config/firebase.php to point to new location
'credentials' => '/home/ekray/.firebase/firebase_credentials.json',
```

## Alternative: Use Environment Variables

Instead of storing credentials in a file, you can use environment variables:

### Step 1: Add to .env

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
```

### Step 2: Update config/firebase.php

```php
<?php

return [
    'credentials' => [
        'type' => 'service_account',
        'project_id' => env('FIREBASE_PROJECT_ID'),
        'private_key_id' => env('FIREBASE_PRIVATE_KEY_ID'),
        'private_key' => str_replace('\\n', "\n", env('FIREBASE_PRIVATE_KEY')),
        'client_email' => env('FIREBASE_CLIENT_EMAIL'),
        'client_id' => env('FIREBASE_CLIENT_ID'),
        'auth_uri' => 'https://accounts.google.com/o/oauth2/auth',
        'token_uri' => 'https://oauth2.googleapis.com/token',
    ],
];
```

## Troubleshooting

### File Not Found Error
- Verify file path: `ls -la /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json`
- Check permissions: `stat /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json`
- Ensure Laravel can read the file (check `www-data` user permissions)

### Permission Denied
- Check file ownership: `ls -la storage/app/public/`
- Fix ownership: `chown -R www-data:www-data storage/app/public/`
- Fix permissions: `chmod -R 755 storage/app/public/`

### Invalid Credentials
- Verify JSON file is valid: `cat firebase_credentials.json | jq .`
- Check file encoding (should be UTF-8)
- Ensure private key is properly formatted (including `\n` for newlines)

### Cache Issues
After updating config, clear Laravel cache:
```bash
php artisan config:clear
php artisan cache:clear
```

## Quick Setup Script

Save this as `setup-firebase-credentials.sh`:

```bash
#!/bin/bash
# Firebase Credentials Setup Script

FIREBASE_CREDENTIALS_PATH="/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json"

echo "Setting up Firebase credentials..."

# Check if file exists
if [ ! -f "$FIREBASE_CREDENTIALS_PATH" ]; then
    echo "Error: Firebase credentials file not found!"
    echo "Please upload the file to: $FIREBASE_CREDENTIALS_PATH"
    exit 1
fi

# Set permissions
chmod 600 "$FIREBASE_CREDENTIALS_PATH"
chown www-data:www-data "$FIREBASE_CREDENTIALS_PATH"

# Verify JSON is valid
if ! php -r "json_decode(file_get_contents('$FIREBASE_CREDENTIALS_PATH'));" 2>/dev/null; then
    echo "Error: Invalid JSON file!"
    exit 1
fi

echo "Firebase credentials configured successfully!"
echo "Clearing Laravel cache..."
php artisan config:clear
php artisan cache:clear

echo "Setup complete!"
```

Make it executable and run:
```bash
chmod +x setup-firebase-credentials.sh
./setup-firebase-credentials.sh
```

