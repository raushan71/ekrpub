# Fixing 403 Error for Google Sign-In

## Problem
Google Sign-In works successfully, but when trying to link with Laravel backend, you get a **403 Forbidden** error.

## Root Cause
A 403 error typically means:
1. **Firebase credentials file missing** on the backend server
2. **Firebase token verification failing** on the backend
3. **Backend route is protected** by middleware that's blocking the request
4. **CORS issues** (less likely but possible)

## Solution

### Step 1: Check Backend Laravel Logs

SSH into your VPS and check Laravel logs:

```bash
ssh vps
tail -f /home/ekray/htdocs/ekray.com/storage/logs/laravel.log
```

Then try Google Sign-In from the app and watch for errors.

### Step 2: Verify Firebase Credentials File

Check if the Firebase credentials file exists on the server:

```bash
ls -la /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

If it doesn't exist, upload it (see `FIREBASE_VPS_SETUP.md`).

### Step 3: Check File Permissions

```bash
chmod 600 /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
chown www-data:www-data /home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json
```

### Step 4: Verify Laravel Route

Check your `routes/api.php` file. The route should be **outside** the auth middleware:

```php
// Firebase Auth route (should be BEFORE auth middleware)
Route::controller(AuthController::class)->group(function () {
    Route::post('/firebase-auth', 'firebaseAuth');
});

// Auth middleware routes (below)
Route::middleware(['auth:sanctum', 'role:customer'])->group(function () {
    // ... other routes
});
```

### Step 5: Check Laravel Controller

Make sure your `AuthController::firebaseAuth` method is properly handling Firebase token verification:

```php
public function firebaseAuth(Request $request)
{
    // ... validation ...
    
    try {
        $firebaseAuth = Firebase::auth();
        $verifiedIdToken = $firebaseAuth->verifyIdToken($request->firebase_id_token);
        // ... rest of the code
    } catch (\Exception $e) {
        // This might be throwing 403
        return response()->json([
            'message' => 'Firebase token verification failed: ' . $e->getMessage()
        ], 403);
    }
}
```

### Step 6: Test Backend Endpoint Directly

Test the endpoint with curl:

```bash
curl -X POST https://ekray.com/api/firebase-auth \
  -H "Content-Type: application/json" \
  -d '{
    "firebase_id_token": "YOUR_TEST_TOKEN"
  }'
```

Replace `YOUR_TEST_TOKEN` with a valid Firebase ID token from your app (you can get it from debug logs).

## Common Issues

### Issue 1: Firebase Credentials File Path Wrong

Check your `config/firebase.php`:

```php
'credentials' => storage_path('app/public/firebase_credentials.json'),
```

Make sure the path matches where you uploaded the file.

### Issue 2: Firebase Admin SDK Not Installed

```bash
composer require kreait/firebase-php
```

Or if using Laravel Firebase package:

```bash
composer require kreait/laravel-firebase
php artisan vendor:publish --provider="Kreait\Laravel\Firebase\ServiceProvider"
```

### Issue 3: Route Behind Auth Middleware

If your route is inside `auth:sanctum` middleware, it will require authentication before Firebase auth, causing a 403. Move it outside.

### Issue 4: CORS Configuration

If you have CORS middleware, make sure it allows POST requests to `/api/firebase-auth`.

## Improved Error Handling

The app now shows better error messages for 403 errors:
- If Firebase credentials file is missing
- If token verification fails
- Specific backend error messages

## Next Steps

1. ✅ Check Laravel logs for specific error
2. ✅ Verify Firebase credentials file exists
3. ✅ Check route is not behind auth middleware
4. ✅ Test endpoint directly with curl
5. ✅ Verify Firebase Admin SDK is properly configured

## Debugging Tips

1. **Enable debug logging in Laravel** (`.env`):
   ```
   APP_DEBUG=true
   LOG_LEVEL=debug
   ```

2. **Check Firebase Admin SDK logs**:
   ```php
   \Log::info('Firebase token: ' . $request->firebase_id_token);
   \Log::info('Firebase verification attempt');
   ```

3. **Check app debug logs** for the exact error message

