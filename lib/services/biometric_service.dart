import 'package:flutter/foundation.dart';
import 'package:flutter_practise/database/app_database.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

/// Biometric (fingerprint / face) unlock: **local only**, no server.
///
/// - We only store a **preference** "use biometrics" in SQLite.
/// - The actual auth is done by the **device** (local_auth); we never see
///   fingerprint/face data. On success we treat it as "user verified" and unlock.
/// - Same pattern as real banking apps: biometrics = alternative to entering PIN.
class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the user has turned on "use fingerprint/face" in our app.
  static Future<bool> isBiometricsEnabled() async {
    return AppDatabase.getBiometricsEnabled();
  }

  /// Turn on/off "use fingerprint/face" (only call when PIN is already set).
  static Future<void> setBiometricsEnabled(bool enabled) async {
    await AppDatabase.setBiometricsEnabled(enabled);
  }

  /// True if device has biometric hardware and at least one biometric enrolled (no app preference).
  static Future<bool> get deviceHasBiometrics async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// True if device has biometrics enrolled and user has enabled them in our app.
  static Future<bool> canUseBiometrics() async {
    final enabled = await isBiometricsEnabled();
    if (!enabled) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Human-readable label for "fingerprint" or "face" (for UI).
  static Future<String> getBiometricLabel() async {
    try {
      final list = await _auth.getAvailableBiometrics();
      if (list.contains(BiometricType.face)) return 'Face ID';
      if (list.contains(BiometricType.fingerprint)) return 'Fingerprint';
      return 'Biometrics';
    } catch (_) {
      return 'Biometrics';
    }
  }

  /// Show system biometric prompt.
  /// Returns (true, null) on success; (false, message) on failure (message for UI).
  static Future<(bool success, String? failureMessage)> authenticate({
    String reason = 'Unlock Test Bank',
  }) async {
    try {
      // biometricOnly: false — on some devices (e.g. Samsung) true can cause
      // immediate failure. useErrorDialogs: true lets the system show errors.
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
      return (ok, null);
    } on LocalAuthException catch (e) {
      debugPrint(
        'BiometricService.authenticate LocalAuthException: ${e.code} ${e.description}',
      );
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.userRequestedFallback:
          return (false, 'Cancelled');
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          return (false, 'Too many attempts. Use M-PIN for now.');
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noCredentialsSet:
          return (false, 'Add a fingerprint in device Settings first.');
        case LocalAuthExceptionCode.noBiometricHardware:
          return (false, 'This device doesn\'t support fingerprint.');
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          return (false, 'Fingerprint sensor busy. Try M-PIN.');
        case LocalAuthExceptionCode.uiUnavailable:
          return (false, 'Biometric screen unavailable. Try M-PIN or email.');
        case LocalAuthExceptionCode.authInProgress:
          return (false, 'Already checking. Wait a moment.');
        case LocalAuthExceptionCode.timeout:
          return (false, 'Timed out. Try again or use M-PIN.');
        case LocalAuthExceptionCode.deviceError:
        case LocalAuthExceptionCode.unknownError:
          final fallback = e.description?.isNotEmpty == true
              ? e.description!
              : 'Fingerprint didn\'t work. Try M-PIN or email.';
          return (false, fallback);
      }
    } catch (e) {
      debugPrint('BiometricService.authenticate error: $e');
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('user')) {
        return (false, 'Cancelled');
      }
      if (msg.contains('lock')) {
        return (false, 'Too many attempts. Use M-PIN for now.');
      }
      if (msg.contains('enrolled') || msg.contains('credential')) {
        return (false, 'Add a fingerprint in device Settings first.');
      }
      // Show actual error so we can fix device-specific issues (e.g. Samsung)
      final errStr = e.toString();
      if (errStr.length <= 120) {
        return (false, errStr);
      }
      return (false, 'Fingerprint didn\'t work. Try M-PIN or email.');
    }
  }
}
