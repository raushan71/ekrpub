<?php

/**
 * Restore SuperAdmin Role
 * Run this in Laravel Tinker or as a one-time script
 */

// Option 1: Run in Tinker
// php artisan tinker
// Then paste the code below

use App\Models\User;
use Spatie\Permission\Models\Role;

$email = 'rishagrwl24@gmail.com';

// Find the user
$user = User::where('email', $email)->first();

if (!$user) {
    echo "User not found with email: $email\n";
    exit;
}

// Check if superadmin role exists
$superAdminRole = Role::where('name', 'super_admin')->first();
if (!$superAdminRole) {
    // Try 'admin' instead
    $superAdminRole = Role::where('name', 'admin')->first();
    if (!$superAdminRole) {
        echo "SuperAdmin or Admin role not found. Creating...\n";
        $superAdminRole = Role::create(['name' => 'super_admin']);
    }
}

// Remove customer role if exists
if ($user->hasRole('customer')) {
    $user->removeRole('customer');
    echo "Removed customer role\n";
}

// Assign superadmin role
if (!$user->hasRole($superAdminRole->name)) {
    $user->assignRole($superAdminRole->name);
    echo "Assigned {$superAdminRole->name} role\n";
} else {
    echo "User already has {$superAdminRole->name} role\n";
}

// Verify
echo "User roles: " . $user->roles->pluck('name')->join(', ') . "\n";
echo "User email: {$user->email}\n";
echo "User ID: {$user->id}\n";

