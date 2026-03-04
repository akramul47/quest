class ChangelogEntry {
  final String title;
  final String description;

  const ChangelogEntry({required this.title, required this.description});
}

class ReleaseNotes {
  // ==============================================================================
  // UPDATE CONFIGURATION
  // ==============================================================================

  /// Title shown when an update is downloaded and ready to install
  static const String updateReadyTitle = 'A new update is ready to install.';

  /// Title shown after the app has been updated
  static const String appUpdatedTitle = 'What\'s New';

  // ==============================================================================
  // WHATS NEW — v1.2.0 (Edit this section for each release)
  // ==============================================================================

  static const List<ChangelogEntry> changelog = [
    ChangelogEntry(
      title: 'App Branding',
      description:
          'Introduced the new Quest glass logo across the app, sidebar, and about card for a unified, premium look.',
    ),
    ChangelogEntry(
      title: 'Serene Theme',
      description:
          'Added the brand-new Serene theme with a soft, calming color palette. Switch between Classic and Serene in Settings.',
    ),
    ChangelogEntry(
      title: 'UI Refinements',
      description:
          'Polished the task page empty states with custom illustrations, refined the sidebar and bottom nav dark mode backgrounds, and improved habit detail layout across all screen sizes.',
    ),
    ChangelogEntry(
      title: 'Bug Fixes',
      description:
          'Fixed layout issues on Android tablets, resolved streak overflow on habit detail, corrected status bar styling in edge-to-edge mode, and addressed misc navigation stability issues.',
    ),
  ];

  /// Flattened plain text for backward compatibility
  static String get currentReleaseNotes =>
      changelog.map((e) => '${e.title}\n${e.description}').join('\n\n');

  static const String pendingUpdateText =
      'A new version of Quest is ready. Restart to apply the update and enjoy the latest features.';
}
