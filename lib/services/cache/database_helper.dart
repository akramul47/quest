import 'dart:io' show Directory, Platform, File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_schema.dart';

/// Singleton database helper for managing SQLite database connections.
///
/// Handles platform-specific initialization:
/// - Mobile (iOS/Android): Uses native sqflite
/// - Desktop (Windows/macOS/Linux): Uses sqflite_common_ffi
///
/// Usage:
/// ```dart
/// await DatabaseHelper.instance.initDatabase();
/// final db = DatabaseHelper.instance.database;
/// ```
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;
  bool _isInitialized = false;

  /// Returns true if database is initialized
  bool get isInitialized => _isInitialized;

  /// Get the database instance. Throws if not initialized.
  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized. Call initDatabase() first.');
    }
    return _database!;
  }

  /// Initialize the database with platform-specific setup.
  ///
  /// This should be called early in app startup, before any database operations.
  Future<void> initDatabase() async {
    if (_isInitialized) return;

    // Web platform doesn't support sqflite - skip initialization
    if (kIsWeb) {
      print(
        'Database initialization skipped on web platform. Use SharedPreferences or IndexedDB instead.',
      );
      _isInitialized = true;
      return;
    }

    // Platform-specific initialization
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platforms use FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await _getDatabasePath();

    _database = await openDatabase(
      dbPath,
      version: kDatabaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );

    _isInitialized = true;
  }

  /// Get the database file path
  Future<String> _getDatabasePath() async {
    if (kIsWeb) {
      // Web uses in-memory or IndexedDB path
      return kDatabaseName;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbFolder = join(documentsDirectory.path, 'quest_data');

    // Ensure directory exists
    final dir = Directory(dbFolder);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return join(dbFolder, kDatabaseName);
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create all tables on first database creation
  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    for (final sql in allCreateTableStatements) {
      await db.execute(sql);
    }

    // Create indexes
    for (final sql in createIndexes) {
      await db.execute(sql);
    }
  }

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic for future schema changes
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE todos ADD COLUMN new_field TEXT');
    // }
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }

  /// Delete the database file (for testing or reset)
  Future<void> deleteDatabase() async {
    await close();
    final dbPath = await _getDatabasePath();
    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Execute a transaction with automatic rollback on error
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return database.transaction(action);
  }

  /// Execute a batch operation
  Future<List<Object?>> batch(void Function(Batch batch) operations) async {
    final batch = database.batch();
    operations(batch);
    return batch.commit();
  }
}
