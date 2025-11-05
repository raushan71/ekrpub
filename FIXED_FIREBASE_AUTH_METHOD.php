<?php

/**
 * Fixed firebaseAuth method - handles customer creation properly
 * and doesn't block authentication if customer setup fails
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
            // Update existing user
            $user->update([
                'firebase_uid' => $uid,
                'name' => $name ?? $user->name,
                'email' => $email ?? $user->email,
                'phone' => $phone ?? $user->phone,
            ]);
            
            // Try to ensure user has customer relationship (only for customer role users)
            if ($user->hasRole(Roles::CUSTOMER->value) && !$user->customer) {
                try {
                    CustomerRepository::storeByRequest($user);
                } catch (\Exception $e) {
                    // Log error but don't fail authentication
                    \Log::warning('Failed to create customer for user: ' . $user->id . ' - ' . $e->getMessage());
                }
            }
            
            // Try to ensure user has wallet (only for customer role users)
            if ($user->hasRole(Roles::CUSTOMER->value) && !$user->wallet) {
                try {
                    WalletRepository::storeByRequest($user);
                } catch (\Exception $e) {
                    // Log error but don't fail authentication
                    \Log::warning('Failed to create wallet for user: ' . $user->id . ' - ' . $e->getMessage());
                }
            }
            
            // Ensure user has customer role (if they don't have admin role)
            if (!$user->hasRole(Roles::CUSTOMER->value) && !$user->hasAnyRole(['admin', 'super_admin'])) {
                $user->assignRole(Roles::CUSTOMER->value);
            }
        } else {
            // Create new user
            $user = User::create([
                'firebase_uid' => $uid,
                'name' => $name,
                'email' => $email,
                'phone' => $phone,
                'password' => Hash::make(uniqid()),
            ]);
            
            // Assign customer role
            $user->assignRole(Roles::CUSTOMER->value);
            
            // Try to create customer (with error handling)
            try {
                CustomerRepository::storeByRequest($user);
            } catch (\Exception $e) {
                \Log::warning('Failed to create customer for new user: ' . $user->id . ' - ' . $e->getMessage());
            }
            
            // Try to create wallet (with error handling)
            try {
                WalletRepository::storeByRequest($user);
            } catch (\Exception $e) {
                \Log::warning('Failed to create wallet for new user: ' . $user->id . ' - ' . $e->getMessage());
            }
        }
        
        // Don't block authentication if customer doesn't exist
        // Only check if user is trying to access customer-specific features
        // For now, allow authentication to proceed
        
        DB::commit();
        
        // Use the same response format as login/register methods
        return $this->json('Authentication successful', [
            'user' => new UserResource($user),
            'access' => UserRepository::getAccessToken($user),
        ]);
        
    } catch (\Kreait\Firebase\Exception\Auth\InvalidToken $e) {
        DB::rollBack();
        return $this->json('Invalid Firebase token: ' . $e->getMessage(), [], Response::HTTP_UNAUTHORIZED);
    } catch (\Exception $e) {
        DB::rollBack();
        \Log::error('Firebase auth error: ' . $e->getMessage());
        return $this->json('Authentication failed: ' . $e->getMessage(), [], Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}

