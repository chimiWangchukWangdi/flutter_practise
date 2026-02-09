import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// M-PIN and biometric preference stored in platform secure storage
/// (iOS Keychain, Android Keystore). Not in plain SQLite.
class SecureAuthStorage {
  SecureAuthStorage._();

  static const _keyPinHash = 'auth_pin_hash';
  static const _keyPinSalt = 'auth_pin_salt';
  static const _keyBiometricsEnabled = 'auth_biometrics_enabled';
  static const _keyCreatedAt = 'auth_created_at';

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  /// Read all auth fields. Returns null if no PIN is set.
  static Future<SecureAuthRecord?> read() async {
    final pinHash = await _storage.read(key: _keyPinHash);
    if (pinHash == null || pinHash.isEmpty) return null;
    final salt = await _storage.read(key: _keyPinSalt);
    final biometrics = await _storage.read(key: _keyBiometricsEnabled);
    final createdAt = await _storage.read(key: _keyCreatedAt);
    return SecureAuthRecord(
      pinHash: pinHash,
      salt: salt ?? '',
      biometricsEnabled: biometrics == '1',
      createdAt: createdAt != null ? int.tryParse(createdAt) ?? 0 : 0,
    );
  }

  /// Write PIN hash and salt (e.g. on set PIN). Sets biometrics to false.
  static Future<void> writePin(String pinHash, String salt) async {
    await _storage.write(key: _keyPinHash, value: pinHash);
    await _storage.write(key: _keyPinSalt, value: salt);
    await _storage.write(key: _keyBiometricsEnabled, value: '0');
    await _storage.write(
      key: _keyCreatedAt,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Update only PIN hash and salt (change-PIN flow).
  static Future<void> updatePin(String pinHash, String salt) async {
    await _storage.write(key: _keyPinHash, value: pinHash);
    await _storage.write(key: _keyPinSalt, value: salt);
    await _storage.write(
      key: _keyCreatedAt,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Set biometrics enabled flag.
  static Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(
      key: _keyBiometricsEnabled,
      value: enabled ? '1' : '0',
    );
  }

  /// Remove all auth data (forgot PIN / backend reset).
  static Future<void> clear() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinSalt);
    await _storage.delete(key: _keyBiometricsEnabled);
    await _storage.delete(key: _keyCreatedAt);
  }
}

/// In-memory representation of auth record from secure storage.
class SecureAuthRecord {
  const SecureAuthRecord({
    required this.pinHash,
    required this.salt,
    required this.biometricsEnabled,
    required this.createdAt,
  });

  final String pinHash;
  final String salt;
  final bool biometricsEnabled;
  final int createdAt;
}
