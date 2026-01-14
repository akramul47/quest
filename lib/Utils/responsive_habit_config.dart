import 'package:flutter/material.dart';

/// Configuration for responsive habit timeline display.
///
/// Inspired by uhabits' buttonCount + dataOffset pattern for efficient
/// rendering of habit checkmark grids across different screen sizes.
class ResponsiveHabitConfig {
  /// Cell width including margins (28px cell + 3px margins)
  static const double cellWidth = 31.0;

  /// Fixed cell size for checkmarks
  static const double cellSize = 28.0;

  /// Horizontal margin between cells
  static const double cellMargin = 1.5;

  /// Width reserved for habit info section (icon + name + padding)
  static const double habitInfoMinWidth = 140.0;

  /// Minimum columns for mobile
  static const int minColumns = 5;

  /// Maximum columns to show
  static const int maxColumns = 21;

  /// Calculate the number of visible day columns based on available width.
  ///
  /// Dynamically calculates how many columns fit in the available space,
  /// ensuring efficient use of screen real estate on tablets and desktops.
  static int getVisibleColumnCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getVisibleColumnCountForWidth(screenWidth);
  }

  /// Calculate column count from a specific width value.
  ///
  /// Uses dynamic calculation: fills available space with as many columns as fit,
  /// with minimums for mobile and maximums for very large screens.
  static int getVisibleColumnCountForWidth(double width) {
    // Account for all spacing:
    // - Container margins: 32px (16px each side)
    // - Container padding: 24px (12px each side)
    // - Icon spacer: 44px
    // - Habit info width: 140px
    // - Spacing between sections: 12px
    // - Extra buffer for safety: 20px
    const totalReservedWidth = 32 + 24 + 44 + habitInfoMinWidth + 12 + 20;

    final availableWidth = width - totalReservedWidth;

    if (availableWidth <= 0) return minColumns;

    // Calculate how many cells fit (be conservative)
    final fittingColumns = (availableWidth / cellWidth).floor();

    // Clamp between min and max
    return fittingColumns.clamp(minColumns, maxColumns);
  }

  /// Calculate the width needed for a given number of columns.
  static double getColumnsWidth(int columnCount) {
    return columnCount * cellWidth;
  }

  /// Generate visible dates for the current window.
  ///
  /// [dataOffset] - Number of days to offset from today (for pagination)
  /// [columnCount] - Number of visible columns
  ///
  /// Returns a list of dates starting from (today - dataOffset) going backwards.
  static List<DateTime> getVisibleDates({
    required int dataOffset,
    required int columnCount,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(
      columnCount,
      (i) => today.subtract(Duration(days: i + dataOffset)),
    );
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
