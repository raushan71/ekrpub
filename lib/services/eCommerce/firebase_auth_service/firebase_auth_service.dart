import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/utils/api_client.dart';

final firebaseAuthServiceProvider = Provider((ref) => FirebaseAuthService(ref));

class FirebaseAuthService {
  final Ref ref;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuthService(this.ref);

  // Email/Password Sign Up
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('An unknown error occurred during sign up: $e');
    }
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('An unknown error occurred during sign in: $e');
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } on PlatformException catch (e) {
      // Handle Google Sign-In platform-specific errors
      String errorMessage = 'Google sign in failed';
      if (e.code == 'sign_in_failed') {
        errorMessage = 'Google Sign-In configuration error. Please ensure SHA-1 fingerprint is added to Firebase Console.';
      } else if (e.code == 'sign_in_canceled') {
        errorMessage = 'Google sign in was cancelled';
      } else {
        errorMessage = 'Google sign in error: ${e.message ?? e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unknown error occurred during Google sign in: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  // Link Firebase user with Laravel backend
  Future<Response> linkWithLaravelBackend({
    required String firebaseIdToken,
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        AppConstants.firebaseAuthUrl,
        data: {
          'firebase_id_token': firebaseIdToken,
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      return response;
    } on DioException catch (e) {
      debugPrint('Dio error linking with backend: ${e.response?.data}');
      
      // Handle specific HTTP method errors
      if (e.response?.statusCode == 405) {
        throw Exception('Backend endpoint not configured. Please ensure POST route exists for /api/firebase-auth');
      }
      
      // Handle error messages from backend
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          final message = errorData['message'] ?? errorData['error'] ?? 'Failed to link with backend';
          throw Exception(message);
        }
        if (errorData is String) {
          throw Exception(errorData);
        }
      }
      
      throw Exception('Failed to connect to backend. Please check your internet connection.');
    } catch (e) {
      if (e.toString().contains('POST method is not supported')) {
        throw Exception('Backend endpoint not configured. Please ensure POST route exists for /api/firebase-auth');
      }
      throw Exception('An unknown error occurred linking with backend: $e');
    }
  }

  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'invalid-credential':
        return 'The credential is not valid.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}

