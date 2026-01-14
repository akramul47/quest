import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../config/release_notes.dart';

/// Slide-up modal for update notification
/// Matches the habits add modal styling pattern
class UpdateModal extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback?
  onRestart; // Optional: if null, only show dismiss (Web mode)
  final String? patchVersion;
  final String? appVersion;

  const UpdateModal({
    Key? key,
    required this.onDismiss,
    this.onRestart,
    this.patchVersion,
    this.appVersion,
  }) : super(key: key);

  void _handleRestart() {
    if (onRestart != null) {
      onRestart!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme and device context
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive width calculation
    final modalWidth = isMobile
        ? screenWidth - 8
        : (screenWidth > 500 ? 500.0 : screenWidth - 48);

    // Dynamic colors based on theme
    final primaryColor = isDark
        ? AppTheme.primaryColorDark
        : AppTheme.primaryColor;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

    return Container(
      width: modalWidth,
      margin: EdgeInsets.fromLTRB(
        isMobile ? 4 : 24,
        0, // Top margin handled by parent positioning
        isMobile ? 4 : 24,
        12, // Bottom margin
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF000000) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          // Primary color glow
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, -4),
          ),
          // Bottom shadow
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisSize: MainAxisSize.max, // Fill height
          children: [
            // Header Row (Info Left, Close Right)
            Container(
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.fromLTRB(24, 24, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Left Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.system_update_rounded,
                              size: 28, // Slighly larger icon
                              color: primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'App updated!',
                              style: GoogleFonts.outfit(
                                fontSize: 22, // Larger title
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (appVersion != null) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  patchVersion != null
                                      ? '$appVersion (Patch $patchVersion)'
                                      : appVersion!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ), // Spacing from close button
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Close "X" Button
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Description Content (Expanded)
            Expanded(
              child: Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        onRestart == null
                            ? ReleaseNotes.appUpdatedTitle
                            : ReleaseNotes.updateReadyTitle,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        onRestart == null
                            ? ReleaseNotes.currentReleaseNotes
                            : ReleaseNotes.pendingUpdateText,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: isDark
                              ? AppTheme.textMediumDark
                              : AppTheme.textMedium,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider
            Container(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),

            // Buttons Row
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Row(
                children: [
                  if (onRestart != null) ...[
                    // "I understand" button (Left)
                    Expanded(
                      child: _buildButton(
                        context: context,
                        label: 'I understand',
                        isPrimary: false,
                        isDark: isDark,
                        isMobile: isMobile,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onDismiss();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // "Restart" button (Right)
                    Expanded(
                      child: _buildButton(
                        context: context,
                        label: 'Restart',
                        isPrimary: true,
                        isDark: isDark,
                        isMobile: isMobile,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _handleRestart();
                        },
                      ),
                    ),
                  ] else ...[
                    // Single Button (Center)
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: _buildButton(
                        context: context,
                        label: 'I understand',
                        isPrimary: true,
                        isDark: isDark,
                        isMobile: isMobile,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onDismiss();
                        },
                      ),
                    ),
                    const Spacer(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required bool isPrimary,
    required bool isDark,
    required bool isMobile,
    required VoidCallback onPressed,
  }) {
    final primaryColor = isDark
        ? AppTheme.primaryColorDark
        : AppTheme.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 16,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.85)],
                  )
                : null,
            color: isPrimary
                ? null
                : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08),
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: isPrimary
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppTheme.textDarkMode : AppTheme.textDark),
            ),
          ),
        ),
      ),
    );
  }
}
