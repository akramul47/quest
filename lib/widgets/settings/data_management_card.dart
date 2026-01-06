import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_layout.dart';
import '../../services/cache/cache_repository.dart';
import '../../models/todo_list.dart';
import '../../providers/habit_provider.dart';

class DataManagementCard extends StatelessWidget {
  final bool isDark;

  const DataManagementCard({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cacheRepo = context.read<CacheRepository>();
    final todoList = context.read<TodoList>();
    final habitList = context.read<HabitList>();
    final isTabletOrDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup & Restore',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your data for backup or import from a previous backup',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              letterSpacing: 0.1,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          if (isTabletOrDesktop)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    title: 'Export Data',
                    subtitle: 'Create backup file',
                    icon: Icons.upload_file_rounded,
                    accentColor: isDark
                        ? AppTheme.primaryColorDark
                        : AppTheme.primaryColor,
                    onPressed: () => _handleExport(context, cacheRepo, isDark),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionButton(
                    title: 'Import Data',
                    subtitle: 'Restore from backup',
                    icon: Icons.download_rounded,
                    accentColor: Colors.blue,
                    onPressed: () => _handleImport(
                      context,
                      cacheRepo,
                      todoList,
                      habitList,
                      isDark,
                    ),
                    isDark: isDark,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _ActionButton(
                  title: 'Export Data',
                  subtitle: 'Create backup file',
                  icon: Icons.upload_file_rounded,
                  accentColor: isDark
                      ? AppTheme.primaryColorDark
                      : AppTheme.primaryColor,
                  onPressed: () => _handleExport(context, cacheRepo, isDark),
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _ActionButton(
                  title: 'Import Data',
                  subtitle: 'Restore from backup',
                  icon: Icons.download_rounded,
                  accentColor: Colors.blue,
                  onPressed: () => _handleImport(
                    context,
                    cacheRepo,
                    todoList,
                    habitList,
                    isDark,
                  ),
                  isDark: isDark,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    CacheRepository cacheRepo,
    bool isDark,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Exporting data...',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      final file = await cacheRepo.exportToFile(appVersion: appVersion);

      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        await _showExportSuccessDialog(context, file.path, isDark);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        await _showErrorDialog(
          context,
          'Export Failed',
          'Failed to export data: $e',
          isDark,
        );
      }
    }
  }

  Future<void> _handleImport(
    BuildContext context,
    CacheRepository cacheRepo,
    TodoList todoList,
    HabitList habitList,
    bool isDark,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Quest Backup File',
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) {
        if (context.mounted) {
          await _showErrorDialog(
            context,
            'Import Failed',
            'Could not access the selected file',
            isDark,
          );
        }
        return;
      }

      if (!context.mounted) return;
      final importMode = await _showImportModeDialog(context, isDark);
      if (importMode == null) return;

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Importing data...',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final result2 = await cacheRepo.importFromFile(
        filePath,
        replace: importMode == 'replace',
      );

      if (context.mounted) Navigator.pop(context);

      if (result2.success) {
        await todoList.refresh();
        await habitList.refresh();

        if (context.mounted) {
          await _showImportSuccessDialog(context, result2, isDark);
        }
      } else {
        if (context.mounted) {
          await _showErrorDialog(
            context,
            'Import Failed',
            result2.error ?? 'Unknown error',
            isDark,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        await _showErrorDialog(
          context,
          'Import Failed',
          'Failed to import data: $e',
          isDark,
        );
      }
    }
  }

  Future<void> _showExportSuccessDialog(
    BuildContext context,
    String filePath,
    bool isDark,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Export Successful',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Your data has been exported successfully to:\n\n$filePath',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showImportModeDialog(
    BuildContext context,
    bool isDark,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.merge_rounded,
                color: Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Import Mode',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how to import your data:',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            _ImportModeOption(
              title: 'Merge',
              description: 'Add imported data to existing data',
              icon: Icons.merge_type_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ImportModeOption(
              title: 'Replace All',
              description:
                  'Delete all existing data and replace with imported data',
              icon: Icons.warning_amber_rounded,
              isDark: isDark,
              isWarning: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            child: Text(
              'Merge',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
            ),
            child: Text(
              'Replace All',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportSuccessDialog(
    BuildContext context,
    ImportResult result,
    bool isDark,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Import Successful',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Successfully imported:\n\n'
          '• ${result.todosImported} todos\n'
          '• ${result.habitsImported} habits\n'
          '• ${result.sessionsImported} focus sessions',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(
    BuildContext context,
    String title,
    String message,
    bool isDark,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool isDark;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.03),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.02),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppTheme.textMediumDark
                            : AppTheme.textMedium,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportModeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isDark;
  final bool isWarning;

  const _ImportModeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.withValues(alpha: 0.1)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? Colors.red.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isWarning
                ? Colors.red
                : (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isWarning
                        ? Colors.red
                        : (isDark ? AppTheme.textDarkMode : AppTheme.textDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textMediumDark
                        : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
