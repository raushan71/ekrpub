# Debug Laravel Firebase Error

## Check the Full Error

The stack trace shows the bottom, but we need to see the actual error message. Run:

```bash
tail -100 /home/ekray/htdocs/ekray.com/storage/logs/laravel.log | grep -A 20 "ERROR\|Exception\|Error"
```

Or to see the most recent error:

```bash
tail -200 /home/ekray/htdocs/ekray.com/storage/logs/laravel.log | head -50
```

## Common Errors

### 1. Firebase Admin SDK Not Installed

If you see "Class 'Firebase' not found":

```bash
composer require kreait/firebase-php
```

Or if using Laravel Firebase package:

```bash
composer require kreait/laravel-firebase
php artisan vendor:publish --provider="Kreait\Laravel\Firebase\ServiceProvider" --tag="config"
```

### 2. Firebase Config Not Published

If you see "Config file not found":

```bash
php artisan vendor:publish --provider="Kreait\Laravel\Firebase\ServiceProvider" --tag="config"
```

Then check `config/firebase.php` exists and points to your credentials file.

### 3. Credentials File Path Issue

Check your `config/firebase.php`:

```php
<?php

return [
    'credentials' => [
        'file' => storage_path('app/public/firebase_credentials.json'),
    ],
];
```

Or using environment variable:

```php
'credentials' => env('FIREBASE_CREDENTIALS', storage_path('app/public/firebase_credentials.json')),
```

### 4. Test Firebase Connection

Test if Firebase is working:

```bash
php artisan tinker
```

Then run:

```php
try {
    $auth = app('firebase.auth');
    echo "Firebase connection successful!";
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . ":" . $e->getLine() . "\n";
}
```

### 5. Check Route Exists

Verify the route is registered:

```bash
php artisan route:list | grep firebase-auth
```

Should show:
```
POST api/firebase-auth ... AuthController@firebaseAuth
```

### 6. Check Controller Method Exists

Make sure `AuthController` has the `firebaseAuth` method. Check:

```bash
grep -n "firebaseAuth" app/Http/Controllers/API/Auth/AuthController.php
```

## Quick Test Endpoint

Test the endpoint directly with a dummy token:

```bash
curl -X POST https://ekray.com/api/firebase-auth \
  -H "Content-Type: application/json" \
  -d '{"firebase_id_token":"test-token"}' \
  -v
```

This will show you the exact error response.

## Enable Debug Mode

Make sure `.env` has:

```
APP_DEBUG=true
LOG_LEVEL=debug
```

Then try Google Sign-In again and check logs.

