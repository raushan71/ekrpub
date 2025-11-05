<?php

/**
 * Fixed firebaseAuth method for Google Sign-In
 * Matches the login method pattern and doesn't block on customer creation
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
            
            // Ensure user has customer role (if not admin)
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
            
            // Create customer (same as register method)
            CustomerRepository::storeByRequest($user);
            
            // Create wallet (same as register method)
            WalletRepository::storeByRequest($user);
        }
        
        // Check if user has customer (same check as login method)
        // But don't block if customer creation failed - allow authentication to proceed
        if (!$user->customer && $user->hasRole(Roles::CUSTOMER->value)) {
            // Try to create customer if missing (for customer role users)
            try {
                CustomerRepository::storeByRequest($user);
            } catch (\Exception $e) {
                \Log::warning('Failed to create customer for user ' . $user->id . ': ' . $e->getMessage());
                // Continue anyway - don't block authentication
            }
        }
        
        // If user has customer relationship OR is admin, proceed
        // This matches the login method pattern: if ($user?->customer)
        if ($user->customer || $user->hasAnyRole(['admin', 'super_admin'])) {
            DB::commit();
            
            // Handle device key if provided (same as login method)
            if ($request->device_key) {
                DeviceKeyRepository::storeByRequest($user, $request);
            }
            
            // Use the same response format as login/register methods
            return $this->json('Authentication successful', [
                'user' => new UserResource($user),
                'access' => UserRepository::getAccessToken($user),
            ]);
        }
        
        // If customer is required but missing, rollback
        DB::rollBack();
        return $this->json('User account setup incomplete. Please contact support.', [], Response::HTTP_FORBIDDEN);
        
    } catch (\Kreait\Firebase\Exception\Auth\InvalidToken $e) {
        DB::rollBack();
        return $this->json('Invalid Firebase token: ' . $e->getMessage(), [], Response::HTTP_UNAUTHORIZED);
    } catch (\Exception $e) {
        DB::rollBack();
        \Log::error('Firebase auth error: ' . $e->getMessage());
        return $this->json('Authentication failed: ' . $e->getMessage(), [], Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}

