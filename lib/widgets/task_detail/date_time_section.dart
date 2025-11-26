import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'custom_date_picker.dart';

class DateTimeSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? selectedDate;
  final Function(DateTime?) onChanged;
  final bool isDark;

  const DateTimeSection({
    Key? key,
    required this.label,
    required this.icon,
    required this.selectedDate,
    required this.onChanged,
    required this.isDark,
  }) : super(key: key);

  String _formatDateTime(DateTime dateTime) {
    final hasTime = dateTime.hour != 0 || dateTime.minute != 0;
    if (hasTime) {
      return DateFormat('EEE, MMM d, h a').format(dateTime);
    } else {
      return DateFormat('EEE, MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDate != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: (isDark ? Colors.white : Colors.black87).withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.05,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.1,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _formatDateTime(selectedDate!),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => onChanged(null),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: (isDark ? Colors.white : Colors.black87)
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () async {
        final date = await showCustomDatePicker(
          context,
          initialDate: selectedDate,
          isDark: isDark,
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: (isDark ? Colors.white : Colors.black87).withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: (isDark ? Colors.white : Colors.black87).withOpacity(
                  0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
