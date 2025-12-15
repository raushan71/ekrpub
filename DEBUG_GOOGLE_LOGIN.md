# Debug Google Sign-In Customer Issue

## Problem 
Google Sign-In shows "user account setup incomplete" error, but regular login works fine.

## Root Cause
The `CustomerRepository::storeByRequest()` might be failing for Google login users because:
1. It might require specific request data that's not available
2. Customer creation might be failing silently
3. The check happens after user creation, blocking authentication

## Quick Fix

### Option 1: Check CustomerRepository Requirements

```bash
cat app/Repositories/CustomerRepository.php
```

See what `storeByRequest()` expects. It might need:
- Specific request fields
- Device key
- Other data

### Option 2: Test Customer Creation

```bash
php artisan tinker
```

```php
$user = User::where('email', 'test@example.com')->first();
try {
    CustomerRepository::storeByRequest($user);
    echo "Customer created successfully\n";
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
```

### Option 3: Check Customer Model

```php
$customer = \App\Models\Customer::first();
$customer->getFillable(); // Shows required fields
$customer->getTable(); // Shows table name
```

### Option 4: Create Customer Manually

If `storeByRequest()` requires request data, try creating customer directly:

```php
// In firebaseAuth method, instead of:
// CustomerRepository::storeByRequest($user);

// Try:
if (!$user->customer) {
    \App\Models\Customer::create([
        'user_id' => $user->id,
        // Add other required fields
    ]);
}
```

## Updated firebaseAuth Method

The updated method I provided:
1. ✅ Creates customer for new users (same as register)
2. ✅ Tries to create customer if missing (with error handling)
3. ✅ Allows admins to login without customer
4. ✅ Matches login method pattern: `if ($user->customer)`
5. ✅ Handles device_key if provided

## Check Laravel Logs

```bash
tail -f storage/logs/laravel.log
```

Then try Google Sign-In and look for:
- "Failed to create customer" warnings
- Any exceptions during customer creation

## Test After Fix

1. Update `firebaseAuth` method with the fixed version
2. Clear cache: `php artisan config:clear && php artisan cache:clear`
3. Try Google Sign-In
4. Check logs for any errors

