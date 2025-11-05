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

#### Add Route to `routes/api.php`:

Add this route **before** the auth middleware routes (around line 50):

```php
// Firebase Auth route (add this before auth middleware)
Route::controller(AuthController::class)->group(function () {
    Route::post('/firebase-auth', 'firebaseAuth');
});
```

#### Add Method to `App\Http\Controllers\API\Auth\AuthController`:

Add this method to your existing `AuthController`:

```php
/**
 * Handle Firebase Authentication
 */
public function firebaseAuth(Request $request)
{
    $validator = Validator::make($request->all(), [
        'firebase_id_token' => 'required|string',
        'name' => 'nullable|string|max:255',
        'email' => 'nullable|email|max:255',
        'phone' => 'nullable|string|max:20',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422);
    }

    try {
        // Verify Firebase ID token
        $firebaseAuth = Firebase::auth();
        $verifiedIdToken = $firebaseAuth->verifyIdToken($request->firebase_id_token);
        $uid = $verifiedIdToken->claims()->get('sub');
        
        // Get user info from Firebase token
        $firebaseUser = $firebaseAuth->getUser($uid);
        $email = $request->email ?? $firebaseUser->email ?? null;
        $name = $request->name ?? $firebaseUser->displayName ?? 'User';
        $phone = $request->phone ?? $firebaseUser->phoneNumber ?? null;
        
        // Check if user exists by email or Firebase UID
        $user = User::where('email', $email)
            ->orWhere('firebase_uid', $uid)
            ->first();
        
        DB::beginTransaction();
        
        if ($user) {
            // Update existing user - PRESERVE EXISTING ROLE
            $user->update([
                'firebase_uid' => $uid,
                'name' => $name ?? $user->name,
                'email' => $email ?? $user->email,
                'phone' => $phone ?? $user->phone,
                // Do NOT update role - preserve existing role
            ]);
            
            // If user has no role, assign default role
            if (empty($user->role)) {
                $user->update(['role' => 'customer']);
            }
        } else {
            // Create new user with default role
            $user = User::create([
                'firebase_uid' => $uid,
                'name' => $name,
                'email' => $email,
                'phone' => $phone,
                'password' => Hash::make(uniqid()), // Random password since Firebase handles auth
                'role' => 'customer', // Default role - adjust based on your system
            ]);
        }
        
        // Optional: Verify user has required role before generating token
        // Uncomment if you need to enforce role check
        // $allowedRoles = ['customer', 'user'];
        // if (!in_array($user->role, $allowedRoles)) {
        //     DB::rollBack();
        //     return response()->json([
        //         'message' => 'User does not have the right role. Current role: ' . $user->role,
        //     ], 403);
        // }
        
        // Generate Sanctum token (or your existing auth token system)
        $token = $user->createToken('mobile-app')->plainTextToken;
        
        DB::commit();
        
        return response()->json([
            'message' => 'Authentication successful',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'firebase_uid' => $user->firebase_uid,
                ],
                'access' => [
                    'token' => $token,
                ],
            ],
        ], 200);
        
    } catch (\Kreait\Firebase\Exception\Auth\InvalidToken $e) {
        return response()->json([
            'message' => 'Invalid Firebase token: ' . $e->getMessage(),
        ], 401);
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'message' => 'Authentication failed: ' . $e->getMessage(),
        ], 500);
    }
}
```

#### Add Required Imports to AuthController:

Make sure these imports are at the top of your `AuthController.php`:

```php
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Kreait\Laravel\Firebase\Facades\Firebase;
```

### Step 4: Database Migration

Add `firebase_uid` column to your `users` table:

```bash
php artisan make:migration add_firebase_uid_to_users_table
```

In the migration file:

```php
public function up()
{
    Schema::table('users', function (Blueprint $table) {
        $table->string('firebase_uid')->nullable()->unique()->after('id');
    });
}

public function down()
{
    Schema::table('users', function (Blueprint $table) {
        $table->dropColumn('firebase_uid');
    });
}
```

Run migration:
```bash
php artisan migrate
```

### Step 5: Install Firebase Admin SDK (if not already installed)

```bash
composer require kreait/firebase-php
```

Or if using Laravel Firebase package:

```bash
composer require kreait/laravel-firebase
```

Publish config:

```bash
php artisan vendor:publish --provider="Kreait\Laravel\Firebase\ServiceProvider" --tag="config"
```

Configure Firebase credentials in `.env` or `config/firebase.php`.

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

## Response Format

Success response (200):
```json
{
  "message": "Authentication successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Test User",
      "email": "test@example.com",
      "phone": null,
      "firebase_uid": "firebase_uid_here"
    },
    "access": {
      "token": "sanctum_token_here"
    }
  }
}
```

Error response (401/422/500):
```json
{
  "message": "Error message here"
}
```

## Important Notes

1. **Firebase UID:** Store Firebase UID to link Firebase users with Laravel users
2. **Password:** Since Firebase handles authentication, you can set a random password for Laravel users
3. **Email/Phone:** Use email or phone from Firebase token if not provided in request
4. **Role:** Set default role to 'customer' (adjust based on your system)
5. **Token System:** Adjust token generation based on your auth system (Sanctum/Passport/JWT)

## Common Backend Errors

### Error: Firebase Credentials File Not Found

**Error Message:**
```
SplFileObject::__construct(.../firebase_credentials.json): Failed to open stream: No such file or directory
```

**Solution:** 
1. Download Firebase Service Account JSON from Firebase Console
2. Upload it to your VPS: `/home/ekray/htdocs/ekray.com/storage/app/public/firebase_credentials.json`
3. Set proper permissions: `chmod 600` and `chown www-data:www-data`

See `FIREBASE_VPS_SETUP.md` for detailed instructions.

### Error: Google Sign-In Configuration Error

**Error Message:**
```
Google Sign-In configuration error. Please ensure SHA-1 fingerprint is added to Firebase Console.
```

**Solution:** 
1. Get SHA-1 fingerprint (see Step 1 above)
2. Add it to Firebase Console → Project Settings → Your Android App
3. Download updated `google-services.json`
4. Replace in your Flutter app

See Step 1 and Step 2 in this guide for details.

