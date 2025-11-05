<?php

/**
 * Updated firebaseAuth method for AuthController
 * This matches your existing code patterns and uses the same repositories
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
            ]);
            
            // Ensure user has customer relationship
            if (!$user->customer) {
                CustomerRepository::storeByRequest($user);
            }
            
            // Ensure user has wallet
            if (!$user->wallet) {
                WalletRepository::storeByRequest($user);
            }
            
            // Ensure user has role assigned (if using Spatie)
            if (!$user->hasRole(Roles::CUSTOMER->value)) {
                $user->assignRole(Roles::CUSTOMER->value);
            }
        } else {
            // Create new user using the same pattern as register()
            $user = User::create([
                'firebase_uid' => $uid,
                'name' => $name,
                'email' => $email,
                'phone' => $phone,
                'password' => Hash::make(uniqid()), // Random password since Firebase handles auth
            ]);
            
            // Create customer (same as register method)
            CustomerRepository::storeByRequest($user);
            
            // Create wallet (same as register method)
            WalletRepository::storeByRequest($user);
            
            // Assign role (same as register method)
            $user->assignRole(Roles::CUSTOMER->value);
        }
        
        // Check if user has customer (required for login)
        if (!$user->customer) {
            DB::rollBack();
            return $this->json('User account setup incomplete. Please contact support.', [], Response::HTTP_FORBIDDEN);
        }
        
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
        return $this->json('Authentication failed: ' . $e->getMessage(), [], Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}

