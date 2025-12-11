import 'extensions/string_extensions.dart';

class Validators {
  /// Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.isValidEmail) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Password validator
  static String? validatePassword(
    String? value, {
    bool isConfirmPassword = false,
    String? password,
  }) {
    if (isConfirmPassword) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value.length < 6) {
        return 'Confirm password must be at least 6 characters long';
      }
      if (password != value) {
        return 'Confirm password do not match password';
      }
    } else {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    }
    return null;
  }

  /// Required field validator
  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Phone number validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!value.isValidPhone) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
