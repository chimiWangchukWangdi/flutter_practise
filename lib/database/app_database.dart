import 'package:flutter_practise/storage/secure_auth_storage.dart';

/// Auth data (M-PIN hash, salt, biometrics preference) is stored in **secure
/// storage** (iOS Keychain / Android Keystore) via [SecureAuthStorage].
class AppDatabase {
  AppDatabase._();

  static const String tableAuth = 'auth';
  static const String columnId = 'id';
  static const String columnPinHash = 'pin_hash';
  static const String columnSalt = 'salt';
  static const String columnCreatedAt = 'created_at';
  static const String columnBiometricsEnabled = 'biometrics_enabled';

  static Map<String, dynamic> _recordToMap(SecureAuthRecord r) => {
    columnId: 1,
    columnPinHash: r.pinHash,
    columnSalt: r.salt,
    columnCreatedAt: r.createdAt,
    columnBiometricsEnabled: r.biometricsEnabled ? 1 : 0,
  };

  /// Single row: id=1 for the one M-PIN record (stored in secure storage).
  static Future<void> insertPinHash(String pinHash, String salt) async {
    await SecureAuthStorage.writePin(pinHash, salt);
  }

  /// Whether the user has enabled fingerprint/face unlock.
  static Future<bool> getBiometricsEnabled() async {
    final record = await getPinRecord();
    if (record == null) return false;
    final v = record[columnBiometricsEnabled];
    if (v == null) return false;
    return v == 1;
  }

  /// Set fingerprint/face unlock preference (call after PIN is set).
  static Future<void> setBiometricsEnabled(bool enabled) async {
    await SecureAuthStorage.setBiometricsEnabled(enabled);
  }

  /// Get the stored pin_hash and salt, or null if not set.
  static Future<Map<String, dynamic>?> getPinRecord() async {
    final record = await SecureAuthStorage.read();
    if (record == null) return null;
    return _recordToMap(record);
  }

  /// Update existing PIN (for change-PIN flow later).
  static Future<int> updatePinHash(String pinHash, String salt) async {
    await SecureAuthStorage.updatePin(pinHash, salt);
    return 1;
  }

  /// Clear M-PIN and biometric preference (e.g. forgot PIN or backend reset).
  /// After this, [getPinRecord] returns null and user must go through Setup M-PIN.
  static Future<void> clearAuth() async {
    await SecureAuthStorage.clear();
  }
}
