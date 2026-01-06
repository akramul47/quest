import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/focus_provider.dart';
import '../focus_settings_dialog.dart';
import 'session_label.dart';

class FocusHeader extends StatelessWidget {
  final bool isDark;
  final bool isMobile;

  const FocusHeader({Key? key, required this.isDark, required this.isMobile})
    : super(key: key);

  void _showSettingsDialog(BuildContext context, FocusProvider provider) {
    showDialog(
      context: context,
      builder: (context) => FocusSettingsDialog(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = Provider.of<FocusProvider>(context);

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered session label - truly centered based on screen width
          Center(
            child: SessionLabel(
              provider: focusProvider,
              isDark: isDark,
              isMobile: isMobile,
              isSmall: false,
            ),
          ),

          // Settings button positioned absolutely on the right
          Positioned(
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: Icon(
                  Icons.settings_outlined,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                onPressed: () {
                  _showSettingsDialog(context, focusProvider);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
