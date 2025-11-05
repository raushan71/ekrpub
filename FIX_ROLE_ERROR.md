# Fix "User does not have the right role" Error

## Problem
After successful Firebase authentication, you get "user does not have the right role" error.

## Root Cause
The user might:
1. Already exist with a different role
2. Have no role assigned
3. Need a specific role format/name

## Solution: Update Laravel `firebaseAuth` Method

Update your `AuthController::firebaseAuth` method to handle roles properly:

```php
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
        
        // Check if user has required role before generating token
        // Adjust this based on your role requirements
        $allowedRoles = ['customer', 'user']; // Add other allowed roles
        
        if (!in_array($user->role, $allowedRoles)) {
            DB::rollBack();
            return response()->json([
                'message' => 'User does not have the right role. Current role: ' . $user->role,
            ], 403);
        }
        
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
                    'role' => $user->role, // Include role in response
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

## Alternative: Check Your Role System

Your Laravel app might use a different role system. Check:

### 1. Check User Model

```php
// Check app/Models/User.php
// See what role field/relationship is used
```

### 2. Check Existing Users

```bash
php artisan tinker
```

```php
$user = User::first();
echo "Role field: " . ($user->role ?? 'N/A') . "\n";
echo "All fields: " . json_encode($user->toArray()) . "\n";
```

### 3. Check Role Middleware

Look at your routes - if you see `'role:customer'`, that's the role name you need:

```php
Route::middleware(['auth:sanctum', 'role:customer'])->group(function () {
    // Routes here
});
```

### 4. Check Role Assignment

If using Spatie Laravel Permission or similar:

```php
// Might need to assign role differently
$user->assignRole('customer');
```

## Quick Fix: Update Existing Users

If existing users don't have the right role:

```bash
php artisan tinker
```

```php
// Update all users without role to 'customer'
User::whereNull('role')->orWhere('role', '')->update(['role' => 'customer']);

// Or update specific user
$user = User::where('email', 'user@example.com')->first();
$user->update(['role' => 'customer']);
```

## Common Role Values

Based on your routes, the role should be:
- `'customer'` (most common for mobile app users)
- `'user'`
- `'client'`

Check your `routes/api.php` to see what role middleware expects.

## Test After Fix

1. Clear Laravel cache:
   ```bash
   php artisan config:clear
   php artisan cache:clear
   ```

2. Try Google Sign-In again

3. Check if user has correct role:
   ```bash
   php artisan tinker
   ```
   ```php
   $user = User::latest()->first();
   echo "Role: " . $user->role . "\n";
   ```

