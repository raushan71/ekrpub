import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ekray/models/eCommerce/authentication/sign_up.dart';
import 'package:ekray/models/eCommerce/authentication/user.dart';
import 'package:ekray/models/eCommerce/common/common_response.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/services/eCommerce/auth_service/auth_service.dart';
import 'package:ekray/services/eCommerce/firebase_auth_service/firebase_auth_service.dart';
import 'package:ekray/controllers/eCommerce/address/address_controller.dart';
import 'package:ekray/utils/api_client.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) => AuthController(ref));

class AuthController extends StateNotifier<bool> {
  final Ref ref;
  AuthController(this.ref) : super(false);

  Future<CommonResponse> singUp({required SingUp singUpInfo}) async {
    state = true;
    final response =
        await ref.read(authServiceProvider).signUp(singUpInfo: singUpInfo);
    final String message = response.data['message'];
    if (response.statusCode == 200) {
      final userInfo = User.fromMap(response.data['data']['user']);
      final accessToken = response.data['data']['access']['token'];
      ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
      ref.read(hiveServiceProvider).saveUserAuthToken(authToken: accessToken);
      ref.read(apiClientProvider).updateToken(token: accessToken);
      state = false;
      return CommonResponse(isSuccess: true, message: message);
    }
    state = false;
    return CommonResponse(isSuccess: false, message: message);
  }

