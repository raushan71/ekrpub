# Spatie Laravel Permission Setup for Firebase Auth

## Your Setup

Your Laravel app uses **Spatie Laravel Permission** package, which means:
- Roles are stored in a separate `roles` table
- User-role relationships are in `model_has_roles` pivot table
- **NO `role` column in `users` table** (that's why `User::first()->role` returns `null`)

## Verify Spatie is Working

```bash
php artisan tinker
```

```php
// Check if Spatie is installed
use Spatie\Permission\Models\Role;
Role::all();

// Check if customer role exists
Role::where('name', 'customer')->first();

// Check user's roles
$user = User::first();
$user->roles; // Should show collection of roles
$user->hasRole('customer'); // Should return true/false
```

## Fix Existing Users Without Roles

If you have users without the customer role assigned:

```bash
php artisan tinker
```

```php
use App\Enums\Roles;
use App\Models\User;

// Get all users without customer role
$usersWithoutRole = User::whereDoesntHave('roles', function($query) {
    $query->where('name', Roles::CUSTOMER->value);
})->get();

// Assign customer role to all users without it
foreach ($usersWithoutRole as $user) {
    if (!$user->hasRole(Roles::CUSTOMER->value)) {
        $user->assignRole(Roles::CUSTOMER->value);
    }
}

echo "Updated " . $usersWithoutRole->count() . " users";
```

## Ensure Customer Role Exists

If the customer role doesn't exist, create it:

```bash
php artisan tinker
```

```php
use Spatie\Permission\Models\Role;
use App\Enums\Roles;

// Check if customer role exists
$role = Role::where('name', Roles::CUSTOMER->value)->first();

if (!$role) {
    // Create customer role
    Role::create(['name' => Roles::CUSTOMER->value]);
    echo "Customer role created";
} else {
    echo "Customer role already exists";
}
```

## Verify Your firebaseAuth Method

Your `firebaseAuth` method should:

1. ✅ Use `$user->assignRole(Roles::CUSTOMER->value)` (not `$user->role = 'customer'`)
2. ✅ Check roles with `$user->hasRole(Roles::CUSTOMER->value)`
3. ✅ NOT try to set a `role` column directly

The updated method I provided does this correctly.

## Test the Setup

After updating your `firebaseAuth` method:

1. Try Google Sign-In from the app
2. Check if user was created/updated:
   ```bash
   php artisan tinker
   ```
   ```php
   $user = User::latest()->first();
   echo "Has customer role: " . ($user->hasRole('customer') ? 'Yes' : 'No') . "\n";
   echo "Has customer relationship: " . ($user->customer ? 'Yes' : 'No') . "\n";
   ```

## Common Issues

### Issue 1: Role doesn't exist
**Solution:** Create the role using the tinker command above

### Issue 2: User has no roles
**Solution:** Run the fix script above to assign roles to existing users

### Issue 3: Middleware check fails
**Solution:** Make sure `'role:customer'` middleware is checking Spatie roles, not a column

## Quick Fix Command

Run this to fix all users without customer role:

```bash
php artisan tinker
```

```php
use App\Enums\Roles;
use App\Models\User;

User::all()->each(function($user) {
    if (!$user->hasRole(Roles::CUSTOMER->value)) {
        $user->assignRole(Roles::CUSTOMER->value);
        echo "Assigned role to user: {$user->email}\n";
    }
});
```

