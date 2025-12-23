import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create user with email & password
  /// Throws FirebaseAuthException on failure.
  Future<String?> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user!=null) {
      return credential.user!.uid;
    }
    return null;
  }

  /// Sign in with email & password
  /// Throws FirebaseAuthException on failure.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  }


  /// Send OTP to phone number and return the verificationId.
  /// The phone number should include the country code, e.g. +91xxxxxxxxxx
  /// This function wraps [verifyPhoneNumber] and completes when the code is sent.
  /// Note: On web you must use a RecaptchaVerifier and a different flow.
  Future<String> sendOtp({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final Completer<String> completer = Completer();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification on Android
        // You can choose to sign in automatically here, or let the caller handle it.
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            // If auto-signed-in, return a special value: the uid as verificationId
            completer.complete(userCredential.user?.uid ?? '');
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto retrieval timed out — still return the verificationId so caller can show OTP input.
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );

    return completer.future;
  }

  /// Verify SMS code (OTP) using [verificationId] returned from [sendOtp]
  /// and [smsCode] provided by the user. Returns the signed-in UserCredential.
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Optional helper: get current user
  User? get currentUser => _auth.currentUser;
}

class AuthErrorMessages {
  static String getMessage(String code) {
    switch (code) {
    // Common email/password
      case 'invalid-credential':
        return 'The provided credentials are incorrect.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Your password is too weak. Please choose a stronger one.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';

    // Phone (OTP) specific
      case 'invalid-phone-number':
        return 'The phone number is not valid.';
      case 'missing-phone-number':
        return 'Phone number is missing.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      case 'invalid-verification-code':
        return 'Invalid verification code (OTP). Please check and try again.';
      case 'invalid-verification-id':
        return 'Verification failed. Please restart verification.';
      case 'session-expired':
      case 'code-expired': // some platforms/libraries use this term
        return 'The verification code has expired. Request a new one.';

    // Google / federated
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'credential-already-in-use':
        return 'This credential is already linked to another user.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      case 'user-cancelled':
        return 'Sign-in was cancelled by user.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

