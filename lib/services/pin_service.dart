import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:argon2/argon2.dart';
import 'package:flutter_practise/database/app_database.dart';

/// - **SQLite** stores only the **hash** of the PIN (and salt) on the device.
class PinService {
  PinService._();

  static const int _saltLength = 16;
  static const int _hashLength = 32;
  static const int _iterations = 3;
  static const int _memoryPowerOf2 = 16;

  /// Returns true if user has already set an M-PIN.
  static Future<bool> hasPin() async {
    final record = await AppDatabase.getPinRecord();
    return record != null &&
        record[AppDatabase.columnPinHash] != null &&
        record[AppDatabase.columnSalt] != null;
  }

  /// Hash [pin] (6 digits) with a new salt and store in SQLite.
  /// [pin] must be exactly 6 digits.
  static Future<void> setPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw ArgumentError('PIN must be exactly 6 digits');
    }
    final salt = _randomBytes(_saltLength);
    final hash = _hashPin(pin, salt);
    final saltB64 = base64Encode(salt);
    final hashB64 = base64Encode(hash);
    await AppDatabase.insertPinHash(hashB64, saltB64);
  }

  /// Clear stored M-PIN (and thus biometric preference). Use for forgot-PIN or backend reset.
  static Future<void> clearPin() async {
    await AppDatabase.clearAuth();
  }

  /// Verify [pin] against stored hash. Returns true if correct.
  static Future<bool> verifyPin(String pin) async {
    if (!_isValidPin(pin)) return false;
    final record = await AppDatabase.getPinRecord();
    if (record == null) return false;
    final storedHashB64 = record[AppDatabase.columnPinHash] as String?;
    final storedSaltB64 = record[AppDatabase.columnSalt] as String?;
    if (storedHashB64 == null || storedSaltB64 == null) return false;
    final salt = base64Decode(storedSaltB64);
    final computedHash = _hashPin(pin, Uint8List.fromList(salt));
    final storedHash = base64Decode(storedHashB64);
    return _constantTimeEquals(computedHash, storedHash);
  }

  static bool _isValidPin(String pin) {
    if (pin.length != 6) return false;
    return pin.runes.every((r) => r >= 0x30 && r <= 0x39);
  }

  static Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
  }

  static Uint8List _hashPin(String pin, Uint8List salt) {
    final parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_i,
      salt,
      version: Argon2Parameters.ARGON2_VERSION_10,
      iterations: _iterations,
      memoryPowerOf2: _memoryPowerOf2,
    );
    final argon2 = Argon2BytesGenerator();
    argon2.init(parameters);
    final passwordBytes = parameters.converter.convert(pin);
    final result = Uint8List(_hashLength);
    argon2.generateBytes(passwordBytes, result, 0, result.length);
    return result;
  }

  static bool _constantTimeEquals(Uint8List a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
