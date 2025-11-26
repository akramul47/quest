import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

Future<DateTime?> showCustomDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  bool isDark = false,
}) async {
  DateTime selectedDate = initialDate ?? DateTime.now();
  TimeOfDay? selectedTime = initialDate != null
      ? TimeOfDay.fromDateTime(initialDate)
      : null;

  // If existing date has no time (midnight), reset selectedTime to null for the UI
  if (selectedTime != null &&
      selectedTime.hour == 0 &&
      selectedTime.minute == 0) {
    selectedTime = null;
  }

  return await showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF1C1C1E) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: isDark
                  ? BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDark
                          ? ColorScheme.dark(
                              primary: Theme.of(context).colorScheme.primary,
                              surface: const Color(0xFF1C1C1E),
                            )
                          : ColorScheme.light(
                              primary: Theme.of(context).colorScheme.primary,
                            ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : null,
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      onDateChanged: (date) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 24,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            selectedTime != null
                                ? 'Time: ${selectedTime!.format(context)}'
                                : 'Set time',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            final finalDate = selectedTime != null
                                ? DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime!.hour,
                                    selectedTime!.minute,
                                  )
                                : DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  );
                            Navigator.pop(context, finalDate);
                          },
                          child: Text(
                            'Done',
                            style: GoogleFonts.inter(
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
        },
      );
    },
  );
}
