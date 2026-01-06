/// Represents the synchronization state of a local entity with the server.
///
/// Used by all syncable models (Todo, Habit, FocusSession) to track
/// whether local changes need to be pushed to the backend.
enum SyncStatus {
  /// Local changes exist that haven't been synced to server
  pending,

  /// Entity is in sync with server
  synced,

  /// Local and server versions conflict (requires resolution)
  conflict,
}

extension SyncStatusExtension on SyncStatus {
  /// Convert to integer for database storage
  int toInt() {
    switch (this) {
      case SyncStatus.pending:
        return 0;
      case SyncStatus.synced:
        return 1;
      case SyncStatus.conflict:
        return 2;
    }
  }

  /// Create from database integer value
  static SyncStatus fromInt(int value) {
    switch (value) {
      case 1:
        return SyncStatus.synced;
      case 2:
        return SyncStatus.conflict;
      default:
        return SyncStatus.pending;
    }
  }
}
