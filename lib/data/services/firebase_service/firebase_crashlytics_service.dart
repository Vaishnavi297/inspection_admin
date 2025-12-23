import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseCrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize Crashlytics
  /// Call this in your main.dart after Firebase.initializeApp()
  /// Note: Crashlytics is not fully supported on web, so we skip initialization on web
  static Future<void> initialize() async {
    // Skip Crashlytics initialization on web platform
    if (kIsWeb) {
      return;
    }

    try {
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = (errorDetails) {
        _crashlytics.recordFlutterFatalError(errorDetails);
      };

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      // Silently fail if Crashlytics is not available (e.g., on web)
      debugPrint('Firebase Crashlytics initialization failed: $e');
    }
  }

  /// Record an error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) async {
    if (kIsWeb) return;
    try {
      await _crashlytics.recordError(exception, stackTrace, fatal: fatal);
    } catch (e) {
      debugPrint('Failed to record error in Crashlytics: $e');
    }
  }

  /// Record a Flutter error
  static Future<void> recordFlutterError(
    FlutterErrorDetails errorDetails,
  ) async {
    if (kIsWeb) return;
    try {
      await _crashlytics.recordFlutterFatalError(errorDetails);
    } catch (e) {
      debugPrint('Failed to record Flutter error in Crashlytics: $e');
    }
  }

  /// Trigger a test error for testing Crashlytics
  static Future<void> triggerTestError() async {
    if (kIsWeb) return;
    await recordError(
      Exception('Test error for Firebase Crashlytics'),
      StackTrace.current,
      fatal: false,
    );
  }
}
