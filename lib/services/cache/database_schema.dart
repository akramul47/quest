/// Database schema definitions and SQL table creation scripts.
///
/// This file contains all table schemas with sync-ready metadata fields
/// for future server synchronization support.
library;

/// Current database version - increment when schema changes
const int kDatabaseVersion = 2;

/// Database name
const String kDatabaseName = 'quest_cache.db';

/// Sync status enum values stored as integers
class SyncStatus {
  static const int pending = 0;
  static const int synced = 1;
  static const int conflict = 2;
}

/// SQL to create all tables
const String createTodosTable = '''
  CREATE TABLE IF NOT EXISTS todos (
    id TEXT PRIMARY KEY,
    task TEXT NOT NULL,
    description TEXT,
    is_completed INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    completed_at TEXT,
    is_archived INTEGER NOT NULL DEFAULT 0,
    priority INTEGER NOT NULL DEFAULT 1,
    date_time TEXT,
    deadline TEXT,
    server_id TEXT,
    last_modified TEXT NOT NULL,
    sync_status INTEGER NOT NULL DEFAULT 0
  )
''';

const String createSubtasksTable = '''
  CREATE TABLE IF NOT EXISTS subtasks (
    id TEXT PRIMARY KEY,
    todo_id TEXT NOT NULL,
    title TEXT NOT NULL,
    is_completed INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (todo_id) REFERENCES todos (id) ON DELETE CASCADE
  )
''';

const String createHabitsTable = '''
  CREATE TABLE IF NOT EXISTS habits (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    color INTEGER NOT NULL,
    icon_code_point INTEGER NOT NULL,
    icon_font_family TEXT,
    icon_font_package TEXT,
    type INTEGER NOT NULL DEFAULT 0,
    unit TEXT,
    created_at TEXT NOT NULL,
    is_archived INTEGER NOT NULL DEFAULT 0,
    question TEXT,
    reminder_hour INTEGER,
    reminder_minute INTEGER,
    server_id TEXT,
    last_modified TEXT NOT NULL,
    sync_status INTEGER NOT NULL DEFAULT 0
  )
''';

const String createHabitEntriesTable = '''
  CREATE TABLE IF NOT EXISTS habit_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id TEXT NOT NULL,
    date TEXT NOT NULL,
    value TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
    UNIQUE (habit_id, date)
  )
''';

const String createFocusSessionsTable = '''
  CREATE TABLE IF NOT EXISTS focus_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    start_time TEXT NOT NULL,
    end_time TEXT,
    duration_minutes INTEGER NOT NULL,
    session_type TEXT NOT NULL,
    completed INTEGER NOT NULL DEFAULT 0,
    server_id TEXT,
    last_modified TEXT NOT NULL,
    sync_status INTEGER NOT NULL DEFAULT 0
  )
''';

const String createSettingsTable = '''
  CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
''';

const String createSyncMetadataTable = '''
  CREATE TABLE IF NOT EXISTS sync_metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
''';

/// Streak system tables
const String createStreakTable = '''
  CREATE TABLE IF NOT EXISTS streak (
    id INTEGER PRIMARY KEY DEFAULT 1,
    current_streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    last_active_date TEXT,
    streak_start_date TEXT,
    freeze_days_used INTEGER NOT NULL DEFAULT 0,
    freeze_days_available INTEGER NOT NULL DEFAULT 2,
    restore_tokens INTEGER NOT NULL DEFAULT 0,
    is_frozen_today INTEGER NOT NULL DEFAULT 0,
    server_id TEXT,
    last_modified TEXT NOT NULL,
    sync_status INTEGER NOT NULL DEFAULT 0
  )
''';

const String createDailyActivityTable = '''
  CREATE TABLE IF NOT EXISTS daily_activity (
    date TEXT PRIMARY KEY,
    completed_todo INTEGER NOT NULL DEFAULT 0,
    logged_habit INTEGER NOT NULL DEFAULT 0,
    tracked_focus INTEGER NOT NULL DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 0,
    is_freeze_day INTEGER NOT NULL DEFAULT 0,
    last_modified TEXT NOT NULL,
    sync_status INTEGER NOT NULL DEFAULT 0
  )
''';

const String createRestoreTokensTable = '''
  CREATE TABLE IF NOT EXISTS restore_tokens (
    id TEXT PRIMARY KEY,
    generated_at TEXT NOT NULL,
    expires_at TEXT,
    is_used INTEGER NOT NULL DEFAULT 0,
    used_at TEXT,
    server_id TEXT,
    last_modified TEXT NOT NULL,
    sync_status INTEGER NOT NULL DEFAULT 0
  )
''';

/// Create indexes for better query performance
const List<String> createIndexes = [
  'CREATE INDEX IF NOT EXISTS idx_todos_archived ON todos (is_archived)',
  'CREATE INDEX IF NOT EXISTS idx_todos_completed ON todos (is_completed)',
  'CREATE INDEX IF NOT EXISTS idx_todos_sync ON todos (sync_status)',
  'CREATE INDEX IF NOT EXISTS idx_subtasks_todo ON subtasks (todo_id)',
  'CREATE INDEX IF NOT EXISTS idx_habits_archived ON habits (is_archived)',
  'CREATE INDEX IF NOT EXISTS idx_habits_sync ON habits (sync_status)',
  'CREATE INDEX IF NOT EXISTS idx_habit_entries_habit ON habit_entries (habit_id)',
  'CREATE INDEX IF NOT EXISTS idx_habit_entries_date ON habit_entries (date)',
  'CREATE INDEX IF NOT EXISTS idx_focus_sessions_start ON focus_sessions (start_time)',
  'CREATE INDEX IF NOT EXISTS idx_focus_sessions_sync ON focus_sessions (sync_status)',
  // Streak indexes
  'CREATE INDEX IF NOT EXISTS idx_daily_activity_date ON daily_activity (date)',
  'CREATE INDEX IF NOT EXISTS idx_restore_tokens_used ON restore_tokens (is_used)',
];

/// All table creation statements in order
const List<String> allCreateTableStatements = [
  createTodosTable,
  createSubtasksTable,
  createHabitsTable,
  createHabitEntriesTable,
  createFocusSessionsTable,
  createSettingsTable,
  createSyncMetadataTable,
  // Streak tables
  createStreakTable,
  createDailyActivityTable,
  createRestoreTokensTable,
];

/// Migration statements for version upgrades
const Map<int, List<String>> migrationStatements = {
  // Version 1 -> 2: Add streak tables
  2: [
    createStreakTable,
    createDailyActivityTable,
    createRestoreTokensTable,
    'CREATE INDEX IF NOT EXISTS idx_daily_activity_date ON daily_activity (date)',
    'CREATE INDEX IF NOT EXISTS idx_restore_tokens_used ON restore_tokens (is_used)',
  ],
};
