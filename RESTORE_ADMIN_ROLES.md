# Restore SuperAdmin Role

## Quick Fix

Run this in your VPS terminal:

```bash
php artisan tinker
```

Then paste this code:

```php
use App\Models\User;
use Spatie\Permission\Models\Role;

$email = 'rishagrwl24@gmail.com';
$user = User::where('email', $email)->first();

if ($user) {
    // Check if superadmin role exists
    $superAdminRole = Role::where('name', 'super_admin')->orWhere('name', 'admin')->first();
    
    if (!$superAdminRole) {
        // Create superadmin role if it doesn't exist
        $superAdminRole = Role::create(['name' => 'super_admin']);
    }
    
    // Remove customer role if exists
    if ($user->hasRole('customer')) {
        $user->removeRole('customer');
        echo "Removed customer role\n";
    }
    
    // Assign superadmin role
    $user->assignRole($superAdminRole->name);
    echo "Assigned {$superAdminRole->name} role to {$user->email}\n";
    echo "Current roles: " . $user->roles->pluck('name')->join(', ') . "\n";
} else {
    echo "User not found\n";
}
```

## Alternative: Check What Roles Exist

First, check what admin roles are available:

```php
Role::all()->pluck('name');
```

Then assign the appropriate role:

```php
$user = User::where('email', 'rishagrwl24@gmail.com')->first();
$user->assignRole('super_admin'); // or 'admin', 'administrator', etc.
```

## Fix Firebase Auth Method

To prevent this from happening again, update your `firebaseAuth` method to:

1. **Check if user is admin before assigning customer role:**
```php
// Only assign customer role if user is not admin
if (!$user->hasAnyRole(['admin', 'super_admin', 'administrator'])) {
    $user->assignRole(Roles::CUSTOMER->value);
}
```

2. **Preserve existing admin roles when updating:**
```php
if ($user) {
    // Update existing user
    $user->update([
        'firebase_uid' => $uid,
        'name' => $name ?? $user->name,
        'email' => $email ?? $user->email,
        'phone' => $phone ?? $user->phone,
    ]);
    
    // DON'T assign customer role if user is admin
    if (!$user->hasAnyRole(['admin', 'super_admin', 'administrator'])) {
        if (!$user->hasRole(Roles::CUSTOMER->value)) {
            $user->assignRole(Roles::CUSTOMER->value);
        }
    }
}
```

## List All Admin Users

To see all users with admin roles:

```php
User::role(['admin', 'super_admin', 'administrator'])->get(['id', 'name', 'email']);
```

## Check User's Current Roles

```php
$user = User::where('email', 'rishagrwl24@gmail.com')->first();
echo "Roles: " . $user->roles->pluck('name')->join(', ') . "\n";
```

