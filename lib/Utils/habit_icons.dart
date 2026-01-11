import 'package:flutter/material.dart';

/// Predefined icon constants for tree-shaking optimization.
/// Maps icon code points to their corresponding IconData constants.
class HabitIcons {
  HabitIcons._(); // Private constructor to prevent instantiation

  // Predefined icon constants (tree-shakeable)
  static const IconData favorite = Icons.favorite;
  static const IconData fitnessCenter = Icons.fitness_center;
  static const IconData book = Icons.book;
  static const IconData waterDrop = Icons.water_drop;
  static const IconData bedtime = Icons.bedtime;
  static const IconData restaurant = Icons.restaurant;
  static const IconData directionsRun = Icons.directions_run;
  static const IconData selfImprovement = Icons.self_improvement;
  static const IconData musicNote = Icons.music_note;
  static const IconData brush = Icons.brush;
  static const IconData school = Icons.school;
  static const IconData work = Icons.work;
  static const IconData coffee = Icons.coffee;
  static const IconData pets = Icons.pets;
  static const IconData nature = Icons.nature;
  static const IconData sunny = Icons.sunny;
  static const IconData medication = Icons.medication;
  static const IconData psychology = Icons.psychology;
  static const IconData spa = Icons.spa;
  static const IconData familyRestroom = Icons.family_restroom;
  static const IconData celebration = Icons.celebration;
  static const IconData emojiEvents = Icons.emoji_events;
  static const IconData lightbulb = Icons.lightbulb;
  static const IconData palette = Icons.palette;

  /// List of all available icons for selection
  static const List<IconData> availableIcons = [
    favorite,
    fitnessCenter,
    book,
    waterDrop,
    bedtime,
    restaurant,
    directionsRun,
    selfImprovement,
    musicNote,
    brush,
    school,
    work,
    coffee,
    pets,
    nature,
    sunny,
    medication,
    psychology,
    spa,
    familyRestroom,
    celebration,
    emojiEvents,
    lightbulb,
    palette,
  ];

  /// Map of code points to IconData for O(1) lookup
  static final Map<int, IconData> _codePointMap = {
    favorite.codePoint: favorite,
    fitnessCenter.codePoint: fitnessCenter,
    book.codePoint: book,
    waterDrop.codePoint: waterDrop,
    bedtime.codePoint: bedtime,
    restaurant.codePoint: restaurant,
    directionsRun.codePoint: directionsRun,
    selfImprovement.codePoint: selfImprovement,
    musicNote.codePoint: musicNote,
    brush.codePoint: brush,
    school.codePoint: school,
    work.codePoint: work,
    coffee.codePoint: coffee,
    pets.codePoint: pets,
    nature.codePoint: nature,
    sunny.codePoint: sunny,
    medication.codePoint: medication,
    psychology.codePoint: psychology,
    spa.codePoint: spa,
    familyRestroom.codePoint: familyRestroom,
    celebration.codePoint: celebration,
    emojiEvents.codePoint: emojiEvents,
    lightbulb.codePoint: lightbulb,
    palette.codePoint: palette,
  };

  /// Get IconData from code point (O(1) lookup, tree-shakeable)
  /// Returns Icons.favorite as fallback if code point not found
  static IconData fromCodePoint(int codePoint) {
    return _codePointMap[codePoint] ?? favorite;
  }
}
