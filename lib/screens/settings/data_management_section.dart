import 'package:flutter/material.dart';
import '../../widgets/settings/data_management_card.dart';

class DataManagementSection extends StatelessWidget {
  final bool isDark;

  const DataManagementSection({Key? key, required this.isDark})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 20),
        DataManagementCard(isDark: isDark),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.08),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.06),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.storage_outlined,
            size: 22,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Data Management',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }
}
