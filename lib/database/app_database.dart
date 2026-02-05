import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite: **local storage for M-PIN only** (one record per app).
///
/// Stores: pin_hash (Argon2 hash of the 6-digit PIN) + salt.
/// Only one M-PIN is kept; each new setup overwrites the previous.
class AppDatabase {
  AppDatabase._();

  static const String _dbName = 'test_bank.db';
  static const int _dbVersion = 2;

  static const String tableAuth = 'auth';
  static const String columnId = 'id';
  static const String columnPinHash = 'pin_hash';
  static const String columnSalt = 'salt';
  static const String columnCreatedAt = 'created_at';
  static const String columnBiometricsEnabled = 'biometrics_enabled';

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAuth (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPinHash TEXT NOT NULL,
        $columnSalt TEXT NOT NULL,
        $columnCreatedAt INTEGER NOT NULL,
        $columnBiometricsEnabled INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableAuth ADD COLUMN $columnBiometricsEnabled INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  /// Single row: id=1 for the one M-PIN record.
  static Future<void> insertPinHash(String pinHash, String salt) async {
    final db = await database;
    await db.insert(tableAuth, {
      columnId: 1,
      columnPinHash: pinHash,
      columnSalt: salt,
      columnCreatedAt: DateTime.now().millisecondsSinceEpoch,
      columnBiometricsEnabled: 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
    final db = await database;
    await db.update(
      tableAuth,
      {columnBiometricsEnabled: enabled ? 1 : 0},
      where: '$columnId = ?',
      whereArgs: [1],
    );
  }

  /// Get the stored pin_hash and salt, or null if not set.
  static Future<Map<String, dynamic>?> getPinRecord() async {
    final db = await database;
    final rows = await db.query(tableAuth, limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Update existing PIN (for change-PIN flow later).
  static Future<int> updatePinHash(String pinHash, String salt) async {
    final db = await database;
    return db.update(
      tableAuth,
      {
        columnPinHash: pinHash,
        columnSalt: salt,
        columnCreatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '$columnId = ?',
      whereArgs: [1],
    );
  }

  /// Clear M-PIN and biometric preference (e.g. forgot PIN or backend reset).
  /// After this, [getPinRecord] returns null and user must go through Setup M-PIN.
  static Future<void> clearAuth() async {
    final db = await database;
    await db.delete(tableAuth, where: '$columnId = ?', whereArgs: [1]);
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
