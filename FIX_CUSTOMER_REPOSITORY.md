# Fix Customer Repository Issue

## Problem
- Firebase auth shows "user account setup incomplete"
- Admin users can't login
- Customer creation might be failing

## Root Cause
1. `CustomerRepository::storeByRequest()` might require specific request data
2. Admin users don't need customer relationship
3. Customer creation might be failing silently

## Solution 1: Check CustomerRepository

Check what `CustomerRepository::storeByRequest()` expects:

```bash
cat app/Repositories/CustomerRepository.php
```

It might need:
- Request object with specific fields
- Device key
- Other data

## Solution 2: Alternative Customer Creation

If `storeByRequest()` requires request data, create customer directly:

```php
// Instead of CustomerRepository::storeByRequest($user)
// Try creating customer directly if method exists:

if (!$user->customer) {
    try {
        // Check if Customer model has a create method
        \App\Models\Customer::create([
            'user_id' => $user->id,
            // Add other required fields based on your Customer model
        ]);
    } catch (\Exception $e) {
        \Log::warning('Customer creation failed: ' . $e->getMessage());
    }
}
```

## Solution 3: Make Customer Optional

Update the firebaseAuth method to:
1. Not require customer relationship for authentication
2. Only create customer for customer-role users
3. Allow admins to authenticate without customer

## Solution 4: Check Customer Model

See what fields Customer model requires:

```bash
php artisan tinker
```

```php
$customer = \App\Models\Customer::first();
$customer->getFillable(); // Shows required fields
```

## Quick Fix: Remove Customer Check

If customer relationship is optional, remove the check:

```php
// Remove this check:
// if (!$user->customer) {
//     DB::rollBack();
//     return $this->json('User account setup incomplete...', [], Response::HTTP_FORBIDDEN);
// }

// Replace with optional customer creation:
if (!$user->customer && $user->hasRole(Roles::CUSTOMER->value)) {
    try {
        CustomerRepository::storeByRequest($user);
    } catch (\Exception $e) {
        \Log::warning('Customer creation failed: ' . $e->getMessage());
    }
}
```

## Check Your Login Method

Your regular login method checks `$user?->customer`. See if that's causing issues:

```php
// In login method
if ($user?->customer) {
    // Login success
} else {
    return $this->json('Credential is invalid!', [], Response::HTTP_BAD_REQUEST);
}
```

This might be too strict. Consider making it optional for certain user types.

