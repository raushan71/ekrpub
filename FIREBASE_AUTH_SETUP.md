# Firebase Authentication Setup Guide

## Issues Found

Based on the error messages you're seeing:

### 1. Backend API Error
**Error:** "The POST method is not supported for route api/firebase-auth. Supported methods: GET, HEAD."

**Solution:** You need to add a POST route in your Laravel backend for `/api/firebase-auth`.

### 2. Google Sign-In Error
**Error:** "PlatformException(sign_in_failed, com.google.android.gms.common.api.j: 10:)"

**Solution:** This error code 10 (`DEVELOPER_ERROR`) typically means:
- Missing SHA-1 fingerprint in Firebase Console
- Google Sign-In not enabled in Firebase Console
- Incorrect OAuth client ID configuration

## Setup Instructions

### Step 1: Add SHA-1 Fingerprint to Firebase

1. Get your SHA-1 fingerprint:
   ```bash
   # For debug keystore (default)
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # For release keystore (if you have one)
   keytool -list -v -keystore android/app/key.jks -alias key -storepass raushan7171 -keypass raushan7171
   ```

2. Copy the SHA-1 fingerprint (looks like: `AA:BB:CC:DD:EE:FF:...`)

3. Go to Firebase Console → Project Settings → Your Android App
4. Scroll to "SHA certificate fingerprints"
5. Click "Add fingerprint" and paste your SHA-1
6. Download the updated `google-services.json` and replace the existing one

### Step 2: Enable Google Sign-In in Firebase Console

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable "Google" provider
3. Add your OAuth client IDs (these are automatically added when you add SHA-1)

### Step 3: Configure Laravel Backend

Add this route to your Laravel `routes/api.php`:

```php
Route::post('/firebase-auth', [AuthController::class, 'firebaseAuth'])->name('firebase.auth');
```

Add this method to your `AuthController`:

```php
public function firebaseAuth(Request $request)
{
    $request->validate([
        'firebase_id_token' => 'required|string',
        'name' => 'nullable|string',
        'email' => 'nullable|email',
        'phone' => 'nullable|string',
    ]);

    try {
        // Verify Firebase ID token
        $firebaseAuth = app('firebase.auth');
        $verifiedIdToken = $firebaseAuth->verifyIdToken($request->firebase_id_token);
        $uid = $verifiedIdToken->claims()->get('sub');
        
        // Get or create user
        $user = User::firstOrCreate(
            ['firebase_uid' => $uid],
            [
                'name' => $request->name ?? 'User',
                'email' => $request->email,
                'phone' => $request->phone,
            ]
        );

        // Generate access token (using your existing auth system)
        $token = $user->createToken('mobile-app')->accessToken;

        return response()->json([
            'message' => 'Authentication successful',
            'data' => [
                'user' => $user,
                'access' => [
                    'token' => $token,
                ],
            ],
        ], 200);
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Authentication failed: ' . $e->getMessage(),
        ], 401);
    }
}
```

### Step 4: Install Firebase Admin SDK in Laravel (if not already installed)

```bash
composer require kreait/firebase-php
```

## Testing

After completing the setup:

1. **Email/Password Auth:** Should work immediately if Firebase is configured
2. **Google Sign-In:** Will work after adding SHA-1 fingerprint and enabling in Firebase Console
3. **Backend Linking:** Will work after adding the Laravel route

## Error Handling

The app now provides clearer error messages:
- Google Sign-In errors will indicate configuration issues
- Backend errors will indicate if the route is missing
- Network errors will be clearly identified

