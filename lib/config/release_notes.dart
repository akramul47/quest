class ReleaseNotes {
  // ==============================================================================
  // UPDATE CONFIGURATION
  // ==============================================================================

  /// Title shown when an update is downloaded and ready to install
  static const String updateReadyTitle = 'A new update is ready to install.';

  /// Title shown after the app has been updated
  static const String appUpdatedTitle = 'What\'s New';

  // ==============================================================================
  // WHATS NEW (Edit this section for each release)
  // ==============================================================================

  /// The detailed release notes shown to the user.
  /// Use \n\n for paragraph breaks and • for bullet points.
  static const String currentReleaseNotes = '''
• Web Update Notifications: You'll now be notified of new web versions automatically.

• Responsive Design: The update modal now adapts beautifully to mobile, tablet, and desktop screens.

• Performance Improvements: We've optimized the app loading and interaction speeds for a smoother experience.

• Bug Fixes: Resolved layout issues on tablet devices and improved navigation stability.

• UI Polish: Enhanced padding and margins for a cleaner look.

• Habit Detail Redesign: A cleaner look with simplified statistics, optimized layout for larger screens, and refined streak cards.

• Focus Timer Enhancements: Enjoy a more fluid experience with improved wave animations and better positioning of session details.

• Task Management Polish: Refined task detail interactions and fixed undo functionality for a smoother workflow.

• Optimized Overview: Adjusted the overview card design for better balance and visibility on tablet and desktop devices.

• Web Stability: Significant improvements to data handling and stability when running on the web platform.
''';

  /// Text shown when an update is pending (waiting for restart).
  /// This can be a shorter summary or the full notes.
  static const String pendingUpdateText = currentReleaseNotes;
}