  Future<CommonResponse> sendOTP(
      {required String phone, required bool isForgot}) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .sendOTP(phone: phone, isForgot: isForgot);
      final String message = response.data['message'];
      final String otp = response.data['data']['otp'].toString();
      state = false;
      return CommonResponse(isSuccess: true, message: message, data: otp);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> verifyOTP(
      {required String phone, required String otp}) async {
    try {
      state = true;
      final response =
          await ref.read(authServiceProvider).verifyOTP(phone: phone, otp: otp);
      final String message = response.data['message'];
      final String token = response.data['data']['token'];
      state = false;
      return CommonResponse(isSuccess: true, message: message, data: token);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> resetPassword({
    required String password,
    required String confrimPassword,
    required String forgotPasswordToken,
  }) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).resetPassword(
            password: password,
            confirmPassword: confrimPassword,
            forgotPasswordToken: forgotPasswordToken,
          );
      final String message = response.data['message'];

      if (response.statusCode == 200) {
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }
      state = false;
      return CommonResponse(
        isSuccess: false,
        message: message,
      );
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> login(
      {required String phone, required String password}) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .login(phone: phone, password: password);
      final String message = response.data['message'];
      final userInfo = User.fromMap(response.data['data']['user']);
      final accessToken = response.data['data']['access']['token'];
      ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
      ref.read(hiveServiceProvider).saveUserAuthToken(authToken: accessToken);
      ref.read(apiClientProvider).updateToken(token: accessToken);
      state = false;
      return CommonResponse(isSuccess: true, message: message);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmNewPassword: confirmNewPassword,
          );
      final String message = response.data['message'];
      if (response.statusCode == 200) {
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      } else {
        state = false;
        return CommonResponse(isSuccess: false, message: message);
      }
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> updateProfile(
      {required User userInfo, required File? file}) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).updateProfile(
            userInfo: userInfo,
            file: file,
          );
      final String message = response.data['message'];
      final User userData = User.fromMap(response.data['data']['user']);
      ref.read(hiveServiceProvider).saveUserInfo(userInfo: userData);
      state = false;
      return CommonResponse(isSuccess: true, message: message);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  Future<CommonResponse> logout() async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).logout();
      final String message = response.data['message'];

      // Also sign out from Firebase
      await ref.read(firebaseAuthServiceProvider).signOut();

      state = false;
      return CommonResponse(isSuccess: true, message: message);
    } catch (error) {
      state = false;
      debugPrint(error.toString());
      return CommonResponse(isSuccess: false, message: error.toString());
    }
  }

  /// Sign up with email and password using Firebase Auth
  Future<CommonResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      state = true;

      // Sign up with Firebase Auth
      final userCredential = await ref.read(firebaseAuthServiceProvider)
          .signUpWithEmailPassword(email: email, password: password);

      // Get Firebase ID token
      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        state = false;
        return CommonResponse(
          isSuccess: false,
          message: 'Failed to get Firebase authentication token',
        );
      }

      // Get FCM token for device registration
      String? fcmToken;
      String? deviceType;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        deviceType = Platform.isIOS ? 'ios' : 'android';
        debugPrint('FCM Token for Firebase sign up: $fcmToken');
      } catch (e) {
        debugPrint('Failed to get FCM token: $e');
      }

      // Link with Laravel backend (include device key)
      final response = await ref.read(firebaseAuthServiceProvider)
          .linkWithLaravelBackend(
        firebaseIdToken: firebaseIdToken,
        name: name,
        email: email,
        phone: phone,
        deviceKey: fcmToken,
        deviceType: deviceType,
      );

      final String message = response.data['message'] ?? 'Registration successful';

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userInfo = User.fromMap(response.data['data']['user']);
        final accessToken = response.data['data']['access']['token'];
        ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
        ref.read(hiveServiceProvider).saveUserAuthToken(authToken: accessToken);
        ref.read(apiClientProvider).updateToken(token: accessToken);
        ref.read(addressControllerProvider.notifier).getAddress();
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }

      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (error) {
      state = false;
      debugPrint('Firebase sign up error: $error');
      return CommonResponse(
        isSuccess: false,
        message: error.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Sign in with email and password using Firebase Auth
  Future<CommonResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = true;

      // Sign in with Firebase Auth
      final userCredential = await ref.read(firebaseAuthServiceProvider)
          .signInWithEmailPassword(email: email, password: password);

      // Get Firebase ID token
      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        state = false;
        return CommonResponse(
          isSuccess: false,
          message: 'Failed to get Firebase authentication token',
        );
      }

      // Get FCM token for device registration
      String? fcmToken;
      String? deviceType;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        deviceType = Platform.isIOS ? 'ios' : 'android';
        debugPrint('FCM Token for Firebase sign in: $fcmToken');
      } catch (e) {
        debugPrint('Failed to get FCM token: $e');
      }

      // Link with Laravel backend (include device key)
      final response = await ref.read(firebaseAuthServiceProvider)
          .linkWithLaravelBackend(
        firebaseIdToken: firebaseIdToken,
        email: email,
        deviceKey: fcmToken,
        deviceType: deviceType,
      );

      final String message = response.data['message'] ?? 'Login successful';

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userInfo = User.fromMap(response.data['data']['user']);
        final accessToken = response.data['data']['access']['token'];
        ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
        ref.read(hiveServiceProvider).saveUserAuthToken(authToken: accessToken);
        ref.read(apiClientProvider).updateToken(token: accessToken);
        ref.read(addressControllerProvider.notifier).getAddress();
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }

      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (error) {
      state = false;
      debugPrint('Firebase sign in error: $error');
      return CommonResponse(
        isSuccess: false,
        message: error.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Sign in with Google
  Future<CommonResponse> signInWithGoogle() async {
    try {
      state = true;

      // Get FCM token for device registration
      String? fcmToken;
      String? deviceType;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        deviceType = Platform.isIOS ? 'ios' : 'android';
        debugPrint('FCM Token for Google login: $fcmToken');
      } catch (e) {
        debugPrint('Failed to get FCM token: $e');
        // Continue without device key if FCM token fails
      }

      // Sign in with Google
      final userCredential = await ref.read(firebaseAuthServiceProvider)
          .signInWithGoogle();

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        state = false;
        return CommonResponse(
          isSuccess: false,
          message: 'Google sign in failed',
        );
      }

      // Get Firebase ID token
      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) {
        state = false;
        return CommonResponse(
          isSuccess: false,
          message: 'Failed to get Firebase authentication token',
        );
      }

      // Link with Laravel backend (include device key)
      final response = await ref.read(firebaseAuthServiceProvider)
          .linkWithLaravelBackend(
        firebaseIdToken: firebaseIdToken,
        name: firebaseUser.displayName,
        email: firebaseUser.email,
        phone: firebaseUser.phoneNumber,
        deviceKey: fcmToken,
        deviceType: deviceType,
      );

      // Check for 403 or other error status codes
      if (response.statusCode == 403) {
        state = false;
        final errorMessage = response.data is Map 
            ? (response.data['message'] ?? 'Access forbidden. Please check backend configuration.')
            : 'Access forbidden (403). Firebase token verification failed on backend.';
        return CommonResponse(isSuccess: false, message: errorMessage);
      }

      final String message = response.data['message'] ?? 'Google sign in successful';

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userInfo = User.fromMap(response.data['data']['user']);
        final accessToken = response.data['data']['access']['token'];
        ref.read(hiveServiceProvider).saveUserInfo(userInfo: userInfo);
        ref.read(hiveServiceProvider).saveUserAuthToken(authToken: accessToken);
        ref.read(apiClientProvider).updateToken(token: accessToken);
        ref.read(addressControllerProvider.notifier).getAddress();
        state = false;
        return CommonResponse(isSuccess: true, message: message);
      }

      state = false;
      return CommonResponse(isSuccess: false, message: message);
    } catch (error) {
      state = false;
      debugPrint('Google sign in error: $error');
      String errorMessage = error.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('cancelled')) {
        errorMessage = 'Sign in was cancelled';
      }
      return CommonResponse(isSuccess: false, message: errorMessage);
    }
  }
}
