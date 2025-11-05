# Login Issue Fix

## Problem
Users can login via web frontend (https://ekray.com) but cannot login using the Flutter app with the same credentials.

## Root Cause
The Flutter app was trying to use Firebase Auth for email logins, which requires Firebase credentials file on the backend. However:
- Existing users registered via web frontend use standard Laravel authentication
- The Laravel backend accepts both email and phone in the `phone` field
- Firebase Auth should only be used for NEW users who sign up via Firebase

## Solution
Updated the login flow to use the standard Laravel login API for both email and phone, matching the web frontend behavior.

### Changes Made

1. **Updated `login_layout.dart`**:
   - Removed Firebase Auth check for email login
   - Now uses standard Laravel login API for both email and phone
   - Laravel backend handles both email and phone in the `phone` field

2. **Updated `auth_service.dart`**:
   - Added comment clarifying that `phone` field accepts both email and phone

## How It Works Now

- **Email Login**: Uses Laravel `/api/login` with email in `phone` field
- **Phone Login**: Uses Laravel `/api/login` with phone in `phone` field
- **Firebase Auth**: Only used for new signups via Firebase (Google Sign-In, Firebase email/password signup)

## Testing

After this fix:
1. Users who registered via web frontend can now login with email/password
2. Users who registered via web frontend can login with phone/password
3. New users can still sign up via Firebase (Google Sign-In)
4. All logins use the same Laravel authentication system

## Fallback Option

If you want to keep Firebase Auth for email logins (for new Firebase users), you can:
1. First try standard Laravel login
2. If it fails, try Firebase Auth (for new Firebase users)
3. This requires Firebase credentials on the backend

But the current fix (using Laravel login for all) is simpler and matches the web frontend behavior.

