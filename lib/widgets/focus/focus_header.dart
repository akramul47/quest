import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/focus_provider.dart';
import '../focus_settings_dialog.dart';

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
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Focus',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              size: 24,
            ),
            onPressed: () {
              _showSettingsDialog(
                context,
                Provider.of<FocusProvider>(context, listen: false),
              );
            },
          ),
        ],
      ),
    );
  }
}
