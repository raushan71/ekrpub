# Verify Firebase Credentials Setup

## ✅ File Uploaded Successfully

Your Firebase credentials file is now at:
```
/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

## Next Steps

### Step 1: Set Proper Permissions

SSH into your VPS and set the correct permissions:

```bash
ssh vps

# Set file permissions (read-only for owner, no access for others)
chmod 600 /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json

# Set ownership (adjust user/group based on your setup)
chown www-data:www-data /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

### Step 2: Verify File is Readable

```bash
# Check if Laravel can read the file
php -r "echo file_exists('/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json') ? 'File exists' : 'File not found';"

# Check if JSON is valid
php -r "json_decode(file_get_contents('/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json')); echo 'JSON is valid';"
```

### Step 3: Clear Laravel Cache

```bash
cd /home/ekray/htdocs/ekray.com
php artisan config:clear
php artisan cache:clear
```

### Step 4: Test Firebase Connection

You can test if Laravel can connect to Firebase:

```bash
php artisan tinker
```

Then in tinker:
```php
try {
    $auth = app('firebase.auth');
    echo "Firebase connection successful!";
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage();
}
```

### Step 5: Test the Endpoint

Monitor Laravel logs while testing:

```bash
# In one terminal, watch logs
tail -f /home/ekray/htdocs/ekray.com/storage/logs/laravel.log

# In another terminal or from your app, try Google Sign-In
```

### Step 6: Check Laravel Config

Make sure your `config/firebase.php` points to the correct file:

```php
'credentials' => storage_path('app/public/firebase_credentials.json'),
```

Or if using environment variable:

```php
'credentials' => env('FIREBASE_CREDENTIALS', storage_path('app/public/firebase_credentials.json')),
```

## Troubleshooting

### If you still get 403:

1. **Check Laravel logs** for specific error:
   ```bash
   tail -50 /home/ekray/htdocs/ekray.com/storage/logs/laravel.log
   ```

2. **Check file permissions**:
   ```bash
   ls -la /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
   ```
   Should show: `-rw------- www-data www-data`

3. **Verify route is accessible**:
   ```bash
   curl -X POST https://ekray.com/api/firebase-auth \
     -H "Content-Type: application/json" \
     -d '{"firebase_id_token":"test"}'
   ```

4. **Check if Firebase Admin SDK is installed**:
   ```bash
   composer show | grep firebase
   ```

## Expected Result

After setup:
- ✅ Google Sign-In should work
- ✅ No more 403 errors
- ✅ User should be created/linked in Laravel database
- ✅ User should receive Laravel authentication token

## Test Google Sign-In Again

1. Open your Flutter app
2. Try Google Sign-In
3. Check if it works without 403 error
4. If error persists, check Laravel logs for specific error message

