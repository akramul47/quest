/// Quest Cache Module
///
/// SQLite-based caching system for persistent storage across all platforms.
///
/// Usage:
/// ```dart
/// // Initialize database on app start
/// await DatabaseHelper.instance.initDatabase();
///
/// // Run migration from SharedPreferences if needed
/// await MigrationService().migrateIfNeeded();
///
/// // Use DAOs for data operations
/// final todoDao = TodoDao();
/// final todos = await todoDao.getAll();
///
/// // Export/import data
/// final repo = CacheRepository();
/// final data = await repo.exportAllData();
/// await repo.importData(data);
/// ```
library;

export 'cache_repository.dart';
export 'daos/focus_session_dao.dart';
export 'daos/habit_dao.dart';
export 'daos/todo_dao.dart';
export 'database_helper.dart';
export 'database_schema.dart';
export 'migration_service.dart';
