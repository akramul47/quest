import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/timer_state.dart';
import '../providers/focus_provider.dart';

class FocusSettingsDialog extends StatefulWidget {
  final FocusProvider provider;

  const FocusSettingsDialog({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<FocusSettingsDialog> createState() => _FocusSettingsDialogState();
}

class _FocusSettingsDialogState extends State<FocusSettingsDialog> {
  late TimerSettings _tempSettings;

  @override
  void initState() {
    super.initState();
    _tempSettings = widget.provider.settings;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Focus Settings',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            Divider(
              height: 1,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Timer Durations', isDark),
                    const SizedBox(height: 16),
                    _buildDurationSetting(
                      'Focus Duration',
                      _tempSettings.focusDuration,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(focusDuration: value);
                      }),
                      isDark,
                      Icons.psychology_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDurationSetting(
                      'Short Break',
                      _tempSettings.shortBreakDuration,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(shortBreakDuration: value);
                      }),
                      isDark,
                      Icons.coffee_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDurationSetting(
                      'Long Break',
                      _tempSettings.longBreakDuration,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(longBreakDuration: value);
                      }),
                      isDark,
                      Icons.free_breakfast_outlined,
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Automation', isDark),
                    const SizedBox(height: 16),
                    
                    _buildSwitchSetting(
                      'Auto-start Breaks',
                      'Automatically start break timer after focus session',
                      _tempSettings.autoStartBreaks,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(autoStartBreaks: value);
                      }),
                      isDark,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSwitchSetting(
                      'Auto-start Focus',
                      'Automatically start next focus session after break',
                      _tempSettings.autoStartFocus,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(autoStartFocus: value);
                      }),
                      isDark,
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Session Tracking', isDark),
                    const SizedBox(height: 16),
                    
                    _buildSwitchSetting(
                      'Count Skipped Sessions',
                      'Count focus sessions as completed when skipped',
                      _tempSettings.countSkippedSessions,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(countSkippedSessions: value);
                      }),
                      isDark,
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Notifications', isDark),
                    const SizedBox(height: 16),
                    
                    _buildSwitchSetting(
                      'Enable Notifications',
                      'Get notified when timer completes',
                      _tempSettings.enableNotifications,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(enableNotifications: value);
                      }),
                      isDark,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSwitchSetting(
                      'Enable Sound',
                      'Play sound when timer completes',
                      _tempSettings.enableSound,
                      (value) => setState(() {
                        _tempSettings = _tempSettings.copyWith(enableSound: value);
                      }),
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
            
            Divider(
              height: 1,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
            
            // Footer with action buttons
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.provider.updateSettings(_tempSettings);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 32,
                        vertical: isMobile ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDurationSetting(
    String label,
    int value,
    Function(int) onChanged,
    bool isDark,
    IconData icon,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: isMobile ? 18 : 20,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 2 : 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > 5 ? () => onChanged(value - 5) : null,
                color: Theme.of(context).colorScheme.primary,
                iconSize: isMobile ? 18 : 22,
                padding: EdgeInsets.all(isMobile ? 0 : 4),
                constraints: const BoxConstraints(),
              ),
              Container(
                constraints: BoxConstraints(minWidth: isMobile ? 40 : 50),
                alignment: Alignment.center,
                child: Text(
                  '$value min',
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: value < 120 ? () => onChanged(value + 5) : null,
                color: Theme.of(context).colorScheme.primary,
                iconSize: isMobile ? 18 : 22,
                padding: EdgeInsets.all(isMobile ? 0 : 4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
